-- PrivateMatch

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Separator = RuntimeLib.import(script, script.Parent.Parent, "components", "separator").Separator
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
return {
	["PrivateMatch"] = function(props)
		local createElement = React.createElement
		local windowComponent = Window
		local windowProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
		}
		local windowPosition
		if ScreenUtil.isMobile() then
			windowPosition = UDim2.new(0.5, 0, 0.5, -40)
		else
			windowPosition = UDim2.new(0.5, 0, 0.5, -180)
		end
		windowProps.Position = windowPosition
		windowProps.Size = UDim2.fromOffset(1020, 600)
		return createElement(
			windowComponent,
			windowProps,
			props.Sidebar,
			React.createElement(Separator, {
				["Position"] = UDim2.fromOffset(270, 30),
				["Size"] = UDim2.fromOffset(4, 540),
			}),
			props.Page
		)
	end,
}
