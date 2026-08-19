-- EggArrowTrail

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-decorator"
).CosmeticDecorator
local ArrowTrailEffect = RuntimeLib.import(script, script.Parent.Parent, "arrow-trail-effect").ArrowTrailEffect
local EggCharacters = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"egg-character",
	"egg-character"
).EggCharacters
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local EggCharacterUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"egg-character",
	"egg-character-util"
).EggCharacterUtil
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil

type EggArrowTrailData = {
	TeamColorId: string,
	Ref: Model,
	Colors: { Color3 },
}

local function getEggColors(color: Color3): { Color3 }
	return {
		ColorUtil.scaleValue(color, 1.2),
		ColorUtil.scaleValue(color, 1.1),
		color,
		ColorUtil.scaleValue(color, 0.9),
		ColorUtil.scaleValue(color, 0.8),
	}
end

local EGG_TRAIL_DATA = {}
local redEgg = EggCharacters.Red
local redEggData = {
	["TeamColorId"] = "Red",
	["Ref"] = nil,
	["Colors"] = nil,
	["Ref"] = EggCharacterUtil.createEggModel("Red"),
	["Colors"] = getEggColors(redEgg.Color),
}
local limeEgg = EggCharacters.Lime
local limeEggData = {
	["TeamColorId"] = "Lime",
	["Ref"] = nil,
	["Colors"] = nil,
	["Ref"] = EggCharacterUtil.createEggModel("Lime"),
	["Colors"] = getEggColors(limeEgg.Color),
}
local cyanEgg = EggCharacters.Cyan
local cyanEggData = {
	["TeamColorId"] = "Cyan",
	["Ref"] = nil,
	["Colors"] = nil,
	["Ref"] = EggCharacterUtil.createEggModel("Cyan"),
	["Colors"] = getEggColors(cyanEgg.Color),
}
local yellowEgg = EggCharacters.Yellow
__set_list(EGG_TRAIL_DATA, 1, {
	redEggData,
	limeEggData,
	cyanEggData,
	{
		["TeamColorId"] = "Yellow",
		["Ref"] = nil,
		["Colors"] = nil,
		["Ref"] = EggCharacterUtil.createEggModel("Yellow"),
		["Colors"] = getEggColors(yellowEgg.Color),
	},
})

local EggArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "EggArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
EggArrowTrail.__index = EggArrowTrail

function EggArrowTrail.new(...)
	local self = setmetatable({}, EggArrowTrail)
	return self:constructor(...) or self
end

function EggArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
	self.history = {}
end

function EggArrowTrail.onStart(self)
	Players.PlayerRemoving:Connect(function(player: Player)
		local history = self.history
		local hadHistory = history[player] ~= nil
		history[player] = nil
		return hadHistory
	end)
end

function EggArrowTrail.playEffect(self, projectile: BasePart, maid: Maid)
	local shooter = self:getShooter(projectile)
	local nextEgg = self:getNextEgg(shooter)
	if shooter then
		self.history[shooter] = nextEgg
	end
	local trail = self:createTrail(projectile, nextEgg.Colors)
	local particleEmitter = self:createParticleEmitter(projectile, nextEgg.Colors)
	maid:GiveTask(function()
		particleEmitter.Enabled = false
		return particleEmitter.Enabled
	end)
	local trailProps = {
		["ItemScale"] = 0.35,
		["ItemDuration"] = 0.3,
		["UpdateInterval"] = 0.2,
		["OnItemAdded"] = nil,
		["OnItemRemoved"] = nil,
		["OnItemAdded"] = function(item: Model, distance: number)
			if distance > 100 then
				return nil
			end
			item:ScaleTo(0.01)
			TweenUtil.simple(
				0.01,
				1,
				TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
				function(scale: number)
					item:ScaleTo(scale)
				end
			)
		end,
		["OnItemRemoved"] = function(item: Model, distance: number)
			if distance > 100 then
				return true
			end
			task.spawn(function()
				TweenUtil.simple(
					item:GetScale(),
					0.01,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
					function(scale: number)
						item:ScaleTo(scale)
					end
				).Completed
					:Wait()
				item:Destroy()
			end)
			return false
		end,
	}
	self:createModelTrail(projectile, maid, nextEgg.Ref, trailProps)
	trail.Parent = projectile
end

function EggArrowTrail.getNextEgg(self, shooter: Player?): EggArrowTrailData
	local previousEgg
	if shooter then
		previousEgg = self.history[shooter]
	else
		previousEgg = nil
	end
	return ArrayUtil.random(EGG_TRAIL_DATA, nil, unpack(ArrayUtil.filterDefined({ previousEgg })))
end

Reflect.defineMetadata(EggArrowTrail, "identifier", "Npb")
Reflect.decorate(EggArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailEgg })

return {
	["EggArrowTrail"] = EggArrowTrail,
}
