-- RoduxController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local InventoryStoreActionType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "inventory-store").InventoryStoreActionType
local QueueStoreActionType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "rodux", "queue-store").QueueStoreActionType
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService: HttpService = Services.HttpService
local Players: Players = Services.Players
local TextChatService: TextChatService = Services.TextChatService
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent

type RoduxController = {
	initialReplicatedEvent: unknown,
	replicatedHistory: { [string]: boolean },
	constructor: (self: RoduxController) -> (),
	onStart: (self: RoduxController) -> (),
	moveItem: (self: RoduxController, item: unknown, slotId: unknown) -> (),
	updateQueue: (self: RoduxController, queueTime: number, queueServerAcknowledged: boolean) -> (),
	setValue: (self: RoduxController, key: string, value: unknown) -> (),
	awaitLoadedProfile: (self: RoduxController) -> (),
	awaitReplication: (self: RoduxController, key: string) -> (),
}

local RoduxController = setmetatable({}, {
	["__tostring"] = function()
		return "RoduxController"
	end
})
RoduxController.__index = RoduxController
function RoduxController.new(...): RoduxController
	local self = setmetatable({}, RoduxController)
	return self:constructor(...) or self
end
function RoduxController.constructor(self: RoduxController)
	self.initialReplicatedEvent = AsyncEvent.new()
	self.replicatedHistory = {}
end
function RoduxController.onStart(self: RoduxController)
	Events.SetValue:connect(function(payload)
		GlobalStore:dispatch(payload)
		local shouldReplicate = payload.type == "SetValue"
		if shouldReplicate then
			local alreadyReplicated = self.replicatedHistory[payload.Key] ~= nil
			shouldReplicate = not alreadyReplicated
		end
		if shouldReplicate then
			self.replicatedHistory[payload.Key] = true
			self.initialReplicatedEvent:fire({
				["key"] = payload.Key
			})
		end
	end)
	local playerId = Players.LocalPlayer.UserId
	if table.find({ 1730213868, 1800687521, 2037862588 }, playerId) == nil then
		return nil
	end
	TextChatService.SendingMessage:Connect(function(message)
		local parts = string.split(message.Text, " ")
		local command = parts[1]
		local argument = parts[2]
		if command ~= "roduxdebug" then
			return nil
		end
		local state = GlobalStore:getState()
		if #argument == 0 then
			print(("Store:\n%*"):format(HttpService:JSONEncode(state)))
			return nil
		end
		local value = state[argument]
		local encodedValue
		if value == 0 or (value ~= value or (value == "" or not value)) then
			encodedValue = nil
		else
			encodedValue = HttpService:JSONEncode(value)
		end
		print(("%*:\n%*"):format(argument, encodedValue))
	end)
end
function RoduxController.moveItem(_, item, slotId)
	GlobalStore:dispatch({
		["type"] = InventoryStoreActionType.MoveItem,
		["Item"] = item,
		["SlotId"] = slotId
	})
end
function RoduxController.updateQueue(_, queueTime: number, queueServerAcknowledged: boolean)
	GlobalStore:dispatch({
		["type"] = QueueStoreActionType.UpdateQueue,
		["queueTime"] = queueTime,
		["queueServerAcknowledged"] = queueServerAcknowledged
	})
end
function RoduxController.setValue(_, key: string, value: unknown)
	GlobalStore:dispatch({
		["type"] = "SetValue",
		["Key"] = nil,
		["Value"] = nil,
		["Key"] = key,
		["Value"] = value
	})
end
function RoduxController.awaitLoadedProfile(self: RoduxController)
	self:awaitReplication("Profile")
end
function RoduxController.awaitReplication(self: RoduxController, key: string)
	if self.replicatedHistory[key] ~= nil then
		return nil
	end
	local event = AsyncEvent.new()
	local connection = nil
	connection = self.initialReplicatedEvent:bind(function(payload)
		if payload.key == key then
			connection:Disconnect()
			event:fire()
		end
	end)
	event:wait()
	event:destroy()
end
Reflect.defineMetadata(RoduxController, "identifier", "zG")
Reflect.defineMetadata(RoduxController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(RoduxController, "$:flamework@Controller", Controller, {})
return {
	["RoduxController"] = RoduxController
}
