-- LightningArrowTrail

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
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local CosmeticDecorator = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-decorator"
).CosmeticDecorator
local ArrowTrailEffect = RuntimeLib.import(script, script.Parent.Parent, "arrow-trail-effect").ArrowTrailEffect
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ElectricArc = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"eletric-arc",
	"lib"
)
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local Queue = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "queue").Queue

local LightningArrowTrail = setmetatable({}, {
	["__tostring"] = function()
		return "LightningArrowTrail"
	end,
	["__index"] = ArrowTrailEffect,
})
LightningArrowTrail.__index = LightningArrowTrail

function LightningArrowTrail.new(...)
	local self = setmetatable({}, LightningArrowTrail)
	return self:constructor(...) or self
end

function LightningArrowTrail.constructor(self, ...)
	ArrowTrailEffect.constructor(self, ...)
	self.arrowPositions = Queue.new(3)
	self.arcs = Queue.new(6)
end

function LightningArrowTrail.playEffect(self, attachment: Attachment, maid: Maid)
	self.arcs:setOnRemoveHandler(function(arcItem)
		return arcItem.Value:Destroy()
	end)
	maid:GiveTask(ScheduleUtil.createSchedule(0.03333333333333333, function()
		local position = attachment.Position
		self:addArrowPosition(position)
		local oldestPosition = self.arrowPositions:peek()
		if oldestPosition then
			self:addArc(position, oldestPosition.Value)
		end
	end))
	maid:GiveTask(function()
		self:clearAllArcs()
		RuntimeLib.Promise.delay(0.24):andThen(function()
			self:cleanup()
		end)
	end)
	local trail = self:createTrail(attachment)
	trail.MaxLength = 18
	maid:GiveTask(function()
		trail.Enabled = false
		return trail.Enabled
	end)
	trail.Parent = attachment
end

function LightningArrowTrail.addArrowPosition(self, position)
	self.arrowPositions:add(position)
end

function LightningArrowTrail.addArc(self, from, to)
	local arc = ElectricArc.new(from, to, Color.White, Color.LightBlue, 1, 0.3)
	self.arcs:add(arc)
end

function LightningArrowTrail.clearAllArcs(self)
	task.spawn(function()
		while not self.arcs:isEmpty() do
			self.arcs:poll()
			task.wait(0.03333333333333333)
		end
	end)
end

function LightningArrowTrail.cleanup(self)
	self.arrowPositions:clear()
	self.arcs:clear()
end

Reflect.defineMetadata(LightningArrowTrail, "identifier", "LAo")
Reflect.decorate(LightningArrowTrail, "1YG", CosmeticDecorator, { CosmeticId.ArrowTrailLightning })

return {
	["LightningArrowTrail"] = LightningArrowTrail,
}
