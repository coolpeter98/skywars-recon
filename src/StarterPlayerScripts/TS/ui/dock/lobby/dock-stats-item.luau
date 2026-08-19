-- DockStatsItem

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local TextModule = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text")
local DEFAULT_BOLD_FONT = TextModule.DEFAULT_BOLD_FONT
local Text = TextModule.Text
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local TextService: TextService = Services.TextService
local TweenService: TweenService = Services.TweenService
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local useButton = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-button").useButton
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type DockStatsItemProps = {
	Text: string,
	Image: string,
	LayoutOrder: number,
	Activated: (() -> ())?,
	Selectable: boolean?,
}

return {
	["DockStatsItem"] = function(props: DockStatsItemProps)
		local textSize: Vector2 = TextService:GetTextSize(props.Text, 22, DEFAULT_BOLD_FONT, Vector2.new(1920, 1080))
		local button = useButton({
			["Disabled"] = false,
			["Activated"] = nil,
			["Activated"] = props.Activated or function() end
		})
		local wrapperRef = useRef()
		useEffect(function()
			local ref = wrapperRef.current
			if not ref then
				return nil
			end
			local hoverOffset = button.Hovering and -10 or 0
			TweenService:Create(ref, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				["Position"] = UDim2.fromOffset(0, hoverOffset)
			}):Play()
		end, { button.Hovering })
		return React.createElement(Grid, {
			["key"] = ("Item%*"):format(props.LayoutOrder),
			["Size"] = UDim2.fromOffset(86, 80),
			["LayoutOrder"] = props.LayoutOrder,
			["Activated"] = button.Activated,
			["Active"] = props.Activated ~= nil,
			["Event"] = {
				["MouseEnter"] = button.MouseEnter,
				["MouseLeave"] = button.MouseLeave
			},
			["Selectable"] = props.Selectable
		}, React.createElement(Grid, {
			["key"] = "Wrapper",
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Ref"] = nil,
			["Size"] = UDim2.fromScale(1, 1),
			["Ref"] = wrapperRef
		}, React.createElement(Image, {
			["key"] = "Image",
			["Size"] = nil,
			["Image"] = nil,
			["LayoutOrder"] = 0,
			["Size"] = UDim2.fromOffset(40, 40),
			["Image"] = props.Image
		}), React.createElement(Text, {
			["key"] = "Text",
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 20,
			["TextYAlignment"] = nil,
			["Bold"] = true,
			["LayoutOrder"] = 1,
			["Size"] = UDim2.fromOffset(textSize.X, textSize.Y),
			["Text"] = props.Text,
			["TextYAlignment"] = Enum.TextYAlignment.Bottom
		}), React.createElement(CornerRadius, {
			["Radius"] = 20
		}), React.createElement(List, {
			["Vertical"] = true,
			["Padding"] = nil,
			["Padding"] = UDim.new(0, 2)
		})))
	end
}
