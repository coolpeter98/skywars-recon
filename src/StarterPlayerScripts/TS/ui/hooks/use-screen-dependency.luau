-- useScreenDependency

type UseScreenDependencyProps = {
	ScreenId: string,
}

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
	["useScreenDependency"] = function(props: UseScreenDependencyProps)
		local isOpen, setIsOpen = useState(Flamework.resolveDependency("lB5"):isOpen(props.ScreenId))

		useEffect(function()
			local maid = Maid.new()
			maid:GiveTask(Flamework.resolveDependency("lB5").ScreenOpenedEvent:bind(function(openedScreen)
				if openedScreen.screenHandler.ScreenId == props.ScreenId then
					setIsOpen(true)
				end
			end))
			maid:GiveTask(Flamework.resolveDependency("lB5").ScreenClosedEvent:bind(function(closedScreen)
				if closedScreen.screenHandler.ScreenId == props.ScreenId then
					setIsOpen(false)
				end
			end))
			return function()
				return maid:DoCleaning()
			end
		end, { props.ScreenId })

		return {
			["IsOpen"] = isOpen,
		}
	end,
}
