--!strict
-- Drop schema for the persisted PlayerData document.
-- Migration rules: never edit the initial value or an existing step — append a
-- new `Drop.migrate` line below (numbered V<next>); each migration receives the
-- previous document and must return a complete one.

local ServerStorage = game:GetService("ServerStorage")

local Drop = require(ServerStorage.Drop)
local PlayerDataRules = require(script.Parent.PlayerDataRules)

-- V1 — initial format: progression lives under Stats.
local PlayerDataSchema = Drop.schema(PlayerDataRules.initialPlayerData())

-- V2 — (future example)
-- PlayerDataSchema = Drop.migrate(PlayerDataSchema, function(old)
-- 	...
-- end)

return PlayerDataSchema
