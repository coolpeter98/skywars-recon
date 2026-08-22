// Per-island walking surface analysis.
import { readFileSync } from "node:fs";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const file = RobloxFile.ReadFromBuffer(readFileSync(process.argv[2]));
const airport = file.Roots[0];
const mod3 = (v) => ((v % 3) + 3) % 3;

// climb to the model directly under Airport
function topModel(p) {
	let top = p.Parent;
	while (top && top.Parent && top.Parent !== airport) top = top.Parent;
	return top;
}
const R = parseFloat(process.argv[3] ?? "234"); // map root Y (default = MapService anchor - 1.5 grid offset)
for (const island of airport.Children.filter((c) => c.IsAUnsafe("Model"))) {
	const parts = island.FindDescendants((d) => d.IsAUnsafe("BasePart"));
	// horizontal slabs: flat-ish parts with Y as smallest-ish dim and area > 4
	const slabs = parts.filter((p) => p.Size.Y <= p.Size.X && p.Size.Y <= p.Size.Z && p.Size.X * p.Size.Z >= 4);
	if (slabs.length === 0) continue;
	const tops = [...new Set(slabs.map((p) => (p.CFrame.Position.Y + p.Size.Y / 2).toFixed(2)))].sort(
		(a, b) => parseFloat(a) - parseFloat(b)
	);
	const topStr = tops.map((t) => `top=${t} world=${(parseFloat(t) + R).toFixed(2)} mod3=${mod3(parseFloat(t) + R).toFixed(2)}`);
	console.log(`${island.Name}: ${topStr.join("  ")}`);
}
