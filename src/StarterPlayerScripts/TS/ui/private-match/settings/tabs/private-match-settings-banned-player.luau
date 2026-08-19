-- PrivateMatchSettingsBannedPlayer

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local CornerRadius =
	RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "player-icon").PlayerIcon
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent.Parent, "components", "button").Button

local function sumStringBytes(text: string): number
	local bytes = { string.byte(text) }
	local sum = 0
	for i = 1, #bytes do
		local byte = bytes[i]
		sum = sum + byte
	end
	return sum
end

return {
	["PrivateMatchSettingsBannedPlayer"] = function(props: { Player: Player })
		return React.createElement(
			Grid,
			{
				Size = UDim2.fromOffset(650, 84),
				BackgroundTransparency = 0.6,
				LayoutOrder = sumStringBytes(props.Player.DisplayName),
			},
			React.createElement(PlayerIcon, {
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.fromOffset(64, 64),
				UserId = props.Player.UserId,
			}),
			React.createElement(Text, {
				Bold = true,
				FixSize = true,
				LayoutOrder = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 84, 0.5, 0),
				Text = props.Player.DisplayName,
				TextColor3 = Color.White,
			}),
			React.createElement(Button, {
				Text = "Unban",
				TextSize = 24,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -30, 0.5, 0),
				Size = { 150, 50 },
				Color = Color.Button.Green,
				Activated = function()
					Flamework.resolveDependency("kXp"):unbanPlayer(props.Player)
				end,
			}),
			React.createElement(CornerRadius, {
				Radius = 10,
			})
		)
	end,
}
