-- AmbientController

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
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType

type AmbientController = {}

local AmbientController = setmetatable({}, {
	["__tostring"] = function()
		return "AmbientController"
	end,
})
AmbientController.__index = AmbientController

function AmbientController.new(...)
	local self = setmetatable({}, AmbientController)
	return self:constructor(...) or self
end

function AmbientController.constructor(self: AmbientController) end

function AmbientController.onStart(self: AmbientController)
	if PlaceUtil.isLobbyServer() then
		Flamework.resolveDependency("jL9"):playSound(RobloxSound.Lobby.SOUNDTRACK, {
			["Volume"] = 0.8,
			["Looped"] = true,
			["SoundGroup"] = nil,
			["SoundGroup"] = SoundGroupType.Music,
		})
	end
	Flamework.resolveDependency("jL9"):playSound(RobloxSound.Misc.WIND, {
		["Volume"] = 1.5,
		["Looped"] = true,
	})
end

Reflect.defineMetadata(AmbientController, "identifier", "6qY")
Reflect.defineMetadata(AmbientController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(AmbientController, "$:flamework@Controller", Controller, {})
return {
	["AmbientController"] = AmbientController,
}
