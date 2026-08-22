// Dumps the instance tree of a .rbxm model (class/name/CFrames for
// structural instances) for inspection.
// Usage: node tools/dump_rbxm.mjs <path-to.rbxm> [out.txt]
import { readFileSync, writeFileSync } from "node:fs";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const [path, outPath] = process.argv.slice(2);
if (!path) {
	console.error("usage: node tools/dump_rbxm.mjs <file.rbxm> [out.txt]");
	process.exit(1);
}
const file = RobloxFile.ReadFromBuffer(readFileSync(path));
if (!file) {
	console.error("parse failed");
	process.exit(1);
}

const fmtCFrame = (cf) => {
	const p = cf?.Position;
	if (!p) return "none";
	return `(${p.X.toFixed(3)}, ${p.Y.toFixed(3)}, ${p.Z.toFixed(3)})`;
};

const interesting = new Set(["Folder", "CFrameValue", "SpawnLocation", "Model", "ProximityPrompt", "MeshPart"]);
const lines = [];
function walk(inst, depth) {
	const name = inst.Name ?? "";
	const cls = inst.ClassName ?? "";
	let extra = "";
	if (cls === "CFrameValue" || cls === "SpawnLocation") {
		extra = ` :: ${fmtCFrame(inst.Value ?? inst.CFrame)}`;
	} else if (inst.IsAUnsafe("Part")) {
		extra = ` :: ${fmtCFrame(inst.CFrame)}`;
	}
	if (interesting.has(cls) || depth <= 1) {
		lines.push(`${"  ".repeat(depth)}[${cls}] ${name}${extra}`);
	}
	for (const child of inst.Children) walk(child, depth + 1);
}
for (const root of file.Roots) walk(root, 0);

const output = lines.join("\n");
if (outPath) writeFileSync(outPath, output);
console.log(output);
