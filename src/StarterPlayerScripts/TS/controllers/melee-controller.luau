-- MeleeController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local CollectionService: CollectionService = Services.CollectionService
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local Util = RuntimeLib.import(script, script.Parent.Parent, "util", "util")
local GetCamera = Util.GetCamera
local GetCharacter = Util.GetCharacter
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local MeleeConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "melee", "melee-constants").MeleeConstants
local VectorUtilModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util")
local Distance = VectorUtilModule.Distance
local VectorUtil = VectorUtilModule.VectorUtil
local QueryUtilModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "query-util")
local CombatRaycastType = QueryUtilModule.CombatRaycastType
local QueryUtil = QueryUtilModule.QueryUtil
local RaycastUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "raycast", "raycast-util").RaycastUtil
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil

type MeleeAnimationData = {
	ItemAnimation: any,
	AnimationIndex: number,
	AnimationTime: number?,
}

type MeleeController = {
	maid: any,
	characterAnimationData: { [Model]: MeleeAnimationData },
}

local MeleeController = setmetatable({}, {
	["__tostring"] = function()
		return "MeleeController"
	end,
})
MeleeController.__index = MeleeController

function MeleeController.new(...): MeleeController
	local class = MeleeController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function MeleeController.constructor(self: MeleeController)
	self.maid = Maid.new()
	self.characterAnimationData = {}
end

function MeleeController.onStart(self: MeleeController)
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isPcInteract(input) then
			return nil
		end
		self:strike(input)
	end)
end

function MeleeController.strike(self: MeleeController, input: InputObject)
	local heldItemInfo = Flamework.resolveDependency("Dqk"):getHeldItemInfo()
	if heldItemInfo and heldItemInfo.Melee then
		if Players.LocalPlayer.Character then
			local activeSkin = Flamework.resolveDependency("Ggz"):getActiveSkinFromItem(heldItemInfo.Name)
			if self:playAnimation(Players.LocalPlayer.Character, heldItemInfo, activeSkin) then
				Flamework.resolveDependency("jL9"):playSound(RobloxSound.Sword.SLASH)
			end
		end
		local mouseLocation = UserInputService:GetMouseLocation()
		if InputUtil.isMobileInteract(input) or InputUtil.isControllerInteract(input) then
			self:strikeMobile()
		else
			self:strikeDesktop(mouseLocation)
		end
	else
		return nil
	end
end

function MeleeController.playAnimation(self: MeleeController, character: Model, item, activeSkin): boolean
	local animationData = self.characterAnimationData[character]
	if animationData and not TimeUtil.elapsed(animationData.AnimationTime, 0.3) then
		return false
	end
	local itemAnimation = Flamework.resolveDependency("Ggz"):getItemAnimation(item, activeSkin)
	local meleeAnimations
	if itemAnimation == nil then
		meleeAnimations = itemAnimation
	else
		meleeAnimations = itemAnimation.Melee
	end
	if not meleeAnimations or #itemAnimation.Melee == 0 then
		self:playDefaultAnimation(character)
		return true
	end
	local animationIndex = (
		(
			(
					not animationData
					or (
						TimeUtil.elapsed(animationData.AnimationTime, 1)
						or animationData.ItemAnimation ~= itemAnimation
					)
				)
				and -1
			or animationData.AnimationIndex
		) + 1
	) % #itemAnimation.Melee
	local animation = itemAnimation.Melee[animationIndex + 1]
	Flamework.resolveDependency("Kp"):playHumanoidAnimation(animation, false, 1, character)
	self:setCharacterMeleeAnimationData(character, {
		["ItemAnimation"] = itemAnimation,
		["AnimationIndex"] = animationIndex,
		["AnimationTime"] = os.clock(),
	})
	return true
end

function MeleeController.playDefaultAnimation(self: MeleeController, character: Model)
	Flamework.resolveDependency("Kp"):playHumanoidAnimation(RobloxAnimation.SWORD_SLASH, false, 1, character)
	self:setCharacterMeleeAnimationData(character, {
		["ItemAnimation"] = nil,
		["AnimationIndex"] = 0,
		["AnimationTime"] = nil,
		["AnimationTime"] = os.clock(),
	})
end

