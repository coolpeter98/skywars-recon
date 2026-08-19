-- HealthBarScreen

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
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local HealthBarGui = RuntimeLib.import(script, script.Parent, "health-bar-gui").HealthBarGui
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

export type HealthBarScreen = typeof(HealthBarScreen)

local HealthBarScreen = setmetatable({}, {
	["__tostring"] = function()
		return "HealthBarScreen"
	end,
	["__index"] = Screen,
})
HealthBarScreen.__index = HealthBarScreen

function HealthBarScreen.new(...)
	local self = setmetatable({}, HealthBarScreen)
	return self:constructor(...) or self
end

function HealthBarScreen.constructor(self, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local healthController = Flamework.resolveDependency("51k")
		local health, setHealth = useState(healthController:getHealth())
		local shield, setShield = useState(healthController:getShield())
		useEffect(function()
			local maid = Maid.new()
			maid:GiveTask(healthController.HealthChanged:bind(function(event)
				local healthValue = event.health
				setHealth((math.ceil(healthValue)))
			end))
			maid:GiveTask(healthController.ShieldChanged:bind(function(event)
				setShield(event.shield)
			end))
			return function()
				return maid:DoCleaning()
			end
		end, {})
		return React.createElement(HealthBarGui, {
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(0.5, 0, 1, -128),
			["Health"] = health,
			["Shield"] = shield,
		})
	end
end

Reflect.defineMetadata(HealthBarScreen, "identifier", "K80")
Reflect.decorate(HealthBarScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "HealthBar",
	},
})

return {
	["HealthBarScreen"] = HealthBarScreen,
}
