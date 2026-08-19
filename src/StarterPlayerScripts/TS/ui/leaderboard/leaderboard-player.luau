-- LeaderboardPlayer

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "components", "player-icon").PlayerIcon
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Players: Players = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Outline = RuntimeLib.import(script, script.Parent.Parent, "components", "outline").Outline
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type LeaderboardPlayerProps = {
	AnchorPoint: Vector2,
	Position: UDim2,
	UserId: number,
	LeaderboardPosition: number,
	Width: number,
	DisplayName: string,
	StatImage: string,
	StatValue: string | number,
}

local getAwardImage: ((position: number) -> string?)? = nil
local function LeaderboardPlayer(props: LeaderboardPlayerProps)
	local localUserId = Players.LocalPlayer
	if localUserId ~= nil then
		localUserId = localUserId.UserId
	end
	local isLocalPlayer = localUserId == props.UserId
	local awardImage = getAwardImage(props.LeaderboardPosition)
	local isCompact = props.Width < 500
	local createElement = React.createElement
	local grid = Grid
	local gridProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundTransparency"] = 0.6,
		["Selectable"] = true,
		["LayoutOrder"] = nil,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = UDim2.fromOffset(props.Width, 60),
		["LayoutOrder"] = props.LeaderboardPosition
	}
	local rankElement
	if awardImage == "" or not awardImage then
		rankElement = createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 10, 0.5, 0),
			["Size"] = UDim2.fromOffset(40, 40),
			["Text"] = ("%*."):format(props.LeaderboardPosition + 1)
		})
	else
		rankElement = createElement(Image, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 10, 0.5, 0),
			["Size"] = UDim2.fromOffset(40, 40),
			["Image"] = awardImage
		})
	end
	local playerIcon = PlayerIcon
	local playerIconProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["UserId"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 0,
		["CornerRadius"] = nil,
		["AnchorPoint"] = Vector2.new(0, 0.5),
		["Position"] = UDim2.new(0, 60, 0.5, 0),
		["Size"] = UDim2.fromOffset(40, 40),
		["UserId"] = props.UserId
	}
	local backgroundColor
	if isLocalPlayer then
		backgroundColor = Color.Green
	else
		backgroundColor = Color.White
	end
	playerIconProps.BackgroundColor3 = backgroundColor
	playerIconProps.CornerRadius = UDim.new(1)
	local playerIconElement = createElement(playerIcon, playerIconProps)
	local displayNameElement = createElement(Text, {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Text"] = nil,
		["Bold"] = true,
		["AutoLocalize"] = false,
		["AnchorPoint"] = Vector2.new(0, 0.5),
		["Position"] = UDim2.new(0, 110, 0.5, 0),
		["Text"] = props.DisplayName
	})
	local statElement
	if isCompact then
		local grid = Grid
		local gridProps = {
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -10, 0.5, 0),
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}
		local statImageElement = createElement(Image, {
			["Size"] = nil,
			["Image"] = nil,
			["LayoutOrder"] = 1,
			["Size"] = UDim2.fromOffset(16, 16),
			["Image"] = props.StatImage
		})
		local text = Text
		local textProps = {
			["Text"] = nil,
			["TextSize"] = 16,
			["Bold"] = true,
			["LayoutOrder"] = 2
		}
		local statValue = props.StatValue
		textProps.Text = tostring(statValue)
		statElement = createElement(grid, gridProps, statImageElement, createElement(text, textProps), createElement(List, {
			["Vertical"] = true,
			["Padding"] = nil,
			["Padding"] = UDim.new(0, 2)
		}))
	else
		local fragment = React.Fragment
		local text = Text
		local textProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -66, 0.5, 0)
		}
		local statValue = props.StatValue
		textProps.Text = tostring(statValue)
		statElement = createElement(fragment, nil, createElement(text, textProps), createElement(Image, {
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -20, 0.5, 0),
			["Size"] = UDim2.fromOffset(40, 40),
			["Image"] = props.StatImage
		}))
	end
	local outlineElement
	if isLocalPlayer then
		outlineElement = createElement(Outline, {
			["Thickness"] = 3,
			["Color"] = nil,
			["Color"] = Color.Green
		})
	else
		outlineElement = nil
	end
	return createElement(grid, gridProps, rankElement, playerIconElement, displayNameElement, statElement, outlineElement, createElement(CornerRadius, {
		["Radius"] = 10
	}))
end

getAwardImage = function(position: number): string?
	if position == 0 then
		return RobloxImage.Icon.AWARD_1
	elseif position == 1 then
		return RobloxImage.Icon.AWARD_2
	elseif position == 2 then
		return RobloxImage.Icon.AWARD_3
	else
		return nil
	end
end
return {
	["LeaderboardPlayer"] = LeaderboardPlayer
}
