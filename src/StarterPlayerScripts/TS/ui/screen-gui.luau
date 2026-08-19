-- ScreenGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UserInputService: UserInputService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").UserInputService
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local ScreenUtil = RuntimeLib.import(script, script.Parent, "util", "screen-util").ScreenUtil
local CameraViewportContext = RuntimeLib.import(script, script.Parent, "context", "camera-viewport-context").CameraViewportContext
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local useCameraViewport = RuntimeLib.import(script, script.Parent, "hooks", "use-camera-viewport").useCameraViewport
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useScreen = RuntimeLib.import(script, script.Parent, "context", "screen-context").useScreen
return {
	ScreenGui = function(props: { children: any? })
		local screen = useScreen()
		local options = screen.ScreenHandler.Options
		local viewport = useCameraViewport({
			MobileScale = options.MobileScale,
		})
		useEffect(function()
			if not options.Focused then
				return nil
			end
			local maid = Maid.new()
			maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
				if gameProcessed then
					return nil
				end
				if InputUtil.isGamepadClose(inputObject) then
					screen.Close()
				end
			end))
			return function()
				return maid:DoCleaning()
			end
		end, {})
		local createElement = React.createElement
		local screenGuiTag = "screengui"
		local screenGuiProps = {
			key = nil,
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			DisplayOrder = nil,
			ZIndexBehavior = nil,
			key = screen.ScreenHandler.ScreenName,
		}
		local displayOrder
		if options.DisplayOrder == nil then
			displayOrder = options.Focused and -1 or 0
		else
			displayOrder = options.DisplayOrder
		end
		screenGuiProps.DisplayOrder = displayOrder
		screenGuiProps.ZIndexBehavior = options.ZIndexBehavior
		local viewportProvider = createElement(CameraViewportContext.Provider, {
			value = viewport,
		}, props.children)
		local scaleElement
		if options.DisableScaling then
			scaleElement = nil
		else
			scaleElement = createElement("uiscale", {
				Scale = viewport.Scale,
			})
		end
		local closeFrameElement
		if options.Focused and options.FocusedAllowClose ~= false then
			closeFrameElement = createElement("frame", {
				key = "CloseFrame",
				Size = nil,
				BackgroundColor3 = nil,
				BackgroundTransparency = nil,
				Event = nil,
				Active = true,
				ZIndex = -100,
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color.Black,
				BackgroundTransparency = options.ShowBackground and 0.7 or 1,
				Event = {
					InputBegan = function(_, inputObject)
						if ScreenUtil.shouldClose(inputObject) then
							screen.Close()
						end
					end,
				},
			})
		else
			closeFrameElement = nil
		end
		return createElement(screenGuiTag, screenGuiProps, viewportProvider, scaleElement, closeFrameElement)
	end,
}
