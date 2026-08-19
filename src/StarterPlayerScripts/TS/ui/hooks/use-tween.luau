-- useTween: React hook that tweens a value on a hidden instance and mirrors it back into state.

type TweenableValue = number | string | boolean | Color3 | Vector3 | CFrame | UDim | UDim2 | Vector2

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

local VALUE_CLASS_NAMES = {
	["number"] = "NumberValue",
	["string"] = "StringValue",
	["boolean"] = "BoolValue",
	["Color3"] = "Color3Value",
	["Vector3"] = "Vector3Value",
	["CFrame"] = "CFrameValue",
}

return {
	["useTween"] = function(targetValue: TweenableValue, tweenInfo: TweenInfo): TweenableValue
		local value, setValue = useState(targetValue)
		local valueRef = useRef(targetValue)
		useEffect(function()
			local maid = Maid.new()
			local target: Instance? = nil
			local tween: Tween? = nil
			local info = TweenInfo.new(
				tweenInfo.Time,
				tweenInfo.EasingStyle or Enum.EasingStyle.Linear,
				tweenInfo.EasingDirection or Enum.EasingDirection.Out
			)
			local valueType = typeof(targetValue)
			if VALUE_CLASS_NAMES[valueType] ~= nil then
				target = Instance.new(VALUE_CLASS_NAMES[valueType])
				target.Value = valueRef.current
				tween = TweenService:Create(target, info, {
					["Value"] = targetValue,
				})
				maid:GiveTask(target.Changed:Connect(function(newValue)
					setValue(newValue)
				end))
			elseif typeof(targetValue) == "UDim" then
				target = Instance.new("UICorner")
				if typeof(valueRef.current) == "UDim" then
					target.CornerRadius = valueRef.current
				end
				tween = TweenService:Create(target, info, {
					["CornerRadius"] = targetValue,
				})
				maid:GiveTask(target:GetPropertyChangedSignal("CornerRadius"):Connect(function()
					setValue(target.CornerRadius)
				end))
			elseif typeof(targetValue) == "UDim2" then
				target = Instance.new("Frame")
				if typeof(valueRef.current) == "UDim2" then
					target.Position = valueRef.current
				end
				tween = TweenService:Create(target, info, {
					["Position"] = targetValue,
				})
				maid:GiveTask(target:GetPropertyChangedSignal("Position"):Connect(function()
					setValue(target.Position)
				end))
			elseif typeof(targetValue) == "Vector2" then
				target = Instance.new("Frame")
				if typeof(valueRef.current) == "Vector2" then
					target.AnchorPoint = valueRef.current
				end
				tween = TweenService:Create(target, info, {
					["AnchorPoint"] = targetValue,
				})
				maid:GiveTask(target:GetPropertyChangedSignal("AnchorPoint"):Connect(function()
					setValue(target.AnchorPoint)
				end))
			else
				error("Unsupported type: " .. typeof(targetValue))
			end
			valueRef.current = targetValue
			maid:GiveTask(tween.Completed:Connect(function()
				return target:Destroy()
			end))
			tween:Play()
			maid:GiveTask(tween)
			return function()
				return maid:DoCleaning()
			end
		end, { targetValue })
		return value
	end,
}
