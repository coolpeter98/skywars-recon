-- Queue

type QueueItem = {
	Value: unknown,
	Timestamp: number,
}

type Queue = {
	maxSize: number?,
	list: { QueueItem },
	onRemoveHandler: ((item: QueueItem) -> ())?,
}

local Queue = setmetatable({}, {
	["__tostring"] = function()
		return "Queue"
	end
})
Queue.__index = Queue
function Queue.new(...): Queue
	local queueClass = Queue
	local self = setmetatable({}, queueClass)
	return self:constructor(...) or self
end
function Queue.constructor(self: Queue, maxSize: number?)
	self.maxSize = maxSize
	self.list = {}
end
function Queue.add(self: Queue, ...)
	for _, value in { ... } do
		local list = self.list
		local entry = {
			["Value"] = value,
			["Timestamp"] = os.clock()
		}
		table.insert(list, entry)
	end
	if self.maxSize == nil then
		return nil
	end
	while #self.list > self.maxSize do
		self:poll()
	end
end
function Queue.peek(self: Queue): QueueItem?
	if #self.list == 0 then
		return nil
	else
		return self.list[1]
	end
end
function Queue.poll(self: Queue)
	local item = table.remove(self.list, 1)
	if not item then
		return nil
	end
	if self.onRemoveHandler then
		self.onRemoveHandler(item)
	end
end
function Queue.clear(self: Queue)
	for _, item in self.list do
		if self.onRemoveHandler then
			self.onRemoveHandler(item)
		end
	end
	table.clear(self.list)
end
function Queue.size(self: Queue): number
	return #self.list
end
function Queue.isEmpty(self: Queue): boolean
	return #self.list == 0
end
function Queue.setOnRemoveHandler(self: Queue, handler: (item: QueueItem) -> ())
	self.onRemoveHandler = handler
end
return {
	["Queue"] = Queue
}
