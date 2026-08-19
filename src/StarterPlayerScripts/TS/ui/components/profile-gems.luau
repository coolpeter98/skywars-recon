-- ProfileGems

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Button = RuntimeLib.import(script, script.Parent, "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local GEM_ICON_SIZE = Size.new(60, 60)
local PLUS_BUTTON_SIZE = Size.new(50, 50)

export type ProfileGemsProps = {
	Gems: number,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["ProfileGems"] = function(props: ProfileGemsProps)
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Text"] = StringUtil.formatNumber(props.Gems),
		})

		local gemIcon = React.createElement(
			Image,
			{
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Image"] = nil,
				["Size"] = nil,
				["ZIndex"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0, 0.5),
				["Image"] = RobloxImage.Icon.GEM_GREEN_OUTLINE_256,
				["Size"] = GEM_ICON_SIZE:ToUDim2(),
			},
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(0, 20),
			})
		)

		local textElementProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		for key, value in textProps do
			textElementProps[key] = value
		end

		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(
					GEM_ICON_SIZE.X / 2 + 10 + textProps.Size.X.Offset + 20 + PLUS_BUTTON_SIZE.X / 2,
					40
				),
			},
			gemIcon,
			React.createElement(Text, textElementProps),
			React.createElement(Button, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Icon"] = nil,
				["Color"] = nil,
				["Activated"] = nil,
				["ZIndex"] = 20,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(1, 0.5),
				["Size"] = { PLUS_BUTTON_SIZE.X, PLUS_BUTTON_SIZE.Y },
				["Icon"] = RobloxImage.Icon.PLUS,
				["Color"] = Color.Button.Green,
				["Activated"] = function()
					return Flamework.resolveDependency("vbD"):openShop({
						["ProductType"] = "Gems",
						["ProductId"] = nil,
						["ProductId"] = ProductId.GEMS_TIER_3,
					})
				end,
			})
		)
	end,
}
