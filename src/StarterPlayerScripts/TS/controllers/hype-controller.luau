-- HypeController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Players: Players = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil

export type AnimatedObjectData = {
	StartTime: number,
	Acceleration: Vector2,
	Velocity: Vector2,
	VelocityRotation: number,
}

export type HypeController = {
	animateObjects: { [Frame]: AnimatedObjectData },
	frame: Frame?,
}

local HypeController = setmetatable({}, {
	["__tostring"] = function()
		return "HypeController"
	end
})
HypeController.__index = HypeController
function HypeController.new(...)
	local class = HypeController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function HypeController.constructor(self: HypeController)
	self.animateObjects = {}
end
function HypeController.onRender(self: HypeController, deltaTime: number)
	for frame, animationData in self.animateObjects do
		local velocityDelta = animationData.Velocity * deltaTime
		local positionOffset = UDim2.fromScale(velocityDelta.X, -velocityDelta.Y)
		local newPosition = frame.Position + positionOffset
		if newPosition.Y.Scale < 0 or (newPosition.Y.Scale > 1 or (newPosition.X.Scale < 0 or newPosition.X.Scale > 1)) then
			frame:Destroy()
			self.animateObjects[frame] = nil
		else
			frame.Rotation = frame.Rotation + animationData.VelocityRotation * deltaTime
			frame.Position = newPosition
			animationData.Velocity = animationData.Velocity + animationData.Acceleration * deltaTime
		end
	end
	local objectCount = 0
	for _ in self.animateObjects do
		objectCount = objectCount + 1
	end
	if objectCount == 0 then
		self:destroyFrame()
	end
end
function HypeController.createAnimatedTextObject(self: HypeController, text: string, position: UDim2, rotation: number, acceleration: Vector2, velocity: Vector2, velocityRotation: number)
	if not self.frame then
		self:setupFrame()
	end
	local scale = ScreenUtil.getScale()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0, 0)
	frame.Position = position
	frame.Rotation = rotation
	frame.Selectable = false
	frame.Active = false
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = text
	textLabel.TextSize = 50
	textLabel.Selectable = false
	textLabel.Active = false
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale * (1 + math.random())
	uiScale.Parent = textLabel
	textLabel.Parent = frame
	frame.Parent = self.frame
	self.animateObjects[frame] = {
		["StartTime"] = os.clock(),
		["Acceleration"] = acceleration,
		["Velocity"] = velocity,
		["VelocityRotation"] = velocityRotation
	}
end
function HypeController.setupFrame(self: HypeController)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Hype"
	screenGui.IgnoreGuiInset = true
	self.frame = Instance.new("Frame")
	self.frame.BorderSizePixel = 0
	self.frame.BackgroundTransparency = 1
	self.frame.Size = UDim2.fromScale(1, 1)
	self.frame.Active = false
	self.frame.Selectable = false
	self.frame.Parent = screenGui
	screenGui.Parent = Players.LocalPlayer.PlayerGui
end
function HypeController.destroyFrame(self: HypeController)
	if not self.frame then
		return nil
	end
	if self.frame.Parent then
		self.frame.Parent:Destroy()
	end
	self.frame = nil
end
function HypeController.playEnding(self: HypeController, won: boolean)
	self:waterfallText(function()
		return won and "\240\159\145\145" or "\240\159\146\128"
	end)
end
function HypeController.playLevelUp(self: HypeController)
	self:waterfallText(function()
		return ArrayUtil.random({ "\240\159\142\137", "\240\159\165\179", "\240\159\146\175" })
	end)
end
function HypeController.playPurchase(self: HypeController)
	self:waterfallText(function()
		return ArrayUtil.random({ "\240\159\142\137", "\240\159\165\179", "\240\159\146\175" })
	end)
end
function HypeController.waterfallText(self: HypeController, getText: () -> string)
	task.spawn(function()
		for _ = 0, 29 do
			self:createAnimatedTextObject(getText(), UDim2.fromScale(math.random(), math.random() * 0.2), math.random() * 360, Vector2.new(), Vector2.new(0, -0.4 + math.random() * -0.1), 60 + math.random() * 80)
			task.wait(0.1)
		end
	end)
end
Reflect.defineMetadata(HypeController, "identifier", "qmA")
Reflect.defineMetadata(HypeController, "flamework:implements", { "$:flamework@OnRender" })
Reflect.decorate(HypeController, "$:flamework@Controller", Controller, {})
return {
	["HypeController"] = HypeController
}
