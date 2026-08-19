-- Event module

export type Event = {
	bindableEvent: BindableEvent,
	constructor: (self: Event) -> (),
	fire: (self: Event, ...any) -> (),
	dispose: (self: Event) -> (),
	bind: (self: Event, callback: (...any) -> ()) -> RBXScriptConnection,
	wait: (self: Event) -> ...any,
	event: (self: Event) -> BindableEvent,
}

local Event = setmetatable({}, {
	["__tostring"] = function()
		return "Event"
	end,
})
Event.__index = Event
function Event.new(...)
	local Event = Event
	local self = setmetatable({}, Event)
	return self:constructor(...) or self
end
function Event.constructor(self: Event)
	self.bindableEvent = Instance.new("BindableEvent")
end
function Event.fire(self: Event, ...)
	self.bindableEvent:Fire(unpack({ ... }))
end
function Event.dispose(self: Event)
	self.bindableEvent:Destroy()
end
function Event.bind(self: Event, callback: (...any) -> ())
	return self.bindableEvent.Event:Connect(callback)
end
function Event.wait(self: Event)
	return self.bindableEvent.Event:Wait()
end
function Event.event(self: Event)
	return self.bindableEvent.Event
end
return {
	["Event"] = Event,
}
