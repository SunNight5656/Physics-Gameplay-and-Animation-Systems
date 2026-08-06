#!/usr/bin/env python3
"""Validate SPLAT's feature routes without comparing whole files to old snapshots."""
from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
SUBSYSTEM_MANIFEST = Path(__file__).with_name("splat-flow-contracts.json")
PIPELINE_MANIFEST = Path(__file__).with_name("splat-pipeline-contracts.json")
RUNTIME_ROOT = ROOT / "src" / "r6" / "scripts" / "new Splat"
MENU_FILE = ROOT / "src" / "bin" / "x64" / "plugins" / "cyber_engine_tweaks" / "mods" / "splat_native_settings" / "init.lua"


@dataclass
class Result:
    name: str
    passed: bool
    failures: list[str]


def read_text(relative: str) -> str:
    path = ROOT / Path(relative)
    return path.read_text(encoding="utf-8-sig", errors="replace")


def strip_comments(text: str) -> str:
    # Preserve string contents because settings IDs and route names are intentional contracts.
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"(?m)//.*$", "", text)
    text = re.sub(r"(?m)--.*$", "", text)
    return text


def extract_scope(text: str, function_name: str | None, occurrence: int = 1) -> str:
    if not function_name:
        return text
    pattern = re.compile(
        r"(?im)^\s*(?:(?:public|private|protected|static|final|native|abstract|cb|callback)\s+)*"
        r"(?:func|wrappedMethod|replacedMethod)\s+"
        + re.escape(function_name)
        + r"\s*\("
    )
    matches = list(pattern.finditer(text))
    if occurrence < 1 or occurrence > len(matches):
        raise ValueError(
            f"function scope not found: {function_name} occurrence {occurrence} "
            f"(found {len(matches)})"
        )
    match = matches[occurrence - 1]
    brace = text.find("{", match.end())
    if brace < 0:
        raise ValueError(f"function body has no opening brace: {function_name}")
    depth = 1
    i = brace + 1
    in_string: str | None = None
    escaped = False
    while i < len(text) and depth:
        ch = text[i]
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == in_string:
                in_string = None
        else:
            if ch in ('"', "'"):
                in_string = ch
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
        i += 1
    if depth:
        raise ValueError(f"function body has unbalanced braces: {function_name}")
    return text[match.start():i]


def contains(scope: str, pattern: str, regex: bool = False) -> bool:
    if regex:
        return re.search(pattern, scope, flags=re.I | re.M | re.S) is not None
    return pattern.casefold() in scope.casefold()


def find_index(scope: str, pattern: str, regex: bool = False, start: int = 0) -> int:
    if regex:
        match = re.search(pattern, scope[start:], flags=re.I | re.M | re.S)
        return -1 if match is None else start + match.start()
    return scope.casefold().find(pattern.casefold(), start)


def check_patterns(scope: str, step: dict) -> list[str]:
    failures: list[str] = []
    for item in step.get("required", []):
        if isinstance(item, str):
            pattern, is_regex = item, False
        else:
            pattern, is_regex = item["pattern"], bool(item.get("regex"))
        if not contains(scope, pattern, is_regex):
            failures.append(f"missing required route element: {pattern}")

    for group in step.get("requiredOneOf", []):
        options = group if isinstance(group, list) else group.get("patterns", [])
        if not any(contains(scope, p, False) for p in options):
            failures.append("none of the allowed route alternatives exist: " + " | ".join(options))

    cursor = 0
    previous = None
    for item in step.get("ordered", []):
        if isinstance(item, str):
            pattern, is_regex = item, False
        else:
            pattern, is_regex = item["pattern"], bool(item.get("regex"))
        index = find_index(scope, pattern, is_regex, cursor)
        if index < 0:
            if previous is None:
                failures.append(f"ordered route element missing: {pattern}")
            else:
                failures.append(f"route order broken: {pattern} must appear after {previous}")
            continue
        cursor = index + 1
        previous = pattern

    for item in step.get("forbidden", []):
        if isinstance(item, str):
            pattern, is_regex = item, False
        else:
            pattern, is_regex = item["pattern"], bool(item.get("regex"))
        if contains(scope, pattern, is_regex):
            failures.append(f"forbidden legacy route remains: {pattern}")

    for count_check in step.get("counts", []):
        pattern = count_check["pattern"]
        is_regex = bool(count_check.get("regex"))
        if is_regex:
            count = len(re.findall(pattern, scope, flags=re.I | re.M | re.S))
        else:
            count = scope.casefold().count(pattern.casefold())
        if "exact" in count_check and count != int(count_check["exact"]):
            failures.append(f"{pattern} occurs {count} times; expected exactly {count_check['exact']}")
        if "minimum" in count_check and count < int(count_check["minimum"]):
            failures.append(f"{pattern} occurs {count} times; expected at least {count_check['minimum']}")
    return failures


