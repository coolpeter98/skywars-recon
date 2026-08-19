-- ShopTab

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
local useContext = React.useContext
local useEffect = React.useEffect
local useRef = React.useRef
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local useHovering = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-hovering").useHovering
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local RunService: RunService = Services.RunService
local TweenService: TweenService = Services.TweenService
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local ShopScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "shop-screen-constants").ShopScreenConstants
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType

local ICON_SIZE = Vector2.new(64, 64)
local SELECTED_COLOR = Color.Green
local UNSELECTED_COLOR = Color.LightGrey

type ShopTabProps = {
	Tab: {
		Id: string,
		Text: string,
		Icon: string,
	},
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["ShopTab"] = function(props: ShopTabProps)
		local newShopContext = useContext(NewShopContext)
		local buttonRef = useRef()
		local highlightRef = useRef()
		local isHovering = useHovering(buttonRef)
		local isSelected = newShopContext.SelectedTab.Id == props.Tab.Id
		local backgroundColor
		if isSelected then
			backgroundColor = SELECTED_COLOR
		else
			backgroundColor = UNSELECTED_COLOR
		end
		if isHovering and not isSelected then
			ColorUtil.scaleValue(backgroundColor, 0.8)
		end
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["Text"] = props.Tab.Text,
		})
		local textWidth = ShopScreenConstants.TAB_SIZE_X - (ICON_SIZE.X + ScreenConstants.PADDING_2 * 2)
		useEffect(function()
			local isSelectedCopy = isSelected
			local isHoveringCopy = isHovering
			local backgroundColor
			if isSelectedCopy then
				backgroundColor = SELECTED_COLOR
			else
				backgroundColor = UNSELECTED_COLOR
			end
			if isHoveringCopy and not isSelectedCopy then
				backgroundColor = ColorUtil.scaleValue(backgroundColor, 0.8)
			end
			local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			if buttonRef.current then
				TweenService:Create(buttonRef.current, tweenInfo, {
					["BackgroundColor3"] = backgroundColor,
				}):Play()
			end
			if highlightRef.current then
				TweenService:Create(highlightRef.current, tweenInfo, {
					["BackgroundColor3"] = ColorUtil.scaleValue(backgroundColor, 1.2),
				}):Play()
			end
		end, { isSelected, isHovering })
		local imageElement = React.createElement(Image, {
			["key"] = "Image",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Image"] = nil,
			["Size"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, ScreenConstants.PADDING_2, 0.5, 0),
			["Image"] = props.Tab.Icon,
			["Size"] = UDim2.fromOffset(ICON_SIZE.X, ICON_SIZE.Y),
		})
		local textElementProps = {
			["key"] = "Text",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, ScreenConstants.PADDING_2 + ICON_SIZE.X, 0.5, 0),
		}
		for key, value in textProps do
			textElementProps[key] = value
		end
		textElementProps.Size = UDim2.fromOffset(textWidth, 48)
		return React.createElement(
			Grid,
			{
				["key"] = nil,
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0,
				["Activated"] = nil,
				["Ref"] = nil,
				["key"] = props.Tab.Id,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = UDim2.fromOffset(ShopScreenConstants.TAB_SIZE_X, ShopScreenConstants.TAB_SIZE_Y),
				["Activated"] = function()
					newShopContext.SetSelectedTab(props.Tab.Id)
					if RunService:IsRunning() then
						Flamework.resolveDependency("jL9"):playSound(RobloxSound.Button.DOWN, {
							["SoundGroup"] = SoundGroupType.Ui,
						})
					end
				end,
				["Ref"] = buttonRef,
			},
			imageElement,
			React.createElement(Text, textElementProps),
			React.createElement(Grid, {
				["key"] = "Highlight",
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0,
				["Ref"] = nil,
				["Position"] = UDim2.fromOffset(0, ShopScreenConstants.TAB_SIZE_Y - 6),
				["Size"] = UDim2.fromOffset(ShopScreenConstants.TAB_SIZE_X, 6),
				["Ref"] = highlightRef,
			})
		)
	end,
}
