// Dump walkable-floor candidates: parts whose height < 3 (slabs) per top-level model.
import { readFileSync } from "node:fs";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const file = RobloxFile.ReadFromBuffer(readFileSync(process.argv[2]));
const mod3 = (v) => ((v % 3) + 3) % 3;
const R = 235.5; // current root Y

const models = new Map();
for (const p of file.FindDescendants((i) => i.IsAUnsafe("BasePart"))) {
	let top = p.Parent;
	while (top && top.Parent && top.Parent.IsAUnsafe("Model")) top = top.Parent;
	const key = top?.Name ?? "?";
	if (!models.has(key)) models.set(key, []);
	models.get(key).push(p);
}
for (const [k, parts] of models) {
	const slabs = parts.filter((p) => p.Size.Y < 3 && p.Size.Y >= 0.75 && p.Size.X * p.Size.Z > 25);
	const tops = new Set(slabs.map((p) => (p.CFrame.Position.Y + p.Size.Y / 2).toFixed(2)));
	if (tops.size > 0) {
		const worldTops = [...tops].map((t) => `${t} (world ${(parseFloat(t) + R).toFixed(2)}, mod3=${mod3(parseFloat(t) + R).toFixed(2)})`);
		console.log(`${k}: ${slabs.length} slabs, topYs: ${worldTops.join(" | ")}`);
	}
}
