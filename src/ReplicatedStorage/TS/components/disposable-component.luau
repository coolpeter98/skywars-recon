-- DisposableComponent

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BaseComponent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "components", "out").BaseComponent
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")

type DisposableComponent = { maid: typeof(Maid.new()) }

local DisposableComponent = setmetatable({}, {
	["__tostring"] = function()
		return "DisposableComponent"
	end,
	["__index"] = BaseComponent,
})
DisposableComponent.__index = DisposableComponent

function DisposableComponent.new(...)
	local selfClass = DisposableComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function DisposableComponent.constructor(self: DisposableComponent, ...)
	BaseComponent.constructor(self, ...)
	self.maid = Maid.new()
end

function DisposableComponent.destroy(self: DisposableComponent)
	self.maid:Destroy()
	BaseComponent.destroy(self)
end

return {
	["DisposableComponent"] = DisposableComponent,
}
