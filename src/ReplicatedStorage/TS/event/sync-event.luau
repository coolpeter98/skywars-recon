-- SyncEvent

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

type SyncEventConnection = {
	Priority: number,
	Callback: (value: any) -> (),
	Destroy: () -> (),
}

type SyncEvent = {
	connections: { SyncEventConnection },
	new: (...any) -> SyncEvent,
	constructor: (self: SyncEvent) -> (),
	fire: (self: SyncEvent, value: any) -> any,
	bind: (self: SyncEvent, callback: (value: any) -> (), priority: number?) -> SyncEventConnection,
}

local SyncEvent = setmetatable({}, {
	["__tostring"] = function()
		return "SyncEvent"
	end,
})

SyncEvent.__index = SyncEvent

function SyncEvent.new(...)
	local self = setmetatable({}, SyncEvent)
	return self:constructor(...) or self
end

function SyncEvent.constructor(self: SyncEvent)
	self.connections = {}
end

function SyncEvent.fire(self: SyncEvent, value: any)
	for _, connection in self.connections do
		RuntimeLib.try(function()
			connection.Callback(value)
		end, function(err)
			print((("Error while firing event: %*"):format(err)))
		end)
	end
	return value
end

function SyncEvent.bind(self: SyncEvent, callback: (value: any) -> (), priority: number?)
	local resolvedPriority = priority == nil and 2 or priority
	local index = 0
	for i, connection in ipairs(self.connections) do
		if resolvedPriority < connection.Priority then
			break
		end
		index = i - 1
		if connection.Priority == resolvedPriority then
			break
		end
	end

	local connection = nil
	connection = {
		["Priority"] = resolvedPriority,
		["Callback"] = callback,
		["Destroy"] = function()
			local foundIndex = (table.find(self.connections, connection) or 0) - 1
			if foundIndex ~= -1 then
				table.remove(self.connections, foundIndex + 1)
			end
		end,
	}

	local connections = self.connections
	local insertIndex = index + 1
	local newConnection = connection
	table.insert(connections, insertIndex, newConnection)
	return connection
end

return {
	["SyncEvent"] = SyncEvent,
}
