--!strict

local SkyWarsMode = require(script.Parent.SkyWarsMode)
local EggWarsMode = require(script.Parent.EggWarsMode)

local adapters = { SkyWarsMode, EggWarsMode }

local ModeRegistry = {}

function ModeRegistry.get(gameMode: string)
	for _, adapter in adapters do
		if adapter.supportsGameMode(gameMode) then
			return adapter
		end
	end
	return nil
end

function ModeRegistry.getCustom(gameMode: string)
	local adapter = ModeRegistry.get(gameMode)
	if adapter ~= nil and adapter.supportsCustomGameMode(gameMode) then
		return adapter
	end
	return nil
end

function ModeRegistry.getQueueable(gameMode: string)
	local adapter = ModeRegistry.get(gameMode)
	if adapter ~= nil and adapter.supportsQueueGameMode(gameMode) then
		return adapter
	end
	return nil
end

function ModeRegistry.getDefaultCustom()
	for _, adapter in adapters do
		local gameMode = adapter.getDefaultGameMode()
		if adapter.supportsCustomGameMode(gameMode) then
			return adapter
		end
	end
	return nil
end

function ModeRegistry.getQueueableGameModes(): { string }
	local gameModes = {}
	for _, adapter in adapters do
		for _, gameMode in adapter.getQueueableGameModes() do
			table.insert(gameModes, gameMode)
		end
	end
	return gameModes
end

return ModeRegistry