def validate_subsystems(manifest: dict) -> tuple[list[Result], set[str]]:
    results: list[Result] = []
    covered: set[str] = set()
    for contract in manifest.get("contracts", []):
        name = str(contract["name"])
        relative = str(contract["file"]).replace("\\", "/")
        covered.add(relative)
        failures: list[str] = []
        path = ROOT / relative
        if not path.is_file():
            failures.append(f"required file is missing: {relative}")
        else:
            text = strip_comments(path.read_text(encoding="utf-8-sig", errors="replace"))
            step = {
                "required": list(contract.get("requiredPatterns", [])),
                "ordered": list(contract.get("orderedPatterns", [])),
                "forbidden": list(contract.get("forbiddenPatterns", [])),
            }
            failures.extend(check_patterns(text, step))
        results.append(Result(name, not failures, failures))
    return results, covered


def validate_pipelines(manifest: dict) -> list[Result]:
    results: list[Result] = []
    for pipeline in manifest.get("pipelines", []):
        failures: list[str] = []
        for number, step in enumerate(pipeline.get("steps", []), start=1):
            relative = str(step["file"]).replace("\\", "/")
            path = ROOT / relative
            label = step.get("label") or f"step {number}"
            if not path.is_file():
                failures.append(f"{label}: missing file {relative}")
                continue
            text = strip_comments(path.read_text(encoding="utf-8-sig", errors="replace"))
            try:
                scope = extract_scope(text, step.get("function"), int(step.get("occurrence", 1)))
            except ValueError as exc:
                failures.append(f"{label}: {exc}")
                continue
            for failure in check_patterns(scope, step):
                failures.append(f"{label}: {failure}")
        results.append(Result(str(pipeline["name"]), not failures, failures))
    return results


def main() -> int:
    print("\n============================================================")
    print("SPLAT TEST: FEATURE PIPELINE CONTRACTS")
    print("============================================================")
    try:
        subsystem = json.loads(SUBSYSTEM_MANIFEST.read_text(encoding="utf-8-sig"))
        pipelines = json.loads(PIPELINE_MANIFEST.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"[FAIL] TEST MANIFEST | {exc}")
        return 1

    results, covered = validate_subsystems(subsystem)
    results.extend(validate_pipelines(pipelines))

    runtime_files = {
        p.relative_to(ROOT).as_posix() for p in RUNTIME_ROOT.rglob("*.reds") if p.is_file()
    }
    uncovered = sorted(runtime_files - covered)
    if MENU_FILE.is_file() and "src/bin/x64/plugins/cyber_engine_tweaks/mods/splat_native_settings/init.lua" not in covered:
        uncovered.append("src/bin/x64/plugins/cyber_engine_tweaks/mods/splat_native_settings/init.lua")
    results.append(
        Result(
            "CONTRACT COVERAGE — every runtime source file",
            not uncovered,
            [f"runtime source has no subsystem contract: {path}" for path in uncovered],
        )
    )

    passed = 0
    failed = 0
    for result in results:
        if result.passed:
            print(f"[PASS] {result.name}")
            passed += 1
        else:
            print(f"[FAIL] {result.name}")
            for failure in result.failures:
                print(f"       - {failure}")
            failed += 1

    print("============================================================")
    print("FEATURE PIPELINE SUMMARY")
    print("============================================================")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Total:  {len(results)}")
    print("============================================================")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
