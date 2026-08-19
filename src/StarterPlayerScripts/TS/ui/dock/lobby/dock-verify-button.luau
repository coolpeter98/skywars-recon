-- DockVerifyButton

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework: Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local React: React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type DockVerifyButtonProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	MobileLayout: boolean,
}

return {
	["DockVerifyButton"] = function(props: DockVerifyButtonProps)
		return React.createElement(Button, {
			["key"] = "Verify",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "VERIFY",
			["Icon"] = nil,
			["Color"] = nil,
			["Activated"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = { "auto", props.MobileLayout and 60 or 80 },
			["Icon"] = RobloxImage.Icon.VERIFIED,
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				return Flamework.resolveDependency("0dL"):toggleScreen()
			end
		})
	end
}
