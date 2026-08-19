-- AdvertBillboard

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local useTimer = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-timer").useTimer
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local getAdvertTimeColor =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "lobby", "adverts").getAdvertTimeColor
local useFocused = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-focused").useFocused
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local StringUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "string-util").StringUtil

local getRobuxTextProps = nil
local getCountdownTextProps = nil
local getScaledTextProps = nil

type AdvertBillboardProps = {
	Text: { string },
	PriceInRobux: number?,
	ExpireTime: number?,
	ExpirePrefix: string?,
	BackgroundTransparency: number?,
	StudsOffset: Vector3?,
}

local function AdvertBillboard(props: AdvertBillboardProps)
	local billboardRef = useRef()
	local countdownTextRef = useRef()
	local robuxTextProps = getRobuxTextProps(props.PriceInRobux)
	local topPadding = ScreenConstants.PADDING_2
	local textYPosition
	if props.PriceInRobux == nil then
		textYPosition = ScreenConstants.PADDING_2
	else
		textYPosition = topPadding + 48 + ScreenConstants.PADDING_1
	end
	local maxTextWidth = 0
	local totalTextHeight = 0
	for _, line in props.Text do
		local lineTextProps = getTextProps(line)
		local lineWidth = lineTextProps.Size.X.Offset
		maxTextWidth = math.max(lineWidth, maxTextWidth)
		totalTextHeight = totalTextHeight + lineTextProps.Size.Y.Offset
	end
	local onTimerUpdate = nil
	local timerUpdateArg1 = nil
	local timerUpdateArg2 = nil
	local secondsLeft = props.ExpireTime == nil and 0
		or useTimer({
			["EndTime"] = props.ExpireTime,
			["OnUpdate"] = function(timeLeft)
				return onTimerUpdate(timeLeft, timerUpdateArg1, timerUpdateArg2)
			end,
		})
	local countdownProps = getCountdownTextProps(props.ExpirePrefix, secondsLeft)
	local countdownYPosition = textYPosition + totalTextHeight + ScreenConstants.PADDING_1
	local robuxTextWidth = robuxTextProps.MaxTextProps.Size.X.Offset
	local countdownTextWidth = countdownProps.MaxTextProps.Size.X.Offset
	local totalWidth = math.max(maxTextWidth, robuxTextWidth, countdownTextWidth) + ScreenConstants.PADDING_2 * 2
	local totalHeight = countdownYPosition
		+ (props.ExpireTime == nil and 0 or 48 + ScreenConstants.PADDING_1)
		+ ScreenConstants.PADDING_1
	local priceRowWidth = 48 + ScreenConstants.PADDING_1 + robuxTextProps.MaxTextProps.Size.X.Offset
	local priceRowHeight = robuxTextProps.MaxTextProps.Size.Y.Offset
	local maxDistance = 96 * BlockConstants.BLOCK_SIZE
	useFocused(function(isFocused: boolean)
		if billboardRef.current then
			billboardRef.current.Enabled = not isFocused
		end
	end)
	local backgroundProps = {
		["key"] = "Background",
		["Size"] = nil,
		["Size"] = UDim2.fromScale(1, 1),
	}
	local backgroundTransparency = props.BackgroundTransparency
	backgroundProps.BackgroundTransparency = backgroundTransparency == nil and 0.15 or backgroundTransparency
	local textLines = props.Text
	local textElements = table.create(#textLines)
	local function createTextElement(line: string, layoutOrder: number)
		local lineTextProps = getTextProps(line)
		local elementProps = {
			["key"] = nil,
			["TextScaled"] = true,
			["LayoutOrder"] = nil,
			["key"] = line.Text,
			["LayoutOrder"] = layoutOrder,
		}
		for key, value in lineTextProps do
			elementProps[key] = value
		end
		elementProps.Size =
			UDim2.fromScale(lineTextProps.Size.X.Offset / maxTextWidth, lineTextProps.Size.Y.Offset / totalTextHeight)
		return React.createElement(Text, elementProps)
	end
	for index, line in textLines do
		textElements[index] = createTextElement(line, index - 1, textLines)
	end
	local textGrid = React.createElement(
		Grid,
		{
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, textYPosition / totalHeight),
			["Size"] = UDim2.fromScale(maxTextWidth / totalWidth, totalTextHeight / totalHeight),
		},
		textElements,
		React.createElement(List, {
			["Vertical"] = true,
			["Padding"] = nil,
			["Padding"] = UDim.new(0, 0),
		})
	)
	local priceElement = props.PriceInRobux ~= nil
	if priceElement then
		local priceIcon = React.createElement(Image, {
			["Image"] = RobloxImage.Icon.ROBUX,
			["Size"] = UDim2.fromScale(48 / priceRowWidth, 48 / priceRowHeight),
		})
		local priceTextProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["TextScaled"] = true,
			["TextXAlignment"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0),
			["Position"] = UDim2.fromScale((48 + ScreenConstants.PADDING_1) / priceRowWidth, 0),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
		}
		for key, value in getScaledTextProps(robuxTextProps, priceRowWidth, priceRowHeight) do
			priceTextProps[key] = value
		end
		priceElement = React.createElement(Grid, {
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, topPadding / totalHeight),
			["Size"] = UDim2.fromScale(priceRowWidth / totalWidth, priceRowHeight / totalHeight),
		}, priceIcon, React.createElement(Text, priceTextProps))
	end
	local countdownElement
	if props.ExpireTime == nil then
		countdownElement = nil
	else
		local countdownElementProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["TextScaled"] = true,
			["TextXAlignment"] = nil,
			["Ref"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, countdownYPosition / totalHeight),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["Ref"] = countdownTextRef,
		}
		for key, value in getScaledTextProps(countdownProps, totalWidth, totalHeight) do
			countdownElementProps[key] = value
		end
		countdownElement = React.createElement(Text, countdownElementProps)
	end
	return React.createElement(
		"billboardgui",
		{
			["Size"] = nil,
			["StudsOffsetWorldSpace"] = nil,
			["MaxDistance"] = nil,
			["AlwaysOnTop"] = true,
			["ref"] = nil,
			["Size"] = UDim2.fromScale(totalWidth / 50, totalHeight / 50),
			["StudsOffsetWorldSpace"] = props.StudsOffset or Vector3.new(0, -3.5, 0),
			["MaxDistance"] = maxDistance,
			["ref"] = billboardRef,
		},
		React.createElement(
			Grid,
			backgroundProps,
			textGrid,
			priceElement,
			countdownElement,
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(20 / totalHeight, 0),
			})
		)
	)
