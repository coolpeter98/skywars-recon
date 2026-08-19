-- VoidKillEffect

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
local KillEffect = RuntimeLib.import(script, script.Parent.Parent, "kill-effect").KillEffect
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
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

local VOID_RADIUS = 2 * BlockConstants.BLOCK_SIZE

type VoidKillEffect = {
	new: (...any) -> VoidKillEffect,
	constructor: (self: VoidKillEffect, ...any) -> (),
	playEffect: (self: VoidKillEffect, character: Model) -> (),
	createVoidModel: (self: VoidKillEffect, position: Vector3) -> Model,
	createBasePart: (self: VoidKillEffect, position: Vector3) -> Part,
	createBeam: (self: VoidKillEffect, basePart: Part) -> Beam,
	createDebugPart: (self: VoidKillEffect, position: Vector3, color: Color3) -> (),
	getRotation: (self: VoidKillEffect, beamCount: number) -> number,
	createAttachments: (self: VoidKillEffect, basePart: Part, isOddBeam: boolean) -> { Attachment },
	createAttachment: (self: VoidKillEffect, angle: number, positionX: number, orientation: Vector3) -> Attachment,
	getAttachmentWorldPosition: (self: VoidKillEffect, angle: number, positionX: number) -> Vector3,
	getAttachmentLookAtDirection: (self: VoidKillEffect, angle: number) -> Vector3,
	createRadiusDebugPart: (self: VoidKillEffect, basePart: Part, angle: number) -> (),
	beamCount: number,
}

local VoidKillEffect = setmetatable({}, {
	["__tostring"] = function(): string
		return "VoidKillEffect"
	end,
	["__index"] = KillEffect,
})
VoidKillEffect.__index = VoidKillEffect

function VoidKillEffect.new(...)
	local class = VoidKillEffect
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function VoidKillEffect.constructor(self: VoidKillEffect, ...)
	KillEffect.constructor(self, ...)
	self.beamCount = 0
end

function VoidKillEffect.playEffect(_, character: Model)
	character:Destroy()
	character:GetPivot()
end

function VoidKillEffect.createVoidModel(self: VoidKillEffect, position: Vector3): Model
	local model = Instance.new("Model")
	local basePart = self:createBasePart(position)
	basePart.Parent = model
	self:createDebugPart(basePart.Position + Vector3.new(0, 0, -3), Color.Yellow)
	self:createBeam(basePart)
	self:createBeam(basePart)
	self:createBeam(basePart)
	self:createBeam(basePart)
	return model
end

function VoidKillEffect.createBasePart(_, position: Vector3): Part
	local part = Instance.new("Part")
	part.Position = position
	local sizeY = VOID_RADIUS * 2
	local sizeZ = VOID_RADIUS * 2
	part.Size = Vector3.new(0.1, sizeY, sizeZ)
	part.Orientation = Vector3.new(0, 0, 90)
	part.Material = Enum.Material.Neon
	part.Shape = Enum.PartType.Cylinder
	part.Color = Color3.fromRGB(45, 45, 45)
	part.CanCollide = false
	part.Anchored = true
	return part
end

