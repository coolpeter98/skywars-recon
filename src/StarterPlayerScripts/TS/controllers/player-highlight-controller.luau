-- PlayerHighlightController

type PlayerHighlightController = {
	new: (...any) -> PlayerHighlightController,
	playDamageHighlight: (self: PlayerHighlightController, target: Model) -> (),
	playIceSpikeHighlight: (self: PlayerHighlightController, target: Model, duration: number) -> (),
	playerThunderstormHighlight: (self: PlayerHighlightController, target: Model) -> (),
	getPlayerHighlight: (self: PlayerHighlightController, target: Model) -> Highlight,
	createPlayerHighlight: (self: PlayerHighlightController) -> Highlight,
}

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
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService

local PlayerHighlightController: PlayerHighlightController = setmetatable({}, {
	["__tostring"] = function()
		return "PlayerHighlightController"
	end,
})

PlayerHighlightController.__index = PlayerHighlightController

function PlayerHighlightController.new(...)
	local self = setmetatable({}, PlayerHighlightController)
	return self:constructor(...) or self
end

function PlayerHighlightController.constructor(self) end

function PlayerHighlightController.playDamageHighlight(self, target)
	print(("Applying highlight to %*"):format(target.Name))
	local highlight = self:getPlayerHighlight(target)
	highlight.FillColor = Color3.new(1, 0, 0)
	highlight.FillTransparency = 0.2
	TweenService:Create(highlight, TweenInfo.new(0.25), {
		["FillTransparency"] = 1,
	}):Play()
end

function PlayerHighlightController.playIceSpikeHighlight(self, target, duration)
	local highlight = self:getPlayerHighlight(target)
	highlight.Adornee = target
	highlight.FillColor = Color3.fromRGB(198, 227, 255)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	TweenService:Create(highlight, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		["FillTransparency"] = 0.25,
	}):Play()
end

function PlayerHighlightController.playerThunderstormHighlight(self, target)
	local highlight = self:getPlayerHighlight(target)
	highlight.Adornee = target
	highlight.FillColor = Color3.fromRGB(2, 28, 164)
	highlight.FillTransparency = 0.2
	highlight.OutlineTransparency = 1
	TweenService:Create(highlight, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		["FillTransparency"] = 1,
	}):Play()
end

function PlayerHighlightController.getPlayerHighlight(self, target)
	local highlight = target:FindFirstChild("PlayerHighlight")
	if not highlight then
		highlight = self:createPlayerHighlight()
		highlight.Parent = target
	end
	return highlight
end

function PlayerHighlightController.createPlayerHighlight(self)
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerHighlight"
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineTransparency = 1
	return highlight
end

Reflect.defineMetadata(PlayerHighlightController, "identifier", "Ax3")
Reflect.decorate(PlayerHighlightController, "$:flamework@Controller", Controller, {})
return {
	["PlayerHighlightController"] = PlayerHighlightController,
}
