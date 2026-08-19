-- PartyLeader

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "components", "player-icon").PlayerIcon
local useLevel = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-level").useLevel
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local TextService: TextService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TextService
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Badge = RuntimeLib.import(script, script.Parent.Parent, "components", "badge").Badge
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local PlayerName = RuntimeLib.import(script, script.Parent.Parent, "components", "player-name").PlayerName

type PartyLeaderProps = {
	Player: Player,
	IsFriend: boolean?,
}

return {
	["PartyLeader"] = function(props: PartyLeaderProps)
		usePlayers()
		local level = useLevel(props.Player)
		local levelColour = ColorUtil.getLevelColour(level)
		local displayNameSize =
			TextService:GetTextSize(props.Player.DisplayName, 24, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
		local createElement = React.createElement
		local grid = Grid
		local leaderProps = {
			["key"] = "Leader",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Size"] = UDim2.fromOffset(260, 120),
		}
		local playerIconElement = createElement(
			PlayerIcon,
			{
				["key"] = "PlayerIcon",
				["Position"] = nil,
				["Size"] = nil,
				["UserId"] = nil,
				["BackgroundColor3"] = nil,
				["BackgroundTransparency"] = 0,
				["CornerRadius"] = nil,
				["Position"] = UDim2.fromOffset(20, 20),
				["Size"] = UDim2.fromOffset(80, 80),
				["UserId"] = props.Player.UserId,
				["BackgroundColor3"] = levelColour,
				["CornerRadius"] = UDim.new(1),
			},
			createElement(Image, {
				["key"] = "Crown",
				["Size"] = nil,
				["Image"] = nil,
				["ImageColor3"] = nil,
				["ZIndex"] = 2,
				["Size"] = UDim2.fromOffset(28, 22),
				["Image"] = RobloxImage.Icon.CROWN,
				["ImageColor3"] = Color.Yellow,
			})
		)
		local playerNameElement = createElement(PlayerName, {
			["Position"] = UDim2.fromOffset(110, 20),
			["Player"] = props.Player,
		})
		local friendIconElement
		if props.IsFriend then
			friendIconElement = createElement(Image, {
				["key"] = "Friend",
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ImageColor3"] = nil,
				["Position"] = UDim2.fromOffset(110 + displayNameSize.X + 6, 38),
				["Size"] = UDim2.fromOffset(20, 20),
				["Image"] = RobloxImage.Icon.PEOPLE,
				["ImageColor3"] = Color.Green,
			})
		else
			friendIconElement = nil
		end
		return createElement(
			grid,
			leaderProps,
			playerIconElement,
			playerNameElement,
			friendIconElement,
			createElement(Badge, {
				["key"] = "Badge",
				["Position"] = nil,
				["Text"] = "LEADER",
				["Color"] = nil,
				["Position"] = UDim2.fromOffset(110, 80),
				["Color"] = Color.Yellow,
			}),
			createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
