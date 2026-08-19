-- NotificationController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
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
local NotificationScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "notification", "notification-screen").NotificationScreen
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent

type NotificationController = {
	NotificationMouseEnter: any,
	NotificationMouseLeave: any,
	NotificationHovered: any,
	NotificationRemoved: any,
	Notifications: { [number]: any },
	notificationId: number,
	hovering: boolean,
}

local NotificationController = setmetatable({}, {
	["__tostring"] = function()
		return "NotificationController"
	end,
})
NotificationController.__index = NotificationController

function NotificationController.new(...)
	local class = NotificationController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function NotificationController.constructor(self: NotificationController)
	self.NotificationMouseEnter = AsyncEvent.new()
	self.NotificationMouseLeave = AsyncEvent.new()
	self.NotificationHovered = AsyncEvent.new()
	self.NotificationRemoved = AsyncEvent.new()
	self.Notifications = {}
	self.notificationId = 0
	self.hovering = false
end

function NotificationController.onStart(self: NotificationController)
	Events["f18ee8d7-1911-45e5-a23f-fe005dc1eaf0"]:connect(function(notification)
		self:displayNotification(notification)
	end)
end

function NotificationController.displayNotification(
	self: NotificationController,
	notification: any,
	onClose: (() -> ())?
)
	local notificationId = self.notificationId
	self.notificationId = self.notificationId + 1
	self.Notifications[notificationId] = notification
	local notificationHandle = Flamework.resolveDependency("lB5"):open(NotificationScreen, {
		["Id"] = notificationId,
		["Notification"] = notification,
		["StartTime"] = os.clock(),
	})
	notificationHandle:addCloseHandler(function()
		self.Notifications[notificationId] = nil
		local payload = {
			["notificationId"] = notificationId,
		}
		self.NotificationRemoved:fire(payload)
		local onCloseCallback = onClose
		if onCloseCallback ~= nil then
			onCloseCallback()
		end
	end)
	return notificationHandle
end

function NotificationController.isHovering(self: NotificationController): boolean
	return self.hovering
end

function NotificationController.mouseEnter(self: NotificationController, frame: Frame)
	self.NotificationMouseEnter:fire({
		["frame"] = frame,
	})
	if self.hovering then
		return nil
	end
	self.hovering = true
	self.NotificationHovered:fire({
		["frame"] = frame,
	})
end

function NotificationController.mouseLeave(self: NotificationController)
	self.NotificationMouseLeave:fire()
	if not self.hovering then
		return nil
	end
	local didMouseEnter = false
	local connection = nil
	connection = self.NotificationMouseEnter:bind(function(entered)
		if not entered then
			return nil
		end
		didMouseEnter = true
		connection:Disconnect()
	end)
	task.spawn(function()
		task.wait(1)
		connection:Disconnect()
		if didMouseEnter then
			return nil
		end
		self.hovering = false
		self.NotificationHovered:fire({})
	end)
end

Reflect.defineMetadata(NotificationController, "identifier", "Odx")
Reflect.defineMetadata(NotificationController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(NotificationController, "$:flamework@Controller", Controller, {})

return {
	["NotificationController"] = NotificationController,
}
