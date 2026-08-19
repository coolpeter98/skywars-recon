-- SeasonPassSidebar

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local SidebarGrid = RuntimeLib.import(script, script.Parent, "sidebar-grid").SidebarGrid
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CurrentSeasonNumber =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").CurrentSeasonNumber
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local SeasonUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local SeasonPassProgressBar =
	RuntimeLib.import(script, script.Parent.Parent, "components", "season-pass-progress-bar").SeasonPassProgressBar
local useSeasonData = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-season-data").useSeasonData
local SeasonPassScreen =
	RuntimeLib.import(script, script.Parent.Parent, "season-pass", "season-pass-screen").SeasonPassScreen

type SeasonPassSidebarProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["SeasonPassSidebar"] = function(props: SeasonPassSidebarProps)
		local seasonData: { Experience: number } = useSeasonData()
		local titleProps = getTextProps({
			["Text"] = "SEASON",
			["TextSize"] = 20,
			["Bold"] = true,
		})
		local seasonNumberProps = getTextProps({
			["Text"] = tostring(CurrentSeasonNumber),
			["TextSize"] = 36,
			["Bold"] = true,
		})
		local progress: number = SeasonUtil.getProgress(seasonData.Experience)
		local tier: number = SeasonUtil.getTier(seasonData.Experience) + 1
		local tierText = ("<font face='GothamBlack' size='20' color='#FFF'>TIER %*</font>"):format(tier + 1)
		local spText = ("(%*/%* SP)"):format(
			("<font face='GothamBlack' size=\"16\" color='#36E270'>%*</font>"):format(progress),
			(
				("<font face='GothamBlack' size=\"16\" color='#36E270'>%*</font>"):format(
					SeasonUtil.getExperience(tier) - SeasonUtil.getExperience(tier - 1)
				)
			)
		)
		local seasonPassImage = React.createElement(Image, {
			["Size"] = UDim2.fromOffset(77, 70),
			["Image"] = RobloxImage.SEASON_PASS,
		})
		local titleTextProps = table.clone(titleProps)
		setmetatable(titleTextProps, nil)
		local seasonTitleElement = React.createElement(Text, titleTextProps)
		local seasonNumberTextProps = table.clone(seasonNumberProps)
		setmetatable(seasonNumberTextProps, nil)
		return React.createElement(
			SidebarGrid,
			{
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(222, 212),
			},
			React.createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, 10),
					["Size"] = UDim2.fromOffset(175, 70),
				},
				seasonPassImage,
				React.createElement(
					Grid,
					{
						["Size"] = UDim2.fromOffset(
							titleProps.Size.X.Offset,
							titleProps.Size.Y.Offset + seasonNumberProps.Size.Y.Offset
						),
					},
					seasonTitleElement,
					React.createElement(Text, seasonNumberTextProps),
					React.createElement(List, {
						["Vertical"] = true,
						["Padding"] = nil,
						["Padding"] = UDim.new(),
					})
				),
				React.createElement(List)
			),
			React.createElement(SeasonPassProgressBar, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 92),
				["Size"] = UDim2.fromOffset(182, 12),
			}),
			React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["Bold"] = true,
				["RichText"] = true,
				["TextSize"] = 16,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 110),
				["Text"] = ("%* %*"):format(tierText, spText),
			}),
			React.createElement(Button, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = "View",
				["Activated"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -20),
				["Size"] = { 182, 50 },
				["Activated"] = function()
					return Flamework.resolveDependency("lB5"):toggle(SeasonPassScreen)
				end,
			})
		)
	end,
}
