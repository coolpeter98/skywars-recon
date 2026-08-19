-- ProgressBarUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
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

type ProgressBar = {
	Frame: Frame?,
	TextLabel: TextLabel?,
	DropShadow: TextLabel?,
	Size: Vector2,
	Colors: { Color3 },
	Range: { number } | ((value: number) -> { number }),
	TweenTime: number?,
	OnComplete: (() -> ())?,
}

local ProgressBarUtil = {
	["getBarColor"] = function(colors: { Color3 }, progress: number): Color3
		return ColorUtil.lerpMultiColorRgbViaCieluv(1 - progress, unpack(colors))
	end,
	["createProgressBar"] = function(progressBinding)
		local currentValue = progressBinding.GetValue()
		local connection = progressBinding.Signal:Connect(function()
			local newValue = progressBinding.GetValue()
			ProgressBarUtil.setProgress(progressBinding, newValue, currentValue)
			currentValue = newValue
		end)
		return function()
			return connection:Disconnect()
		end
	end,
}
local tweenDown = nil
local tweenUp = nil
function ProgressBarUtil.setProgress(bar: ProgressBar, value: number, oldValue: number)
	local text = ("<b>%*</b>"):format(value)
	if bar.TextLabel then
		bar.TextLabel.Text = text
	end
	if bar.DropShadow then
		bar.DropShadow.Text = text
	end
	local range = bar.Range
	local resolvedRange
	if type(range) == "function" then
		resolvedRange = bar.Range(value)
	else
		resolvedRange = bar.Range
	end
	local minValue = resolvedRange[1]
	local maxValue = resolvedRange[2]
	local normalizedProgress = (value - minValue) / (maxValue - minValue)
	if value < oldValue then
		task.spawn(function()
			tweenDown(bar, normalizedProgress)
		end)
	elseif oldValue < value then
		task.spawn(function()
			if bar.Frame then
				local range = bar.Range
				local resolvedRange
				if type(range) == "function" then
					resolvedRange = bar.Range(oldValue)
				else
					resolvedRange = bar.Range
				end
				local minValue = resolvedRange[1]
				local maxValue = resolvedRange[2]
				if (value - minValue) / (maxValue - minValue) > 1 then
					tweenUp(bar, 1)
					local onComplete = bar.OnComplete
					if onComplete ~= nil then
						onComplete()
					end
					local resetSize = UDim2.fromOffset(0, bar.Size.Y)
					local colors = bar.Colors
					local resetColor = ColorUtil.lerpMultiColorRgbViaCieluv(1, unpack(colors))
					bar.Frame.Size = resetSize
					bar.Frame.BackgroundColor3 = resetColor
				else
					tweenUp(bar, normalizedProgress)
				end
			else
				return nil
			end
		end)
	end
end
tweenDown = function(bar: ProgressBar, progress: number)
	if not bar.Frame then
		return nil
	end
	local targetSize = UDim2.fromOffset(bar.Size.X * progress, bar.Size.Y)
	local colors = bar.Colors
	local targetColor = ColorUtil.lerpMultiColorRgbViaCieluv(1 - progress, unpack(colors))
	local ghostFrame = bar.Frame:Clone()
	ghostFrame.BackgroundColor3 = Color.White
	ghostFrame.ZIndex = bar.Frame.ZIndex - 1
	ghostFrame.Parent = bar.Frame.Parent
	TweenService:Create(bar.Frame, TweenInfo.new(0), {
		["Size"] = targetSize,
		["BackgroundColor3"] = targetColor,
	}):Play()
	bar.Frame.Size = targetSize
	bar.Frame.BackgroundColor3 = targetColor
	local tweenTime = bar.TweenTime
	local duration = tweenTime == nil and 1 or tweenTime
	local tween =
		TweenService:Create(ghostFrame, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			["Size"] = targetSize,
		})
	local connection = nil
	connection = tween.Completed:Connect(function()
		ghostFrame:Destroy()
		connection:Disconnect()
	end)
	tween:Play()
	tween.Completed:Wait()
end
ProgressBarUtil.tweenDown = tweenDown
tweenUp = function(bar: ProgressBar, progress: number)
	if not bar.Frame then
		return nil
	end
	local targetSize = UDim2.fromOffset(bar.Size.X * progress, bar.Size.Y)
	local colors = bar.Colors
	local targetColor = ColorUtil.lerpMultiColorRgbViaCieluv(1 - progress, unpack(colors))
	local frame = bar.Frame
	local tweenTime = bar.TweenTime
	local duration = tweenTime == nil and 1 or tweenTime
	local tween =
		TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			["Size"] = targetSize,
			["BackgroundColor3"] = targetColor,
		})
	tween:Play()
	tween.Completed:Wait()
end
ProgressBarUtil.tweenUp = tweenUp
return {
	["ProgressBarUtil"] = ProgressBarUtil,
}
