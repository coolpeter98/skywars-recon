-- KillfeedGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService: RunService = Services.RunService
local TweenService: TweenService = Services.TweenService
local KillfeedEntry = RuntimeLib.import(script, script.Parent, "killfeed-entry").KillfeedEntry
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local DamageType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").DamageType
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen

type DamageType = "Melee" | "Bow" | "Fall" | "Void"
type KillfeedEntity = {
	Type: string,
	Name: string,
	Player: { DisplayName: string, UserId: number }?,
	Color: Color3?,
	Icon: string?,
}
type KillfeedGuiProps = {
	Index: number,
	Killer: KillfeedEntity?,
	Killed: KillfeedEntity,
	DamageType: DamageType,
}

local moveUp: ((frame: GuiObject, position: number) -> ())? = nil
local getPosition: ((index: number) -> UDim2)? = nil
local getIcon: ((damageType: DamageType) -> string?)? = nil

local function KillfeedGui(props: KillfeedGuiProps)
	local screenController = useScreen()
	local gridRef: { current: Frame? } = useRef()
	local indexRef: { current: number } = useRef(props.Index)
	useEffect(function()
		if not RunService:IsRunning() then
			return nil
		end
		local maid = Maid.new()
		maid:GiveTask(Flamework.resolveDependency("rB8").KillFeedRemoved:bind(function()
			local grid = gridRef.current
			if grid then
				local indexRefCopy = indexRef
				indexRefCopy.current = indexRefCopy.current - 1
				moveUp(grid, indexRef.current)
			end
		end))
		task.spawn(function()
			task.wait(8)
			maid:DoCleaning()
			local grid = gridRef.current
			if grid then
				TweenUtil.fadeOutSync(grid, 1)
			end
			screenController.Close()
			Flamework.resolveDependency("rB8").KillFeedRemoved:fire()
		end)
	end, {})
	local createElement = React.createElement
	local grid = Grid
	local gridProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["AutomaticSize"] = nil,
		["BackgroundTransparency"] = 0.6,
		["Ref"] = nil,
		["AnchorPoint"] = Vector2.new(1, 0),
		["Position"] = getPosition(props.Index),
		["Size"] = UDim2.fromOffset(100, 40),
		["AutomaticSize"] = Enum.AutomaticSize.X,
		["Ref"] = gridRef,
	}
	local killerEntry
	if props.Killer then
		killerEntry = createElement(KillfeedEntry, {
			["KillfeedEntity"] = nil,
			["LayoutOrder"] = 0,
			["KillfeedEntity"] = props.Killer,
		})
	else
		killerEntry = nil
	end
	return createElement(grid, gridProps, killerEntry, createElement(Image, {
		["Size"] = nil,
		["Image"] = nil,
		["LayoutOrder"] = 1,
		["Size"] = UDim2.fromOffset(30, 30),
		["Image"] = getIcon(props.DamageType),
	}), createElement(KillfeedEntry, {
		["KillfeedEntity"] = nil,
		["LayoutOrder"] = 2,
		["KillfeedEntity"] = props.Killed,
	}), createElement(CornerRadius, {
		["Radius"] = 10,
	}), createElement(List, {
		["Padding"] = UDim.new(0, 10),
	}), createElement("uipadding", {
		["PaddingLeft"] = UDim.new(0, 10),
		["PaddingRight"] = UDim.new(0, 10),
	}))
end
getIcon = function(damageType: DamageType): string?
	local unused = false
	if damageType == DamageType.Melee then
		return RobloxImage.Icon.SWORDS
	end
	if damageType == DamageType.Bow then
		return RobloxImage.Icon.ARROW
	end
	if damageType == DamageType.Fall and true or unused or damageType == DamageType.Void then
		return RobloxImage.Icon.FALLING
	end
end
getPosition = function(index: number): UDim2
	local yOffset = 50 * index
	return UDim2.new(1, -20, 0, 30 + yOffset)
end
moveUp = function(frame: GuiObject, position: number)
	local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		["Position"] = getPosition(position),
	})
	tween:Play()
	tween.Completed:Wait()
end
return {
	["KillfeedGui"] = KillfeedGui,
}
