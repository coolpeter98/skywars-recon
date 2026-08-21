--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventIds = require(ReplicatedStorage.TS.event["event-ids"]).EventIds

type RemoteMap = { [string]: RemoteEvent }

local RemoteRegistry = {}
RemoteRegistry.__index = RemoteRegistry

local function resolveNamespace(namespaceName: string, expectedById: { [string]: string }): RemoteMap
	local namespace = ReplicatedStorage:FindFirstChild(namespaceName)
	if namespace == nil then
		error(("[Server] Missing remote namespace '%s'"):format(namespaceName))
	end
	if namespace:GetAttribute("id") ~= namespaceName then
		error(("[Server] Remote namespace '%s' has an invalid id attribute"):format(namespaceName))
	end

	local byId: RemoteMap = {}
	for _, child in namespace:GetChildren() do
		local id = child:GetAttribute("id")
		if type(id) ~= "string" then
			error(("[Server] Remote '%s/%s' has no string id attribute"):format(namespaceName, child.Name))
		end
		if not child:IsA("RemoteEvent") then
			error(("[Server] Remote '%s/%s' must be a RemoteEvent"):format(namespaceName, id))
		end
		if byId[id] ~= nil then
			error(("[Server] Duplicate remote id '%s' in namespace '%s'"):format(id, namespaceName))
		end
		byId[id] = child
	end

	for id, name in expectedById do
		if byId[id] == nil then
			error(("[Server] Missing remote '%s' (%s) in namespace '%s'"):format(name, id, namespaceName))
		end
	end
	return byId
end

function RemoteRegistry.new()
	local eventNamesById: { [string]: string } = {}
	local functionNamesById: { [string]: string } = {}
	for name, id in EventIds do
		local destination = name == "GetCustomServers" and functionNamesById or eventNamesById
		if destination[id] ~= nil then
			error(("[Server] Canonical protocol id '%s' is assigned more than once"):format(id))
		end
		destination[id] = name
	end

	local eventsById = resolveNamespace("aYZ", eventNamesById)
	local functionsById = resolveNamespace("dYE", functionNamesById)
	return setmetatable({
		eventsById = eventsById,
		functionsById = functionsById,
	}, RemoteRegistry)
end

function RemoteRegistry.getEvent(self, name: string): RemoteEvent
	local id = EventIds[name]
	local remote = id and self.eventsById[id]
	if remote == nil then
		error(("[Server] Unknown event '%s'"):format(name))
	end
	return remote
end

function RemoteRegistry.getFunction(self, name: string): RemoteEvent
	local id = EventIds[name]
	local remote = id and self.functionsById[id]
	if remote == nil then
		error(("[Server] Unknown function '%s'"):format(name))
	end
	return remote
end

return RemoteRegistry
