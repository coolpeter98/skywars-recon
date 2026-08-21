--!strict

local Runtime = require(script.server.Runtime)

local runtime = Runtime.new()
runtime:start()

game:BindToClose(function()
	runtime:stop()
end)
