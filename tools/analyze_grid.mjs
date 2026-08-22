// Analyze block-placement grid alignment of a map against the client's snap math.
// Client math (block-raycast-controller): snapOrigin = blockPosition - halfSize
// (target part's min corner, identity rotation); snapped = snapOrigin + 3*floor((hit-snapOrigin)/3) + 1.5;
// valid only if snapped ≡ 0 (mod 3), i.e. target part min corner ≡ 1.5 (mod 3) per axis.
import { readFileSync } from "node:fs";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const file = RobloxFile.ReadFromBuffer(readFileSync(process.argv[2]));
const targetNames = new Set(JSON.parse(process.argv[3] ?? '["Planks","StoneBricks","Ice","TeamConcrete","Iron"]'));

const mod3 = (v) => ((v % 3) + 3) % 3;
const fmt = (v) => v.map((x) => x.toFixed(3)).join(",");

const parts = file.FindDescendants((i) => i.IsAUnsafe("BasePart"));
let found = 0;
const groups = new Map();
for (const p of parts) {
	if (!targetNames.has(p.Name)) continue;
	found++;
	const pos = p.CFrame.Position;
	const size = p.Size;
	const min = [pos.X - size.X / 2, pos.Y - size.Y / 2, pos.Z - size.Z / 2];
	const minMod = min.map(mod3);
	// find top-level model
	let top = p.Parent;
	while (top && top.Parent && top.Parent.IsAUnsafe("Model")) top = top.Parent;
	const key = `${top?.Name ?? "?"}`;
	if (!groups.has(key)) groups.set(key, []);
	groups.get(key).push({ name: p.Name, pos: [pos.X, pos.Y, pos.Z], size: [size.X, size.Y, size.Z], minMod });
}
console.log(`block-target parts: ${found}`);
for (const [k, list] of groups) {
	console.log(`--- ${k} (${list.length} parts)`);
	for (const p of list.slice(0, 8)) {
		console.log(`  ${p.name} pos=(${fmt(p.pos)}) size=(${fmt(p.size)}) minCornerMod3=(${fmt(p.minMod)})`);
	}
}
