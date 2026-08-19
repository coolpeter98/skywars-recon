-- useCameraViewport

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local Workspace: Workspace = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

type CameraViewportInfo = {
	Scale: number,
	AspectRatio: number,
	ViewportSize: Vector2,
}

return {
	["useCameraViewport"] = function(props)
		local function getCameraViewport(): CameraViewportInfo
			local viewportData = {
				["Scale"] = ScreenUtil.getScale(props.MobileScale),
				["AspectRatio"] = ScreenUtil.getAspectRatio(),
			}
			local viewportSize = Workspace.CurrentCamera
			if viewportSize ~= nil then
				viewportSize = viewportSize.ViewportSize
			end
			if viewportSize == nil then
				viewportSize = Vector2.new(1920, 1080)
			end
			viewportData.ViewportSize = viewportSize
			return viewportData
		end
		local viewportInfo, setViewportInfo = useState(getCameraViewport)
		useEffect(function()
			if not Workspace.CurrentCamera then
				return nil
			end
			local viewportChangedConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				setViewportInfo(getCameraViewport)
			end)
			return function()
				return viewportChangedConnection:Disconnect()
			end
		end, { Workspace.CurrentCamera })
		return viewportInfo
	end,
}
