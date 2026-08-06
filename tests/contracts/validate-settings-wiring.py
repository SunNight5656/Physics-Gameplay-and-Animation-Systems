#!/usr/bin/env python3
"""Validate every Native Settings entry from menu JSON through REDscript runtime."""
from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Iterable

ROOT = Path(__file__).resolve().parents[2]
MENU = ROOT / "src" / "bin" / "x64" / "plugins" / "cyber_engine_tweaks" / "mods" / "splat_native_settings"
SECTIONS = MENU / "sections"
REDS_ROOT = ROOT / "src" / "r6" / "scripts" / "new Splat"
BRIDGE = REDS_ROOT / "00_SPLATDirectSettingsSystem.reds"
SETTINGS_DATA = REDS_ROOT / "SPLATSettingsData.reds"


def collect_settings(node: Any) -> list[dict[str, Any]]:
    found: list[dict[str, Any]] = []
    if isinstance(node, dict):
        value = node.get("settings")
        if isinstance(value, list):
            found.extend(item for item in value if isinstance(item, dict))
        for key, child in node.items():
            if key != "settings":
                found.extend(collect_settings(child))
    elif isinstance(node, list):
        for child in node:
            found.extend(collect_settings(child))
    return found


def extract_class_bodies(source: str) -> dict[str, str]:
    classes: dict[str, str] = {}
    for match in re.finditer(r"\b(?:public\s+)?class\s+(\w+)\s*\{", source):
        name = match.group(1)
        start = match.end()
        depth = 1
        i = start
        while i < len(source) and depth:
            if source[i] == "{":
                depth += 1
            elif source[i] == "}":
                depth -= 1
            i += 1
        if depth == 0:
            classes[name] = source[start : i - 1]
    return classes


def parse_fields(class_bodies: dict[str, str]) -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = defaultdict(dict)
    pattern = re.compile(
        r"(?m)^\s*(?:public\s+|private\s+|protected\s+)?let\s+(\w+)\s*:\s*([\w<>]+)"
    )
    for class_name, body in class_bodies.items():
        for match in pattern.finditer(body):
            result[class_name][match.group(1)] = match.group(2)
    return result


def setting_key(setting: dict[str, Any]) -> str:
    return f"{setting.get('mode', 'global')}|{setting.get('class')}.{setting.get('name')}"


