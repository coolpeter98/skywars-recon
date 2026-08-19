-- HealthBarGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ProgressBarNew =
	RuntimeLib.import(script, script.Parent.Parent, "components", "progress-bar", "progress-bar-new").ProgressBarNew
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type HealthBarGuiProps = {
	Health: number,
	Shield: number,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["HealthBarGui"] = function(props: HealthBarGuiProps)
		local shield = props.Shield
		local totalHealth = props.Health + props.Shield
		local maxHealth = HealthConstants.MAX_HEALTH
		local shieldProgress = shield / math.max(totalHealth, maxHealth)
		local healthText
		if props.Shield > 0 then
			healthText = ('%* <font color="#48F7F7">(\240\159\155\161\239\184\143 %*)</font>'):format(
				props.Health,
				props.Shield
			)
		else
			healthText = ("%*"):format(props.Health)
		end
		return React.createElement(ProgressBarNew, {
			["key"] = "HealthBar",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Progress"] = nil,
			["Text"] = nil,
			["Image"] = nil,
			["Colors"] = nil,
			["SecondaryProgress"] = nil,
			["SecondaryProgressColor"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(974, 35),
			["Progress"] = props.Health / HealthConstants.MAX_HEALTH,
			["Text"] = healthText,
			["Image"] = RobloxImage.Icon.HEART,
			["Colors"] = {
				Color.HealthGreen,
				Color.Yellow,
				Color.HealthOrange,
				Color.HealthRed,
			},
			["SecondaryProgress"] = shieldProgress,
			["SecondaryProgressColor"] = Color.LightBlue,
		})
	end,
}
