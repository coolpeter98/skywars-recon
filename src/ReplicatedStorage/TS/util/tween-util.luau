-- TweenUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")

type FadeOutTween = {
	Play: () -> (),
	Pause: () -> (),
	Cancel: () -> (),
	Completed: RBXScriptSignal?,
	Timestamp: number,
	PropertyMap: { [Instance]: { [string]: any } },
}

local TweenUtil = {
	["simple"] = function(startValue: number, endValue: number, tweenInfo: TweenInfo, onChanged: (value: number) -> (), onCompleted: (() -> ())?): Tween
		local numberValue = Instance.new("NumberValue")
		numberValue.Parent = game.Workspace
		numberValue.Value = startValue
		local tween = TweenService:Create(numberValue, tweenInfo, {
			["Value"] = endValue
		})
		local completedConnection = nil
		completedConnection = tween.Completed:Connect(function()
			if onCompleted then
				onCompleted()
			end
			tween:Destroy()
			numberValue:Destroy()
			completedConnection:Disconnect()
		end)
		numberValue.Changed:Connect(function(newValue: number)
			onChanged(newValue)
		end)
		tween:Play()
		return tween
	end
}

local fadeOutAsync = nil
function TweenUtil.fadeOutSync(instance: Instance, duration: number)
	local completed = fadeOutAsync(instance, duration).Completed
	if completed ~= nil then
		completed:Wait()
	end
end
function TweenUtil.restoreTween(propertyMap: { [Instance]: { [string]: any } }, duration: number?)
	for instance, properties in propertyMap do
		local tweenDuration = duration == nil and 0 or duration
		TweenService:Create(instance, TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), properties):Play()
	end
end
fadeOutAsync = function(instance: Instance, duration: number): FadeOutTween
	local tweens = {}
	local propertyMap = {}
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local function tweenInstance(instance: Instance, properties: { [string]: any })
		local originalProperties = {}
		for _, propertyName in ObjectUtils.keys(properties) do
			originalProperties[propertyName] = instance[propertyName]
		end
		propertyMap[instance] = originalProperties
		local tween = TweenService:Create(instance, tweenInfo, properties)
		table.insert(tweens, tween)
		tween:Play()
		return tween
	end
	local function fadeOutInstance(instance: Instance)
		if instance:IsA("Frame") then
			tweenInstance(instance, {
				["BackgroundTransparency"] = 1
			})
			return
		elseif instance:IsA("TextLabel") then
			tweenInstance(instance, {
				["TextTransparency"] = 1
			})
			return
		elseif instance:IsA("ImageLabel") then
			tweenInstance(instance, {
				["ImageTransparency"] = 1,
				["BackgroundTransparency"] = 1
			})
			return
		elseif instance:IsA("TextButton") then
			tweenInstance(instance, {
				["BackgroundTransparency"] = 1,
				["TextTransparency"] = 1
			})
			return
		elseif instance:IsA("UIStroke") then
			tweenInstance(instance, {
				["Transparency"] = 1
			})
			return
		elseif instance:IsA("ScrollingFrame") then
			tweenInstance(instance, {
				["ScrollBarImageTransparency"] = 1
			})
			return
		elseif instance:IsA("ViewportFrame") then
			tweenInstance(instance, {
				["ImageTransparency"] = 1
			})
			return
		elseif instance:IsA("BasePart") then
			tweenInstance(instance, {
				["Transparency"] = 1
			})
		elseif instance:IsA("Decal") then
			tweenInstance(instance, {
				["Transparency"] = 1
			})
		end
	end
	for _, descendant in instance:GetDescendants() do
		fadeOutInstance(descendant)
	end
	fadeOutInstance(instance)
	local tweenGroup = {
		["Play"] = function()
			for index, tween in tweens do
				local _ = index - 1
				tween:Play()
			end
			return nil
		end,
		["Pause"] = function()
			for index, tween in tweens do
				local _ = index - 1
				tween:Pause()
			end
			return nil
		end,
		["Cancel"] = function()
			for index, tween in tweens do
				local _ = index - 1
				tween:Cancel()
			end
			return nil
		end
	}
	local completedEvent = tweens[1]
	if completedEvent ~= nil then
		completedEvent = completedEvent.Completed
	end
	tweenGroup.Completed = completedEvent
	tweenGroup.Timestamp = os.clock()
	tweenGroup.PropertyMap = propertyMap
	return tweenGroup
end
TweenUtil.fadeOutAsync = fadeOutAsync
return {
	["TweenUtil"] = TweenUtil
}
