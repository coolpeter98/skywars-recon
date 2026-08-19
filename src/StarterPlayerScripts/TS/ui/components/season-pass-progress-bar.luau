-- SeasonPassProgressBar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local SeasonUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local useSeasonData = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-season-data").useSeasonData
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type SeasonPassProgressBarProps = {
	Tier: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

local function SeasonPassProgressBar(props: SeasonPassProgressBarProps)
	local seasonData = useSeasonData()
	local currentTier: number = SeasonUtil.getTier(seasonData.Experience)
	local tier = props.Tier
	if tier == nil then
		tier = currentTier + 1
	end
	local isNextTier: boolean = tier == currentTier + 1
	local isUnlocked: boolean = tier <= currentTier
	local fillScale: number
	if isNextTier then
		fillScale = SeasonUtil.getProgressDecimal(seasonData.Experience)
	else
		fillScale = isUnlocked and 1 or 0
	end
	return React.createElement(
		Grid,
		{
			["key"] = "ProgressBar",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
		},
		React.createElement(Grid, {
			["key"] = "ProgressBarFilled",
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["Size"] = UDim2.fromScale(fillScale, 1),
			["BackgroundColor3"] = Color.Green,
		})
	)
end

return {
	["SeasonPassProgressBar"] = SeasonPassProgressBar,
}
