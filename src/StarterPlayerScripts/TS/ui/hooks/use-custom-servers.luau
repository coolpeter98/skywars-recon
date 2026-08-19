-- useCustomServers

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Functions = RuntimeLib.import(script, script.Parent.Parent.Parent, "events").Functions
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

return {
	["useCustomServers"] = function()
		local servers, setServers = useState({})
		useEffect(function()
			local stopped = false
			task.spawn(function()
				while not stopped do
					print("Updating custom server list...")
					local newServers = Functions.GetCustomServers():expect()
					if stopped then
						break
					end
					setServers(newServers)
					task.wait(10)
				end
			end)

			return function()
				stopped = true
			end
		end, {})

		return servers
	end,
}
