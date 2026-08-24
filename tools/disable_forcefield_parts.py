#!/usr/bin/env python3
"""Disable every BasePart named Forcefield in one or more rbxm map assets."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


BASE_PART_CLASSES = {
    "CornerWedgePart",
    "MeshPart",
    "Part",
    "Seat",
    "SpawnLocation",
    "TrussPart",
    "UnionOperation",
    "VehicleSeat",
    "WedgePart",
}
COLLISION_PROPERTIES = ("CanCollide", "CanQuery", "CanTouch")


def write_project(path: Path, name: str, source: Path) -> None:
    path.write_text(
        json.dumps({"name": name, "tree": {"$path": str(source.resolve())}}),
        encoding="utf-8",
    )


def disable_forcefields(xml_path: Path) -> int:
    tree = ET.parse(xml_path)
    count = 0
    for item in tree.getroot().iter("Item"):
        if item.get("class") not in BASE_PART_CLASSES:
            continue
        properties = item.find("Properties")
        if properties is None:
            continue
        name = next(
            (
                property_element.text
                for property_element in properties
                if property_element.get("name") == "Name"
            ),
            None,
        )
        if name is None or name.casefold() != "forcefield":
            continue
        for property_name in COLLISION_PROPERTIES:
            property_element = next(
                (
                    candidate
                    for candidate in properties
                    if candidate.get("name") == property_name
                ),
                None,
            )
            if property_element is None:
                property_element = ET.SubElement(properties, "bool", {"name": property_name})
            property_element.text = "false"
        count += 1
    tree.write(xml_path, encoding="utf-8", xml_declaration=True)
    return count


def patch_model(path: Path) -> int:
    source = path.resolve()
    with tempfile.TemporaryDirectory(prefix="disable-forcefields-") as temporary_directory:
        temporary = Path(temporary_directory)
        source_project = temporary / "source.project.json"
        source_xml = temporary / "source.rbxmx"
        patched_project = temporary / "patched.project.json"
        patched_model = temporary / "patched.rbxm"

        write_project(source_project, source.stem, source)
        subprocess.run(["rojo", "build", str(source_project), "--output", str(source_xml)], check=True)
        count = disable_forcefields(source_xml)
        if count == 0:
            return 0
        write_project(patched_project, source.stem, source_xml)
        subprocess.run(["rojo", "build", str(patched_project), "--output", str(patched_model)], check=True)
        shutil.copyfile(patched_model, source)
        return count


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+", type=Path)
    args = parser.parse_args()

    total = 0
    for path in args.paths:
        count = patch_model(path)
        total += count
        print(f"disabled {count} Forcefield parts in {path}")
    print(f"disabled {total} Forcefield parts total")


if __name__ == "__main__":
    main()
