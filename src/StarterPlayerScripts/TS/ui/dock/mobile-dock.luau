-- MobileDock

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["MobileDock"] = function(props)
		return React.createElement(Grid, {
			["key"] = "MobileDock",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AnchorPoint"] = props.AnchorPoint or Vector2.new(0, 0.5),
			["Position"] = props.Position or UDim2.new(0, -20, 0.5, -60),
			["Size"] = UDim2.fromOffset(242, Flamework.resolveDependency("0dL"):isVerified() and 405 or 485)
		}, props.children, React.createElement(CornerRadius, {
			["Radius"] = 20
		}), React.createElement("uigradient", {
			["Rotation"] = 270,
			["Transparency"] = nil,
			["Transparency"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.95) })
		}))
	end
}
