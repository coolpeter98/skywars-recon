// Removes the exported Workspace.BlockContainer wrapper from recovered
// SkyWars .rbxm files by promoting its sole Map child to the file root.
//
// Only the binary PRNT (parent relations) chunk is rewritten. Every class,
// property, shared-string, and metadata chunk remains byte-for-byte intact.
// The old BlockContainer instance is retained as an empty child of Map so
// instance tables and referents do not need a lossy full reserialization.
//
// Usage:
//   node tools/unwrap_map_rbxm.mjs                 # validate/dry-run
//   node tools/unwrap_map_rbxm.mjs --write         # normalize all maps
//   node tools/unwrap_map_rbxm.mjs --write <paths> # normalize selections

import { createRequire } from "node:module";
import { globSync, readFileSync, writeFileSync } from "node:fs";
import { basename, resolve } from "node:path";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const require = createRequire(import.meta.url);
const lz4 = require("./rbxm-parser-ts/node_modules/lz4");
const args = process.argv.slice(2);
const write = args[0] === "--write";
const requestedPaths = write ? args.slice(1) : args;
const paths = (
	requestedPaths.length > 0
		? requestedPaths
		: globSync("src/ServerStorage/Maps/SkyWars/*.rbxm")
).map((path) => resolve(path));

if (paths.length === 0) throw new Error("no SkyWars .rbxm files found");

const countInstances = (roots) => {
	let count = 0;
	const visit = (instance) => {
		count += 1;
		for (const child of instance.Children) visit(child);
	};
	for (const root of roots) visit(root);
	return count;
};

const validateMapRoot = (root, path) => {
	if (!root.IsAUnsafe("Model")) {
		throw new Error(`${path}: promoted root is ${root.ClassName}, expected Model`);
	}
	const worldData = root.Children.find((child) => child.Name === "WorldData");
	const spawnLocations = root.Children.find((child) => child.Name === "SpawnLocations");
	if (!worldData?.IsAUnsafe("Folder")) {
		throw new Error(`${path}: promoted root has no WorldData Folder`);
	}
	if (!spawnLocations?.IsAUnsafe("Folder")) {
		throw new Error(`${path}: promoted root has no SpawnLocations Folder`);
	}
	const spawn = worldData.Children.find((child) => child.Name === "Spawn");
	if (!spawn?.IsAUnsafe("CFrameValue")) {
		throw new Error(`${path}: promoted root has no WorldData.Spawn CFrameValue`);
	}
};

const untransformInt32 = (value) => (value >>> 1) ^ -(value & 1);
const transformInt32 = (value) => (value << 1) ^ (value >> 31);

const decodeReferents = (bytes, offset, length) => {
	const values = new Array(length);
	for (let i = 0; i < length; i += 1) {
		const encoded = Buffer.from([
			bytes[offset + i],
			bytes[offset + length + i],
			bytes[offset + length * 2 + i],
			bytes[offset + length * 3 + i],
		]).readInt32BE(0);
		values[i] = untransformInt32(encoded);
		if (i > 0) values[i] += values[i - 1];
	}
	return values;
};

const encodeReferents = (values, bytes, offset) => {
	const length = values.length;
	for (let i = 0; i < length; i += 1) {
		const delta = i === 0 ? values[i] : values[i] - values[i - 1];
		const encoded = Buffer.allocUnsafe(4);
		encoded.writeInt32BE(transformInt32(delta), 0);
		for (let byte = 0; byte < 4; byte += 1) {
			bytes[offset + length * byte + i] = encoded[byte];
		}
	}
};

const findChunk = (buffer, wantedType) => {
	let offset = 32;
	while (offset + 16 <= buffer.length) {
		const type = buffer.toString("ascii", offset, offset + 4);
		const compressedLength = buffer.readUInt32LE(offset + 4);
		const uncompressedLength = buffer.readUInt32LE(offset + 8);
		const dataLength = compressedLength || uncompressedLength;
		const dataOffset = offset + 16;
		const endOffset = dataOffset + dataLength;
		if (endOffset > buffer.length) throw new Error(`truncated ${type} chunk`);
		if (type === wantedType) {
			return { offset, dataOffset, endOffset, compressedLength, uncompressedLength };
		}
		if (type.startsWith("END")) break;
		offset = endOffset;
	}
	throw new Error(`${wantedType} chunk not found`);
};

