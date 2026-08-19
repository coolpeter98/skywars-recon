-- ChristmasController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local Make = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"altmake",
	"out"
).Make
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Lighting: Lighting = Services.Lighting
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local AwaitCharacter: (player: Player?) -> Model =
	RuntimeLib.import(script, script.Parent.Parent, "util", "util").AwaitCharacter
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local GameConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants

type ChristmasController = {
	onStart: (self: ChristmasController) -> (),
	updateLighting: (self: ChristmasController) -> (),
	createSnowParticleEmitter: (self: ChristmasController, emitterPart: Part) -> ParticleEmitter,
	createSnowEmitterPart: (self: ChristmasController, character: Model) -> Part,
	scheduleUpdateSnowEmitterPartPosition: (self: ChristmasController, snowEmitterPart: Part) -> (),
}

local ChristmasController = setmetatable({}, {
	["__tostring"] = function()
		return "ChristmasController"
	end,
})

ChristmasController.__index = ChristmasController

function ChristmasController.new(...)
	local self = setmetatable({}, ChristmasController)
	return self:constructor(...) or self
end

function ChristmasController.constructor(_) end

function ChristmasController.onStart(self)
	if not GameConstants.CHRISTMAS_LOBBY_ENABLED then
		return nil
	end
	if not PlaceUtil.isLobbyServer() then
		return nil
	end
	self:updateLighting()
	local snowEmitterPart = self:createSnowEmitterPart(AwaitCharacter())
	self:createSnowParticleEmitter(snowEmitterPart)
	self:scheduleUpdateSnowEmitterPartPosition(snowEmitterPart)
end

function ChristmasController.updateLighting(_)
	Lighting.Ambient = Color3.fromRGB(131, 122, 150)
	Lighting.ColorShift_Top = Color3.fromRGB(210, 180, 140)
	Lighting.ClockTime = 15.5
	Lighting.GeographicLatitude = 11
	Lighting:FindFirstChildOfClass("Atmosphere").Density = 0.3
	local colorCorrectionEffect = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	colorCorrectionEffect.Saturation = 0.1
	colorCorrectionEffect.TintColor = Color3.fromRGB(240, 249, 255)
end

function ChristmasController.createSnowParticleEmitter(_, emitterPart)
	return Make("ParticleEmitter", {
		["Color"] = nil,
		["LightEmission"] = 0.2,
		["LightInfluence"] = 0.5,
		["Size"] = nil,
		["Texture"] = nil,
		["Transparency"] = nil,
		["EmissionDirection"] = nil,
		["Lifetime"] = nil,
		["Rate"] = 100,
		["Rotation"] = nil,
		["RotSpeed"] = nil,
		["Speed"] = nil,
		["SpreadAngle"] = nil,
		["LockedToPart"] = false,
		["Parent"] = nil,
		["Color"] = ColorUtil.getColorSequence({
			Color.White,
			Color3.fromRGB(255, 250, 250),
			Color3.fromRGB(242, 243, 244),
			Color3.fromRGB(235, 236, 240),
			Color3.fromRGB(235, 246, 247),
		}),
		["Size"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.1) }),
		["Texture"] = RobloxImage.PARTICLE,
		["Transparency"] = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.1, 0),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(0.8, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		}),
		["EmissionDirection"] = Enum.NormalId.Bottom,
		["Lifetime"] = NumberRange.new(5, 10),
		["Rotation"] = NumberRange.new(0, 360),
		["RotSpeed"] = NumberRange.new(-50, 50),
		["Speed"] = NumberRange.new(3, 4),
		["SpreadAngle"] = Vector2.new(5, 5),
		["Parent"] = emitterPart,
	})
end

function ChristmasController.createSnowEmitterPart(_, character)
	local props = {
		["Name"] = "Snow",
		["Size"] = nil,
		["Anchored"] = true,
		["Transparency"] = 1,
		["CanCollide"] = false,
		["Parent"] = nil,
	}
	local sizeX = 64 * BlockConstants.BLOCK_SIZE
	local sizeZ = 64 * BlockConstants.BLOCK_SIZE
	props.Size = Vector3.new(sizeX, 1, sizeZ)
	props.Parent = character
	return Make("Part", props)
end

function ChristmasController.scheduleUpdateSnowEmitterPartPosition(_, snowEmitterPart)
	RunService.Heartbeat:Connect(function()
		if not Players.LocalPlayer.Character then
			return nil
		end
		snowEmitterPart.CFrame =
			Players.LocalPlayer.Character:GetPivot():ToWorldSpace(CFrame.new(0, 8 * BlockConstants.BLOCK_SIZE, 0))
	end)
end

Reflect.defineMetadata(ChristmasController, "identifier", "N4b")
Reflect.defineMetadata(ChristmasController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ChristmasController, "$:flamework@Controller", Controller, {})

return {
	["ChristmasController"] = ChristmasController,
}
