-- SpawnUtil

return {
	["SpawnUtil"] = {
		["createSpawnLocation"] = function(cframe: CFrame): SpawnLocation
			local spawnLocation = Instance.new("SpawnLocation")
			spawnLocation.Name = "SpawnLocation"
			spawnLocation.CFrame = cframe
			spawnLocation.Size = Vector3.new()
			spawnLocation.Transparency = 1
			spawnLocation.Duration = 0
			spawnLocation.CanCollide = false
			spawnLocation.Anchored = true
			return spawnLocation
		end,
	},
}
