-- GeneratorComponent

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local RunService: RunService = Services.RunService
local Workspace: Workspace = Services.Workspace
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type GeneratorComponent = {
	new: (...any) -> GeneratorComponent,
	constructor: (self: GeneratorComponent, ...any) -> (),
	onStart: (self: GeneratorComponent) -> (),
}

local GeneratorComponent = setmetatable({}, {
	["__tostring"] = function()
		return "GeneratorComponent"
	end,
	["__index"] = DisposableComponent,
})
GeneratorComponent.__index = GeneratorComponent

function GeneratorComponent.new(...)
	local self = GeneratorComponent
	local obj = setmetatable({}, self)
	return obj:constructor(...) or obj
end

function GeneratorComponent.constructor(self, ...)
	DisposableComponent.constructor(self, ...)
end

function GeneratorComponent.onStart(self)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	local baseCFrame = CFrame.new(self.instance:GetPrimaryPartCFrame().Position)
	local phaseOffset = math.random() * 10

	self.maid:GiveTask(RunService.Heartbeat:Connect(function(_)
		local primaryPart = self.instance.PrimaryPart
		if not primaryPart then
			return nil
		end

		if (Workspace.CurrentCamera.CFrame.Position - primaryPart.Position).Magnitude > 128 then
			return nil
		end

		local primaryPartCFrame = self.instance:GetPrimaryPartCFrame()
		local rotationCFrame = primaryPartCFrame - primaryPartCFrame.Position
		local instance = self.instance
		local currentTime = os.clock() + phaseOffset
		local bobHeight = math.sin(currentTime) * 0.5
		instance:SetPrimaryPartCFrame((baseCFrame + Vector3.new(0, bobHeight, 0)) * rotationCFrame)
	end))
end

Reflect.defineMetadata(GeneratorComponent, "identifier", "Z63")
Reflect.defineMetadata(GeneratorComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(GeneratorComponent, "$c:components@Component", Component, {
	{
		["tag"] = "generator",
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["GeneratorComponent"] = GeneratorComponent,
}
