-- CosmeticKillEffectDisplayController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local CosmeticId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local ScheduleUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = Services.Players
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local Workspace: Workspace = Services.Workspace
local CosmeticDisplayDecorator = RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").CosmeticDisplayDecorator

type CosmeticKillEffectDisplayController = {
	new: (...any) -> CosmeticKillEffectDisplayController,
	constructor: (self: CosmeticKillEffectDisplayController) -> (),
	equip: (self: CosmeticKillEffectDisplayController, display: any, cosmeticId: string) -> any,
	getGroundPosition: (self: CosmeticKillEffectDisplayController, model: Model) -> CFrame,
	getPivotOffset: (self: CosmeticKillEffectDisplayController, model: Model) -> CFrame,
	__tostring: () -> string,
}

local CosmeticKillEffectDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticKillEffectDisplayController"
	end,
})
CosmeticKillEffectDisplayController.__index = CosmeticKillEffectDisplayController

function CosmeticKillEffectDisplayController.new(...)
	local class = CosmeticKillEffectDisplayController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function CosmeticKillEffectDisplayController.constructor(self) end

function CosmeticKillEffectDisplayController.equip(self, display, cosmeticId)
	local maid = Maid.new()
	if Cosmetics[cosmeticId].Type ~= "KillEffect" or not display.Character then
		return maid
	end
	display.Character.Parent = ReplicatedStorage
	local killEffect = nil
	maid:GiveTask(ScheduleUtil.createSchedule(1, function()
		if not (display.DisplayModel:IsDescendantOf(Workspace) or display.DisplayModel:IsDescendantOf(Players.LocalPlayer.PlayerGui)) then
			if killEffect then
				killEffect.Maid:DoCleaning()
				killEffect = nil
			end
			return nil
		end
		if killEffect and not killEffect.AnimationEnded then
			return nil
		end
		local model = display.Character:Clone()
		model:ScaleTo(1)
		local pivotOffset = self:getPivotOffset(model)
		model:PivotTo(display.Position + pivotOffset.Position)
		model.Parent = display.DisplayModel
		killEffect = Flamework.resolveDependency("Q83"):playKillEffect(model, cosmeticId, nil, display.DisplayModel)
		if killEffect then
			maid:GiveTask(killEffect.Maid)
			display.DisplayModel:ScaleTo(display.Scale)
			if cosmeticId == CosmeticId.KillEffectSlimeCube then
				model = display.DisplayModel
			end
			local groundPosition = self:getGroundPosition(model)
			local offset = display.Position - groundPosition.Position
			if cosmeticId == CosmeticId.KillEffectSlimeCube then
				local scale = display.Scale
				offset = offset - Vector3.new(0, scale, 0)
			end
			display.DisplayModel:TranslateBy(offset.Position)
			killEffect.Maid:GiveTask(function()
				display.DisplayModel:ScaleTo(1)
			end)
		end
	end))
	maid:GiveTask(function()
		local characterParent = display.Character
		if characterParent ~= nil then
			characterParent = characterParent.Parent
		end
		if characterParent then
			display.Character.Parent = display.DisplayModel
		end
	end)
	return maid
end

function CosmeticKillEffectDisplayController.getGroundPosition(self, model)
	local center, size = model:GetBoundingBox()
	local halfHeight = size.Y / 2
	return center - Vector3.new(0, halfHeight, 0)
end

function CosmeticKillEffectDisplayController.getPivotOffset(self, model)
	local groundPosition = self:getGroundPosition(model)
	return model:GetPivot() - groundPosition.Position
end

Reflect.defineMetadata(CosmeticKillEffectDisplayController, "identifier", "PQb")
Reflect.defineMetadata(CosmeticKillEffectDisplayController, "flamework:implements", { "g4k" })
Reflect.decorate(CosmeticKillEffectDisplayController, "MJo", CosmeticDisplayDecorator, { "KillEffect" })
Reflect.decorate(CosmeticKillEffectDisplayController, "$:flamework@Controller", Controller, {})
return {
	["CosmeticKillEffectDisplayController"] = CosmeticKillEffectDisplayController,
}
