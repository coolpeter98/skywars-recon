-- PowerUpEffect

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Effect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "effect", "effect").Effect
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items

type PowerUpEffect = {
	character: Model,
	offset: Vector3,
	part: BasePart?,
}

local PowerUpEffect = setmetatable({}, {
	["__tostring"] = function()
		return "PowerUpEffect"
	end,
	["__index"] = Effect,
})
PowerUpEffect.__index = PowerUpEffect

function PowerUpEffect.new(...): PowerUpEffect
	local class = PowerUpEffect
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function PowerUpEffect.constructor(self: PowerUpEffect, character: Model)
	Effect.constructor(self)
	self.character = character
	local offsetY = 3 * BlockConstants.BLOCK_SIZE
	self.offset = Vector3.new(0, offsetY, 0)
end

function PowerUpEffect.start(self: PowerUpEffect)
	Effect.start(self)
	local cframe = self.character:GetPrimaryPartCFrame() + self.offset
	local handle: BasePart = Items.SpeedBoost.ToolRef:FindFirstChild("Handle"):Clone()
	handle.CFrame = cframe
	handle.Parent = self.character
	handle.Anchored = true
	handle.CanCollide = false
	self.maid:GiveTask(handle)
	self.part = handle
	task.spawn(function()
		task.wait(5)
		self:stop()
	end)
end

function PowerUpEffect.update(self: PowerUpEffect)
	if not self.part then
		return nil
	end
	local cframe = self.character:GetPrimaryPartCFrame()
	local offset = self.offset
	self.part.CFrame = cframe + offset
end

return {
	["PowerUpEffect"] = PowerUpEffect,
}
