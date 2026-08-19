-- CustomGameServerKey

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Emoji = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "emoji").Emoji
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type Props = {
	IsCustomGame: boolean,
	IsCustomOwner: boolean,
	CustomGamePrivacy: string,
	CustomGameServerKey: string,
}

return {
	["CustomGameServerKey"] = function(props: Props)
		if not props.IsCustomGame then
			return React.createElement(React.Fragment)
		end
		if not props.IsCustomOwner and props.CustomGamePrivacy ~= "Public" then
			return React.createElement(React.Fragment)
		end
		local textProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Text"] = ("%* CODE: %*"):format(Emoji.Hashtag, props.CustomGameServerKey)
		})
		local textElementProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5)
		}
		for key, value in textProps do
			textElementProps[key] = value
		end
		return React.createElement(Grid, {
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["LayoutOrder"] = 5,
			["CornerRadius"] = 100,
			["Size"] = UDim2.fromOffset(textProps.Size.X.Offset + 40, 80)
		}, React.createElement(Text, textElementProps))
	end
}
