-- CapeComponent

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local t = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out", "prelude").t
local Component = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "components", "out").Component
local CapeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "cape-util").CapeUtil
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local DisposableComponent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "components", "disposable-component").DisposableComponent

type CapeComponent = {
	rotation: number,
	attachmentOffset: CFrame?,
	instance: Model,
	maid: { GiveTask: (self: any, ...any) -> any },
}

local CapeComponent = setmetatable({}, {
	["__tostring"] = function()
		return "CapeComponent"
	end,
	["__index"] = DisposableComponent,
})
CapeComponent.__index = CapeComponent

function CapeComponent.new(...)
	local selfClass = CapeComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function CapeComponent.constructor(self: CapeComponent, ...)
	DisposableComponent.constructor(self, ...)
	self.rotation = 0
end

function CapeComponent.onStart(self: CapeComponent)
	local capeWeld: Weld? = self.instance:WaitForChild("Cape"):WaitForChild("CapeWeld", 10)
	if not capeWeld then
		return nil
	end
	self.attachmentOffset = capeWeld.C0
	self.maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
		local primaryPart: BasePart? = self.instance.PrimaryPart
		if not primaryPart then
			return nil
		end
		local humanoidRootPart = self.instance.Parent
		if humanoidRootPart ~= nil then
			humanoidRootPart = humanoidRootPart:FindFirstChild("HumanoidRootPart")
		end
		local capeWeld: Weld? = primaryPart:FindFirstChild("CapeWeld")
		if not (humanoidRootPart and capeWeld) then
			return nil
		end
		local upVelocity: number = humanoidRootPart.CFrame.UpVector:Dot(humanoidRootPart.AssemblyLinearVelocity)
		local lookVelocity: number = humanoidRootPart.CFrame.LookVector:Dot(humanoidRootPart.AssemblyLinearVelocity)
		self.rotation = CapeUtil.calculateCapeRotation(self.rotation, upVelocity, lookVelocity, deltaTime)
		CapeUtil.setCapeRotation(primaryPart, capeWeld, self.attachmentOffset, self.rotation)
	end))
end

Reflect.defineMetadata(CapeComponent, "identifier", "bDx")
Reflect.defineMetadata(CapeComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CapeComponent, "$c:components@Component", Component, {
	{
		["tag"] = "character:cape",
		["ancestorBlacklist"] = nil,
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["ancestorBlacklist"] = {},
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	}
})

return {
	["CapeComponent"] = CapeComponent,
}
