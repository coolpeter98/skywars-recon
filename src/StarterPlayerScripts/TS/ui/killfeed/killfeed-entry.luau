-- KillfeedEntry

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local TextService: TextService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TextService
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "components", "player-icon").PlayerIcon
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local KillfeedEntityType = RuntimeLib.import(script, script.Parent, "killfeed-entity").KillfeedEntityType
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type PlayerData = {
	DisplayName: string,
	UserId: number,
}

type KillfeedEntity = {
	Type: string,
	Name: string,
	Player: PlayerData?,
	Color: Color3?,
	Icon: string?,
}

type KillfeedEntryProps = {
	KillfeedEntity: KillfeedEntity,
	AnchorPoint: Vector2,
	Position: UDim2,
	LayoutOrder: number,
}

return {
	["KillfeedEntry"] = function(props: KillfeedEntryProps)
		local entity = props.KillfeedEntity
		local name
		if entity.Type == KillfeedEntityType.Player then
			name = entity.Player.DisplayName
		else
			name = entity.Name
		end
		local textSize = TextService:GetTextSize(name, 20, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
		local color = entity.Color or Color.White
		local hue, saturation, _ = color:ToHSV()
		local backgroundColor = Color3.fromHSV(hue, saturation * 0.7, 1)
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["key"] = name,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(34 + textSize.X, 28),
			["LayoutOrder"] = props.LayoutOrder,
		}
		local iconElement
		if entity.Type == KillfeedEntityType.Player then
			iconElement = React.createElement(PlayerIcon, {
				["Size"] = nil,
				["UserId"] = nil,
				["CornerRadius"] = nil,
				["BackgroundColor3"] = nil,
				["BackgroundTransparency"] = 0,
				["Size"] = UDim2.fromOffset(28, 28),
				["UserId"] = entity.Player.UserId,
				["CornerRadius"] = UDim.new(1),
				["BackgroundColor3"] = backgroundColor,
			})
		else
			iconElement = React.createElement(
				Image,
				{
					["Image"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["BackgroundTransparency"] = 0,
					["Image"] = entity.Icon,
					["Size"] = UDim2.fromOffset(28, 28),
					["BackgroundColor3"] = backgroundColor,
				},
				React.createElement(CornerRadius, {
					["Radius"] = 10,
				})
			)
		end
		return createElement(
			grid,
			gridProps,
			iconElement,
			React.createElement(Text, {
				["key"] = "PlayerName",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = nil,
				["TextSize"] = 20,
				["TextColor3"] = nil,
				["Bold"] = true,
				["AutoLocalize"] = false,
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.fromScale(1, 0.5),
				["Size"] = UDim2.fromOffset(textSize.X, textSize.Y),
				["Text"] = name,
				["TextColor3"] = color,
			})
		)
	end,
}
