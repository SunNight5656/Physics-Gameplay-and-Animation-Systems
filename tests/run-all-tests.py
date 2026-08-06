#!/usr/bin/env python3
"""Single local/GitHub merge-gate runner for the SPLAT staged source tree."""
from __future__ import annotations

import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Callable

ROOT = Path(__file__).resolve().parents[1]
MENU = ROOT / "src" / "bin" / "x64" / "plugins" / "cyber_engine_tweaks" / "mods" / "splat_native_settings"
SECTIONS = MENU / "sections"
SRC = ROOT / "src"


def run_script(relative: str) -> tuple[bool, str]:
    proc = subprocess.run(
        [sys.executable, str(ROOT / relative)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode == 0, proc.stdout.rstrip()


def package_structure() -> tuple[bool, str]:
    required = [
        "src/archive/pc/mod/rig.archive",
        "src/bin/x64/plugins/cyber_engine_tweaks/mods/splat_native_settings/init.lua",
        "src/bin/x64/plugins/cyber_engine_tweaks/mods/splat_native_settings/schema_index.json",
        "src/r6/scripts/new Splat",
    ]
    missing = [path for path in required if not (ROOT / path).exists()]
    if missing:
        return False, "\n".join(f"[MISSING] {path}" for path in missing)
    return True, f"All {len(required)} package roots exist."


def required_inventory() -> tuple[bool, str]:
    baseline = ROOT / "tests" / "baseline" / "required-files.txt"
    if not baseline.is_file():
        return False, f"Missing baseline: {baseline}"
    required = {
        line.strip().replace("\\", "/")
        for line in baseline.read_text(encoding="utf-8-sig").splitlines()
        if line.strip()
    }
    current = {
        path.relative_to(SRC).as_posix()
        for path in SRC.rglob("*")
        if path.is_file()
    }
    missing = sorted(required - current)
    new = sorted(current - required)
    lines = [f"Required: {len(required)}", f"Current:  {len(current)}"]
    lines.extend(f"[NEW] {path}" for path in new)
    lines.extend(f"[MISSING] {path}" for path in missing)
    return not missing, "\n".join(lines)


def read_init() -> str:
    return (MENU / "init.lua").read_text(encoding="utf-8-sig", errors="replace")


def default_menu_visibility() -> tuple[bool, str]:
    failures: list[str] = []
    init = read_init()
    match = re.search(r"local\s+STATE_VERSION\s*=\s*(\d+)", init)
    state_version = int(match.group(1)) if match else -1
    if state_version < 160:
        failures.append("STATE_VERSION is not newer than the broken v159 state")
    required_patterns = [
        r"out\.modes\[mode\.key\]\s*=\s*\{showAll\s*=\s*false,\s*topics\s*=\s*\{\}\}",
        r"if\s+loadedUIVersion\s*<\s*STATE_VERSION\s+then\s*\n\s*loadedUI\s*=\s*defaultUI\(\)",
    ]
    for pattern in required_patterns:
        if not re.search(pattern, init, flags=re.I | re.M):
            failures.append(f"init.lua missing visibility contract: {pattern}")
    if re.search(r"showAll\s*=\s*\(i\s*==\s*1", init):
        failures.append("first mode is still automatically expanded")
    ui = json.loads((MENU / "user_ui.json").read_text(encoding="utf-8-sig"))
    if int(ui.get("version", -1)) != state_version:
        failures.append("user_ui.json version does not match STATE_VERSION")

    def find_true(node, path="root"):
        if isinstance(node, bool):
            if node:
                failures.append(f"packaged visibility is true: {path}")
        elif isinstance(node, dict):
            for key, value in node.items():
                if key == "version":
                    continue
                find_true(value, f"{path}.{key}")
        elif isinstance(node, list):
            for index, value in enumerate(node):
                find_true(value, f"{path}[{index}]")

    find_true(ui)
    return not failures, "\n".join(failures) if failures else f"All menu visibility values are collapsed at version {state_version}."


def obsolete_controls() -> tuple[bool, str]:
    forbidden = [
        "GENERAL_PATH",
        "generalImpulses",
        "General Impulses",
        "rebuildGeneralImpulses",
        "removeGeneralFallCategories",
    ]
    failures: list[str] = []
    for path in SRC.rglob("*"):
        if path.suffix.lower() not in {".reds", ".lua", ".json"}:
            continue
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        for token in forbidden:
            if re.search(r"(?<![A-Za-z0-9_])" + re.escape(token) + r"(?![A-Za-z0-9_])", text):
                failures.append(f"{path.relative_to(ROOT).as_posix()}: obsolete token {token}")
    return not failures, "\n".join(failures) if failures else "Obsolete General Impulses controls are absent."


def function_scope(text: str, marker: str, next_marker: str) -> str | None:
    start = text.find(marker)
    if start < 0:
        return None
    end = text.find(next_marker, start + len(marker))
    if end < 0:
        return None
    return text[start:end]


def single_mode_selector() -> tuple[bool, str]:
    failures: list[str] = []
    init = read_init()
    schema = json.loads((MENU / "schema_index.json").read_text(encoding="utf-8-sig"))
    definitions = [s for s in schema.get("globalSettings", []) if s.get("id") == schema.get("modeSettingId")]
    if len(definitions) != 1:
        failures.append(f"schema must have one global mode selector; found {len(definitions)}")
    registration = "globalModeRef = addSetting(GLOBAL_PATH, modeSetting"
    if init.count(registration) != 1:
        failures.append(f"init.lua must register one global selector; found {init.count(registration)}")
    rebuild = function_scope(init, "  local function rebuildSelectedMenu()", "  globalModeRef =")
    if rebuild is None:
        failures.append("could not isolate rebuildSelectedMenu")
    else:
        if "nativeSettings.refresh(" in rebuild:
            failures.append("rebuildSelectedMenu refreshes Native Settings and can duplicate selector")
        for required in ["removeModeCategories(candidate)", "showModeCategories(active,"]:
            if required not in rebuild:
                failures.append(f"rebuildSelectedMenu missing {required}")
    if not re.search(
        r"writeVar\(setting,\s*math\.floor\(value\),\s*true\)\s*\n\s*if rebuild then defer\(rebuild\) end",
        init,
    ):
        failures.append("mode value is not written before deferred rebuild")
    return not failures, "\n".join(failures) if failures else "One persistent selector owns every mode rebuild."


def collect_settings(node):
    out = []
    if isinstance(node, dict):
        if isinstance(node.get("settings"), list):
            out.extend(s for s in node["settings"] if isinstance(s, dict))
        for key, value in node.items():
            if key != "settings":
                out.extend(collect_settings(value))
    elif isinstance(node, list):
        for value in node:
            out.extend(collect_settings(value))
    return out


def trip_debug_defaults() -> tuple[bool, str]:
    failures: list[str] = []
    settings_text = (ROOT / "src/r6/scripts/new Splat/SPLATSettingsData.reds").read_text(encoding="utf-8-sig")
    fields = [
        "customTripEmotion_showPushReactionPopup",
        "realismPlusTripEmotion_showPushReactionPopup",
        "dirtyTripEmotion_showPushReactionPopup",
        "arnoldTripEmotion_showPushReactionPopup",
    ]
    for field in fields:
        if not re.search(r"(?m)^\s*public let " + re.escape(field) + r": Bool = false;\s*$", settings_text):
            failures.append(f"REDscript default is not false: {field}")
    trip_runtime = (ROOT / "src/r6/scripts/new Splat/Features/00_AAA_Trip_Emotion.reds").read_text(encoding="utf-8-sig")
    if not re.search(r"(?m)^\s*public let showPushReactionPopup: Bool = false;\s*$", trip_runtime):
        failures.append("Trip runtime fallback default is not false")
    files = {
        "realismCustom__trip.json": fields[0],
        "realismPlus__trip.json": fields[1],
        "dirtyHarry__trip.json": fields[2],
        "arnoldArcade__trip.json": fields[3],
    }
    for filename, field in files.items():
        doc = json.loads((SECTIONS / filename).read_text(encoding="utf-8-sig"))
        matches = [s for s in collect_settings(doc) if s.get("name") == field]
        if len(matches) != 1 or matches[0].get("default") is not False:
            failures.append(f"Native Settings default is not false: {filename}/{field}")
    return not failures, "\n".join(failures) if failures else "Trip debug popup defaults are Off in every mode."


def main() -> int:
    tests: list[tuple[str, Callable[[], tuple[bool, str]]]] = [
        ("PACKAGE STRUCTURE", package_structure),
        ("REQUIRED FILE INVENTORY", required_inventory),
        ("FEATURE PIPELINE CONTRACTS", lambda: run_script("tests/contracts/validate-feature-pipelines.py")),
        ("COMPLETE SETTINGS WIRING", lambda: run_script("tests/contracts/validate-settings-wiring.py")),
        ("DEFAULT MENU VISIBILITY", default_menu_visibility),
        ("OBSOLETE MENU CONTROLS", obsolete_controls),
        ("SINGLE MODE SELECTOR", single_mode_selector),
        ("TRIP DEBUG POPUP DEFAULTS", trip_debug_defaults),
    ]
    print("\n============================================================")
    print("SPLAT COMPLETE REGRESSION SUITE")
    print("============================================================")
    print(f"Repository: {ROOT}")
    results: list[tuple[str, bool]] = []
    for name, test in tests:
        print("\n------------------------------------------------------------")
        print(f"TESTING: {name}")
        print("------------------------------------------------------------")
        try:
            passed, detail = test()
        except Exception as exc:  # fail closed with the exact exception
            passed, detail = False, f"{type(exc).__name__}: {exc}"
        print(f"[{'PASS' if passed else 'FAIL'}] {name}")
        if detail:
            for line in detail.splitlines():
                print(f"       {line}")
        results.append((name, passed))
    passed_count = sum(1 for _, passed in results if passed)
    failed_count = len(results) - passed_count
    print("\n============================================================")
    print("SPLAT REGRESSION SUMMARY")
    print("============================================================")
    for name, passed in results:
        print(f"[{'PASS' if passed else 'FAIL'}] {name}")
    print(f"\nPassed: {passed_count}")
    print(f"Failed: {failed_count}")
    print(f"Total:  {len(results)}")
    print("============================================================")
    return 1 if failed_count else 0


if __name__ == "__main__":
    sys.exit(main())
