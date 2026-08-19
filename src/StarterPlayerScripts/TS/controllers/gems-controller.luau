-- GemsController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil

type GemsController = {}

local GemsController: GemsController = setmetatable({}, {
	["__tostring"] = function()
		return "GemsController"
	end,
})

GemsController.__index = GemsController

function GemsController.new(...): GemsController
	local self = setmetatable({}, GemsController)
	return self:constructor(...) or self
end

function GemsController.constructor(self: GemsController)
end

function GemsController.hasEnoughGems(self: GemsController, amount: number): boolean
	if MathUtil.isWholeNumber(amount) then
		return amount <= GlobalStore:getState().Profile.Gems
	else
		return false
	end
end

Reflect.defineMetadata(GemsController, "identifier", "Eq8")
Reflect.decorate(GemsController, "$:flamework@Controller", Controller, {})

return {
	["GemsController"] = GemsController,
}
