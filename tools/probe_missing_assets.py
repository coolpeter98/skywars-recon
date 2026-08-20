#!/usr/bin/env python3
"""Probe every rbxassetid reference and write a missing-asset manifest."""

from __future__ import annotations

import argparse
import concurrent.futures
import datetime
import json
import re
import time
import urllib.error
import urllib.request
from collections import Counter
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "src"
DEFAULT_OUTPUT = ROOT / "missing-assets.json"
ASSET_PATTERN = re.compile(r"rbxassetid://(\d+)")
SYMBOL_PATTERN = re.compile(r'\["([^"]+)"\]\s*=')
SUPPORTED_SUFFIXES = {".json", ".lua", ".luau"}
ENDPOINT = "https://assetdelivery.roblox.com/v1/assetId/{asset_id}"
MODULE_ALIASES = {
    "roblox-animation.luau": "RobloxAnimation",
    "roblox-image.luau": "RobloxImage",
    "roblox-sound.luau": "RobloxSound",
}
MISSING_STATUSES = {"archived", "not_found", "unauthorized"}


def instance_alias(path: Path) -> str | None:
    relative = path.relative_to(ROOT).as_posix()
    if not relative.startswith("src/"):
        return None
    for suffix in (".model.json", ".meta.json"):
        if relative.endswith(suffix):
            return relative[4 : -len(suffix)].replace("/", ".")
    return None


def infer_asset_type(aliases: list[str], references: list[dict[str, Any]]) -> str:
    alias_text = " ".join(aliases).lower()
    if "animation" in alias_text:
        return "Animation"
    if "sound" in alias_text or "soundtrack" in alias_text:
        return "Sound"
    if "image" in alias_text:
        return "Image"

    reference_text = " ".join(reference["sourceLine"] for reference in references).lower()
    property_types = (
        ("animation", "Animation"),
        ("soundid", "Sound"),
        ("audiocontent", "Sound"),
        ("texture", "ImageOrTexture"),
        ("image", "Image"),
        ("meshid", "Mesh"),
        ("video", "Video"),
    )
    for marker, asset_type in property_types:
        if marker in reference_text:
            return asset_type
    return "Unknown"


def collect_references() -> dict[str, dict[str, Any]]:
    assets: dict[str, dict[str, Any]] = {}
    for path in SOURCE_ROOT.rglob("*"):
        if not path.is_file() or path.suffix not in SUPPORTED_SUFFIXES:
            continue
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue

        relative_path = path.relative_to(ROOT).as_posix()
        module_alias = MODULE_ALIASES.get(path.name)
        model_alias = instance_alias(path)

        for line_number, line in enumerate(lines, start=1):
            ids = ASSET_PATTERN.findall(line)
            if not ids:
                continue

            symbol_match = SYMBOL_PATTERN.search(line)
            symbol = symbol_match.group(1) if symbol_match else None
            aliases: list[str] = []
            if module_alias and symbol:
                aliases.append(f"{module_alias}.{symbol}")
            elif symbol:
                aliases.append(symbol)
            if model_alias:
                aliases.append(model_alias)

            for asset_id in ids:
                entry = assets.setdefault(
                    asset_id,
                    {
                        "aliases": set(),
                        "references": [],
                        "relatedAssetIds": set(),
                    },
                )
                entry["aliases"].update(aliases)
                entry["relatedAssetIds"].update(other_id for other_id in ids if other_id != asset_id)
                entry["references"].append(
                    {
                        "path": relative_path,
                        "line": line_number,
                        "sourceLine": line.strip(),
                    }
                )
    return assets


def classify_response(payload: dict[str, Any]) -> tuple[str, int | None, str]:
    if payload.get("isArchived"):
        return "archived", None, "Asset is archived."
    if payload.get("location") or payload.get("locations"):
        return "available", None, "Asset delivery location returned."

    errors = payload.get("errors") or []
    if not errors:
        return "unexpected_response", None, "Asset Delivery returned no location or structured error."

    error = errors[0]
    error_code = error.get("code")
    message = error.get("message") or "Asset Delivery returned an error."
    if error_code == 401:
        return "authentication_required", error_code, message
    if error_code == 403:
        return "unauthorized", error_code, message
    if error_code == 404:
        return "not_found", error_code, message
    return "asset_error", error_code, message


