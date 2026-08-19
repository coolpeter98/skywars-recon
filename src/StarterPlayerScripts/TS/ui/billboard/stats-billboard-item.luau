-- StatsBillboardItem

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local useStats = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-stats").useStats
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local GradientCard = RuntimeLib.import(script, script.Parent.Parent, "components", "gradient-card").GradientCard
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type StatsBillboardItemProps = {
	GameType: string,
	Statistic: string,
	Color: Color3,
	LayoutOrder: number,
	Icon: string,
}

return {
	["StatsBillboardItem"] = function(props: StatsBillboardItemProps)
		local stats = useStats(props.GameType, props.Statistic)

		return React.createElement(
			GradientCard,
			{
				["key"] = nil,
				["Size"] = nil,
				["Color"] = nil,
				["StrokeThickness"] = 12,
				["ScalingDisabled"] = true,
				["FooterHeight"] = 330,
				["LayoutOrder"] = nil,
				["FooterComponent"] = nil,
				["key"] = ("Stats_%*"):format(props.Statistic),
				["Size"] = Size.new(402, 820),
				["Color"] = props.Color,
				["LayoutOrder"] = props.LayoutOrder,
				["FooterComponent"] = React.createElement(
					React.Fragment,
					nil,
					React.createElement(Text, {
						["key"] = "WinsValue",
						["AnchorPoint"] = nil,
						["Position"] = nil,
						["Text"] = nil,
						["TextSize"] = 96,
						["Bold"] = true,
						["ZIndex"] = 5,
						["AnchorPoint"] = Vector2.new(0.5, 0),
						["Position"] = UDim2.new(0.5, 0, 0, 80),
						["Text"] = StringUtil.formatNumber(stats),
					}),
					React.createElement(Text, {
						["key"] = "WinsText",
						["AnchorPoint"] = nil,
						["Position"] = nil,
						["Text"] = nil,
						["TextSize"] = 48,
						["TextColor3"] = nil,
						["Bold"] = true,
						["ZIndex"] = 5,
						["AnchorPoint"] = Vector2.new(0.5, 0),
						["Position"] = UDim2.new(0.5, 0, 0, 197),
						["Text"] = string.upper(props.Statistic),
						["TextColor3"] = Color.White,
					})
				),
			},
			React.createElement(Image, {
				["key"] = "PlayerIcon",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ZIndex"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 110),
				["Size"] = UDim2.fromOffset(256, 256),
				["Image"] = props.Icon,
			})
		)
	end,
}
