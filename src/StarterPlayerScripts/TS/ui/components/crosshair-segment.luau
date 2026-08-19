-- CrosshairSegment

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
return {
	["CrosshairSegment"] = function(props)
		return React.createElement(
			Grid,
			{
				["Position"] = props.Position,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Size"] = UDim2.fromScale(0.01, 0.01),
				["Rotation"] = props.Rotation,
			},
			React.createElement(Image, {
				["Name"] = props.Name,
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Size"] = props.Size,
				["Image"] = RobloxImage.Crosshair.TRI,
				["ImageTransparency"] = props.Transparency,
				["ScaleType"] = Enum.ScaleType.Stretch,
			})
		)
	end,
}