def probe_asset(asset_id: str, attempts: int = 4) -> dict[str, Any]:
    url = ENDPOINT.format(asset_id=asset_id)
    last_error = "Probe did not run."
    for attempt in range(attempts):
        request = urllib.request.Request(
            url,
            headers={
                "Accept": "application/json",
                "User-Agent": "skywars-decompile-asset-audit/1.0",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                body = response.read().decode("utf-8")
                payload = json.loads(body)
                status, embedded_code, message = classify_response(payload)
                return {
                    "status": status,
                    "httpStatus": response.status,
                    "assetErrorCode": embedded_code,
                    "message": message,
                    "isArchived": bool(payload.get("isArchived")),
                    "assetTypeId": payload.get("assetTypeId"),
                }
        except urllib.error.HTTPError as error:
            last_error = f"HTTP {error.code}: {error.reason}"
            if error.code not in {429, 500, 502, 503, 504}:
                return {
                    "status": "http_error",
                    "httpStatus": error.code,
                    "assetErrorCode": None,
                    "message": last_error,
                    "isArchived": False,
                    "assetTypeId": None,
                }
        except (json.JSONDecodeError, TimeoutError, urllib.error.URLError) as error:
            last_error = str(error)
        time.sleep(0.5 * (attempt + 1))

    return {
        "status": "probe_failed",
        "httpStatus": None,
        "assetErrorCode": None,
        "message": last_error,
        "isArchived": False,
        "assetTypeId": None,
    }


def build_manifest(workers: int) -> dict[str, Any]:
    references_by_id = collect_references()
    asset_ids = sorted(references_by_id, key=int)
    probes: dict[str, dict[str, Any]] = {}

    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        future_to_id = {executor.submit(probe_asset, asset_id): asset_id for asset_id in asset_ids}
        for future in concurrent.futures.as_completed(future_to_id):
            asset_id = future_to_id[future]
            probes[asset_id] = future.result()

    counts = Counter(probe["status"] for probe in probes.values())
    missing_assets: list[dict[str, Any]] = []
    for asset_id in asset_ids:
        probe = probes[asset_id]
        if probe["status"] not in MISSING_STATUSES:
            continue

        source = references_by_id[asset_id]
        aliases = sorted(source["aliases"])
        references = source["references"]
        entry: dict[str, Any] = {
            "id": asset_id,
            "uri": f"rbxassetid://{asset_id}",
            "type": infer_asset_type(aliases, references),
            "aliases": aliases,
            "status": probe["status"],
            "failure": probe["message"],
            "httpProbe": {
                "httpStatus": probe["httpStatus"],
                "assetErrorCode": probe["assetErrorCode"],
                "isArchived": probe["isArchived"],
                "assetTypeId": probe["assetTypeId"],
            },
            "references": references,
        }
        related_ids = sorted(source["relatedAssetIds"], key=int)
        if related_ids:
            entry["relatedAssetIds"] = related_ids
        missing_assets.append(entry)

    return {
        "schemaVersion": 2,
        "generatedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "scope": (
            "Every rbxassetid reference under src was probed without authentication. "
            "Only confirmed unauthorized, not-found, or archived assets are listed."
        ),
        "probe": {
            "endpoint": ENDPOINT,
            "authentication": "none",
            "referencedAssetCount": len(asset_ids),
            "missingAssetCount": len(missing_assets),
            "statusCounts": dict(sorted(counts.items())),
            "interpretation": {
                "available": "Roblox returned a delivery location.",
                "authentication_required": (
                    "Inconclusive without credentials; excluded because some assets with this response "
                    "still load in Studio."
                ),
                "unauthorized": "Roblox explicitly denied access; included as missing.",
                "not_found": "Roblox reported that the asset does not exist; included as missing.",
                "archived": "Roblox reported that the asset is archived; included as missing.",
            },
        },
        "assets": missing_assets,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workers", type=int, default=12)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    manifest = build_manifest(max(1, args.workers))
    args.output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest["probe"], indent=2))


if __name__ == "__main__":
    main()
