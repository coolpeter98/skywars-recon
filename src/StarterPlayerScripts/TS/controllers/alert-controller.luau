-- AlertController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flamework.Reflect
local Flamework = flamework.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local AlertScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "alert", "alert-screen").AlertScreen
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events

type AlertData = {
	Icon: string,
	Text: string,
	Color: Color3,
	Duration: number,
}

type AlertController = {
	alertQueue: { AlertData },
	alertScreen: any,
	new: (...any) -> AlertController,
	constructor: (self: AlertController) -> (),
	onStart: (self: AlertController) -> (),
	displayAlert: (self: AlertController, icon: string, text: string, color: Color3, duration: number) -> (),
	updateQueue: (self: AlertController) -> (),
}

local AlertController = setmetatable({}, {
	__tostring = function()
		return "AlertController"
	end,
})
AlertController.__index = AlertController

function AlertController.new(...)
	local self = setmetatable({}, AlertController)
	return self:constructor(...) or self
end

function AlertController.constructor(self: AlertController)
	self.alertQueue = {}
	self.alertScreen = nil
end

function AlertController.onStart(self: AlertController)
	Events["c2781cee-e34c-4c42-bd09-193723dc6473"]:connect(
		function(icon: string, text: string, color: Color3, duration: number)
			self:displayAlert(icon, text, color, duration)
		end
	)
end

function AlertController.displayAlert(
	self: AlertController,
	icon: string,
	text: string,
	color: Color3,
	duration: number
)
	local alertQueue = self.alertQueue
	table.insert(alertQueue, {
		Icon = icon,
		Text = text,
		Color = color,
		Duration = duration,
	})
	self:updateQueue()
end

function AlertController.updateQueue(self: AlertController)
	if self.alertScreen then
		return nil
	end

	local alert = table.remove(self.alertQueue, 1)
	if not alert then
		return nil
	end

	local alertScreen = Flamework.resolveDependency("lB5"):open(AlertScreen, {
		Icon = alert.Icon,
		Text = alert.Text,
		Color = alert.Color,
	})
	self.alertScreen = alertScreen
	task.spawn(function()
		task.wait(alert.Duration)
		alertScreen:close()
		self.alertScreen = nil
		task.wait(1)
		self:updateQueue()
	end)
end

Reflect.defineMetadata(AlertController, "identifier", "PPb")
Reflect.defineMetadata(AlertController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(AlertController, "$:flamework@Controller", Controller, {})
return {
	["AlertController"] = AlertController,
}
