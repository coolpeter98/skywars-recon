-- HoverComponent

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local t = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out", "prelude").t
local Component = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "components", "out").Component
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local DisposableComponent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "components", "disposable-component").DisposableComponent
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute

type HoverComponent = typeof(HoverComponent) & typeof(DisposableComponent) & {
	instance: Model,
}

local HoverComponent = setmetatable({}, {
	["__tostring"] = function()
		return "HoverComponent"
	end,
	["__index"] = DisposableComponent,
})
HoverComponent.__index = HoverComponent

function HoverComponent.new(...): HoverComponent
	local classTable = HoverComponent
	local instance = setmetatable({}, classTable)
	return instance:constructor(...) or instance
end

function HoverComponent.constructor(self: HoverComponent, ...)
	DisposableComponent.constructor(self, ...)
end

function HoverComponent.onStart(self: HoverComponent)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	local baseCFrame: CFrame = CFrame.new(self.instance:GetPrimaryPartCFrame().Position)
	local hoverScaleAttribute: number? = self.instance:GetAttribute(Attribute.HoverScale)
	local hoverScale: number = hoverScaleAttribute == nil and 1 or hoverScaleAttribute

	self.maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
		if not self.instance.PrimaryPart then
			return
		end

		local currentCFrame: CFrame = self.instance:GetPrimaryPartCFrame()
		local rotation: CFrame = currentCFrame - currentCFrame.Position
		local angles = CFrame.Angles
		local rotationSpeed: number = 0.5 * (deltaTime / 0.016666666666666666)
		local rotatedCFrame: CFrame = rotation * angles(0, math.rad(rotationSpeed), 0)
		local instance = self.instance
		local time: number = os.clock()
		local hoverOffset: number = math.sin(time) * hoverScale
		instance:SetPrimaryPartCFrame((baseCFrame + Vector3.new(0, hoverOffset, 0)) * rotatedCFrame)
	end))
end

Reflect.defineMetadata(HoverComponent, "identifier", "lBl")
Reflect.defineMetadata(HoverComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(HoverComponent, "$c:components@Component", Component, {
	{
		["tag"] = "animate:hover",
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["HoverComponent"] = HoverComponent,
}
