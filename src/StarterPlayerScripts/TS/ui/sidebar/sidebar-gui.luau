-- SidebarGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ProfileSidebar = RuntimeLib.import(script, script.Parent, "profile-sidebar").ProfileSidebar

return {
	["SidebarGui"] = function(_)
		local createElement = React.createElement
		local grid = Grid
		local props = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, -10, 0.5, 0),
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}
		local profileSidebar
		if ScreenUtil.isMobile() then
			profileSidebar = React.createElement(ProfileSidebar)
		else
			profileSidebar = nil
		end
		return createElement(grid, props, profileSidebar, React.createElement(List, {
			["Vertical"] = true,
			["Padding"] = nil,
			["Padding"] = UDim.new(0, 20)
		}))
	end
}
