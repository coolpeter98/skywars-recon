// Verifies the unpopulated Egg Wars map contract consumed by EggWarsMap.

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const MAP_DIRECTORY = "src/ServerStorage/Maps/EggWars";
const MAPS = {
	ConstructionEgg: [4, 8, 4, 4],
	PhoenixEgg: [4, 8, 4, 4],
	// The supplied Tundra asset intentionally contains two tier-four markers
	// at one corner; runtime population follows every authored marker.
	TundraEgg: [4, 8, 4, 5],
};
const EMPTY_RUNTIME_FOLDERS = ["SpawnLocations", "Generators", "Shops", "Chests"];

function child(parent, name, className) {
	const instance = parent.Children.find((candidate) => candidate.Name === name && candidate.ClassName === className);
	assert(instance, `missing ${className} ${parent.Name}.${name}`);
	return instance;
}

function assertCFrameValues(folder, expectedCount) {
	const count = folder.Children.filter((candidate) => candidate.ClassName === "CFrameValue").length;
	assert.equal(count, expectedCount, `${folder.Name} CFrameValue count`);
}

for (const [mapName, generatorCounts] of Object.entries(MAPS)) {
	const file = RobloxFile.ReadFromBuffer(readFileSync(`${MAP_DIRECTORY}/${mapName}.rbxm`));
	assert(file, `${mapName} must parse`);
	assert.equal(file.Roots.length, 1, `${mapName} root count`);
	const map = file.Roots[0];
	assert.equal(map.ClassName, "Model", `${mapName} root class`);

	const worldData = child(map, "WorldData", "Folder");
	const anchor = child(worldData, "Spawn", "CFrameValue");
	assertCFrameValues(child(worldData, "GameSpawn", "Folder"), 4);
	assertCFrameValues(child(worldData, "SpawnEgg", "Folder"), 4);

	const generatorMarkers = child(worldData, "Generator", "Folder");
	for (const [tier, expectedCount] of generatorCounts.entries()) {
		assertCFrameValues(child(generatorMarkers, String(tier + 1), "Folder"), expectedCount);
	}
	const shopMarkers = child(worldData, "Shop", "Folder");
	assertCFrameValues(child(shopMarkers, "Blacksmith", "Folder"), 4);
	assertCFrameValues(child(shopMarkers, "Merchant", "Folder"), 4);
	assertCFrameValues(child(worldData, "QuickShop", "Folder"), 4);

	for (const folderName of EMPTY_RUNTIME_FOLDERS) {
		assert.equal(child(map, folderName, "Folder").Children.length, 0, `${mapName}.${folderName} must be empty`);
	}
	const topSpawn = child(map, "SpawnLocation", "SpawnLocation");
	const anchorPosition = anchor.Value.Position;
	const spawnPosition = topSpawn.CFrame.Position;
	const translation = {
		X: anchorPosition.X - spawnPosition.X,
		Y: anchorPosition.Y - spawnPosition.Y,
		Z: anchorPosition.Z - spawnPosition.Z,
	};
	assert(
		Math.abs(translation.X) < 0.01 && Math.abs(translation.Y) < 0.01 && Math.abs(translation.Z) < 0.01,
		`${mapName} physical geometry must already align with WorldData`,
	);
	console.log(`PASS ${mapName}`);
}
