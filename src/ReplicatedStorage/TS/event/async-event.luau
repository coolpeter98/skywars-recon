-- AsyncEvent

export type AsyncEvent = {
	bindableEvent: BindableEvent,
}

local AsyncEvent = setmetatable({}, {
	["__tostring"] = function()
		return "AsyncEvent"
	end,
})
AsyncEvent.__index = AsyncEvent
function AsyncEvent.new(...): AsyncEvent
	local self = setmetatable({}, AsyncEvent)
	return self:constructor(...) or self
end
function AsyncEvent.constructor(self: AsyncEvent)
	self.bindableEvent = Instance.new("BindableEvent")
end
function AsyncEvent.fire(self: AsyncEvent, ...): ()
	self.bindableEvent:Fire(...)
end
function AsyncEvent.bind(self: AsyncEvent, callback: (...any) -> ()): RBXScriptConnection
	return self.bindableEvent.Event:Connect(callback)
end
function AsyncEvent.wait(self: AsyncEvent): ...any
	return self.bindableEvent.Event:Wait()
end
function AsyncEvent.destroy(self: AsyncEvent): ()
	self.bindableEvent:Destroy()
end
return {
	["AsyncEvent"] = AsyncEvent,
}
