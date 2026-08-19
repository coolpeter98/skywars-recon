-- HealthBarUtil

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
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute

local HealthBarUtil = {}

local getHealthBarColor: ((health: number) -> Color3)? = nil
local getHealthBarSize: ((health: number) -> UDim2)? = nil

function HealthBarUtil.setupHealthBar(
	player: Player,
	barFrame: Frame,
	textLabel: TextLabel?,
	textLabel2: TextLabel?,
	sizeGetter: ((health: number) -> UDim2)?,
	colorGetter: ((health: number) -> Color3)?,
	attributeName: string?
): RBXScriptConnection
	if sizeGetter == nil then
		sizeGetter = getHealthBarSize
	end
	if colorGetter == nil then
		colorGetter = getHealthBarColor
	end
	if attributeName == nil then
		attributeName = Attribute.Health
	end
	local previousHealth = Flamework.resolveDependency("51k"):getHealth(player)
	return player:GetAttributeChangedSignal(attributeName):Connect(function()
		local newHealth = Flamework.resolveDependency("51k"):getHealth(player)
		if previousHealth == newHealth then
			return nil
		end
		local size = sizeGetter(newHealth)
		local color = colorGetter(newHealth)
		local text = ("%*"):format(newHealth)
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		if newHealth < previousHealth then
			local delayBar = barFrame:Clone()
			delayBar.BackgroundColor3 = Color.White
			delayBar.ZIndex = barFrame.ZIndex - 1
			delayBar.Parent = barFrame.Parent
			TweenService:Create(barFrame, TweenInfo.new(0), {
				["Size"] = size,
				["BackgroundColor3"] = color,
			}):Play()
			barFrame.Size = size
			barFrame.BackgroundColor3 = color
			local tween = TweenService:Create(delayBar, tweenInfo, {
				["Size"] = size,
			})
			local connection = nil
			connection = tween.Completed:Connect(function()
				delayBar:Destroy()
				connection:Disconnect()
			end)
			tween:Play()
		elseif previousHealth < newHealth then
			TweenService:Create(barFrame, tweenInfo, {
				["Size"] = size,
				["BackgroundColor3"] = color,
			}):Play()
		end
		if textLabel then
			textLabel.Text = text
		end
		if textLabel2 then
			textLabel2.Text = text
		end
		previousHealth = newHealth
	end)
end

getHealthBarColor = function(health: number): Color3
	return ColorUtil.getHealthColor(1 - health / HealthConstants.MAX_HEALTH)
end
HealthBarUtil.getHealthBarColor = getHealthBarColor

getHealthBarSize = function(health: number): UDim2
	return UDim2.fromOffset(960 * (health / HealthConstants.MAX_HEALTH), 10)
end
HealthBarUtil.getHealthBarSize = getHealthBarSize

return {
	["HealthBarUtil"] = HealthBarUtil,
}
