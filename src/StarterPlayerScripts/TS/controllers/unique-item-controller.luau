-- UniqueItemController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller

type UniqueItemController = {}

local UniqueItemController: UniqueItemController = setmetatable({}, {
	["__tostring"] = function()
		return "UniqueItemController"
	end,
})

UniqueItemController.__index = UniqueItemController

function UniqueItemController.new(...): UniqueItemController
	local self = setmetatable({}, UniqueItemController)
	return self:constructor(...) or self
end

function UniqueItemController.constructor(self: UniqueItemController)
end

function UniqueItemController.onStart(self: UniqueItemController)
end

Reflect.defineMetadata(UniqueItemController, "identifier", "QAM")
Reflect.defineMetadata(UniqueItemController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(UniqueItemController, "$:flamework@Controller", Controller, {})

return {
	["UniqueItemController"] = UniqueItemController,
}
