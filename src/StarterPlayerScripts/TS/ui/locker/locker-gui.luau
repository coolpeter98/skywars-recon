-- LockerGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local FullscreenWindow =
	RuntimeLib.import(script, script.Parent.Parent, "components", "common", "fullscreen-window").FullscreenWindow
local LockerSidebar = RuntimeLib.import(script, script.Parent, "locker-sidebar").LockerSidebar
local LockerSearchBar = RuntimeLib.import(script, script.Parent, "locker-search-bar").LockerSearchBar
local LockerScrollingFrame = RuntimeLib.import(script, script.Parent, "locker-scrolling-frame").LockerScrollingFrame
local useWindow = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-window").useWindow
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local useLockerCosmetics =
	RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-locker-cosmetics").useLockerCosmetics
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
return {
	["LockerGui"] = function()
		local window = useWindow()
		local profile = useProfile()
		local lockerCosmeticsState = useLockerCosmetics({
			["Profile"] = profile,
		})
		local sidebarHeight = window.ContentFrameSize.Y
		local contentX = 480 + ScreenConstants.PADDING_3
		local contentWidth = window.ContentFrameSize.X - contentX
		local scrollingFrameHeight = window.ContentFrameSize.Y - 60
		return React.createElement(
			FullscreenWindow,
			{
				["key"] = "LockerGui",
				["Text"] = "LOCKER",
			},
			React.createElement(LockerSidebar, {
				["Size"] = UDim2.fromOffset(480, sidebarHeight),
				["Experience"] = profile.Experience,
			}),
			React.createElement(LockerSearchBar, {
				["Position"] = UDim2.fromOffset(contentX, 0),
				["Size"] = UDim2.fromOffset(contentWidth, 50),
				["LockerCosmeticsState"] = lockerCosmeticsState,
			}),
			React.createElement(LockerScrollingFrame, {
				["Position"] = UDim2.fromOffset(contentX, 60),
				["Size"] = UDim2.fromOffset(contentWidth, scrollingFrameHeight),
				["LockerCosmeticsState"] = lockerCosmeticsState,
			})
		)
	end,
}
