-- Spectating

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "player-icon").PlayerIcon
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local TextImage = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text-image").TextImage
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type SpectatingProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	AutomaticSize: EnumItem?,
	UserId: number?,
	Color: Color3?,
	DisplayName: string?,
}

return {
	["Spectating"] = function(props: SpectatingProps)
		return React.createElement(
			Grid,
			{
				["key"] = "Spectating",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["AutomaticSize"] = nil,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			React.createElement(PlayerIcon, {
				["key"] = "PlayerIcon",
				["Size"] = nil,
				["UserId"] = nil,
				["BackgroundColor3"] = nil,
				["BackgroundTransparency"] = 0,
				["CornerRadius"] = nil,
				["Size"] = UDim2.fromOffset(80, 80),
				["UserId"] = props.UserId,
				["BackgroundColor3"] = props.Color,
				["CornerRadius"] = UDim.new(1),
			}),
			React.createElement(
				Grid,
				{
					["key"] = "Text",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["AutomaticSize"] = nil,
					["AnchorPoint"] = Vector2.new(0, 0.5),
					["Position"] = UDim2.new(0, 100, 0.5, 0),
					["AutomaticSize"] = Enum.AutomaticSize.XY,
				},
				React.createElement(Text, {
					["key"] = "SpectatingText",
					["Text"] = "You are now spectating",
					["TextSize"] = 16,
					["TextColor3"] = nil,
					["Bold"] = true,
					["FixSize"] = true,
					["TextColor3"] = Color.LightGrey,
				}),
				React.createElement(Text, {
					["key"] = "PlayerText",
					["Text"] = nil,
					["TextSize"] = 24,
					["TextColor3"] = nil,
					["Bold"] = true,
					["FixSize"] = true,
					["Text"] = props.DisplayName,
					["TextColor3"] = Color.White,
				}),
				React.createElement(TextImage, {
					["key"] = "ClickText",
					["Image"] = nil,
					["ImageSize"] = 20,
					["Text"] = "Click to spectate next player",
					["TextSize"] = 16,
					["TextColor"] = nil,
					["Padding"] = 6,
					["Image"] = RobloxImage.Icon.COMPUTER_MOUSE,
					["TextColor"] = Color.White,
				}),
				React.createElement(List, {
					["Vertical"] = true,
					["Padding"] = nil,
					["HorizontalAlignment"] = nil,
					["Padding"] = UDim.new(0, 6),
					["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
				})
			)
		)
	end,
}
