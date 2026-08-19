-- EggwarsTeamGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local TextImage = RuntimeLib.import(script, script.Parent.Parent, "components", "text-image").TextImage
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local EggCharacters = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"egg-character",
	"egg-character"
).EggCharacters
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type EggwarsTeamGuiProps = {
	NearbyEgg: { TeamId: number }?,
	TeamId: number,
	TeamName: string,
	AnchorPoint: Vector2,
	Position: UDim2,
	AliveCount: number,
	Color: Color3,
	HasEgg: boolean,
}

return {
	["EggwarsTeamGui"] = function(props: EggwarsTeamGuiProps)
		local isNearbyEggSameTeam
		if props.NearbyEgg == nil then
			isNearbyEggSameTeam = false
		else
			isNearbyEggSameTeam = props.NearbyEgg.TeamId == props.TeamId
		end
		local eggCharacter = EggCharacters[props.TeamId]
		local createElement = React.createElement
		local Grid = Grid
		local gridProps = {
			["key"] = ("EggwarsTeam%*"):format(props.TeamName),
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(100, 50),
		}
		local createElement = React.createElement
		local Grid = Grid
		local barProps = {
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.fromScale(1, 0.25),
			["Size"] = UDim2.fromOffset(86, isNearbyEggSameTeam and 64 or 32),
		}
		local barColor
		if props.AliveCount > 0 then
			barColor = props.Color
		else
			barColor = Color.Grey
		end
		barProps.BackgroundColor3 = barColor
		local teamBarElement = createElement(
			Grid,
			barProps,
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local createElement = React.createElement
		local Grid = Grid
		local eggRowProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 1,
			["AnchorPoint"] = Vector2.new(1, 0),
			["Position"] = UDim2.fromScale(1, 0.25),
			["Size"] = UDim2.fromOffset(86, 32),
		}
		local createElement = React.createElement
		local Image = Image
		local eggImageProps = {
			["key"] = "EggImage",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ScaleType"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, -48, 0.1, 0),
			["Size"] = UDim2.fromOffset(90, 90),
		}
		local eggImageId
		if props.HasEgg then
			if eggCharacter then
				eggImageId = eggCharacter.IconId
			else
				eggImageId = RobloxImage.Egg.RED
			end
		elseif eggCharacter then
			eggImageId = eggCharacter.IconDeadId
		else
			eggImageId = RobloxImage.EggDead.RED
		end
		eggImageProps.Image = eggImageId
		eggImageProps.ScaleType = Enum.ScaleType.Crop
		local eggImageElement = createElement(Image, eggImageProps)
		local createElement = React.createElement
		local TextImage = TextImage
		local aliveTextProps = {
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -6, 0.5, 0),
			["Image"] = RobloxImage.Icon.PEOPLE,
		}
		local aliveCount = props.AliveCount
		aliveTextProps.Text = tostring(aliveCount)
		return createElement(
			Grid,
			gridProps,
			teamBarElement,
			createElement(Grid, eggRowProps, eggImageElement, createElement(TextImage, aliveTextProps))
		)
	end,
}
