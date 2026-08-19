-- QueryUtil

local Services =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"services"
	)
local CollectionService: CollectionService = Services.CollectionService
local Players: Players = Services.Players
local Workspace: Workspace = Services.Workspace

local QueryUtil = {
	["getPlayersInBounds"] = function(part: BasePart, size: Vector3, rotation: CFrame): { [Player]: boolean }
		local players: { [Player]: boolean } = {}
		for _, partInBounds: BasePart in Workspace:GetPartBoundsInBox(part, size, rotation) do
			local model = partInBounds:FindFirstAncestorOfClass("Model")
			if model then
				local player = Players:GetPlayerFromCharacter(model)
				if player then
					players[player] = true
				end
			end
		end
		return players
	end,
}

local getCombatRaycastParams: ((
	partName: string,
	ignorePlayer: Player?,
	includeBlocks: boolean?,
	includePlayers: boolean?,
	includeEntities: boolean?
) -> RaycastParams)? =
	nil

function QueryUtil.getCombatOverlapParams(
	partName: string,
	ignorePlayer: Player?,
	includeBlocks: boolean?,
	includePlayers: boolean?,
	includeEntities: boolean?
): OverlapParams
	if ignorePlayer == nil then
		ignorePlayer = Players.LocalPlayer
	end
	local includeBlocks = includeBlocks == nil and true or includeBlocks
	local includePlayers = includePlayers == nil and true or includePlayers
	local includeEntities = includeEntities == nil and true or includeEntities
	local overlapParams: OverlapParams = OverlapParams.new()
	local raycastParams: RaycastParams =
		getCombatRaycastParams(partName, ignorePlayer, includeBlocks, includePlayers, includeEntities)
	overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
	overlapParams.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
	return overlapParams
end

getCombatRaycastParams = function(
	partName: string,
	ignorePlayer: Player?,
	includeBlocks: boolean?,
	includePlayers: boolean?,
	includeEntities: boolean?
): RaycastParams
	if ignorePlayer == nil then
		ignorePlayer = Players.LocalPlayer
	end
	local includeBlocks = includeBlocks == nil and true or includeBlocks
	local includePlayers = includePlayers == nil and true or includePlayers
	local includeEntities = includeEntities == nil and true or includeEntities
	local filterInstances: { Instance } = {}
	if includeBlocks and Workspace:FindFirstChild("BlockContainer") then
		local blockContainer: Instance = Workspace.BlockContainer
		table.insert(filterInstances, blockContainer)
	end
	if includePlayers then
		for _, player: Player in Players:GetPlayers() do
			if (not ignorePlayer or player ~= ignorePlayer) and (player.Character and player.Character.PrimaryPart) then
				local part = player.Character:FindFirstChild(partName)
				if part then
					table.insert(filterInstances, part)
				end
			end
		end
	end
	if includeEntities then
		for _, entity: Instance in CollectionService:GetTagged("entity") do
			table.insert(filterInstances, entity)
		end
	end
	local raycastParams: RaycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = filterInstances
	return raycastParams
end

QueryUtil.getCombatRaycastParams = getCombatRaycastParams

return {
	["CombatRaycastType"] = {
		["MELEE"] = "Hitbox",
		["RANGED"] = "ProjectileHitbox",
	},
	["QueryUtil"] = QueryUtil,
}
