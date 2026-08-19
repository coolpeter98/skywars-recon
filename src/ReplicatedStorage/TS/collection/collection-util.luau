-- CollectionUtil

type CollectionUtil = {
	CollectionTagged: (tag: string, callback: (instance: Instance) -> ()) -> (),
}

local CollectionService: CollectionService = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").CollectionService
return {
	["CollectionTagged"] = function(tag: string, callback: (instance: Instance) -> ())
		for _, instance in CollectionService:GetTagged(tag) do
			task.spawn(function()
				callback(instance)
			end)
		end
		CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
	end,
}
