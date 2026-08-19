-- KillEffect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil

local FALL_DISTANCE = 5 * BlockConstants.BLOCK_SIZE

return {
	["KillEffect"] = {
		["constructor"] = function(_) end,
		["cleanup"] = function(_, effectInstance)
			effectInstance.Maid:DoCleaning()
		end,
		["getGroundPosition"] = function(_, character: Model, origin: Vector3, distance: number?)
			if distance == nil then
				distance = FALL_DISTANCE
			end

			if character.IsInViewportFrame then
				return Vector3.new(0, -3, 0)
			end

			local raycastParams = RaycastParams.new()
			local filterList: { Instance } = {}

			if
				(PlaceUtil.isGameServer() or PlaceUtil.isPrivateServer()) and Workspace:FindFirstChild("BlockContainer")
			then
				local blockContainer = Workspace.BlockContainer
				table.insert(filterList, blockContainer)
			end

			local gameWorld = Flamework.resolveDependency("Jj"):getWorld()
			if (PlaceUtil.isLobbyServer() or PlaceUtil.isPrivateServer()) and gameWorld then
				table.insert(filterList, gameWorld)
			end

			raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
			raycastParams.FilterDescendantsInstances = filterList

			local workspace = Workspace
			local negativeDistance = -distance
			local raycastResult = workspace:Raycast(origin, Vector3.new(0, negativeDistance, 0), raycastParams)
			if raycastResult ~= nil then
				raycastResult = raycastResult.Position
			end

			return raycastResult
		end,
		["createModel"] = function(self, model: Model): Model
			local clonedModel = model:Clone()
			for _, descendant in clonedModel:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = false
					self:createWeld(descendant, clonedModel.PrimaryPart)
				end
			end

			return clonedModel
		end,
		["createWeld"] = function(_, part: BasePart, targetPart: BasePart): WeldConstraint
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = targetPart
			weld.Part1 = part
			weld.Parent = part

			return weld
		end,
	},
}
