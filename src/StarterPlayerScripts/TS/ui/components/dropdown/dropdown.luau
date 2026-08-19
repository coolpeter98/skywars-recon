-- Dropdown

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Button = RuntimeLib.import(script, script.Parent.Parent, "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent.Parent, "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Text = RuntimeLib.import(script, script.Parent.Parent, "text").Text
local Grid = RuntimeLib.import(script, script.Parent.Parent, "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "list").List
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "screen-util").ScreenUtil
local DropdownOption = RuntimeLib.import(script, script.Parent, "dropdown-option").DropdownOption
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "corner-radius").CornerRadius
local UserInputService: UserInputService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).UserInputService
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "util", "input-util").InputUtil
local VectorUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

type DropdownItem = {
	Id: string,
	Image: string,
	Text: string,
}

type DropdownProps = {
	Items: { DropdownItem },
	SelectedId: string,
	SetSelectedId: (id: string) -> (),
	Size: Vector2,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["Dropdown"] = function(props: DropdownProps)
		local isOpen, setIsOpen = useState(false)
		local dropdownRef = useRef()
		local selectedItem = nil
		for index, item in props.Items do
			local _ = index - 1
			if item.Id == props.SelectedId == true then
				selectedItem = item
				break
			end
		end
		if selectedItem == nil then
			selectedItem = props.Items[1]
		end
		useEffect(function()
			local connection = UserInputService.InputBegan:Connect(function(input)
				if not InputUtil.isModalInteract(input) then
					return nil
				end
				local inputPosition = Vector2.new(input.Position.X, input.Position.Y)
				local frame = dropdownRef.current
				if not frame then
					return nil
				end
				local framePosition = frame.AbsolutePosition
				local frameBottomRight = framePosition + frame.AbsoluteSize
				if not VectorUtil.isInAABB2(inputPosition, framePosition, frameBottomRight) then
					setIsOpen(false)
				end
			end)
			return function()
				return connection:Disconnect()
			end
		end, {})
		local buttonElement = React.createElement(
			Button,
			{
				["key"] = "Button",
				["Size"] = nil,
				["Color"] = nil,
				["Activated"] = nil,
				["Size"] = { props.Size.X, props.Size.Y },
				["Color"] = Color.Button.Grey,
				["Activated"] = function()
					return setIsOpen(function(isOpen)
						return not isOpen
					end)
				end,
			},
			React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["TextXAlignment"] = nil,
				["TextYAlignment"] = nil,
				["Text"] = nil,
				["TextSize"] = 24,
				["Bold"] = true,
				["ZIndex"] = 20,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 20, 0.5, 0),
				["TextXAlignment"] = Enum.TextXAlignment.Left,
				["TextYAlignment"] = Enum.TextYAlignment.Center,
				["Text"] = string.upper(selectedItem.Text),
			}),
			React.createElement(Image, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ZIndex"] = 20,
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.new(1, -20, 0.5, 0),
				["Size"] = UDim2.fromOffset(30, 30),
				["Image"] = RobloxImage.Icon.DROPDOWN,
			})
		)
		local listElement
		if isOpen then
			local items = props.Items
			local elements = table.create(#items)
			local function createOptionElement(item, index)
				return React.createElement(DropdownOption, {
					["key"] = item.Id,
					["Size"] = props.Size,
					["Image"] = item.Image,
					["Text"] = item.Text,
					["LayoutOrder"] = index,
					["FirstItem"] = index == 0,
					["LastItem"] = index == #props.Items - 1,
					["Activated"] = function()
						setIsOpen(false)
						props.SetSelectedId(item.Id)
					end,
				})
			end
			for i, item in items do
				elements[i] = createOptionElement(item, i - 1, items)
			end
			listElement = React.createElement(
				Grid,
				{
					["key"] = "List",
					["Position"] = nil,
					["Size"] = nil,
					["BackgroundColor3"] = nil,
					["ZIndex"] = 20,
					["Position"] = UDim2.fromOffset(0, 50),
					["Size"] = UDim2.fromOffset(
						props.Size.X,
						ScreenUtil.getGridSize(props.Size.Y, 4, #props.Items) + 4
					),
					["BackgroundColor3"] = Color3.fromRGB(92, 92, 92),
				},
				elements,
				React.createElement(CornerRadius, {
					["Radius"] = 10,
				}),
				React.createElement(List, {
					["Vertical"] = true,
					["Padding"] = nil,
					["VerticalAlignment"] = nil,
					["Padding"] = UDim.new(0, 4),
					["VerticalAlignment"] = Enum.VerticalAlignment.Top,
				})
			)
		else
			listElement = nil
		end
		return React.createElement(Grid, {
			["key"] = "Dropdown",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["AutomaticSize"] = nil,
			["Ref"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["AutomaticSize"] = Enum.AutomaticSize.XY,
			["Ref"] = dropdownRef,
		}, buttonElement, listElement)
	end,
}
