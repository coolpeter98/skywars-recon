-- BaseGrid

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local UserInputService: UserInputService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).UserInputService
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local omit = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "object", "omit").omit

type BaseGridProps = {
	TitleText: string?,
	TitleTextSize: number?,
	TitleImage: string?,
	TitleImageSize: number?,
	TitleAnchorPoint: Vector2?,
	TitlePosition: UDim2?,
	Activated: ((input: InputObject?, guiObject: GuiObject?) -> ())?,
	children: any?,
	Event: { [string]: any }?,
	ActivateReroute: boolean?,
	Ref: any?,
	BackgroundColor3: Color3?,
	[string]: any,
}

type EventHandlers = {
	TouchTap: (input: InputObject) -> (),
	InputBegan: (input: InputObject, guiObject: GuiObject) -> (),
	SelectionGained: (guiObject: GuiObject) -> (),
	SelectionLost: (guiObject: GuiObject) -> (),
	[string]: any,
}

return {
	["BaseGrid"] = function(props: BaseGridProps)
		local remainingProps = omit(
			omit(props, {
				"TitleText",
				"TitleTextSize",
				"TitleImage",
				"TitleImageSize",
				"TitleAnchorPoint",
				"TitlePosition",
			}),
			{
				"Activated",
				"children",
				"Event",
				"ActivateReroute",
				"Ref",
			}
		)
		local connection: RBXScriptConnection?, setConnection: (connection: RBXScriptConnection?) -> () = useState(nil)
		local frameProps = {}
		local activateReroute = props.ActivateReroute
		if activateReroute == nil then
			activateReroute = false
		end
		frameProps.Active = activateReroute
		frameProps.BackgroundColor3 = Color.Black
		frameProps.BackgroundTransparency = props.BackgroundColor3 and 0 or 1
		frameProps.BorderSizePixel = 0
		frameProps.ref = props.Ref
		for key, value in remainingProps do
			frameProps[key] = value
		end
		local events: EventHandlers = {}
		local userEvents = props.Event
		if userEvents then
			for key, value in userEvents do
				events[key] = value
			end
		end
		function events.TouchTap(input: InputObject)
			if not props.ActivateReroute then
				return nil
			end
			local activated = props.Activated
			if activated ~= nil then
				activated(input, nil)
			end
		end
		function events.InputBegan(input: InputObject, guiObject: GuiObject)
			if props.ActivateReroute and InputUtil.isMobileInteract(guiObject) then
				return nil
			end
			local userEvents = props.Event
			if userEvents ~= nil then
				local eventHandler = userEvents.InputBegan
				if eventHandler ~= nil then
					eventHandler(input, guiObject)
				end
			end
			if not InputUtil.isModalInteract(guiObject) then
				return nil
			end
			if
				guiObject.UserInputState == Enum.UserInputState.Change
				and guiObject.UserInputType == Enum.UserInputType.Touch
			then
				return nil
			end
			local activated = props.Activated
			if activated ~= nil then
				activated(input, guiObject)
			end
		end
		function events.SelectionGained(guiObject: GuiObject)
			local userEvents = props.Event
			if userEvents ~= nil then
				local eventHandler = userEvents.SelectionGained
				if eventHandler ~= nil then
					eventHandler(guiObject)
				end
			end
			local inputConnection = UserInputService.InputBegan:Connect(function(input: InputObject)
				if input.KeyCode == Enum.KeyCode.ButtonA then
					local activated = props.Activated
					if activated ~= nil then
						activated(guiObject, input)
					end
				end
			end)
			setConnection(inputConnection)
			guiObject.Destroying:Connect(function()
				inputConnection:Disconnect()
			end)
		end
		function events.SelectionLost(guiObject: GuiObject)
			local userEvents = props.Event
			if userEvents ~= nil then
				local eventHandler = userEvents.SelectionLost
				if eventHandler ~= nil then
					eventHandler(guiObject)
				end
			end
			if connection then
				connection:Disconnect()
				if not guiObject.Parent then
					return nil
				end
				setConnection(nil)
			end
		end
		frameProps.Event = events
		return React.createElement("frame", frameProps, props.children)
	end,
}
