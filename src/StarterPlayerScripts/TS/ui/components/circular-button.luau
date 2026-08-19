-- CircularButton

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local RunService: RunService = Services.RunService
local TextService: TextService = Services.TextService
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local List = RuntimeLib.import(script, script.Parent, "list").List
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType

type CircularButtonProps = {
	Size: number,
	New: boolean?,
	Notifications: number?,
	Text: string,
	AbsorbInput: boolean?,
	Disabled: boolean?,
	Activated: () -> (),
	AnchorPoint: Vector2?,
	Position: UDim2?,
	LayoutOrder: number?,
	ImageAspectRatio: number?,
	Image: string,
	Color: Color3,
	[string]: any,
}

return {
	["CircularButton"] = function(props: CircularButtonProps)
		local _, setPressed = useState(false)
		local scale = props.Size / 120
		local badgeText
		if props.New then
			badgeText = "NEW"
		else
			local notifications = props.Notifications
			if notifications == 0 or (notifications ~= notifications or not notifications) then
				badgeText = nil
			elseif props.Notifications > 9 then
				badgeText = "9+"
			else
				local notifications = props.Notifications
				badgeText = tostring(notifications)
			end
		end
		local badgeTextSize
		if badgeText == "" or not badgeText then
			badgeTextSize = nil
		else
			badgeTextSize =
				TextService:GetTextSize(badgeText, 16 * scale, Enum.Font.GothamBlack, Vector2.new(42, 42) * scale)
		end
		local textSize = TextService:GetTextSize(
			string.upper(props.Text),
			18 * scale,
			Enum.Font.GothamBlack,
			Vector2.new(120, 120) * scale
		)
		local gridProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["ZIndex"] = 10,
			["LayoutOrder"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(props.Size + 6, props.Size + 6),
			["LayoutOrder"] = props.LayoutOrder,
		}
		local absorbInput = props.AbsorbInput
		if absorbInput == nil then
			absorbInput = false
		end
		gridProps.Active = absorbInput
		function gridProps.Activated(guiObject: GuiObject, input: InputObject)
			if not InputUtil.isModalInteract(input) then
				return nil
			end
			if props.Disabled then
				return nil
			end
			if RunService:IsRunning() then
				Flamework.resolveDependency("jL9"):playSound(RobloxSound.Button.DOWN, {
					["SoundGroup"] = SoundGroupType.Ui,
				})
				task.delay(0.05, function()
					Flamework.resolveDependency("jL9"):playSound(RobloxSound.Button.UP, {
						["SoundGroup"] = SoundGroupType.Ui,
					})
				end)
			end
			if guiObject.Parent then
				setPressed(true)
			end
			props.Activated()
		end
		local badge
		if badgeText == "" or not badgeText then
			badge = nil
		else
			local createElement = React.createElement
			local badgeGrid = Grid
			local badgeProps = {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["ZIndex"] = 3,
				["AnchorPoint"] = Vector2.new(0, 0),
				["Position"] = UDim2.new(1, -40 * scale, 0, -5 * scale),
			}
			local fromOffset = UDim2.fromOffset
			local badgeWidth
			if props.New then
				badgeWidth = badgeTextSize.X + 20 * scale
			else
				badgeWidth = 40 * scale
			end
			badgeProps.Size = fromOffset(badgeWidth, 40 * scale)
			badgeProps.BackgroundColor3 = Color3.fromRGB(221, 51, 51)
			badge = createElement(
				badgeGrid,
				badgeProps,
				React.createElement(Text, {
					["AnchorPoint"] = nil,
					["Position"] = nil,
					["Text"] = nil,
					["Font"] = nil,
					["TextSize"] = nil,
					["ZIndex"] = 5,
					["DropShadow"] = nil,
					["FixSize"] = true,
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Text"] = badgeText,
					["Font"] = Enum.Font.GothamBlack,
					["TextSize"] = (props.New and 16 or 24) * scale,
					["DropShadow"] = Vector2.new(0, 3),
				}),
				React.createElement("uipadding", {
					["PaddingLeft"] = UDim.new(0, 40 * scale),
					["PaddingRight"] = UDim.new(0, 40 * scale),
				}),
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(0, 40 * scale),
				})
			)
		end
		local imageProps = {}
		local imageSize = 60 * scale
		local imageAspectRatio = props.ImageAspectRatio
		imageProps.Size = UDim2.fromOffset(
			imageSize,
			(
				(imageAspectRatio == 0 or (imageAspectRatio ~= imageAspectRatio or not imageAspectRatio)) and 1
				or 1 / props.ImageAspectRatio
			)
				* 60
				* scale
		)
		return React.createElement(
			Grid,
			gridProps,
			badge,
			React.createElement(
				Grid,
				{
					["Size"] = UDim2.fromScale(1, 1),
					["BackgroundColor3"] = Color.White,
				},
				React.createElement(
					Grid,
					{
						["AnchorPoint"] = Vector2.new(0.5, 0.5),
						["Position"] = UDim2.fromScale(0.5, 0.5),
						["Size"] = UDim2.fromScale(0.95, 0.95),
						["BackgroundColor3"] = Color3.new(
							props.Color.R + 0.1,
							props.Color.G + 0.1,
							props.Color.B + 0.1
						),
					},
					React.createElement(
						Grid,
						{
							["AnchorPoint"] = Vector2.new(0.5, 0.5),
							["Position"] = UDim2.fromScale(0.5, 0.5),
							["Size"] = UDim2.fromOffset(props.Size - 10, props.Size - 10),
							["BackgroundColor3"] = props.Color,
						},
						React.createElement(
							Grid,
							imageProps,
							React.createElement(Image, {
								["Size"] = nil,
								["Image"] = nil,
								["ZIndex"] = 3,
								["DropShadow"] = nil,
								["Size"] = UDim2.fromScale(1, 1),
								["Image"] = props.Image,
								["DropShadow"] = Vector2.new(0, 3),
							})
						),
						React.createElement(
							Grid,
							{
								["Size"] = UDim2.fromOffset(textSize.X, textSize.Y),
							},
							React.createElement(Text, {
								["Size"] = nil,
								["Text"] = nil,
								["Font"] = nil,
								["TextSize"] = nil,
								["ZIndex"] = 5,
								["DropShadow"] = nil,
								["Size"] = UDim2.fromScale(1, 1),
								["Text"] = string.upper(props.Text),
								["Font"] = Enum.Font.GothamBlack,
								["TextSize"] = 18 * scale,
								["DropShadow"] = Vector2.new(0, 3),
							})
						),
						React.createElement(List, {
							["Vertical"] = true,
							["Padding"] = nil,
							["Padding"] = UDim.new(0, 8 * scale),
						}),
						React.createElement("uicorner", {
							["CornerRadius"] = UDim.new(1, 0),
						})
					),
					React.createElement("uicorner", {
						["CornerRadius"] = UDim.new(1, 0),
					})
				),
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1, 0),
				})
			)
		)
	end,
}
