-- TextUtil: builds full TextLabel-style props from a smaller set of input props.

local TextService: TextService = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TextService

type GetTextProps = {
	Bold: boolean?,
	TextSize: number?,
	FrameSize: Vector2?,
	Text: string,
	Color: Color3?,
}

return {
	["getTextProps"] = function(props: GetTextProps)
		local font
		if props.Bold then
			font = Enum.Font.GothamBlack
		else
			font = Enum.Font.Gotham
		end
		local textSize = props.TextSize
		local resolvedTextSize = textSize == nil and 24 or textSize
		local frameSize = props.FrameSize or Vector2.new(1920, 1080)
		local textBounds = TextService:GetTextSize(props.Text, resolvedTextSize, font, frameSize)
		return {
			["Size"] = UDim2.fromOffset(textBounds.X, textBounds.Y),
			["AutomaticSize"] = Enum.AutomaticSize.None,
			["Text"] = props.Text,
			["TextSize"] = resolvedTextSize,
			["Font"] = font,
			["TextColor3"] = props.Color
		}
	end
}