function MeleeController.strikeMobile(_)
	local character = GetCharacter()
	if not (character and character.PrimaryPart) then
		return nil
	end
	local boxCFrame = character:GetPrimaryPartCFrame() * CFrame.new(Vector3.new(0, 0, -5))
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
	overlapParams.FilterDescendantsInstances =
		QueryUtil.getCombatRaycastParams(CombatRaycastType.MELEE, Players.LocalPlayer, false).FilterDescendantsInstances
	local targets = {}
	for _, part in Workspace:GetPartBoundsInBox(boxCFrame, Vector3.new(12, 6, 9), overlapParams) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and (Players:GetPlayerFromCharacter(model) or CollectionService:HasTag(model, "entity")) then
			table.insert(targets, model)
		end
	end
	if #targets == 0 then
		Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(nil)
		return nil
	end
	table.sort(targets, function(left, right)
		return Distance(Players.LocalPlayer, left) < Distance(Players.LocalPlayer, right)
	end)
	local targetCount = #targets
	local target = targets[targetCount]
	targets[targetCount] = nil
	if target and Distance(Players.LocalPlayer, target) < MeleeConstants.MAXIMUM_HIT_RANGE_BLOCKS * 2.3 then
		local player = Players:GetPlayerFromCharacter(target)
		local raycastParams = QueryUtil.getCombatRaycastParams(CombatRaycastType.MELEE, nil, true, false, false)
		if player then
			if RaycastUtil.isCharacterVisible(target, raycastParams) then
				Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(player)
			end
		elseif RaycastUtil.isModelVisible(target, raycastParams) then
			Events["ccbf1e6a-d343-4e2b-9bd2-b824fd4c2b8b"]:fire(target)
		end
		return nil
	end
	Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(nil)
end

function MeleeController.strikeDesktop(self: MeleeController, mouseLocation: Vector2)
	local ray = GetCamera():ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastParams = QueryUtil.getCombatRaycastParams(CombatRaycastType.MELEE)
	local origin = ray.Origin
	for _, part in raycastParams.FilterDescendantsInstances do
		if part:IsA("BasePart") then
			local position = part.Position
			local size = part.Size
			local min = position - size / 2
			local max = position + size / 2
			if VectorUtil.isInAABB(origin, min, max) and self:attemptStrikeDesktop(part) then
				print("Struck within hitbox!")
				return nil
			end
		end
	end
	self:manageShimBlocks(true)
	local raycastResult = Workspace:Raycast(origin, ray.Direction * 35, raycastParams)
	self:manageShimBlocks(false)
	if not raycastResult then
		self.maid:DoCleaning()
		Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(nil)
		return nil
	end
	self:attemptStrikeDesktop(raycastResult.Instance)
end

function MeleeController.manageShimBlocks(_, shrink: boolean)
	for _, shim in CollectionService:GetTagged("shim") do
		if shrink then
			shim.Size = Vector3.new(0.01, 0.01, 0.01)
		else
			shim.Size = Vector3.new(3, 3, 3)
		end
	end
end

function MeleeController.attemptStrikeDesktop(self: MeleeController, part: BasePart): boolean
	local model = part:FindFirstAncestorOfClass("Model")
	self.maid:DoCleaning()
	if model then
		local player = Players:GetPlayerFromCharacter(model)
		if player or CollectionService:HasTag(model, "entity") then
			local distance = Distance(Players.LocalPlayer, model)
			if
				distance == 0
				or (distance ~= distance or (not distance or MeleeConstants.MAXIMUM_HIT_RANGE_BLOCKS * 3 < distance))
			then
				Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(nil)
				return false
			else
				if player then
					Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(player)
				else
					Events["ccbf1e6a-d343-4e2b-9bd2-b824fd4c2b8b"]:fire(model)
				end
				return true
			end
		else
			Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(nil)
			return false
		end
	else
		Events["bf26abfd-c509-43b4-9b49-5ae3a5521cd4"]:fire(nil)
		return false
	end
end

function MeleeController.setCharacterMeleeAnimationData(
	self: MeleeController,
	character: Model,
	data: MeleeAnimationData
)
	if self.characterAnimationData[character] == nil then
		local connection = nil
		connection = character.Destroying:Connect(function()
			self.characterAnimationData[character] = nil
			connection:Disconnect()
		end)
	end
	self.characterAnimationData[character] = data
end

Reflect.defineMetadata(MeleeController, "identifier", "Gpz")
Reflect.defineMetadata(MeleeController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(MeleeController, "$:flamework@Controller", Controller, {})
return {
	["MeleeController"] = MeleeController,
}
