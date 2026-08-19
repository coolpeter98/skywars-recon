-- useVerify

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Players: Players = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local Constants = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "constants").Constants
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

return {
	["useVerify"] = function(): { IsInGroup: boolean }
		local isInGroup, setIsInGroup = useState(false)

		useEffect(function()
			local isActive = true

			task.spawn(function()
				setIsInGroup(Players.LocalPlayer:IsInGroup(Constants.VOXELS_GROUP_ID))

				while isActive do
					setIsInGroup(Players.LocalPlayer:IsInGroup(Constants.VOXELS_GROUP_ID))
					task.wait(5)
				end
			end)

			return function()
				isActive = false
			end
		end, {})

		return {
			["IsInGroup"] = isInGroup
		}
	end
}
