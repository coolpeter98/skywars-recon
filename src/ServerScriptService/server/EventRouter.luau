--!strict

local Players = game:GetService("Players")

type Arguments = {
	n: number,
	[number]: any,
}
type Route = {
	Name: string,
	Validate: (arguments: Arguments) -> (boolean, string?),
	Handle: (player: Player, arguments: Arguments) -> (),
}

local EventRouter = {}
EventRouter.__index = EventRouter

function EventRouter.new(remoteRegistry, playerSessions, routes: { Route })
	return setmetatable({
		remoteRegistry = remoteRegistry,
		playerSessions = playerSessions,
		routes = routes,
		connections = {} :: { RBXScriptConnection },
		started = false,
	}, EventRouter)
end

function EventRouter.start(self)
	if self.started then
		return
	end
	local registered: { [string]: boolean } = {}
	for _, route in self.routes do
		if registered[route.Name] then
			error(("[Server] Event '%s' is registered more than once"):format(route.Name))
		end
		registered[route.Name] = true
		local remote = self.remoteRegistry:getEvent(route.Name)
		local connection = remote.OnServerEvent:Connect(function(player: Player, ...)
			if player.Parent ~= Players or self.playerSessions:get(player) == nil then
				warn(
					("[Server] Rejected %s from inactive player %s (%d)"):format(route.Name, player.Name, player.UserId)
				)
				return
			end
			local arguments = table.pack(...)
			local validationResult = table.pack(pcall(route.Validate, arguments))
			if not validationResult[1] then
				warn(("[Server] Validator %s failed: %s"):format(route.Name, tostring(validationResult[2])))
				return
			end
			local valid = validationResult[2]
			local validationError = validationResult[3]
			if not valid then
				warn(
					("[Server] Rejected %s from %s (%d): %s"):format(
						route.Name,
						player.Name,
						player.UserId,
						validationError or "invalid arguments"
					)
				)
				return
			end
			task.spawn(function()
				local success, message = pcall(route.Handle, player, arguments)
				if not success then
					warn(
						("[Server] Handler %s failed for %s (%d): %s"):format(
							route.Name,
							player.Name,
							player.UserId,
							tostring(message)
						)
					)
				end
			end)
		end)
		table.insert(self.connections, connection)
	end
	self.started = true
end

function EventRouter.stop(self)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	self.started = false
end

return EventRouter
