-- GlobalStore

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local roduxModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "rodux")
local defaultGlobalState = roduxModule.DefaultGlobalState
local globalReducer = roduxModule.GlobalReducer
local Rodux = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "rodux", "src")
local createSelectorHook = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "ReactRedux").createSelectorHook

local store = Rodux.Store.new(globalReducer, defaultGlobalState)
local useGlobalStoreSelector = createSelectorHook()

local function useGlobalStore(key: string)
	return useGlobalStoreSelector(function(state: { [string]: any })
		return state[key]
	end)
end

return {
	["GlobalStoreChanged"] = function(key: string, callback: (oldValue: any, newValue: any) -> ())
		return store.changed:connect(function(oldState, newState)
			local oldValue = oldState[key]
			local newValue = newState[key]
			if oldValue ~= newValue then
				callback(oldValue, newValue)
			end
		end)
	end,
	["GlobalStore"] = store,
	["useGlobalStoreSelector"] = useGlobalStoreSelector,
	["useGlobalStore"] = useGlobalStore,
	["useProfile"] = function()
		return useGlobalStore("Profile")
	end,
	["useParty"] = function()
		return useGlobalStore("Party")
	end,
	["useTeams"] = function()
		return useGlobalStore("GameTeams")
	end,
}
