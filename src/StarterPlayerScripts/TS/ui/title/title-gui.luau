-- TitleGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type TitleGuiProps = {
	Title: string,
	Color: Color3,
	Styled: boolean?,
}

return {
	["TitleGui"] = function(props: TitleGuiProps)
		local textProps = table.clone(props)
		setmetatable(textProps, nil)
		textProps.Title = nil
		textProps.Color = nil
		textProps.Styled = nil

		local baseTextProps = {
			["ZIndex"] = 10,
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["TextSize"] = 100,
			["DropShadow"] = nil,
			["TextColor3"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Text"] = ("%*"):format(props.Title),
		}

		local dropShadow: Vector2?
		if props.Styled then
			dropShadow = nil
		else
			dropShadow = Vector2.new(0, 8)
		end

		baseTextProps.DropShadow = dropShadow
		baseTextProps.TextColor3 = props.Color

		for key, value in textProps do
			baseTextProps[key] = value
		end

		local baseTextElement = React.createElement(Text, baseTextProps)

		local styledTextElement
		if props.Styled then
			local styledTextProps = {
				["ZIndex"] = 4,
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["Bold"] = true,
				["TextSize"] = 100,
				["Transparency"] = 1,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Text"] = ("%*"):format(props.Title),
			}

			for key, value in textProps do
				styledTextProps[key] = value
			end

			styledTextElement = React.createElement(
				Text,
				styledTextProps,
				React.createElement("uistroke", {
					["Thickness"] = 3,
					["Color"] = nil,
					["LineJoinMode"] = nil,
					["Color"] = Color.White,
					["LineJoinMode"] = Enum.LineJoinMode.Miter,
				})
			)
		else
			styledTextElement = nil
		end

		return React.createElement(React.Fragment, nil, baseTextElement, styledTextElement)
	end,
}
