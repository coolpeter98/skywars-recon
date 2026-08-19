-- AlivePlayers

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local TextService: TextService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TextService
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef

type AlivePlayersProps = {
	Alive: number,
	Total: number,
}

local function AlivePlayers(props: AlivePlayersProps)
	local textRef = useRef()
	local text: string = ("%* / %*"):format(props.Alive, props.Total)
	local textSize: Vector2 = TextService:GetTextSize(text, 24, Enum.Font.GothamBlack, Vector2.new(150, 50))
	return React.createElement(Grid, {
		["AutomaticSize"] = nil,
		["BackgroundTransparency"] = 0.6,
		["AutomaticSize"] = Enum.AutomaticSize.XY
	}, React.createElement(Image, {
		["Size"] = UDim2.fromOffset(30, 30),
		["Image"] = RobloxImage.Icon.PEOPLE
	}), React.createElement(Text, {
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
		["Text"] = text,
		["TextXAlignment"] = Enum.TextXAlignment.Left,
		["Ref"] = textRef
	}), React.createElement("uipadding", {
		["PaddingTop"] = UDim.new(0, 10),
		["PaddingRight"] = UDim.new(0, 10),
		["PaddingBottom"] = UDim.new(0, 10),
		["PaddingLeft"] = UDim.new(0, 10)
	}), React.createElement(CornerRadius, {
		["Radius"] = 10
	}))
end

return {
	["AlivePlayers"] = AlivePlayers
}
