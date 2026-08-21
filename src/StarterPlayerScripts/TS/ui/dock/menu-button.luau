-- MenuButton

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local useButton = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-button").useButton
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local Badge = RuntimeLib.import(script, script.Parent.Parent, "components", "badge").Badge

type MenuButtonColor = {
	Primary: Color3,
	Dark: Color3,
	Light: Color3,
}

type MenuButtonProps = {
	Disabled: boolean?,
	Activated: (() -> ())?,
	Color: MenuButtonColor?,
	HasUpdated: (() -> boolean)?,
	Image: string?,
	Text: string?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["MenuButton"] = function(props: MenuButtonProps)
		local button = useButton({
			["Disabled"] = props.Disabled,
			["Activated"] = props.Activated,
		})
		local backgroundRef = useRef()
		useEffect(function()
			local background = backgroundRef.current
			if not background then
				return nil
			end
			local offset: number = button.Hovering and -10 or 0
			TweenService:Create(background, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				["Position"] = UDim2.fromOffset(0, offset),
			}):Play()
		end, { button.Hovering })
		local backgroundColor
		if props.Disabled then
			backgroundColor = Color.Button.Grey
		else
			backgroundColor = props.Color
		end
		local hasUpdated = props.HasUpdated
		if hasUpdated ~= nil then
			hasUpdated = hasUpdated()
		end
		local badge = hasUpdated == true
		local gridProps = {
			["key"] = "MenuButton",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Event"] = nil,
			["Activated"] = nil,
			["Selectable"] = true,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(140, 140),
			["Event"] = {
				["MouseEnter"] = button.MouseEnter,
				["MouseLeave"] = button.MouseLeave,
			},
			["Activated"] = function(guiObject, inputObject)
				button.Activated(guiObject, inputObject)
			end,
		}
		local backgroundProps = {
			["key"] = "Background",
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["Ref"] = nil,
			["Size"] = UDim2.fromScale(1, 1),
			["BackgroundColor3"] = Color.White,
			["Ref"] = backgroundRef,
		}
		if badge then
			badge = React.createElement(Badge, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = "NEW",
				["TextSize"] = 24,
				["Color"] = nil,
				["Rotation"] = 20,
				["ZIndex"] = 5,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.new(1, -20, 0, 10),
				["Color"] = Color.Red,
			})
		end
		return React.createElement(
			Grid,
			gridProps,
			React.createElement(
				Grid,
				backgroundProps,
				badge,
				React.createElement(
					Grid,
					{
						["key"] = "Clipping",
						["Position"] = nil,
						["Size"] = nil,
						["ClipsDescendants"] = true,
						["Position"] = UDim2.fromOffset(8, 8),
						["Size"] = UDim2.fromOffset(124, 92),
					},
					React.createElement(
						Grid,
						{
							["key"] = "PrimaryColor",
							["Size"] = nil,
							["BackgroundColor3"] = nil,
							["Size"] = UDim2.fromOffset(124, 124),
							["BackgroundColor3"] = backgroundColor.Primary,
						},
						React.createElement(CornerRadius, {
							["Radius"] = 22,
						})
					),
					React.createElement(
						Grid,
						{
							["key"] = "DarkColor",
							["AnchorPoint"] = nil,
							["Position"] = nil,
							["Size"] = nil,
							["BackgroundColor3"] = nil,
							["ZIndex"] = 2,
							["AnchorPoint"] = Vector2.new(0, 1),
							["Position"] = UDim2.fromScale(0, 1),
							["Size"] = UDim2.fromOffset(124, button.Pressed and 4 or 8),
							["BackgroundColor3"] = backgroundColor.Dark,
						},
						React.createElement(Grid, {
							["key"] = "LightColor",
							["AnchorPoint"] = nil,
							["Size"] = nil,
							["BackgroundColor3"] = nil,
							["AnchorPoint"] = Vector2.new(0, 1),
							["Size"] = UDim2.fromOffset(124, 4),
							["BackgroundColor3"] = backgroundColor.Light,
						})
					),
					React.createElement(Image, {
						["key"] = "Image",
						["AnchorPoint"] = nil,
						["Position"] = nil,
						["Size"] = nil,
						["Image"] = nil,
						["ZIndex"] = 2,
						["DropShadow"] = nil,
						["AnchorPoint"] = Vector2.new(0.5, 0.5),
						["Position"] = UDim2.fromScale(0.5, 0.45),
						["Size"] = UDim2.fromOffset(70, 70),
						["Image"] = props.Image,
						["DropShadow"] = Vector2.new(0, 3),
					})
				),
				React.createElement(Text, {
					["key"] = "Text",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Text"] = nil,
					["Bold"] = true,
					["TextColor3"] = nil,
					["TextSize"] = 20,
					["AnchorPoint"] = Vector2.new(0.5, 1),
					["Position"] = UDim2.new(0.5, 0, 1, -10),
					["Text"] = props.Text,
					["TextColor3"] = backgroundColor.Primary,
				}),
				React.createElement(CornerRadius, {
					["Radius"] = 30,
				})
			)
		)
	end,
}