const decodeChunk = (buffer, chunk) => {
	const source = buffer.subarray(chunk.dataOffset, chunk.endOffset);
	if (chunk.compressedLength === 0) return Buffer.from(source);
	if (source.subarray(0, 4).equals(Buffer.from([0x28, 0xb5, 0x2f, 0xfd]))) {
		throw new Error("zstd-compressed PRNT chunks are not supported");
	}
	const output = Buffer.allocUnsafe(chunk.uncompressedLength);
	const decodedLength = lz4.decodeBlock(source, output);
	if (decodedLength !== chunk.uncompressedLength) {
		throw new Error(`PRNT decoded to ${decodedLength}, expected ${chunk.uncompressedLength}`);
	}
	return output;
};

const replaceChunk = (buffer, chunk, uncompressed) => {
	const compressed = Buffer.allocUnsafe(lz4.encodeBound(uncompressed.length));
	const compressedLength = lz4.encodeBlock(uncompressed, compressed);
	if (compressedLength <= 0) throw new Error("failed to compress PRNT chunk");
	const header = Buffer.from(buffer.subarray(chunk.offset, chunk.dataOffset));
	header.writeUInt32LE(compressedLength, 4);
	header.writeUInt32LE(uncompressed.length, 8);
	return Buffer.concat([
		buffer.subarray(0, chunk.offset),
		header,
		compressed.subarray(0, compressedLength),
		buffer.subarray(chunk.endOffset),
	]);
};

const promoteMapRoot = (buffer, file, outer, map, path) => {
	const outerRef = file.ReferentMap.get(outer);
	const mapRef = file.ReferentMap.get(map);
	if (outerRef === undefined || mapRef === undefined) {
		throw new Error(`${path}: missing wrapper referents`);
	}
	const chunk = findChunk(buffer, "PRNT");
	const bytes = decodeChunk(buffer, chunk);
	const count = bytes.readInt32LE(1);
	const childrenOffset = 5;
	const parentsOffset = childrenOffset + count * 4;
	if (parentsOffset + count * 4 !== bytes.length) {
		throw new Error(`${path}: malformed PRNT payload`);
	}
	const children = decodeReferents(bytes, childrenOffset, count);
	const parents = decodeReferents(bytes, parentsOffset, count);
	const outerIndex = children.indexOf(outerRef);
	const mapIndex = children.indexOf(mapRef);
	if (outerIndex < 0 || mapIndex < 0) throw new Error(`${path}: wrapper absent from PRNT`);
	if (parents[outerIndex] !== -1 || parents[mapIndex] !== outerRef) {
		throw new Error(`${path}: wrapper parent relations are not in the expected shape`);
	}
	parents[outerIndex] = mapRef;
	parents[mapIndex] = -1;
	encodeReferents(parents, bytes, parentsOffset);
	return replaceChunk(buffer, chunk, bytes);
};

let changed = 0;
let unchanged = 0;
for (const path of paths.sort()) {
	const original = readFileSync(path);
	const file = RobloxFile.ReadFromBuffer(original);
	if (!file) throw new Error(`${path}: parse failed`);
	if (file.Roots.length !== 1) {
		throw new Error(`${path}: expected one root, found ${file.Roots.length}`);
	}
	const outer = file.Roots[0];
	if (outer.Children.some((child) => child.Name === "WorldData")) {
		validateMapRoot(outer, path);
		unchanged += 1;
		console.log(`ok       ${basename(path)} (already normalized)`);
		continue;
	}
	if (!outer.IsAUnsafe("Model") || outer.Name !== "BlockContainer" || outer.Children.length !== 1) {
		throw new Error(
			`${path}: expected sole root Model BlockContainer with one child; got ${outer.ClassName} ${outer.Name} with ${outer.Children.length}`,
		);
	}
	const map = outer.Children[0];
	if (map.Name !== "Map") throw new Error(`${path}: wrapper child is ${map.Name}, expected Map`);
	validateMapRoot(map, path);
	const beforeCount = countInstances(file.Roots);
	const output = promoteMapRoot(original, file, outer, map, path);
	const verified = RobloxFile.ReadFromBuffer(output);
	if (!verified || verified.Roots.length !== 1) {
		throw new Error(`${path}: rewritten file failed round-trip validation`);
	}
	validateMapRoot(verified.Roots[0], path);
	const afterCount = countInstances(verified.Roots);
	if (afterCount !== beforeCount) {
		throw new Error(`${path}: instance count changed from ${beforeCount} to ${afterCount}`);
	}
	const emptyWrapper = verified.Roots[0].Children.find((child) => child.Name === "BlockContainer");
	if (!emptyWrapper || emptyWrapper.Children.length !== 0) {
		throw new Error(`${path}: old BlockContainer was not retained as an empty child`);
	}
	if (write) writeFileSync(path, output);
	changed += 1;
	console.log(`${write ? "rewrote" : "would rewrite"} ${basename(path)} (${beforeCount} instances)`);
}

console.log(`${write ? "normalized" : "validated"}: ${changed} changed, ${unchanged} already normalized`);

