-- NameTagBillboardGui

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
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
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
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local useParty = GlobalStore.useParty
local useTeams = GlobalStore.useTeams
local Ranks = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "ranks").Ranks
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local GameMode = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameMode
local useFocused = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-focused").useFocused
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useAttribute = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-attribute").useAttribute
local NameTag = RuntimeLib.import(script, script.Parent, "name-tag").NameTag

type NameTagBillboardGuiProps = {
	Player: Player,
	Dummy: boolean,
	Character: Model?,
}

local getNameTagHealthSize: ((health: number) -> UDim2)? = nil

local function NameTagBillboardGui(props: NameTagBillboardGuiProps)
	local billboardGuiRef = useRef()
	local billboardRef = useRef()

	useFocused(function(focused: boolean)
		if billboardRef.current then
			billboardRef.current.Enabled = not focused
		end
	end)

	local party = useParty()
	local teams = useTeams()
	local teamId = useAttribute(props.Player, Attribute.TeamId)
	local team = useMemo(function()
		if teamId == nil then
			return nil
		else
			return teams[teamId]
		end
	end, { teams, teamId })

	local rank = useAttribute(props.Player, Attribute.Rank)
	local title = useAttribute(props.Player, Attribute.Title)
	local dummyTitle = useAttribute(props.Player, Attribute.DummyTitle)

	useEffect(function()
		if not billboardGuiRef.current then
			return nil
		end
		if not (PlaceUtil.isLobbyServer() or props.Dummy) then
			local healthBarConnection =
				HealthBarUtil.setupHealthBar(props.Player, billboardGuiRef.current, nil, nil, getNameTagHealthSize)
			return function()
				return healthBarConnection:Disconnect()
			end
		end
	end, { billboardGuiRef.current })

	local displayName = props.Player.DisplayName
	if not (party and PartyUtil.isInParty(PlayerUtil.toReplicated(props.Player), party)) and team then
		local _ = team == Flamework.resolveDependency("x5"):getPlayerTeam()
	end

	local nameSize = TextService:GetTextSize(displayName, 24, Enum.Font.GothamBlack, Vector2.new(1920, 1080)) * 1.05
	if rank then
		rank = Ranks[rank]
	end
	if rank then
		rank = TextService:GetTextSize(string.upper(rank.Name), 16, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
			* 1.05
	end
	if dummyTitle then
		title = Cosmetics[dummyTitle]
	elseif title then
		title = Cosmetics[title]
	end
	if title then
		title = TextService:GetTextSize(string.upper(title.Title), 16, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
			* 1.05
	end

	local nameWidth = nameSize.X
	if title ~= nil then
		title = title.X
	end
	if title == nil then
		if rank ~= nil then
			rank = rank.X
		end
		title = rank == nil and 0 or rank
	end

	local width = math.max(nameWidth, title) + 70 + 10 + 50 + 10
	local maxDistance = (PlaceUtil.getGameMode() == GameMode.EggWarsQuads and 40 or 96) * BlockConstants.BLOCK_SIZE

	return React.createElement(
		"billboardgui",
		{
			["key"] = "NameTag",
			["Size"] = nil,
			["ExtentsOffset"] = Vector3.new(0, 0, 0),
			["MaxDistance"] = nil,
			["AlwaysOnTop"] = true,
			["ref"] = nil,
			["Enabled"] = nil,
			["Size"] = UDim2.fromScale(width / 50, 2.1),
			["MaxDistance"] = maxDistance,
			["ref"] = billboardRef,
			["Enabled"] = not Flamework.resolveDependency("lB5"):isFocused(),
		},
		React.createElement(NameTag, {
			["Player"] = nil,
			["Dummy"] = nil,
			["Character"] = nil,
			["IsBillboardGuiDescendant"] = true,
			["Player"] = props.Player,
			["Dummy"] = props.Dummy,
			["Character"] = props.Character,
		})
	)
end

getNameTagHealthSize = function(health: number): UDim2
	local healthWidth = 280 * (health / HealthConstants.MAX_HEALTH)
	return UDim2.fromScale(healthWidth / 300, 0.42857142857142855)
end

return {
	["NameTagBillboardGui"] = NameTagBillboardGui,
}
