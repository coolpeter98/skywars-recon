-- DockParty

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local PartyInstance = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance")
local PARTY_MAX_PLAYERS: number = PartyInstance.PARTY_MAX_PLAYERS
local PartyUtil = PartyInstance.PartyUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "player-icon").PlayerIcon
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

local PLAYER_COLORS = {
	Color.Green,
	Color.LightBlue,
	Color.Yellow,
	Color.Red
}

type DockPartyProps = {
	Party: { Players: { number } },
	AnchorPoint: Vector2,
	Position: UDim2,
}

local function DockParty(props: DockPartyProps)
	local isFull: boolean = PartyUtil.isFull(props.Party, false)
	local players: { number } = props.Party.Players
	table.sort(players, function(playerA, playerB)
		if PartyUtil.isOwnerId(playerA, props.Party) then
			return true
		elseif PartyUtil.isOwnerId(playerB, props.Party) then
			return false
		else
			return playerA < playerB
		end
	end)
	local isScreenFocused: boolean
	if RunService:IsRunning() then
		isScreenFocused = Flamework.resolveDependency("lB5"):isFocused()
	else
		isScreenFocused = false
	end
	local isVisible, setIsVisible = useState(not isScreenFocused)
	useEffect(function()
		if not RunService:IsRunning() then
			return nil
		end
		local connection = Flamework.resolveDependency("lB5").ScreenOpenedEvent:bind(function()
			local isScreenFocused: boolean
			if RunService:IsRunning() then
				isScreenFocused = Flamework.resolveDependency("lB5"):isFocused()
			else
				isScreenFocused = false
			end
			setIsVisible(not isScreenFocused)
		end)
		return function()
			return connection:Disconnect()
		end
	end, {})
	local playerElements = table.create(#players)
	local function renderPlayerIcon(userId: number, slotIndex: number)
		if PARTY_MAX_PLAYERS <= slotIndex then
			return React.createElement(React.Fragment)
		end
		local iconProps = {
			["key"] = "PlayerIcon",
			["Size"] = nil,
			["UserId"] = nil,
			["BackgroundColor3"] = nil,
			["BackgroundTransparency"] = 0,
			["CornerRadius"] = nil,
			["LayoutOrder"] = nil,
			["Size"] = UDim2.fromOffset(60, 60),
			["UserId"] = userId,
			["BackgroundColor3"] = PLAYER_COLORS[slotIndex + 1] or Color.White,
			["CornerRadius"] = UDim.new(1),
			["LayoutOrder"] = slotIndex
		}
		local crownElement
		if PartyUtil.isOwnerId(userId, props.Party) then
			crownElement = React.createElement(Image, {
				["key"] = "Crown",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ImageColor3"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromOffset(7, 5.5),
				["Size"] = UDim2.fromOffset(28, 22),
				["Image"] = RobloxImage.Icon.CROWN,
				["ImageColor3"] = Color.Yellow
			})
		else
			crownElement = nil
		end
		return React.createElement(PlayerIcon, iconProps, crownElement)
	end
	for index, userId in players do
		playerElements[index] = renderPlayerIcon(userId, index - 1, players)
	end
	local gridProps = {
		["key"] = "DockParty",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundTransparency"] = 0.6,
		["Visible"] = nil,
		["Activated"] = nil,
		["Active"] = true,
		["Selectable"] = true,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = UDim2.fromOffset(ScreenUtil.getGridSize(60, 10, #props.Party.Players + 1) + 20, 80),
		["Visible"] = isVisible,
		["Activated"] = function()
			return Flamework.resolveDependency("PrB"):toggleScreen()
		end
	}
	local settingsProps = {
		["key"] = "PartySettings",
		["Size"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 0.6,
		["LayoutOrder"] = nil,
		["Size"] = UDim2.fromOffset(60, 60),
		["BackgroundColor3"] = Color.Black,
		["LayoutOrder"] = #props.Party.Players
	}
	local settingsImageProps = {
		["key"] = "Image",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["Image"] = nil,
		["AnchorPoint"] = Vector2.new(0.5, 0.5),
		["Position"] = UDim2.fromScale(0.5, 0.5),
		["Size"] = UDim2.fromOffset(30, 30)
	}
	local settingsIcon
	if isFull then
		settingsIcon = RobloxImage.Icon.SETTINGS
	else
		settingsIcon = RobloxImage.Icon.USER_PLUS
	end
	settingsImageProps.Image = settingsIcon
	return React.createElement(Grid, gridProps, playerElements, React.createElement(Grid, settingsProps, React.createElement(Image, settingsImageProps), React.createElement("uicorner", {
		["CornerRadius"] = UDim.new(1)
	})), React.createElement(CornerRadius, {
		["Radius"] = 100
	}), React.createElement(List))
end

return {
	["DockParty"] = DockParty,
}
