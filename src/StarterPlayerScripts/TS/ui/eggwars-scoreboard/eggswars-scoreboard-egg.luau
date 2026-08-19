-- EggwarsScoreboardEgg

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local ProgressBarNew =
	RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type EggwarsScoreboardEggProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	NearbyEgg: {
		TeamColor: Color3,
		TeamName: string,
		Health: number,
	},
}

return {
	["EggwarsScoreboardEgg"] = function(props: EggwarsScoreboardEggProps)
		local gridProps = {
			["key"] = "ScoreboardEgg",
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(438, 90),
			["BackgroundTransparency"] = 0.6,
		}
		local eggBackgroundProps = {
			["key"] = "EggBackground",
			["Position"] = UDim2.fromOffset(10, 10),
			["Size"] = UDim2.fromOffset(70, 70),
			["BackgroundColor3"] = props.NearbyEgg.TeamColor,
		}
		local eggImageProps = {
			["key"] = "EggImage",
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(45, 56),
		}
		local eggImage
		if props.NearbyEgg.Health > 0 then
			eggImage = RobloxImage.EGG_GREYSCALE
		else
			eggImage = RobloxImage.EGG_GREYSCALE
		end
		eggImageProps.Image = eggImage
		return React.createElement(
			Grid,
			gridProps,
			React.createElement(
				Grid,
				eggBackgroundProps,
				React.createElement(Image, eggImageProps),
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1),
				})
			),
			React.createElement(Text, {
				["key"] = "Text",
				["Position"] = UDim2.fromOffset(90, 12),
				["Size"] = UDim2.fromOffset(338, 33),
				["Text"] = ("%*'s Egg"):format(props.NearbyEgg.TeamName),
				["Bold"] = true,
				["TextXAlignment"] = Enum.TextXAlignment.Center,
			}),
			React.createElement(ProgressBarNew, {
				["key"] = "HealthBar",
				["Position"] = UDim2.fromOffset(90, 55),
				["Size"] = UDim2.fromOffset(338, 15),
				["Progress"] = props.NearbyEgg.Health / HealthConstants.EGG_DEFAULT_HEALTH,
				["Colors"] = {
					Color.HealthGreen,
					Color.Yellow,
					Color.HealthOrange,
					Color.HealthRed,
				},
				["Outline"] = 0,
			}),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
