--!strict

local Players = game:GetService("Players")

type Arguments = {
	n: number,
	[number]: any,
}
type FunctionRoute = {
	Name: string,
	Validate: (arguments: Arguments) -> (boolean, string?),
	Handle: (player: Player, arguments: Arguments) -> any,
}

local FunctionRouter = {}
FunctionRouter.__index = FunctionRouter

local function isFiniteRequestId(value: any): boolean
	return type(value) == "number"
		and value == value
		and value ~= math.huge
		and value ~= -math.huge
		and value % 1 == 0
		and value >= 0
end

function FunctionRouter.new(remoteRegistry, playerSessions, routes: { FunctionRoute })
	return setmetatable({
		remoteRegistry = remoteRegistry,
		playerSessions = playerSessions,
		routes = routes,
		connections = {} :: { RBXScriptConnection },
		started = false,
	}, FunctionRouter)
end

function FunctionRouter.start(self)
	if self.started then
		return
	end
	local registered: { [string]: boolean } = {}
	for _, route in self.routes do
		if registered[route.Name] then
			error(("[Server] Function '%s' is registered more than once"):format(route.Name))
		end
		registered[route.Name] = true
		local remote = self.remoteRegistry:getFunction(route.Name)
		local connection = remote.OnServerEvent:Connect(function(player: Player, requestId: any, ...)
			if not isFiniteRequestId(requestId) then
				warn(
					("[Server] Rejected %s with an invalid request id from %s (%d)"):format(
						route.Name,
						player.Name,
						player.UserId
					)
				)
				return
			end
			if player.Parent ~= Players or self.playerSessions:get(player) == nil then
				remote:FireClient(player, requestId, "BadRequest")
				return
			end
			local arguments = table.pack(...)
			local validationResult = table.pack(pcall(route.Validate, arguments))
			if not validationResult[1] then
				warn(("[Server] Validator %s failed: %s"):format(route.Name, tostring(validationResult[2])))
				remote:FireClient(player, requestId, "BadRequest")
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
				remote:FireClient(player, requestId, "BadRequest")
				return
			end
			task.spawn(function()
				local result = table.pack(pcall(route.Handle, player, arguments))
				if result[1] then
					remote:FireClient(player, requestId, true, result[2])
				else
					warn(
						("[Server] Function %s failed for %s (%d): %s"):format(
							route.Name,
							player.Name,
							player.UserId,
							tostring(result[2])
						)
					)
					remote:FireClient(player, requestId, "Unprocessed")
				end
			end)
		end)
		table.insert(self.connections, connection)
	end
	self.started = true
end

function FunctionRouter.stop(self)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	self.started = false
end

return FunctionRouter
