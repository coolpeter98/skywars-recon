-- ProximityPromptGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local useWindow: () -> { ContentFrameSize: Vector2 } =
	RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-window").useWindow
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["ProximityPromptGui"] = function(_)
		local window = useWindow()
		local promptHeight = window.ContentFrameSize.Y
		local promptWidth = 480 + ScreenConstants.PADDING_3
		local availableWidth = window.ContentFrameSize.X - promptWidth
		local availableHeight = window.ContentFrameSize.Y - 60
		return React.createElement(Grid)
	end,
}
