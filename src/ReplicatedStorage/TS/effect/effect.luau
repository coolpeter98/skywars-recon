-- Effect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService

type Effect = {
	maid: any,
}

local Effect = setmetatable({}, {
	["__tostring"] = function()
		return "Effect"
	end,
})

Effect.__index = Effect

function Effect.new(...): Effect
	local self = setmetatable({}, Effect)
	return self:constructor(...) or self
end

function Effect.constructor(self: Effect)
	self.maid = Maid.new()
end

function Effect.start(self: Effect)
	self.maid:GiveTask(RunService.Heartbeat:Connect(function()
		return self:update()
	end))
end

function Effect.update(_: Effect) end

function Effect.stop(self: Effect)
	self.maid:DoCleaning()
end

return {
	["Effect"] = Effect,
}
