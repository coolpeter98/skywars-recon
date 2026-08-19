-- SeasonPassSale

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Button = RuntimeLib.import(script, script.Parent, "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local Outline = RuntimeLib.import(script, script.Parent, "outline").Outline
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local useHovering = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-hovering").useHovering
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local LOGO_SIZE = Size.new(200, 200)

type Props = {
	AnchorPoint: Vector2,
	Position: UDim2,
}

return {
	["SeasonPassSale"] = function(props: Props)
		local containerRef = useRef()
		local hovering = useHovering(containerRef)
		local uiscaleRef = useRef()
		local textProps = getTextProps({
			["Text"] = "SEASON 3\nOUT NOW",
			["TextSize"] = 36,
			["Bold"] = true,
		})
		useEffect(function()
			if uiscaleRef.current then
				local tweenGoal = {
					["Scale"] = hovering and 1.05 or 1,
				}
				TweenService:Create(uiscaleRef.current, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), tweenGoal):Play()
			end
		end, { hovering })
		local width = LOGO_SIZE.X / 2 + ScreenConstants.PADDING_1 + textProps.Size.X.Offset + ScreenConstants.PADDING_3
		local uiscale = React.createElement("uiscale", {
			["ref"] = uiscaleRef,
		})
		local logo = React.createElement(Image, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Image"] = nil,
			["Size"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0, 0.5),
			["Image"] = RobloxImage.GameProduct.SEASON_PASS_LOGO,
			["Size"] = LOGO_SIZE:ToUDim2(),
		}, React.createElement("uicorner", {
			["CornerRadius"] = UDim.new(0, 20),
		}))
		local textElementProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["ZIndex"] = 2,
			["AnchorPoint"] = Vector2.new(0, 0),
			["Position"] = UDim2.fromOffset(LOGO_SIZE.X / 2 + ScreenConstants.PADDING_1, ScreenConstants.PADDING_2),
		}
		for key, value in textProps do
			textElementProps[key] = value
		end
		return React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 10,
			["Ref"] = nil,
			["Activated"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(width, 108 + ScreenConstants.PADDING_1 * 5),
			["Ref"] = containerRef,
			["Activated"] = function()
				Flamework.resolveDependency("lB5"):closeScreenId("Lobby")
				Flamework.resolveDependency("vbD"):openShop({
					["ProductType"] = "SeasonPass",
				})
			end,
		}, uiscale, logo, React.createElement(Text, textElementProps, React.createElement(Outline, {
			["Thickness"] = 3,
			["Color"] = nil,
			["Color"] = Color.Red,
		})), React.createElement(Button, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "SHOP",
			["Color"] = nil,
			["ZIndex"] = 20,
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 1),
			["Position"] = UDim2.new(0, LOGO_SIZE.X / 2 + (width - (LOGO_SIZE.X / 2 + ScreenConstants.PADDING_1)) / 2, 1, -ScreenConstants.PADDING_2),
			["Size"] = { 180, 36 },
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				Flamework.resolveDependency("lB5"):closeScreenId("Lobby")
				Flamework.resolveDependency("vbD"):openShop({
					["ProductType"] = "SeasonPass",
				})
			end,
		}))
	end,
}
