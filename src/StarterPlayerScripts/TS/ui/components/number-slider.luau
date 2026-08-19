-- NumberSlider

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local TextService: TextService = Services.TextService
local UserInputService: UserInputService = Services.UserInputService
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef

export type NumberSliderProps = {
	Value: number,
	SetValue: (value: number) -> (),
	Min: number,
	Max: number,
	Released: ((value: number) -> ())?,
	Size: UDim2?,
	BackgroundColor3: Color3?,
	Ref: { current: GuiObject? }?,
	LayoutOrder: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	ZIndex: number?,
	Activated: ((button: GuiButton, inputObject: InputObject) -> ())?,
	[string]: any,
}

return {
	["NumberSlider"] = function(props: NumberSliderProps)
		local trackRef = useRef()
		local buttonRef = useRef()
		local restProps = table.clone(props)
		setmetatable(restProps, nil)
		restProps.Size = nil
		restProps.Value = nil
		restProps.SetValue = nil
		restProps.Min = nil
		restProps.Max = nil
		restProps.Released = nil
		local textService = TextService
		local maxValue = props.Max
		local maxTextSize =
			textService:GetTextSize(tostring(maxValue), 24, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
		local gridProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["AutomaticSize"] = Enum.AutomaticSize.XY,
		}
		for key, value in restProps do
			gridProps[key] = value
		end
		local createElement = React.createElement
		local grid = Grid
		local track = createElement(
			Grid,
			{
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["LayoutOrder"] = 2,
				["Ref"] = nil,
				["Size"] = props.Size,
				["BackgroundColor3"] = Color.White,
				["Ref"] = trackRef,
			},
			createElement(
				Grid,
				{
					["key"] = "ButtonHitBox",
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Size"] = nil,
					["ZIndex"] = 10,
					["Ref"] = nil,
					["Activated"] = nil,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale((props.Value - props.Min) / (props.Max - props.Min), 0.5),
					["Size"] = UDim2.fromOffset(40, 40),
					["Ref"] = buttonRef,
					["Activated"] = function(_, inputObject: InputObject)
						if not InputUtil.isModalInteract(inputObject) then
							return nil
						end
						local maid = Maid.new()
						local value = props.Value
						maid:GiveTask(inputObject:GetPropertyChangedSignal("UserInputState"):Connect(function()
							if
								inputObject.UserInputState ~= Enum.UserInputState.Cancel
								and inputObject.UserInputState ~= Enum.UserInputState.End
							then
								return nil
							end
							maid:DoCleaning()
							if props.Released then
								props.Released(value)
							end
						end))
						local function handleDrag(mousePosition: Vector2)
							if not (buttonRef.current and trackRef.current) then
								return nil
							end
							local relativeX = (mousePosition - trackRef.current.AbsolutePosition).X
								/ trackRef.current.AbsoluteSize.X
							local clamped = math.clamp(relativeX, 0, 1)
							buttonRef.current.Position = UDim2.fromScale(clamped, 0.5)
							local rawValue = clamped * (props.Max - props.Min) + props.Min
							value = math.round(rawValue)
							local preMinValue = value
							local minValue = props.Min
							value = math.max(preMinValue, minValue)
							local preMaxValue = value
							local maxValue = props.Max
							value = math.min(preMaxValue, maxValue)
							if value ~= props.Value then
								props.SetValue(value)
							end
						end
						if ScreenUtil.isMobile() then
							maid:GiveTask(UserInputService.TouchMoved:Connect(function(touchInput: InputObject)
								handleDrag((Vector2.new(touchInput.Position.X, touchInput.Position.Y)))
							end))
						else
							maid:GiveTask(UserInputService.InputChanged:Connect(function(input: InputObject)
								if input.UserInputType ~= Enum.UserInputType.MouseMovement then
									return nil
								end
								handleDrag((UserInputService:GetMouseLocation()))
							end))
						end
					end,
				},
				createElement(
					Grid,
					{
						["key"] = "Button",
						["AnchorPoint"] = nil,
						["Position"] = nil,
						["Size"] = nil,
						["BackgroundColor3"] = nil,
						["AnchorPoint"] = Vector2.new(0.5, 0.5),
						["Position"] = UDim2.fromScale(0.5, 0.5),
						["Size"] = UDim2.fromOffset(24, 24),
						["BackgroundColor3"] = Color.Green,
					},
					createElement("uicorner", {
						["CornerRadius"] = UDim.new(1, 0),
					})
				)
			),
			createElement("uicorner", {
				["CornerRadius"] = UDim.new(1, 0),
			})
		)
		local createTextElement = React.createElement
		local text = Text
		local textProps = {
			["Text"] = nil,
			["Size"] = nil,
			["TextXAlignment"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["LayoutOrder"] = 3,
		}
		local value = props.Value
		textProps.Text = tostring(value)
		textProps.Size = UDim2.fromOffset(maxTextSize.X + 10, maxTextSize.Y)
		textProps.TextXAlignment = Enum.TextXAlignment.Right
		return createElement(
			grid,
			gridProps,
			track,
			createTextElement(text, textProps),
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["Padding"] = UDim.new(0, 10),
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
				["VerticalAlignment"] = Enum.VerticalAlignment.Center,
			})
		)
	end,
}
