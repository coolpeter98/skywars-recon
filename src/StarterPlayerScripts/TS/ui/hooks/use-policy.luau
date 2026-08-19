-- usePolicy

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = services.Players
local PolicyService: PolicyService = services.PolicyService

local react =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect: (callback: () -> (() -> ())?, dependencies: { any }) -> () = react.useEffect
local useState: <T>(initialValue: T) -> (T, (value: T) -> ()) = react.useState

local INITIAL_POLICY_STATE = {
	["Discord"] = false,
	["Facebook"] = false,
	["Twitch"] = false,
	["YouTube"] = false,
}

type LinkPolicy = { [string]: boolean }

return {
	["usePolicy"] = function(): LinkPolicy
		local policy, setPolicy = useState(INITIAL_POLICY_STATE)
		useEffect(function()
			task.spawn(function()
				local policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(Players.LocalPlayer)
				local updatedPolicy = table.clone(INITIAL_POLICY_STATE)
				setmetatable(updatedPolicy, nil)
				for _, linkReference in policyInfo.AllowedExternalLinkReferences do
					updatedPolicy[linkReference] = true
				end
				setPolicy(updatedPolicy)
			end)
		end, {})
		return policy
	end,
}
