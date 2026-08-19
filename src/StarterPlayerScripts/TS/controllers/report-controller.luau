-- ReportController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local ReportScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "report", "report-screen").ReportScreen

type ReportScreen = {
	open: (self: ReportScreen, screenModule: any, data: any) -> (),
}

type ReportController = {
	new: (...any) -> ReportController,
	constructor: (self: ReportController, screenController: ReportScreen) -> (),
	openReport: (self: ReportController, player: Player) -> (),
	submitReport: (self: ReportController, player: Player) -> (),
	hasReported: (self: ReportController, player: Player) -> boolean,
	screenController: ReportScreen,
	reportedPlayers: { any },
}

local ReportController: ReportController = setmetatable({}, {
	["__tostring"] = function()
		return "ReportController"
	end,
})
ReportController.__index = ReportController

function ReportController.new(...)
	local class = ReportController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function ReportController.constructor(self, screenController)
	self.screenController = screenController
	self.reportedPlayers = {}
end

function ReportController.openReport(self, player)
	if self:hasReported(player) then
		return nil
	end
	local reportData = {
		["Player"] = PlayerUtil.toReplicated(player),
	}
	self.screenController:open(ReportScreen, reportData)
end

function ReportController.submitReport(self, player)
	local reportedPlayers = self.reportedPlayers
	table.insert(reportedPlayers, player)
	Events["a43ccf92-d35c-44f2-babf-2276399766af"]:fire(player)
end

function ReportController.hasReported(self, player)
	local reportedPlayers = self.reportedPlayers
	local userId = player.UserId
	return table.find(reportedPlayers, userId) ~= nil
end

Reflect.defineMetadata(ReportController, "identifier", "JEd")
Reflect.defineMetadata(ReportController, "flamework:parameters", { "lB5" })
Reflect.decorate(ReportController, "$:flamework@Controller", Controller, {})

return {
	["ReportController"] = ReportController,
}
