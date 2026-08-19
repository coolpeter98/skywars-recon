-- InputUtil

local Services = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService

local InputUtil = {
	["isMovementInteract"] = function(input: InputObject): boolean
		if not UserInputService.TouchEnabled then
			return false
		end
		local touchFrame = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
		if touchFrame ~= nil then
			touchFrame = touchFrame:FindFirstChild("TouchControlFrame")
			if touchFrame ~= nil then
				touchFrame = touchFrame:FindFirstChild("DynamicThumbstickFrame")
			end
		end
		if not touchFrame then
			return false
		end
		local topLeft = touchFrame.AbsolutePosition
		local bottomRight = touchFrame.AbsolutePosition + touchFrame.AbsoluteSize
		local insideBounds: boolean
		if input.X >= topLeft.X and (input.X <= bottomRight.X and input.Y >= topLeft.Y) then
			insideBounds = input.Y <= bottomRight.Y
		else
			insideBounds = false
		end
		return insideBounds
	end,
	["isWorldInteract"] = function(input: InputObject): boolean
		local inputType = input.UserInputType
		return (inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch) and true or input.KeyCode == Enum.KeyCode.ButtonR2
	end,
	["isModalInteract"] = function(input: InputObject): boolean
		local inputType = input.UserInputType
		return (inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch) and true or input.KeyCode == Enum.KeyCode.ButtonA
	end,
	["isPcInteract"] = function(input: InputObject): boolean
		return input.UserInputType == Enum.UserInputType.MouseButton1 and true or input.KeyCode == Enum.KeyCode.ButtonR2
	end,
	["isControllerInteract"] = function(input: InputObject): boolean
		local _ = input.UserInputType
		return input.KeyCode == Enum.KeyCode.ButtonR2
	end,
	["isMobileInteract"] = function(input: InputObject): boolean
		return input.UserInputType == Enum.UserInputType.Touch
	end,
	["isSprint"] = function(input: InputObject): boolean
		return input.KeyCode == Enum.KeyCode.LeftShift and true or input.KeyCode == Enum.KeyCode.RightShift
	end,
	["isSprintToggle"] = function(input: InputObject): boolean
		return input.KeyCode == Enum.KeyCode.ButtonL3
	end,
	["isDropItem"] = function(input: InputObject): boolean
		return input.KeyCode == Enum.KeyCode.Q and true or input.KeyCode == Enum.KeyCode.DPadDown
	end,
	["isShiftLock"] = function(input: InputObject): boolean
		return input.KeyCode == Enum.KeyCode.LeftControl
	end,
}

local isCycleLeft: ((input: InputObject) -> boolean)? = nil
local isCycleRight: ((input: InputObject) -> boolean)? = nil

function InputUtil.isCycle(input: InputObject): boolean
	return isCycleLeft(input) or isCycleRight(input)
end

function InputUtil.hasInputEnded(input: InputObject): boolean
	return input.UserInputState == Enum.UserInputState.Cancel and true or input.UserInputState == Enum.UserInputState.End
end

isCycleLeft = function(input: InputObject): boolean
	return input.KeyCode == Enum.KeyCode.ButtonL1
end
InputUtil.isCycleLeft = isCycleLeft

isCycleRight = function(input: InputObject): boolean
	return input.KeyCode == Enum.KeyCode.ButtonR1
end
InputUtil.isCycleRight = isCycleRight

function InputUtil.isToggleInventory(input: InputObject): boolean
	return input.KeyCode == Enum.KeyCode.E and true or input.KeyCode == Enum.KeyCode.DPadUp
end

function InputUtil.isGamepadClose(input: InputObject): boolean
	return input.KeyCode == Enum.KeyCode.ButtonB
end

function InputUtil.isGamepadEnabled(): boolean
	return UserInputService.GamepadEnabled
end

return {
	["InputUtil"] = InputUtil,
}