function VoidKillEffect.createBeam(self: VoidKillEffect, basePart: Part): Beam
	self.beamCount = self.beamCount + 1
	local isBeamOneOrTwo = self.beamCount == 1 and true or self.beamCount == 2
	local attachments = self:createAttachments(basePart, self.beamCount == 1 and true or self.beamCount == 3)
	local attachmentA = attachments[1]
	local attachmentB = attachments[2]
	attachmentA.Parent = basePart
	attachmentB.Parent = basePart
	local beam = Instance.new("Beam")
	beam.Color = ColorSequence.new(Color.Red)
	beam.Texture = "rbxassetid://1359426947"
	beam.TextureLength = 0.5
	beam.TextureMode = Enum.TextureMode.Static
	beam.TextureSpeed = 0.5
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(0.7, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	beam.CurveSize0 = isBeamOneOrTwo and 5 or -5
	beam.CurveSize1 = isBeamOneOrTwo and 5 or -5
	beam.Segments = 36
	beam.Width0 = 5
	beam.Width1 = 5
	local attachment0
	if isBeamOneOrTwo then
		attachment0 = attachmentA
	else
		attachment0 = attachmentB
	end
	beam.Attachment0 = attachment0
	if isBeamOneOrTwo then
		attachmentA = attachmentB
	end
	beam.Attachment1 = attachmentA
	beam.Parent = basePart
	return beam
end

function VoidKillEffect.createDebugPart(_, position: Vector3, color: Color3)
	local part = Instance.new("Part")
	part.Position = position
	part.Size = Vector3.new(1, 1, 1)
	part.Anchored = true
	part.Color = color
	part.Parent = Workspace
end

function VoidKillEffect.getRotation(_, beamCount: number): number
	return beamCount == 1 and 270
		or (beamCount == 2 and 360 or (beamCount == 3 and 90 or (beamCount == 4 and 180 or 270)))
end

function VoidKillEffect.createAttachments(self: VoidKillEffect, basePart: Part, isOddBeam: boolean): { Attachment }
	local rotation = self:getRotation(self.beamCount)
	local rotationRadians = math.rad(rotation)
	local beamLength = MathUtil.random(4 * BlockConstants.BLOCK_SIZE, 7 * BlockConstants.BLOCK_SIZE)
	local bottomAttachment =
		self:createAttachment(rotationRadians, 0, isOddBeam and Vector3.new(0, -180, -135) or Vector3.new(0, -180, 135))
	bottomAttachment.Name = "Bottom"
	bottomAttachment.Parent = basePart
	local topAttachment = self:createAttachment(
		rotationRadians + 3.141592653589793,
		beamLength,
		isOddBeam and Vector3.new(0, 0, 45) or Vector3.new(0, 0, -45)
	)
	topAttachment.Name = "Top"
	topAttachment.Parent = basePart
	self:createRadiusDebugPart(basePart, 0)
	self:createRadiusDebugPart(basePart, 45)
	self:createRadiusDebugPart(basePart, 90)
	self:createRadiusDebugPart(basePart, 135)
	self:createRadiusDebugPart(basePart, 180)
	self:createRadiusDebugPart(basePart, 270)
	return { bottomAttachment, topAttachment }
end

function VoidKillEffect.createAttachment(
	self: VoidKillEffect,
	angle: number,
	positionX: number,
	orientation: Vector3
): Attachment
	local attachment = Instance.new("Attachment")
	attachment.Position = self:getAttachmentWorldPosition(angle, positionX)
	attachment.Orientation = orientation
	return attachment
end

function VoidKillEffect.getAttachmentWorldPosition(_, angle: number, positionX: number): Vector3
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)
	local offset = Vector3.new(cosAngle, 0, sinAngle) * MathUtil.random(VOID_RADIUS - 0.5, VOID_RADIUS + 1.5)
	local offsetX = offset.X
	local offsetZ = offset.Z
	return Vector3.new(positionX, offsetX, offsetZ)
end

function VoidKillEffect.getAttachmentLookAtDirection(_, angle: number): Vector3
	local perpendicularAngle = angle + 1.5707963267948966
	local cosAngle = math.cos(perpendicularAngle)
	local sinAngle = math.sin(perpendicularAngle)
	return Vector3.new(cosAngle, 0, sinAngle)
end

function VoidKillEffect.createRadiusDebugPart(self: VoidKillEffect, basePart: Part, angle: number)
	local shade = angle / 360
	local angleRadians = math.rad(angle)
	local cosAngle = math.cos(angleRadians)
	local sinAngle = math.sin(angleRadians)
	local offsetDirection = Vector3.new(cosAngle, 0, sinAngle)
	self:createDebugPart(basePart.Position + offsetDirection * VOID_RADIUS, Color3.new(shade, shade, shade))
end

Reflect.defineMetadata(VoidKillEffect, "identifier", "dBE")
Reflect.decorate(VoidKillEffect, "1YG", CosmeticDecorator, { CosmeticId.KillEffectVoid })

return {
	["VoidKillEffect"] = VoidKillEffect,
}