end

getRobuxTextProps = function(priceInRobux: number?)
	local price = priceInRobux == nil and 0 or priceInRobux
	local formattedPrice = StringUtil.formatNumber(price)
	return {
		["Text"] = formattedPrice,
		["MaxTextProps"] = getTextProps({
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["Color"] = nil,
			["Text"] = formattedPrice,
			["Color"] = Color.White,
		}),
	}
end

getCountdownTextProps = function(prefix: string?, timeLeft: number)
	local text = (prefix == nil and "" or prefix .. " ") .. TimeUtil.formatTime(timeLeft, false)
	local maxText
	if timeLeft < 86400 then
		local shortenedLength = #text - 2
		maxText = string.sub(text, 0, shortenedLength) .. "00"
	else
		maxText = text
	end
	return {
		["Text"] = text,
		["MaxTextProps"] = getTextProps({
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["Color"] = nil,
			["Text"] = maxText,
			["Color"] = getAdvertTimeColor(timeLeft),
		}),
	}
end

getScaledTextProps = function(textProps: { Text: string, MaxTextProps: any }, width: number, height: number)
	local scaledProps = table.clone(textProps.MaxTextProps)
	setmetatable(scaledProps, nil)
	scaledProps.Size =
		UDim2.fromScale(textProps.MaxTextProps.Size.X.Offset / width, textProps.MaxTextProps.Size.Y.Offset / height)
	scaledProps.Text = textProps.Text
	return scaledProps
end

return {
	["AdvertBillboard"] = AdvertBillboard,
}
