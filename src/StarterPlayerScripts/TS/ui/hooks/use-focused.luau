-- useFocused

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
local useState = React.useState

return {
	["useFocused"] = function(onFocusedChanged: ((focused: boolean) -> ())?)
		local screenController = Flamework.resolveDependency("lB5")
		local focused, setFocused = useState(screenController:isFocused())
		useEffect(function()
			local maid = Maid.new()
			if onFocusedChanged and screenController:isFocused() then
				onFocusedChanged(true)
			end
			maid:GiveTask(screenController.ScreenOpenedEvent:bind(function(screen)
				if not screen.screenHandler.Options.Focused then
					return nil
				end
				setFocused(true)
				if onFocusedChanged then
					onFocusedChanged(true)
				end
			end))
			maid:GiveTask(screenController.ScreenClosedEvent:bind(function(screen)
				if not screen.screenHandler.Options.Focused then
					return nil
				end
				setFocused(false)
				if onFocusedChanged then
					onFocusedChanged(false)
				end
			end))
			return function()
				return maid:DoCleaning()
			end
		end, {})
		return focused
	end,
}
