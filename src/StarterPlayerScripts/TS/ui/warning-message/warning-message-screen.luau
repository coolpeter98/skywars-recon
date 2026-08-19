-- WarningMessageScreen

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Card = RuntimeLib.import(script, script.Parent.Parent, "components", "card").Card
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen

local WarningMessageScreen = setmetatable({}, {
	["__tostring"] = function()
		return "WarningMessageScreen"
	end,
	["__index"] = Screen,
})
WarningMessageScreen.__index = WarningMessageScreen

type WarningMessageScreen = typeof(WarningMessageScreen) & {
	Component: (props: any) -> any,
}

function WarningMessageScreen.new(...)
	local class = WarningMessageScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function WarningMessageScreen.constructor(self: WarningMessageScreen, ...)
	Screen.constructor(self, ...)
	function self.Component(props)
		return React.createElement(Card, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.new(0.5, 0, 0.5, -100),
			["Text"] = props.Text,
			["Image"] = RobloxImage.Icon.WARNING_SIGN,
			["ImageColor"] = Color.Red,
		})
	end
end

Reflect.defineMetadata(WarningMessageScreen, "identifier", "M4o")
Reflect.decorate(WarningMessageScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "WarningMessage",
	},
})

return {
	["WarningMessageScreen"] = WarningMessageScreen,
}
