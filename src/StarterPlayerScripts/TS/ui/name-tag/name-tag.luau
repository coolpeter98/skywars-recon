-- NameTag

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
local HealthBarUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "health-bar-util").HealthBarUtil
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local TextService: TextService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TextService
local PartyUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local globalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local useParty = globalStore.useParty
local useTeams = globalStore.useTeams
local Ranks = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "ranks").Ranks
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "components", "player-icon").PlayerIcon
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local Emoji = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "emoji").Emoji
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local useFocused = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-focused").useFocused
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useAttribute = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-attribute").useAttribute
local getNameTagHealthSize: ((healthPercent: number) -> UDim2)?

type NameTagProps = {
	Player: Player,
	Character: Model?,
	Dummy: boolean?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	IsBillboardGuiDescendant: boolean?,
}

local function NameTag(props: NameTagProps)
	local healthBarRef = useRef()
	local billboardGuiRef = useRef()
	useFocused(function(focused: boolean)
		if billboardGuiRef.current then
			billboardGuiRef.current.Enabled = not focused
		end
	end)
	local party = useParty()
	local teams = useTeams()
	local teamId = useAttribute(props.Player, Attribute.TeamId)
	local team: Team? = useMemo(function()
		if teamId == nil then
			return nil
		else
			return teams[teamId]
		end
	end, { teams, teamId })
	local rank = useAttribute(props.Player, Attribute.Rank)
	local title = useAttribute(props.Player, Attribute.Title)
	local dummyTitle = useAttribute(props.Character, Attribute.DummyTitle)
	local level = useAttribute(props.Player, Attribute.Level)
	local winsValue = useAttribute(props.Player, Attribute.Wins)
	local wins = winsValue == nil and 0 or winsValue
	local killsValue = useAttribute(props.Player, Attribute.Kills)
	local kills = killsValue == nil and 0 or killsValue
	local winStreakValue = useAttribute(props.Player, Attribute.WinStreak)
	local winStreak = winStreakValue == nil and 0 or winStreakValue
	useEffect(function()
		if not healthBarRef.current then
			return nil
		end
		if not (PlaceUtil.isLobbyServer() or props.Dummy) then
			local healthBarConnection: RBXScriptConnection =
				HealthBarUtil.setupHealthBar(props.Player, healthBarRef.current, nil, nil, getNameTagHealthSize)
			return function()
				return healthBarConnection:Disconnect()
			end
		end
	end, { healthBarRef.current })
	local displayName: string = props.Player.DisplayName
	if not (party and PartyUtil.isInParty(PlayerUtil.toReplicated(props.Player), party)) and team then
		local _ = team == Flamework.resolveDependency("x5"):getPlayerTeam()
	end
	local displayNameSize: Vector2 = TextService:GetTextSize(
		displayName,
		24,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	) * 1.05
	if rank then
		rank = Ranks[rank]
	end
	local rankTextSize
	if rank then
		rankTextSize = TextService:GetTextSize(
			string.upper(rank.Name),
			16,
			Enum.Font.GothamBlack,
			Vector2.new(1920, 1080)
		) * 1.05
	else
		rankTextSize = rank
	end
	if dummyTitle then
		title = Cosmetics[dummyTitle]
	elseif title then
		title = Cosmetics[title]
	end
	local titleTextSize
	if title then
		titleTextSize = TextService:GetTextSize(
			string.upper(title.Title),
			16,
			Enum.Font.GothamBlack,
			Vector2.new(1920, 1080)
		) * 1.05
	else
		titleTextSize = title
	end
	local displayNameWidth: number = displayNameSize.X
	local titleWidth
	if titleTextSize == nil then
		titleWidth = titleTextSize
	else
		titleWidth = titleTextSize.X
	end
	if titleWidth == nil then
		local rankWidth
		if rankTextSize == nil then
			rankWidth = rankTextSize
		else
			rankWidth = rankTextSize.X
		end
		titleWidth = rankWidth == nil and 0 or rankWidth
	end
	local maxWidth: number = math.max(displayNameWidth, titleWidth)
	local totalWidth: number = maxWidth + 70 + 10 + 50 + 10
	local levelText = level == nil and "?" or level
	local levelTextSize = TextService:GetTextSize(
		tostring(levelText),
		16,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	) * 1.05
	local levelColor: Color3
	if level == nil then
		levelColor = Color.Level.TierOne
	else
		levelColor = ColorUtil.getLevelColour(level)
	end
	local trophySize: Vector2 = TextService:GetTextSize(
		("%* %*"):format(Emoji.Trophy, (StringUtil.formatNumber(wins))),
		20,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	) * 1.05
	local killsSize: Vector2 = TextService:GetTextSize(
		("%* %*"):format(Emoji.CrossedSwords, (StringUtil.formatNumber(kills))),
		20,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	) * 1.05
	local winStreakSize: Vector2 = TextService:GetTextSize(
		("%* %*"):format(Emoji.Flame, (StringUtil.formatNumber(winStreak))),
		20,
		Enum.Font.GothamBlack,
		Vector2.new(1920, 1080)
	) * 1.05
	local statsWidth: number = trophySize.X + killsSize.X + winStreakSize.X + 44
	local mainGridProps = {
		["BackgroundTransparency"] = 0.6,
		["Size"] = UDim2.fromScale(1, 0.666666667),
	}
	local teamColor: Color3?
	if team == nil then
		teamColor = team
	else
		teamColor = team.Color
	end
	local backgroundColor: Color3
	if teamColor == nil then
		backgroundColor = Color.Black
	else
		local h, s, v = team.Color:ToHSV()
		backgroundColor = Color3.fromHSV(h, s, v * 0.8)
	end
	mainGridProps.BackgroundColor3 = backgroundColor
	local playerIconElement = React.createElement(PlayerIcon, {
		["AnchorPoint"] = Vector2.new(0, 0.5),
		["Position"] = UDim2.fromScale(10 / totalWidth, 0.5),
		["Size"] = UDim2.fromScale(50 / totalWidth, 0.7142857142857143),
		["UserId"] = props.Player.UserId,
		["CornerRadius"] = UDim.new(0.14285714285714285),
	})
	local rankTitleLabel
	if title or rank then
		local labelProps = {
			["TextSize"] = 14,
			["TextScaled"] = true,
			["TextTransparency"] = 0,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["LayoutOrder"] = 1,
		}
		local labelWidth
		if title then
			labelWidth = titleTextSize.X
		else
			labelWidth = rankTextSize.X
		end
		local labelWidthScale = labelWidth / maxWidth
		local labelHeight
		if title then
			labelHeight = titleTextSize.Y
		else
			labelHeight = rankTextSize.Y
		end
		labelProps.Size = UDim2.fromScale(labelWidthScale, labelHeight / 70)
		labelProps.Font = Enum.Font.GothamBlack
		local labelColor
		if title then
			labelColor = title.Color
		else
			labelColor = rank.Color
		end
		labelProps.TextColor3 = labelColor
		local iconText
		if title then
			iconText = title.Icon == nil and "" or title.Icon .. "  "
		else
			iconText = rank.Icon .. "  "
		end
		local labelTitle
		if title then
			labelTitle = string.upper(title.Title)
		else
			labelTitle = string.upper(rank.Name)
		end
		labelProps.Text = ("%*%*"):format(iconText, labelTitle)
		rankTitleLabel = React.createElement("textlabel", labelProps)
	else
		rankTitleLabel = nil
	end
	local displayNameProps = {
		["AutoLocalize"] = false,
		["Size"] = UDim2.fromScale(displayNameSize.X / maxWidth, displayNameSize.Y / 70),
		["Font"] = Enum.Font.GothamBlack,
	}
	local displayNameColor
	if team == nil then
		displayNameColor = team
	else
		displayNameColor = team.Color
	end
	if displayNameColor == nil then
		displayNameColor = Color.White
	end
	displayNameProps.TextColor3 = displayNameColor
	displayNameProps.TextSize = 24
	displayNameProps.TextScaled = true
	displayNameProps.TextTransparency = 0
	displayNameProps.BackgroundTransparency = 1
	displayNameProps.BorderSizePixel = 0
	displayNameProps.Text = displayName
	displayNameProps.LayoutOrder = 2
	local playerInfoElement = React.createElement(
		Grid,
		{
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromScale(70 / totalWidth, 0.5),
			["Size"] = UDim2.fromScale(maxWidth / totalWidth, 1),
		},
		rankTitleLabel,
		React.createElement("textlabel", displayNameProps),
		React.createElement(List, {
			["Vertical"] = true,
			["Padding"] = UDim.new(),
		})
	)
	local levelProps = {
		["TextSize"] = 16,
		["TextScaled"] = true,
		["TextTransparency"] = 0,
		["BackgroundTransparency"] = 1,
		["BorderSizePixel"] = 0,
		["AnchorPoint"] = Vector2.new(0.5, 1),
		["Position"] = UDim2.fromScale(0.5, 0.92),
		["Size"] = UDim2.fromScale(levelTextSize.X / 46, levelTextSize.Y / 50),
		["Font"] = Enum.Font.GothamBlack,
		["TextColor3"] = Color.White,
	}
	local levelLabelText = level == nil and "?" or level
	levelProps.Text = tostring(levelLabelText)
	levelProps.ZIndex = 2
	local statsElement = React.createElement(
		Grid,
		mainGridProps,
		playerIconElement,
		playerInfoElement,
		React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.fromScale(1 - 10 / totalWidth, 0.5),
				["Size"] = UDim2.fromScale(46 / totalWidth, 0.7142857142857143),
			},
			React.createElement("textlabel", levelProps),
			React.createElement(Image, {
				["ZIndex"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.fromScale(0.5, 0.14),
				["Size"] = UDim2.fromScale(0.43478260869565216, 0.4),
				["Image"] = RobloxImage.Icon.CIRCLE_STAR,
			}),
			React.createElement(
				Grid,
				{
					["Size"] = UDim2.fromScale(1, 1),
					["BackgroundColor3"] = levelColor,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1),
				})
			),
			React.createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(0, 1),
					["Position"] = UDim2.fromScale(0, 1),
					["Size"] = UDim2.fromScale(1, 0.54),
					["BackgroundColor3"] = levelColor,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(0.14285714285714285),
				})
			)
		),
		React.createElement("uicorner", {
			["CornerRadius"] = UDim.new(0.14285714285714285, 0),
		})
	)
	local healthBarGridProps = {
		["BackgroundTransparency"] = 0.6,
		["Position"] = UDim2.fromScale(0.5, 0.8),
		["AnchorPoint"] = Vector2.new(0.5, 0),
	}
	local healthBarWidthScale: number
	if PlaceUtil.isLobbyServer() or props.Dummy then
		healthBarWidthScale = statsWidth / totalWidth
	else
		healthBarWidthScale = 300 / totalWidth
	end
	healthBarGridProps.Size = UDim2.fromScale(healthBarWidthScale, 0.3333333333333333)
	local healthBarColor: Color3?
	if team == nil then
		healthBarColor = team
	else
		healthBarColor = team.Color
	end
	local healthBarBackgroundColor: Color3
	if healthBarColor == nil then
		healthBarBackgroundColor = Color.Black
	else
		local h, s, v = team.Color:ToHSV()
		healthBarBackgroundColor = Color3.fromHSV(h, s, v * 0.8)
	end
	healthBarGridProps.BackgroundColor3 = healthBarBackgroundColor
	local rootProps = {
		["key"] = "NameTag",
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
	}
	local rootSize: UDim2
	if props.IsBillboardGuiDescendant then
		rootSize = UDim2.fromScale(1, 1)
	else
		rootSize = UDim2.fromOffset(totalWidth, 105)
	end
	rootProps.Size = rootSize
	local healthBarContent
	if PlaceUtil.isLobbyServer() or props.Dummy then
		healthBarContent = React.createElement(
			React.Fragment,
			nil,
			React.createElement("textlabel", {
				["TextSize"] = 20,
				["TextScaled"] = true,
				["TextTransparency"] = 0,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["LayoutOrder"] = 2,
				["Size"] = UDim2.fromScale(trophySize.X / statsWidth, trophySize.Y / 35),
				["Font"] = Enum.Font.GothamBlack,
				["TextColor3"] = Color.White,
				["Text"] = ("%* %*"):format(Emoji.Trophy, (StringUtil.formatNumber(wins))),
			}),
			React.createElement("textlabel", {
				["TextSize"] = 20,
				["TextScaled"] = true,
				["TextTransparency"] = 0,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["LayoutOrder"] = 2,
				["Size"] = UDim2.fromScale(killsSize.X / statsWidth, killsSize.Y / 35),
				["Font"] = Enum.Font.GothamBlack,
				["TextColor3"] = Color.White,
				["Text"] = ("%* %*"):format(Emoji.CrossedSwords, (StringUtil.formatNumber(kills))),
			}),
			React.createElement("textlabel", {
				["TextSize"] = 20,
				["TextScaled"] = true,
				["TextTransparency"] = 0,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["LayoutOrder"] = 2,
				["Size"] = UDim2.fromScale(winStreakSize.X / statsWidth, winStreakSize.Y / 35),
				["Font"] = Enum.Font.GothamBlack,
				["TextColor3"] = Color.White,
				["Text"] = ("%* %*"):format(Emoji.Flame, (StringUtil.formatNumber(winStreak))),
			}),
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
				["Padding"] = UDim.new(10 / statsWidth, 0),
				["VerticalAlignment"] = Enum.VerticalAlignment.Center,
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
			})
		)
	else
		healthBarContent = React.createElement(
			Grid,
			{
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.fromScale(0.03333333333333333, 0.5),
				["Size"] = getNameTagHealthSize(100),
				["BackgroundColor3"] = HealthBarUtil.getHealthBarColor(100),
				["Ref"] = healthBarRef,
			},
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1, 0),
			})
		)
	end
	return React.createElement(
		Grid,
		rootProps,
		statsElement,
		React.createElement(
			Grid,
			healthBarGridProps,
			healthBarContent,
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1, 0),
			})
		)
	)
end
getNameTagHealthSize = function(healthPercent: number)
	local healthWidth: number = 280 * (healthPercent / HealthConstants.MAX_HEALTH)
	return UDim2.fromScale(healthWidth / 300, 0.42857142857142855)
end
return {
	["NameTag"] = NameTag,
}
