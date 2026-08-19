-- MobileButtonGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useState = React.useState
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CameraViewportContext = RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local MobileButtons = RuntimeLib.import(script, script.Parent.Parent.Parent, "mobile-button", "mobile-button").MobileButtons

type Props = {
	DefaultActive: boolean?,
	MobileButtonId: string,
	Position: UDim2,
}

return {
	["MobileButtonGui"] = function(props: Props)
		local defaultActive = props.DefaultActive
		if defaultActive == nil then
			defaultActive = false
		end
		local active, setActive = useState(defaultActive)
		local viewport = useContext(CameraViewportContext)
		local isSmallScreen: boolean = ScreenUtil.isSmallScreen()
		local buttonSize: number = isSmallScreen and 70 or 120
		local iconSize: number = isSmallScreen and 40 or 70
		local buttonData = MobileButtons[props.MobileButtonId]
		local createElement = React.createElement
		local gridProps = {
			["Active"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["BackgroundTransparency"] = 0.6,
			["BorderSizePixel"] = 0,
			["Activated"] = nil,
			["Active"] = buttonData.Active,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(buttonSize, buttonSize)
		}
		local backgroundColor
		if active then
			backgroundColor = Color.White
		else
			backgroundColor = Color.Black
		end
		gridProps.BackgroundColor3 = backgroundColor
		function gridProps.Activated(_, inputObject: InputObject)
			if not InputUtil.isModalInteract(inputObject) then
				return nil
			end
			buttonData.Activated(inputObject)
			setActive(not buttonData.Toggle and true or not active)
			local maid = Maid.new()
			maid:GiveTask(inputObject:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if inputObject.UserInputState ~= Enum.UserInputState.Cancel and inputObject.UserInputState ~= Enum.UserInputState.End then
					return nil
				end
				maid:DoCleaning()
				if not buttonData.Toggle then
					setActive(false)
				end
			end))
		end
		local imageLabelType = "imagelabel"
		local imageProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ImageColor3"] = nil,
			["ImageTransparency"] = 0.6,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(iconSize, iconSize),
			["Image"] = buttonData.Image
		}
		local imageColor
		if active then
			imageColor = Color.Black
		else
			imageColor = Color.White
		end
		imageProps.ImageColor3 = imageColor
		return createElement(Grid, gridProps, createElement(imageLabelType, imageProps), React.createElement("uistroke", {
			["Color"] = nil,
			["Thickness"] = nil,
			["Transparency"] = 0.6,
			["Color"] = buttonData.Color,
			["Thickness"] = viewport.Scale * 5
		}), React.createElement("uicorner", {
			["CornerRadius"] = UDim.new(1, 0)
		}))
	end
}
