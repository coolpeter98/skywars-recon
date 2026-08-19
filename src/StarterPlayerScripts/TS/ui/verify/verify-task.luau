-- VerifyTask

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type VerifyTaskProps = {
	Icon: string,
	Task: string,
	Completed: boolean,
}

return {
	["VerifyTask"] = function(props: VerifyTaskProps)
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Size"] = UDim2.fromOffset(500, 60),
		}
		local createElement = React.createElement
		local image = Image
		local imageProps = {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 12, 0.5, 0),
			["Size"] = UDim2.fromOffset(24, 24),
			["Image"] = props.Icon,
		}
		local imageColor3
		if props.Completed then
			imageColor3 = Color.HealthGreen
		else
			imageColor3 = Color3.fromRGB(117, 124, 119)
		end
		imageProps.ImageColor3 = imageColor3
		return createElement(
			grid,
			gridProps,
			createElement(image, imageProps),
			React.createElement(Text, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = nil,
				["TextXAlignment"] = nil,
				["Bold"] = true,
				["RichText"] = true,
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0, 48, 0.5, 0),
				["Size"] = UDim2.new(1, -48, 1, 0),
				["Text"] = props.Task,
				["TextXAlignment"] = Enum.TextXAlignment.Left,
			}),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
