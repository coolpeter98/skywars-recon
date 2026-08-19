-- NotificationGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "components", "player-icon").PlayerIcon
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen

type NotificationData = {
	Activated: (() -> ())?,
	Declined: (() -> ())?,
	ActivatedText: string?,
	DeclinedText: string?,
	Duration: number,
	Icon: string?,
	IconColor: Color3?,
	IconScale: number?,
	Message: string,
	Player: { UserId: number }?,
	Title: string,
}

type NotificationGuiProps = {
	Id: number,
	Notification: NotificationData,
	StartTime: number,
}

local moveUp: (frame: GuiObject, id: number) -> ()
local getPosition: (id: number) -> UDim2
local getHeight: (notification: NotificationData) -> number

local function NotificationGui(props: NotificationGuiProps)
	local screenController = useScreen()
	local gridRef = useRef()
	local progressRef = useRef()
	local fadeTweenRef = useRef()
	local hasButtons = props.Notification.Activated or props.Notification.Declined
	useEffect(function()
		if not gridRef.current then
			return nil
		end
		local odx = Flamework.resolveDependency("Odx")
		local maid = Maid.new()
		maid:GiveTask(odx.NotificationHovered:bind(function(hovered)
			if hovered.frame and fadeTweenRef.current then
				fadeTweenRef.current.Pause()
				TweenUtil.restoreTween(fadeTweenRef.current)
			end
			if hovered.frame then
				return nil
			elseif TimeUtil.elapsed(props.StartTime, props.Notification.Duration) then
				if gridRef.current then
					local fadeTween = TweenUtil.fadeOutAsync(gridRef.current, 1.5)
					fadeTweenRef.current = fadeTween
					local completed = fadeTween.Completed
					if completed ~= nil then
						completed:Wait()
					end
				end
				screenController.Close()
			else
				moveUp(gridRef.current, props.Id)
			end
		end))
		maid:GiveTask(Flamework.resolveDependency("Odx").NotificationRemoved:bind(function(removed)
			if removed.notificationId >= props.Id then
				return nil
			end
			if odx then
				moveUp(gridRef.current, props.Id)
			end
		end))
		task.spawn(function()
			task.wait(props.Notification.Duration)
			if odx:isHovering() then
				return nil
			end
			if gridRef.current then
				local fadeTween = TweenUtil.fadeOutAsync(gridRef.current, 1.5)
				fadeTweenRef.current = fadeTween
				local completed = fadeTween.Completed
				if completed ~= nil then
					completed:Wait()
				end
			end
			screenController.Close()
		end)
		return function()
			return maid:DoCleaning()
		end
	end, { gridRef.current })
	useEffect(function()
		if not progressRef.current then
			return nil
		end
		local remainingTime = props.StartTime + props.Notification.Duration - os.clock()
		local tweenInfo = TweenInfo.new(remainingTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
		TweenService:Create(progressRef.current, tweenInfo, {
			["Size"] = UDim2.fromScale(1, 0)
		}):Play()
	end, { progressRef.current })
	local playerIconElement
	if props.Notification.Player then
		local createElement = React.createElement
		local playerIcon = PlayerIcon
		local playerIconProps = {
			["Position"] = UDim2.fromOffset(10, 10)
		}
		local playerIconSize
		if hasButtons then
			playerIconSize = UDim2.fromOffset(100, 100)
		else
			playerIconSize = UDim2.fromOffset(60, 60)
		end
		playerIconProps.Size = playerIconSize
		playerIconProps.UserId = props.Notification.Player.UserId
		playerIconElement = createElement(playerIcon, playerIconProps)
	else
		playerIconElement = nil
	end
	local icon = not props.Notification.Player
	if icon then
		icon = props.Notification.Icon
	end
	local iconElement
	if icon == "" or not icon then
		iconElement = nil
	else
		local imageProps = {}
		local xOffset
		if hasButtons then
			local iconScale = props.Notification.IconScale
			xOffset = 100 * (1 - (iconScale == nil and 1 or iconScale)) / 2
		else
			local iconScale = props.Notification.IconScale
			xOffset = 60 * (1 - (iconScale == nil and 1 or iconScale)) / 2
		end
		local xPosition = 10 + xOffset
		local yOffset
		if hasButtons then
			local iconScale = props.Notification.IconScale
			yOffset = 100 * (1 - (iconScale == nil and 1 or iconScale)) / 2
		else
			local iconScale = props.Notification.IconScale
			yOffset = 60 * (1 - (iconScale == nil and 1 or iconScale)) / 2
		end
		imageProps.Position = UDim2.fromOffset(xPosition, 10 + yOffset)
		local iconSize
		if hasButtons then
			local iconScale = props.Notification.IconScale
			local iconWidth = 100 * (iconScale == nil and 1 or iconScale)
			local heightScale = props.Notification.IconScale
			local normalizedScale = heightScale == nil and 1 or heightScale
			iconSize = UDim2.fromOffset(iconWidth, 100 * normalizedScale)
		else
			local iconScale = props.Notification.IconScale
			local iconWidth = 60 * (iconScale == nil and 1 or iconScale)
			local heightScale = props.Notification.IconScale
			local normalizedScale = heightScale == nil and 1 or heightScale
			iconSize = UDim2.fromOffset(iconWidth, 60 * normalizedScale)
		end
		imageProps.Size = iconSize
		imageProps.Image = props.Notification.Icon
		imageProps.ImageColor3 = props.Notification.IconColor
		iconElement = React.createElement(Image, imageProps)
	end
	local createElement = React.createElement
	local textComponent = Text
	local titleProps = {
		["Position"] = nil,
		["Text"] = nil,
		["Bold"] = true
	}
	local titlePosition
	if hasButtons then
		titlePosition = UDim2.fromOffset(120, 10)
	else
		titlePosition = UDim2.fromOffset(80, 15)
	end
	titleProps.Position = titlePosition
	titleProps.Text = props.Notification.Title
	local titleElement = createElement(textComponent, titleProps)
	local createElement = React.createElement
	local textComponent = Text
	local messageProps = {
		["Position"] = nil,
		["Text"] = nil,
		["TextSize"] = 18,
		["Bold"] = true,
		["RichText"] = true
	}
	local messagePosition
	if hasButtons then
		messagePosition = UDim2.fromOffset(120, 40)
	else
		messagePosition = UDim2.fromOffset(80, 48)
	end
	messageProps.Position = messagePosition
	messageProps.Text = props.Notification.Message
	local messageElement = createElement(textComponent, messageProps)
	local acceptButtonElement
	if props.Notification.Activated then
		local acceptButtonProps = {
			["Size"] = { 118, 40 }
		}
		local activatedText = props.Notification.ActivatedText
		acceptButtonProps.Text = activatedText == nil and "Accept" or activatedText
		acceptButtonProps.Color = Color.Button.Green
		function acceptButtonProps.Activated()
			screenController.Close()
			props.Notification.Activated()
		end
		acceptButtonElement = React.createElement(Button, acceptButtonProps)
	else
		acceptButtonElement = nil
	end
	local denyButtonElement
	if props.Notification.Declined then
		local denyButtonProps = {
			["Size"] = { 118, 40 }
		}
		local declinedText = props.Notification.DeclinedText
		denyButtonProps.Text = declinedText == nil and "Deny" or declinedText
		denyButtonProps.Color = Color.Button.Red
		function denyButtonProps.Activated()
			screenController.Close()
			props.Notification.Declined()
		end
		denyButtonElement = React.createElement(Button, denyButtonProps)
	else
		denyButtonElement = nil
	end
	return React.createElement(Grid, {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundTransparency"] = 0.6,
		["Ref"] = nil,
		["Event"] = nil,
		["AnchorPoint"] = Vector2.new(1, 0),
		["Position"] = getPosition(props.Id),
		["Size"] = UDim2.fromOffset(450, getHeight(props.Notification)),
		["Ref"] = gridRef,
		["Event"] = {
			["MouseEnter"] = function(frame)
				return Flamework.resolveDependency("Odx"):mouseEnter(frame)
			end,
			["MouseLeave"] = function()
				return Flamework.resolveDependency("Odx"):mouseLeave()
			end
		}
	}, playerIconElement, iconElement, titleElement, messageElement, React.createElement(Grid, {
		["AnchorPoint"] = Vector2.new(0, 1),
		["Position"] = UDim2.new(0, 120, 1, -10),
		["AutomaticSize"] = Enum.AutomaticSize.XY
	}, acceptButtonElement, denyButtonElement, React.createElement("uilistlayout", {
		["FillDirection"] = Enum.FillDirection.Horizontal,
		["Padding"] = UDim.new(0, 10),
		["SortOrder"] = Enum.SortOrder.LayoutOrder
	})), React.createElement(Grid, {
		["AnchorPoint"] = Vector2.new(1, 0),
		["Position"] = UDim2.new(1, -10, 0, 10),
		["Size"] = UDim2.fromOffset(10, hasButtons and 100 or 60)
	}, React.createElement(Grid, {
		["BackgroundColor3"] = nil,
		["ZIndex"] = 2,
		["AnchorPoint"] = Vector2.new(0.5, 1),
		["Position"] = UDim2.fromScale(0.5, 1),
		["Size"] = UDim2.fromScale(1, 1),
		["BackgroundColor3"] = Color.Green,
		["Ref"] = progressRef
	}, React.createElement(CornerRadius, {
		["Radius"] = 10
	})), React.createElement(CornerRadius, {
		["Radius"] = 10
	})), React.createElement(CornerRadius, {
		["Radius"] = 10
	}))
end
getHeight = function(notification)
	return (notification.Activated or notification.Declined) and 120 or 80
end
getPosition = function(id)
	local totalHeight = 0
	local count = 0
	for notificationId, notification in Flamework.resolveDependency("Odx").Notifications do
		if notificationId < id then
			totalHeight = totalHeight + getHeight(notification)
			count = count + 1
		end
	end
	local spacing = count * 20
	return UDim2.new(1, -30, 0, totalHeight + 30 + spacing)
end
moveUp = function(frame, id)
	local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		["Position"] = getPosition(id)
	})
	tween:Play()
	tween.Completed:Wait()
end
return {
	["NotificationGui"] = NotificationGui
}
