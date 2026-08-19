-- CrateRewardsScreen

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local CrateRewardsGui = RuntimeLib.import(script, script.Parent, "crate-rewards-gui").CrateRewardsGui
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type CrateRewardsScreenProps = {
	CrateRewardResults: { any },
}

type CrateRewardsScreen = {
	Component: (props: CrateRewardsScreenProps) -> any,
}

local CrateRewardsScreen = setmetatable({}, {
	["__tostring"] = function()
		return "CrateRewardsScreen"
	end,
	["__index"] = Screen,
})

CrateRewardsScreen.__index = CrateRewardsScreen

function CrateRewardsScreen.new(...)
	local self = setmetatable({}, CrateRewardsScreen)
	return self:constructor(...) or self
end

function CrateRewardsScreen.constructor(self, ...)
	Screen.constructor(self, ...)

	function self.Component(props)
		return React.createElement(CrateRewardsGui, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["CrateRewardResults"] = props.CrateRewardResults,
		})
	end
end

Reflect.defineMetadata(CrateRewardsScreen, "identifier", "7PZ")
Reflect.decorate(CrateRewardsScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "CrateRewards",
		["DisableHealthBar"] = true,
	},
})

return {
	["CrateRewardsScreen"] = CrateRewardsScreen,
}
