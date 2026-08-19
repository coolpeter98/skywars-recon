-- QueueStore

type QueueStoreState = {
	QueueStartTime: number?,
	QueueServerAcknowledged: boolean?,
}

type QueueStoreAction = {
	type: string,
	queueTime: number?,
	queueServerAcknowledged: boolean?,
}

local QueueStoreActionType = {
	["UpdateQueue"] = "UpdateQueue",
}

return {
	["QueueStoreReducer"] = function(state: QueueStoreState, action: QueueStoreAction): QueueStoreState?
		if action.type == QueueStoreActionType.UpdateQueue then
			local newState = table.clone(state)
			setmetatable(newState, nil)
			newState.QueueStartTime = action.queueTime
			newState.QueueServerAcknowledged = action.queueServerAcknowledged
			return newState
		end
	end,
	["DefaultQueueStore"] = {},
	["QueueStoreActionType"] = QueueStoreActionType,
}
