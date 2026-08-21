--!strict

local SkyWarsMode = require(script.Parent.SkyWarsMode)

local adapters = { SkyWarsMode }

local ModeRegistry = {}

function ModeRegistry.get(gameMode: string)
	for _, adapter in adapters do
		if adapter.supportsGameMode(gameMode) then
			return adapter
		end
	end
	return nil
end

function ModeRegistry.getDefault()
	return SkyWarsMode
end

return ModeRegistry
