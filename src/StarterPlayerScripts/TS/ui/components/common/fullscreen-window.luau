-- FullscreenWindow

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "text").Text
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Image = RuntimeLib.import(script, script.Parent.Parent, "image").Image
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local useWindow = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-window").useWindow
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local useScreen = RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "screen-context").useScreen

type FullscreenWindowProps = {
	Text: string,
	TopBarChildren: { any }?,
	children: { any }?,
	[string]: any,
}

return {
	["FullscreenWindow"] = function(props: FullscreenWindowProps)
		local screen = useScreen()
		local window = useWindow()
		local isHovered, setIsHovered = useState(false)
		local primaryBlue = Color.Button.Blue.Primary
		local darkBlue = Color.Button.Blue.Dark
		local topBarHeight = ScreenConstants.TOP_BAR_HEIGHT - 4
		local createElement = React.createElement
		local Grid = Grid
		local windowProps = {
			["key"] = "Window",
			["Size"] = nil,
			["Size"] = UDim2.fromScale(1, 1),
		}
		local createElement = React.createElement
		local Grid = Grid
		local topBarProps = {
			["key"] = "TopBar",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.fromScale(0.5, 0),
			["Size"] = UDim2.new(1, 0, 0, topBarHeight),
		}
		local createElement = React.createElement
		local Grid = Grid
		local topBarFrameProps = {
			["key"] = "TopBarFrame",
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["Size"] = UDim2.new(1, 0, 0, topBarHeight),
			["BackgroundColor3"] = primaryBlue,
		}
		local topBarChildren = props.TopBarChildren
		local titleElement = React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 36,
			["Bold"] = true,
			["DropShadow"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Text"] = props.Text,
			["DropShadow"] = Vector2.new(0, 4),
		})
		local createElement = React.createElement
		local Grid = Grid
		local closeButtonProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ZIndex"] = 10,
			["Activated"] = nil,
			["Event"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, 0, 0.5, 0),
			["Size"] = UDim2.fromOffset(topBarHeight + 24, topBarHeight + 24),
			["Activated"] = function()
				return screen.Close()
			end,
			["Event"] = {
				["MouseEnter"] = function()
					return setIsHovered(true)
				end,
				["MouseLeave"] = function()
					return setIsHovered(false)
				end,
			},
		}
		local createElement = React.createElement
		local Grid = Grid
		local closeIconProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(topBarHeight - 8, topBarHeight - 8),
		}
		local closeIconColor
		if isHovered then
			closeIconColor = ColorUtil.scaleValue(Color.Red, 0.9)
		else
			closeIconColor = Color.Red
		end
		closeIconProps.BackgroundColor3 = closeIconColor
		local closeIconElement = React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(20, 20),
			["Image"] = RobloxImage.Icon.X_MARK,
			["ImageColor3"] = Color.White,
		})
		local createElement = React.createElement
		local CornerRadius = CornerRadius
		local cornerRadiusProps = {
			["CornerRadius"] = {
				["CornerRadius"] = UDim.new(1, 0),
			},
		}
		return createElement(
			Grid,
			windowProps,
			createElement(
				Grid,
				topBarProps,
				createElement(
					Grid,
					topBarFrameProps,
					topBarChildren,
					titleElement,
					createElement(
						Grid,
						closeButtonProps,
						createElement(
							Grid,
							closeIconProps,
							closeIconElement,
							createElement(CornerRadius, cornerRadiusProps)
						)
					)
				),
				React.createElement(Grid, {
					["key"] = "TopBarDropShadow",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0, topBarHeight),
					["Size"] = UDim2.new(1, 0, 0, 4),
					["BackgroundColor3"] = darkBlue,
				})
			),
			React.createElement(Grid, {
				["key"] = "WindowContent",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 1,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, ScreenConstants.TOP_BAR_HEIGHT + ScreenConstants.PADDING_3),
				["Size"] = UDim2.fromOffset(window.ContentFrameSize.X, window.ContentFrameSize.Y),
			}, props.children)
		)
	end,
}
