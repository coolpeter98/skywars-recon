-- useButton

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local RobloxSound = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local useState = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react").useState

type UseButtonOptions = {
	Disabled: boolean?,
	Muted: boolean?,
	Activated: () -> (),
}

type UseButtonState = {
	Hovering: boolean,
	Pressed: boolean,
	Activated: (button: GuiButton, input: InputObject) -> (),
	MouseEnter: () -> (),
	MouseLeave: () -> (),
}

return {
	["useButton"] = function(options: UseButtonOptions): UseButtonState
		local hovering, setHovering = useState(false)
		local pressed, setPressed = useState(false)
		return {
			["Hovering"] = hovering,
			["Pressed"] = pressed,
			["Activated"] = function(button: GuiButton, input: InputObject)
				if not InputUtil.isModalInteract(input) then
					return nil
				end
				if options.Disabled then
					return nil
				end
				if RunService:IsRunning() and not options.Muted then
					Flamework.resolveDependency("jL9"):playSound(RobloxSound.Button.DOWN)
				end
				if button.Parent then
					setPressed(true)
				end
				options.Activated()
				local connection: RBXScriptConnection? = nil
				connection = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
					if not InputUtil.hasInputEnded(input) then
						return nil
					end
					if RunService:IsRunning() and not options.Muted then
						Flamework.resolveDependency("jL9"):playSound(RobloxSound.Button.UP)
					end
					connection:Disconnect()
					if button.Parent then
						setPressed(false)
					end
				end)
			end,
			["MouseEnter"] = function()
				return setHovering(true)
			end,
			["MouseLeave"] = function()
				return setHovering(false)
			end,
		}
	end,
}
