-- EggComponent

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
local t = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out",
	"prelude"
).t
local Component = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"components",
	"out"
).Component
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local EggCharacters = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"egg-character",
	"egg-character"
).EggCharacters
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type EggComponent = {
	new: (...any) -> EggComponent,
	constructor: (self: EggComponent, ...any) -> (),
	onStart: (self: EggComponent) -> (),
}

local EggComponent = setmetatable({}, {
	["__tostring"] = function()
		return "EggComponent"
	end,
	["__index"] = DisposableComponent,
})
EggComponent.__index = EggComponent

function EggComponent.new(...)
	local self = EggComponent
	local obj = setmetatable({}, self)
	return obj:constructor(...) or obj
end

function EggComponent.constructor(self, ...)
	DisposableComponent.constructor(self, ...)
end

function EggComponent.onStart(self)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	local teamId = self.instance:GetAttribute(Attribute.TeamId)
	if teamId == nil then
		return nil
	end

	Flamework.resolveDependency("zG"):awaitReplication("GameTeams")

	local team = GlobalStore:getState().GameTeams[teamId]
	if not team then
		return nil
	end

	local eggCharacter = EggCharacters[teamId]
	if not eggCharacter then
		return nil
	end

	local markerSetup = {
		["Color"] = nil,
		["HideDistance"] = nil,
		["HideBackground"] = true,
		["Image"] = nil,
		["Color"] = team.Color,
		["HideDistance"] = BlockConstants.BLOCK_SIZE * 15,
	}

	local iconId
	if team.CanRespawn then
		iconId = eggCharacter.IconId
	else
		iconId = eggCharacter.IconDeadId
	end
	markerSetup.Image = iconId

	local marker = Flamework.resolveDependency("04V")
		:addKeypoint(self.instance:GetPivot().Position + Vector3.new(0, 12, 0), markerSetup)

	self.maid:GiveTask(Events["e81ad96c-f3a4-4d32-8e0c-1fab6c11d1c7"]:connect(function(eliminatedTeamId)
		if teamId == eliminatedTeamId then
			markerSetup.Image = eggCharacter.IconDeadId
		end
	end))

	self.maid:GiveTask(function()
		Flamework.resolveDependency("04V"):removeKeypoint(marker)
	end)
end

Reflect.defineMetadata(EggComponent, "identifier", "xW6")
Reflect.defineMetadata(EggComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(EggComponent, "$c:components@Component", Component, {
	{
		["tag"] = "egg",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["EggComponent"] = EggComponent,
}
