-- GameTimer

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local useTimer = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-timer").useTimer
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local TextService: TextService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TextService
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef

type GameTimerProps = {
	StartTime: number,
}

return {
	["GameTimer"] = function(props: GameTimerProps)
		local textRef = useRef()
		local displayedTextRef = useRef()
		local updateTimer = nil

		local time = useTimer({
			["StartTime"] = props.StartTime,
			["Refs"] = { textRef },
			["OnUpdate"] = function(newTime: number)
				return updateTimer(newTime)
			end,
		})

		updateTimer = function(newTime: number)
			local formattedTime = TimeUtil.formatTime(newTime)
			local trimmedLength = #formattedTime - 2
			local timeText = string.sub(formattedTime, 0, trimmedLength)
			if displayedTextRef.current == timeText then
				return nil
			end
			displayedTextRef.current = timeText
			local textSize = TextService:GetTextSize(timeText .. "00", 24, Enum.Font.GothamBlack, Vector2.new(150, 50))
			local textElement = textRef.current
			if textElement then
				textElement.Size = UDim2.fromOffset(textSize.X, textSize.Y)
			end
		end

		local formattedTime = TimeUtil.formatTime(time)
		local trimmedLength = #formattedTime - 2
		local textSize = TextService:GetTextSize(
			string.sub(formattedTime, 0, trimmedLength) .. "00",
			24,
			Enum.Font.GothamBlack,
			Vector2.new(150, 50)
		)
		return React.createElement(
			Grid,
			{
				["AutomaticSize"] = nil,
				["BackgroundTransparency"] = 0.6,
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			React.createElement(Image, {
				["Size"] = UDim2.fromOffset(30, 30),
				["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
			}),
			React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["AutomaticSize"] = nil,
				["Text"] = nil,
				["TextSize"] = 24,
				["TextXAlignment"] = nil,
				["Bold"] = true,
				["Ref"] = nil,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 40, 0.5, 0),
				["Size"] = UDim2.fromOffset(textSize.X, textSize.Y),
				["AutomaticSize"] = Enum.AutomaticSize.None,
				["Text"] = TimeUtil.formatTime(time),
				["TextXAlignment"] = Enum.TextXAlignment.Left,
				["Ref"] = textRef,
			}),
			React.createElement("uipadding", {
				["PaddingTop"] = UDim.new(0, 10),
				["PaddingRight"] = UDim.new(0, 10),
				["PaddingBottom"] = UDim.new(0, 10),
				["PaddingLeft"] = UDim.new(0, 10),
			}),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
