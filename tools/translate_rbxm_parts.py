#!/usr/bin/env python3
"""Translate physical rbxm geometry while preserving CFrameValue metadata.

Rojo performs the binary/XML conversions so the result stays compatible with
the project's model loader. Only BasePart world CFrames and Model world pivots
are translated; authored WorldData CFrameValues remain untouched.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import tempfile
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
ITEM_RE = re.compile(r'<Item class="([^"]+)"')
AXIS_RE = re.compile(r"<([XYZ])>([^<]+)</\1>")


def write_project(path: Path, name: str, source: Path) -> None:
    path.write_text(
        json.dumps({"name": name, "tree": {"$path": str(source.resolve())}}),
        encoding="utf-8",
    )


def translate_xml(source: Path, destination: Path, translation: dict[str, float]) -> tuple[int, int]:
    class_stack: list[str] = []
    in_part_cframe = False
    in_world_pivot = False
    translated_parts = 0
    translated_pivots = 0

    with source.open("r", encoding="utf-8") as reader, destination.open("w", encoding="utf-8") as writer:
        for line in reader:
            item_match = ITEM_RE.search(line)
            if item_match:
                class_stack.append(item_match.group(1))

            current_class = class_stack[-1] if class_stack else ""
            if '<CoordinateFrame name="CFrame">' in line and current_class in BASE_PART_CLASSES:
                in_part_cframe = True
                translated_parts += 1
            elif '<OptionalCoordinateFrame name="WorldPivotData">' in line and current_class == "Model":
                in_world_pivot = True
                translated_pivots += 1

            if in_part_cframe or in_world_pivot:
                axis_match = AXIS_RE.search(line)
                if axis_match:
                    axis = axis_match.group(1)
                    updated = float(axis_match.group(2)) + translation[axis]
                    line = AXIS_RE.sub(f"<{axis}>{updated:.9g}</{axis}>", line, count=1)

            if in_part_cframe and "</CoordinateFrame>" in line:
                in_part_cframe = False
            if in_world_pivot and "</OptionalCoordinateFrame>" in line:
                in_world_pivot = False

            writer.write(line)
            if "</Item>" in line:
                class_stack.pop()

    return translated_parts, translated_pivots


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("x", type=float)
    parser.add_argument("y", type=float)
    parser.add_argument("z", type=float)
    args = parser.parse_args()

    source = args.input.resolve()
    output = args.output.resolve()
    translation = {"X": args.x, "Y": args.y, "Z": args.z}
    with tempfile.TemporaryDirectory(prefix="translate-rbxm-") as temporary_directory:
        temporary = Path(temporary_directory)
        source_project = temporary / "source.project.json"
        source_xml = temporary / "source.rbxmx"
        patched_xml = temporary / "patched.rbxmx"
        patched_project = temporary / "patched.project.json"
        patched_model = temporary / "patched.rbxm"

        write_project(source_project, source.stem, source)
        subprocess.run(["rojo", "build", str(source_project), "--output", str(source_xml)], check=True)
        part_count, pivot_count = translate_xml(source_xml, patched_xml, translation)
        if part_count == 0:
            raise RuntimeError("the source model contained no physical parts")
        write_project(patched_project, output.stem, patched_xml)
        subprocess.run(["rojo", "build", str(patched_project), "--output", str(patched_model)], check=True)
        output.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(patched_model, output)

    print(f"translated {part_count} parts and {pivot_count} model pivots: {source} -> {output}")


if __name__ == "__main__":
    main()
