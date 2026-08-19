-- rodux: combined global store (inventory, game, queue, profile, screen)

export type GlobalState = { [string]: any }

export type Action = {
	type: string,
	Key: any,
	Value: any,
}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local InventoryStoreModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "inventory-store")
local defaultInventoryStore = InventoryStoreModule.DefaultInventoryStore
local InventoryStoreActionType = InventoryStoreModule.InventoryStoreActionType
local InventoryStoreReducer = InventoryStoreModule.InventoryStoreReducer
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local defaultGameStore =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "game-store").DefaultGameStore
local HttpService: HttpService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).HttpService
local QueueStoreModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "queue-store")
local defaultQueueStore = QueueStoreModule.DefaultQueueStore
local QueueStoreActionType = QueueStoreModule.QueueStoreActionType
local QueueStoreReducer = QueueStoreModule.QueueStoreReducer
local ProfileStoreModule =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "profile-store")
local defaultProfileStore = ProfileStoreModule.DefaultProfileStore
local ProfileStoreActionType = ProfileStoreModule.ProfileStoreActionType
local ProfileStoreReducer = ProfileStoreModule.ProfileStoreReducer
local defaultScreenStore =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "screen-store").DefaultScreenStore

local defaultGlobalState: GlobalState = table.clone(defaultInventoryStore)
setmetatable(defaultGlobalState, nil)
for key, value in defaultGameStore do
	defaultGlobalState[key] = value
end
for key, value in defaultQueueStore do
	defaultGlobalState[key] = value
end
for key, value in defaultProfileStore do
	defaultGlobalState[key] = value
end
for key, value in defaultScreenStore do
	defaultGlobalState[key] = value
end

local isInventoryStoreAction: (action: Action) -> boolean
local isQueueStoreAction: (action: Action) -> boolean
local isProfileStoreAction: (action: Action) -> boolean

local function GlobalReducer(state: GlobalState, action: Action): GlobalState
	local actionType = action.type
	if actionType == "@@INIT" then
		return state
	end
	if actionType == "SetValue" then
		local newState = table.clone(state)
		setmetatable(newState, nil)
		newState[action.Key] = action.Value
		return newState
	end
	if isInventoryStoreAction(action) then
		return InventoryStoreReducer(state, action)
	end
	if isQueueStoreAction(action) then
		return QueueStoreReducer(state, action)
	end
	if isProfileStoreAction(action) then
		return ProfileStoreReducer(state, action)
	end
	local encodedAction
	if action then
		encodedAction = HttpService:JSONEncode(action)
	else
		encodedAction = nil
	end
	error(("Unhandled reducer action %*"):format(encodedAction))
end

isInventoryStoreAction = function(action: Action): boolean
	local actionType = action.type
	return table.find(ObjectUtils.values(InventoryStoreActionType), actionType) ~= nil
end

isQueueStoreAction = function(action: Action): boolean
	local actionType = action.type
	return table.find(ObjectUtils.values(QueueStoreActionType), actionType) ~= nil
end

isProfileStoreAction = function(action: Action): boolean
	local actionType = action.type
	return table.find(ObjectUtils.values(ProfileStoreActionType), actionType) ~= nil
end

return {
	["GlobalReducer"] = GlobalReducer,
	["DefaultGlobalState"] = defaultGlobalState,
	["isInventoryStoreAction"] = isInventoryStoreAction,
	["isQueueStoreAction"] = isQueueStoreAction,
	["isProfileStoreAction"] = isProfileStoreAction,
}
