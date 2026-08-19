-- GameStatus

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local GameState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-state").GameState
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local useState = React.useState
local useTimer = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-timer").useTimer
local GameConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-constants").GameConstants
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps

type GameStatusProps = {
	GameStateChangeTime: number,
	GameState: "Pregame" | "Countdown" | "InGame" | "Ended",
}

return {
	["GameStatus"] = function(props: GameStatusProps)
		local textRef = useRef()
		local remainingTime, setRemainingTime = useState(10)
		useTimer({
			["EndTime"] = props.GameStateChangeTime + GameConstants.PREGAME_DURATION,
			["OnUpdate"] = function(newTime)
				return setRemainingTime(newTime)
			end
		})
		local statusText
		if props.GameState == GameState.Pregame then
			local roundedTime = math.round(remainingTime)
			statusText = not GameConstants.PREGAME_LOBBY_ENABLED and "Waiting for players..." or (roundedTime <= 0 and "Starting now..." or ("Starting in %*..."):format(roundedTime))
		else
			statusText = nil
		end
		if statusText == "" or not statusText then
			return React.createElement(React.Fragment)
		end
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Text"] = not GameConstants.PREGAME_LOBBY_ENABLED and "Waiting for players..." or ("Starting in %*..."):format(60)
		})
		return React.createElement(Grid, {
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Size"] = UDim2.fromOffset(textProps.Size.X.Offset + 40, textProps.Size.Y.Offset + 20)
		}, React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Ref"] = nil,
			["FixSize"] = true,
			["TextXAlignment"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(textProps.Size.X.Offset, textProps.Size.Y.Offset),
			["Text"] = statusText,
			["Ref"] = textRef,
			["TextXAlignment"] = Enum.TextXAlignment.Left
		}), React.createElement(CornerRadius, {
			["Radius"] = 10
		}))
	end
}
