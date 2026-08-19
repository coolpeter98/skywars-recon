-- DropdownOption

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent, "text").Text
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local Image = RuntimeLib.import(script, script.Parent.Parent, "image").Image
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

type DropdownOptionProps = {
	Text: string,
	Size: any,
	Activated: (() -> ())?,
	LayoutOrder: number?,
	FirstItem: boolean?,
	LastItem: boolean?,
	Image: string?,
}

return {
	["DropdownOption"] = function(props: DropdownOptionProps)
		local hovered, setHovered = useState(false)
		local frameRef = useRef()
		useEffect(function()
			local frame = frameRef.current
			if not frame then
				return nil
			end
			local targetColor
			if hovered then
				targetColor = Color3.fromRGB(92, 92, 92)
			else
				targetColor = Color3.fromRGB(51, 51, 51)
			end
			TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				["BackgroundColor3"] = targetColor
			}):Play()
		end, { hovered })
		local topRadius = props.FirstItem and 10 or 0
		local bottomRadius = props.LastItem and 10 or 0
		local image = props.Image
		local imageElement
		if image == "" or not image then
			imageElement = nil
		else
			imageElement = React.createElement(Image, {
				["key"] = "Image",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 16, 0.5, 0),
				["Size"] = UDim2.fromOffset(20, 20),
				["Image"] = props.Image
			})
		end
		local textProps = {
			["key"] = "Text",
			["AnchorPoint"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5)
		}
		local imageValue = props.Image
		textProps.Position = UDim2.new(0, (imageValue == "" or not imageValue) and 16 or 46, 0.5, 0)
		textProps.Text = props.Text
		textProps.Bold = true
		textProps.FixSize = true
		textProps.ZIndex = 22
		return React.createElement(Grid, {
			["key"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["Activated"] = nil,
			["LayoutOrder"] = nil,
			["ZIndex"] = 21,
			["Ref"] = nil,
			["Event"] = nil,
			["CornerRadius"] = nil,
			["key"] = props.Text,
			["Size"] = props.Size:ToUDim2(),
			["BackgroundColor3"] = Color3.fromRGB(51, 51, 51),
			["Activated"] = props.Activated,
			["LayoutOrder"] = props.LayoutOrder,
			["Ref"] = frameRef,
			["Event"] = {
				["MouseEnter"] = function()
					return setHovered(true)
				end,
				["MouseLeave"] = function()
					return setHovered(false)
				end
			},
			["CornerRadius"] = {
				["TopLeft"] = topRadius,
				["TopRight"] = topRadius,
				["BottomLeft"] = bottomRadius,
				["BottomRight"] = bottomRadius
			}
		}, imageElement, React.createElement(Text, textProps))
	end,
}