def main() -> int:
    print("\n============================================================")
    print("SPLAT TEST: COMPLETE SETTINGS WIRING")
    print("============================================================")
    failures: list[str] = []
    passed_checks = 0

    required_files = [MENU / "init.lua", MENU / "schema_index.json", MENU / "user_ui.json", MENU / "user_settings.json", BRIDGE, SETTINGS_DATA]
    for path in required_files:
        if not path.is_file():
            failures.append(f"missing required settings file: {path.relative_to(ROOT).as_posix()}")
    if failures:
        for failure in failures:
            print(f"[FAIL] {failure}")
        return 1

    init_text = (MENU / "init.lua").read_text(encoding="utf-8-sig", errors="replace")
    state_match = re.search(r"local\s+STATE_VERSION\s*=\s*(\d+)", init_text)
    if not state_match:
        failures.append("init.lua does not declare STATE_VERSION")
        state_version = -1
    else:
        state_version = int(state_match.group(1))

    json_files = [MENU / "schema_index.json", MENU / "user_ui.json", MENU / "user_settings.json", *sorted(SECTIONS.glob("*.json"))]
    parsed: dict[Path, Any] = {}
    for path in json_files:
        try:
            parsed[path] = json.loads(path.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError) as exc:
            failures.append(f"invalid JSON: {path.relative_to(ROOT).as_posix()}: {exc}")
    if failures:
        for failure in failures:
            print(f"[FAIL] {failure}")
        return 1

    schema = parsed[MENU / "schema_index.json"]
    user_ui = parsed[MENU / "user_ui.json"]
    user_settings = parsed[MENU / "user_settings.json"]
    for label, document in [("schema_index.json", schema), ("user_ui.json", user_ui), ("user_settings.json", user_settings)]:
        if int(document.get("version", -1)) != state_version:
            failures.append(f"{label} version {document.get('version')} does not match STATE_VERSION {state_version}")
    if int(user_settings.get("valueCount", -1)) != len(user_settings.get("values", {})):
        failures.append("user_settings.json valueCount does not match the number of saved values")

    modes = [m["key"] for m in schema.get("modes", []) if m.get("key") != "vanilla"]
    expected_topics = {"arcade", "body", "bulletJolts", "explosions", "head", "randomization", "settle", "situational", "trip", "tumble", "twitch", "vehicles"}
    section_documents: list[tuple[Path, dict[str, Any]]] = []
    for path in sorted(SECTIONS.glob("*.json")):
        document = parsed[path]
        section_documents.append((path, document))
        expected_name = f"{document.get('mode')}__{document.get('topic')}.json"
        if path.name != expected_name:
            failures.append(f"section filename does not match mode/topic: {path.name} != {expected_name}")
    for mode in modes:
        found_topics = {d.get("topic") for _, d in section_documents if d.get("mode") == mode}
        missing = sorted(expected_topics - found_topics)
        extra = sorted(found_topics - expected_topics)
        if missing:
            failures.append(f"{mode} is missing section files: {', '.join(missing)}")
        if extra:
            failures.append(f"{mode} has unexpected section files: {', '.join(extra)}")

    all_settings: list[tuple[str, dict[str, Any]]] = []
    all_settings.extend(("schema_index.json", s) for s in collect_settings(schema))
    for path, document in section_documents:
        all_settings.extend((path.name, s) for s in collect_settings(document))

    required_keys = {"id", "class", "name", "mode", "topic", "type", "default", "label"}
    ids_by_file: dict[str, set[str]] = defaultdict(set)
    all_ids: set[str] = set()
    for location, setting in all_settings:
        missing_keys = sorted(required_keys - setting.keys())
        if missing_keys:
            failures.append(f"{location}: setting is missing keys {', '.join(missing_keys)}")
            continue
        sid = str(setting["id"])
        if sid in ids_by_file[location]:
            failures.append(f"{location}: duplicate setting id {sid}")
        ids_by_file[location].add(sid)
        all_ids.add(sid)
        stype = setting["type"]
        default = setting["default"]
        if stype == "Bool" and not isinstance(default, bool):
            failures.append(f"{location}: {sid} Bool default is not boolean")
        if stype in {"Float", "Int32"} and (isinstance(default, bool) or not isinstance(default, (int, float))):
            failures.append(f"{location}: {sid} numeric default is not numeric")
        dependency = setting.get("dependency")
        if dependency and dependency not in all_ids:
            # Resolve after all IDs are collected below.
            pass

    for location, setting in all_settings:
        dependency = setting.get("dependency")
        if dependency and dependency not in all_ids:
            failures.append(f"{location}: {setting.get('id')} references missing dependency {dependency}")

    # Four primary target lanes must exist in every editable mode.
    lane_labels = {
        "arcade": [
            "Enable Bullet Push on NPCs",
            "V Only — Bullet Push on NPCs",
            "Enable Bullet Push on Vehicles",
            "V Only — Bullet Push on Vehicles",
        ],
        "explosions": [
            "Enable Explosion Push on NPCs",
            "V Only — Explosion Push on NPCs",
            "Enable Explosion Push on Vehicles",
            "V Only — Explosion Push on Vehicles",
        ],
    }
    for mode in modes:
        for topic, labels in lane_labels.items():
            document = next((d for _, d in section_documents if d.get("mode") == mode and d.get("topic") == topic), None)
            settings = collect_settings(document) if document else []
            actual_labels = [str(s.get("label")) for s in settings]
            for label in labels:
                count = actual_labels.count(label)
                if count != 1:
                    failures.append(f"{mode}/{topic}: expected exactly one '{label}' control; found {count}")

    reds_files = sorted(REDS_ROOT.rglob("*.reds"))
    all_reds = "\n".join(p.read_text(encoding="utf-8-sig", errors="replace") for p in reds_files)
    classes = extract_class_bodies(all_reds)
    fields = parse_fields(classes)
    bridge_text = BRIDGE.read_text(encoding="utf-8-sig", errors="replace")
    runtime_text = "\n".join(
        p.read_text(encoding="utf-8-sig", errors="replace")
        for p in reds_files
        if p.name not in {"SPLATSettingsData.reds", "00_SPLATDirectSettingsSystem.reds"}
    )
    # This legacy menu field is retained for saved-setting compatibility. The
    # active workspot runtime gate is RFCConfig.wsStandEnabled, built from the
    # current situational component toggles. It must remain bridge-readable but
    # is not itself a runtime field read.
    runtime_compatibility_fields = {("RFCModSettings", "overrideWorkSpots")}
    type_map = {"Bool": "Bool", "Float": "Float", "Int32": "Int32"}
    checked_keys: set[str] = set()
    runtime_checked = 0
    for location, setting in all_settings:
        if setting.get("uiOnly") or setting.get("class") == "UIState":
            continue
        key = setting_key(setting)
        if key in checked_keys:
            continue
        checked_keys.add(key)
        class_name = str(setting["class"])
        field_name = str(setting["name"])
        declared = fields.get(class_name, {}).get(field_name)
        if declared is None:
            failures.append(f"{location}: {class_name}.{field_name} has no REDscript field declaration")
            continue
        expected_type = type_map.get(str(setting["type"]))
        if expected_type and declared != expected_type:
            failures.append(f"{location}: {class_name}.{field_name} type {declared} does not match menu type {expected_type}")
        word = re.compile(r"\b" + re.escape(field_name) + r"\b")
        if not word.search(bridge_text):
            failures.append(f"{location}: {class_name}.{field_name} is missing from the CET-to-REDscript bridge")
        if not word.search(runtime_text) and (class_name, field_name) not in runtime_compatibility_fields:
            failures.append(f"{location}: {class_name}.{field_name} is never read by runtime/config code")
        runtime_checked += 1

    if "globalModeRef = addSetting(GLOBAL_PATH, modeSetting" not in init_text:
        failures.append("init.lua does not register the one persistent global mode selector")
    if "buildRestoreQueue()" not in init_text or "processRestoreQueue()" not in init_text:
        failures.append("init.lua no longer restores saved menu values into REDscript")
    if "SPLATSetBool" not in bridge_text or "SPLATSetFloat" not in bridge_text or "SPLATSetInt" not in bridge_text:
        failures.append("REDscript bridge is missing one or more typed setter entry points")

    if failures:
        print(f"[FAIL] COMPLETE SETTINGS WIRING | {len(failures)} problem(s)")
        for failure in failures:
            print(f"       - {failure}")
        return 1

    print(f"[PASS] JSON documents parsed: {len(json_files)}")
    print(f"[PASS] Editable modes with complete section sets: {len(modes)}")
    print(f"[PASS] Menu settings validated: {len(all_settings)}")
    print(f"[PASS] Non-UI settings wired through declaration, bridge, and runtime: {runtime_checked}")
    print(f"[PASS] STATE_VERSION synchronized at {state_version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
