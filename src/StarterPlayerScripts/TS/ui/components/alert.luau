-- Alert

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Outline = RuntimeLib.import(script, script.Parent, "outline").Outline
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local RunService: RunService = Services.RunService
local TweenService: TweenService = Services.TweenService
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

export type AlertProps = {
	Thickness: number,
	ZIndex: number?,
	AnchorPoint: Vector2,
	Position: UDim2,
	Size: UDim2,
}

local tweenOutlinePulse: (outline: UIStroke, thickness: number) -> ()

local function Alert(props: AlertProps)
	local spotlightRef = useRef()
	local outlineRef = useRef()

	useEffect(function()
		local spotlight = spotlightRef.current
		if not spotlight then
			return nil
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
			local rotationStep = deltaTime / 0.016666666666666666
			spotlight.Rotation = (spotlight.Rotation + rotationStep) % 360
		end)

		return function()
			return heartbeatConnection:Disconnect()
		end
	end, { spotlightRef })

	useEffect(function()
		local outline = outlineRef.current
		if not outline then
			return nil
		end

		local schedule = ScheduleUtil.createSchedule(2, function()
			return tweenOutlinePulse(outline, props.Thickness)
		end)

		return function()
			return schedule:Disconnect()
		end
	end, { outlineRef })

	local zIndex = props.ZIndex
	local baseZIndex = zIndex == nil and 1 or zIndex
	return React.createElement(
		Grid,
		{
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size:ToUDim2(),
			["ZIndex"] = baseZIndex + 1,
		},
		React.createElement(Image, {
			["key"] = "Spotlight",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ZIndex"] = nil,
			["Ref"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(128, 128),
			["Image"] = RobloxImage.SPOTLIGHT,
			["ZIndex"] = baseZIndex,
			["Ref"] = spotlightRef,
		}),
		React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromScale(1, 1),
				["BackgroundColor3"] = Color.White,
				["ZIndex"] = baseZIndex + 1,
			},
			React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = props.Size:div(2):ToUDim2(),
				["Image"] = RobloxImage.Icon.BELL,
				["ZIndex"] = baseZIndex + 2,
			}),
			React.createElement("uigradient", {
				["Rotation"] = 90,
				["Color"] = nil,
				["Color"] = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 54, 54)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 103, 103)),
				}),
			}),
			React.createElement(Outline, {
				["Color"] = Color3.fromRGB(255, 103, 103),
				["Thickness"] = props.Thickness,
			}),
			React.createElement(
				Grid,
				{
					["key"] = "Pulse",
					["Position"] = nil,
					["Size"] = nil,
					["ZIndex"] = nil,
					["Position"] = UDim2.fromOffset(-props.Thickness, -props.Thickness),
					["Size"] = UDim2.new(1, props.Thickness * 2, 1, props.Thickness * 2),
					["ZIndex"] = baseZIndex + 2,
				},
				React.createElement("uicorner", {
					["CornerRadius"] = UDim.new(1),
				}),
				React.createElement(Outline, {
					["Color"] = nil,
					["Thickness"] = 0,
					["Ref"] = nil,
					["Color"] = Color3.fromRGB(255, 103, 103),
					["Ref"] = outlineRef,
				})
			),
			React.createElement("uicorner", {
				["CornerRadius"] = UDim.new(1),
			})
		)
	)
end

tweenOutlinePulse = function(outline: UIStroke, thickness: number)
	local tween = TweenService:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		["Thickness"] = nil,
		["Transparency"] = 1,
		["Thickness"] = thickness,
	})
	tween.Completed:Connect(function()
		outline.Thickness = 0
		outline.Transparency = 0
	end)
	tween:Play()
end

return {
	["Alert"] = Alert,
}
