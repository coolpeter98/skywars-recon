-- useWindow

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CameraViewportContext = RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local useContext = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react").useContext

return {
	["useWindow"] = function(): { ContentFrameSize: Vector2 }
		local cameraViewport = useContext(CameraViewportContext)
		local inverseScale = 1 / cameraViewport.Scale
		local contentWidth = cameraViewport.ViewportSize.X * inverseScale - ScreenConstants.PADDING_3 * 2
		local contentHeight = cameraViewport.ViewportSize.Y * inverseScale - ScreenConstants.TOP_BAR_HEIGHT - ScreenConstants.PADDING_3 * 2
		return {
			["ContentFrameSize"] = Vector2.new(contentWidth, contentHeight)
		}
	end
}
