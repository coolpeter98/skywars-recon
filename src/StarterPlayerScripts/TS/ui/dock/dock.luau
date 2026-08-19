-- Dock

type DockProps = {
	Hidden: boolean?,
	HideButtons: boolean?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	children: { any }?,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local DockLayout = RuntimeLib.import(script, script.Parent, "dock-layout")
local getDockButtons = DockLayout.getDockButtons
local getDockLayout = DockLayout.getDockLayout
local MenuButton = RuntimeLib.import(script, script.Parent, "menu-button").MenuButton
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
return {
	["Dock"] = function(props: DockProps)
		local buttons = getDockButtons(getDockLayout(props))
		local hidden = props.Hidden == true
		local buttonElements
		if props.HideButtons == nil or not props.HideButtons then
			buttonElements = table.create(#buttons)
			for index, buttonProps in buttons do
				local _ = index - 1
				local buttonElementProps = table.clone(buttonProps)
				setmetatable(buttonElementProps, nil)
				buttonElements[index] = React.createElement(MenuButton, buttonElementProps)
			end
		else
			buttonElements = nil
		end
		return React.createElement(
			Grid,
			{
				["key"] = "Dock",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = nil,
				["Active"] = nil,
				["AnchorPoint"] = props.AnchorPoint or Vector2.new(0.5, 1),
				["Position"] = props.Position or UDim2.fromScale(0.5, 1),
				["Size"] = UDim2.new(1, 0, 0, 120),
				["BackgroundTransparency"] = hidden and 1 or 0.3,
				["Active"] = not ScreenUtil.isMobile(),
			},
			React.createElement(Grid, {
				["key"] = "Buttons",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Active"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, -40),
				["Size"] = UDim2.fromOffset(740, 140),
			}, buttonElements, React.createElement(List)),
			props.children,
			React.createElement("uigradient", {
				["Rotation"] = 270,
				["Transparency"] = nil,
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.95),
				}),
			})
		)
	end,
}
