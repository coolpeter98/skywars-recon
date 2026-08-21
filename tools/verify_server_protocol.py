#!/usr/bin/env python3
"""Verify that server routes exactly cover the recovered client protocol."""

from __future__ import annotations

import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVENT_IDS_PATH = ROOT / "src/ReplicatedStorage/TS/event/event-ids.luau"
CLIENT_SCHEMA_PATH = ROOT / "src/StarterPlayerScripts/TS/events.luau"
HANDLERS_PATH = ROOT / "src/ServerScriptService/server/handlers"
FUNCTIONS_PATH = ROOT / "src/ServerScriptService/server/functions"
SERVER_PATH = ROOT / "src/ServerScriptService"

UUID_PATTERN = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"


def parse_canonical_ids() -> dict[str, str]:
    source = EVENT_IDS_PATH.read_text()
    entries = re.findall(r'\["([A-Za-z0-9]+)"\]\s*=\s*"(' + UUID_PATTERN + r')"', source)
    return dict(entries)


def parse_client_outgoing_ids() -> tuple[list[str], list[str]]:
    source = CLIENT_SCHEMA_PATH.read_text()
    event_block = re.search(r"eventsSchema\.outgoingIds\s*=\s*\{(.*?)\n\}", source, re.DOTALL)
    function_block = re.search(
        r'local functionsSchema\s*=\s*\{.*?\["outgoingIds"\]\s*=\s*\{(.*?)\}',
        source,
        re.DOTALL,
    )
    if event_block is None or function_block is None:
        raise SystemExit("Could not locate outgoing protocol declarations")
    return (
        re.findall(r'"(' + UUID_PATTERN + r')"', event_block.group(1)),
        re.findall(r'"(' + UUID_PATTERN + r')"', function_block.group(1)),
    )


def parse_route_names(path: Path) -> list[str]:
    names: list[str] = []
    for file_path in sorted(path.glob("*.luau")):
        names.extend(re.findall(r'\bName\s*=\s*"([A-Za-z0-9]+)"', file_path.read_text()))
    return names


def assert_exact(label: str, actual: list[str], expected: list[str]) -> None:
    duplicate_names = sorted(name for name, count in Counter(actual).items() if count > 1)
    missing = sorted(set(expected) - set(actual))
    unexpected = sorted(set(actual) - set(expected))
    if duplicate_names or missing or unexpected or len(actual) != len(expected):
        raise SystemExit(
            f"{label} coverage failed: duplicates={duplicate_names}, missing={missing}, "
            f"unexpected={unexpected}, actual={len(actual)}, expected={len(expected)}"
        )


def main() -> None:
    canonical_ids = parse_canonical_ids()
    names_by_id = {protocol_id: name for name, protocol_id in canonical_ids.items()}
    if len(names_by_id) != len(canonical_ids):
        raise SystemExit("Canonical event names contain duplicate protocol ids")

    outgoing_event_ids, outgoing_function_ids = parse_client_outgoing_ids()
    try:
        expected_events = [names_by_id[protocol_id] for protocol_id in outgoing_event_ids]
        expected_functions = [names_by_id[protocol_id] for protocol_id in outgoing_function_ids]
    except KeyError as error:
        raise SystemExit(f"Client schema id is absent from EventIds: {error.args[0]}") from error

    event_routes = parse_route_names(HANDLERS_PATH)
    function_routes = parse_route_names(FUNCTIONS_PATH)
    assert_exact("Event", event_routes, expected_events)
    assert_exact("Function", function_routes, expected_functions)
    if "LegacyUnusedEvent" not in event_routes:
        raise SystemExit("LegacyUnusedEvent must remain explicitly routed")

    raw_protocol_ids: list[str] = []
    for file_path in SERVER_PATH.rglob("*.luau"):
        raw_protocol_ids.extend(re.findall(UUID_PATTERN, file_path.read_text()))
    if raw_protocol_ids:
        raise SystemExit("ServerScriptService contains raw protocol UUIDs")

    print(f"Protocol coverage verified: {len(event_routes)} events, {len(function_routes)} function")


if __name__ == "__main__":
    main()
