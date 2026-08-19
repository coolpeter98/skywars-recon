-- UpdateLogController

type UpdateLogController = {}

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events

local UpdateLogController = setmetatable({}, {
	["__tostring"] = function()
		return "UpdateLogController"
	end,
})
UpdateLogController.__index = UpdateLogController

function UpdateLogController.new(...): UpdateLogController
	local self = setmetatable({}, UpdateLogController)
	return self:constructor(...) or self
end

function UpdateLogController.constructor(self) end

function UpdateLogController.hasUpdated(self, updates: { string }, updateLog: { [string]: any }?): boolean
	if updateLog == nil then
		updateLog = GlobalStore:getState().Profile.UpdateLog
	end
	for _, updateId in updates do
		if updateLog[updateId] == nil then
			return true
		end
	end
	return false
end

function UpdateLogController.addUpdatesToProfile(self, updates: { string }, profile: any)
	if profile == nil then
		profile = GlobalStore:getState().Profile
	end
	local count = 0
	local newUpdates = {}
	for index, updateId in updates do
		local _ = index - 1
		if profile.UpdateLog[updateId] == nil == true then
			count = count + 1
			newUpdates[count] = updateId
		end
	end
	if #newUpdates ~= 0 then
		Events.AcknowledgeUpdateLog:fire(newUpdates)
	end
end

Reflect.defineMetadata(UpdateLogController, "identifier", "9ll")
Reflect.decorate(UpdateLogController, "$:flamework@Controller", Controller, {})

return {
	["UpdateLogController"] = UpdateLogController,
}
