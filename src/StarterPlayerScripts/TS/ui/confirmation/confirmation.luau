-- Confirmation

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useRef = React.useRef
local useState = React.useState

export type ConfirmationProps = {
	Title: string?,
	Text: string?,
	OnConfirm: (() -> ())?,
	Close: () -> (),
	CloseDelay: number?,
	SubmittedText: string?,
	IsOpen: () -> boolean,
}

return {
	["Confirmation"] = function(props: ConfirmationProps)
		local textRef = useRef()
		local submitted, setSubmitted = useState(false)

		local windowProps = {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(530, 280),
		}
		local title = props.Title
		windowProps.TitleText = title == nil and "CONFIRM" or title
		windowProps.TitleImage = RobloxImage.Icon.CIRCLE_CHECK

		local textElement = React.createElement(Text, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, -30),
			Size = UDim2.fromOffset(510, 200),
			AutomaticSize = Enum.AutomaticSize.None,
			Text = props.Text,
			Bold = true,
			TextWrapped = true,
			Ref = textRef,
		})

		local cancelButton
		if props.OnConfirm then
			cancelButton = React.createElement(Button, {
				AbsorbInput = true,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 10, 1, -10),
				Size = { 160, 50 },
				Text = submitted and "Close" or "Cancel",
				Color = Color.Button.Grey,
				Activated = function()
					props.Close()
				end,
			})
		else
			cancelButton = nil
		end

		local confirmButton
		if submitted then
			confirmButton = nil
		else
			confirmButton = React.createElement(Button, {
				AbsorbInput = true,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -10, 1, -10),
				Size = { 160, 50 },
				Text = props.OnConfirm and "Confirm" or "Close",
				Color = Color.Button.Green,
				Activated = function()
					if not props.OnConfirm then
						props.Close()
						return nil
					end
					props.OnConfirm()
					if not textRef.current or props.CloseDelay == nil then
						props.Close()
						return nil
					end
					setSubmitted(true)
					textRef.current.Text = props.SubmittedText == nil and "" or props.SubmittedText
					task.spawn(function()
						task.wait(props.CloseDelay)
						if props.IsOpen() then
							props.Close()
						end
					end)
				end,
			})
		end

		return React.createElement(Window, windowProps, textElement, cancelButton, confirmButton)
	end,
}
