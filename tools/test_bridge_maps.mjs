// Verifies the unpopulated Bridge map contract consumed by BridgeMap.

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { RobloxFile } from "./rbxm-parser-ts/dist/index.mjs";

const MAP_DIRECTORY = "src/ServerStorage/Maps/Bridge";
const MAPS = ["Castle", "Phoenix Bridge", "Ships"];
const TEAM_IDS = ["Red", "Blue"];

function child(parent, name, className) {
	const instance = parent.Children.find((candidate) => candidate.Name === name && candidate.ClassName === className);
	assert(instance, `missing ${className} ${parent.Name}.${name}`);
	return instance;
}

function cframeValues(folder) {
	return folder.Children.filter((candidate) => candidate.ClassName === "CFrameValue");
}

function assertMarkers(folder, mapName, requireTeamNames = false) {
	const markers = cframeValues(folder);
	assert.equal(markers.length, 2, `${mapName}.${folder.Name} marker count`);
	if (requireTeamNames) {
		for (const teamId of TEAM_IDS) {
			child(folder, teamId, "CFrameValue");
		}
	}
}

for (const assetName of MAPS) {
	const file = RobloxFile.ReadFromBuffer(readFileSync(`${MAP_DIRECTORY}/${assetName}.rbxm`));
	assert(file, `${assetName} must parse`);
	assert.equal(file.Roots.length, 1, `${assetName} root count`);
	const map = file.Roots[0];
	assert.equal(map.ClassName, "Model", `${assetName} root class`);

	const worldData = child(map, "WorldData", "Folder");
	child(worldData, "Spawn", "CFrameValue");
	assertMarkers(child(worldData, "GameSpawn", "Folder"), assetName, true);
	assertMarkers(child(worldData, "Portal", "Folder"), assetName);

	const bounds = cframeValues(child(worldData, "BuildBounds", "Folder"));
	assert.equal(bounds.length, 2, `${assetName}.BuildBounds marker count`);
	const first = bounds[0].Value.Position;
	const second = bounds[1].Value.Position;
	assert(
		Math.abs(first.X - second.X) > 0.01 &&
			Math.abs(first.Y - second.Y) > 0.01 &&
			Math.abs(first.Z - second.Z) > 0.01,
		`${assetName}.BuildBounds must describe a volume`,
	);

	assert.equal(child(map, "SpawnLocations", "Folder").Children.length, 0, `${assetName}.SpawnLocations must start empty`);
	assert.equal(child(map, "Portals", "Folder").Children.length, 0, `${assetName}.Portals must start empty`);
	child(map, "Default", "Model");
	console.log(`PASS ${assetName}`);
}
