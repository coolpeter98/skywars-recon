-- ParticleModule

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Singleton = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "singleton").Singleton
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local Workspace: Workspace = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local omit = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "object", "omit").omit
local Make = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "altmake", "out").Make

type ParticleEmitterConfig = {
	Color: Color3 | ColorSequence?,
	Texture: string?,
	Speed: number | NumberRange?,
	CharacterParticle: boolean?,
	Count: number?,
}

local ParticleModule = setmetatable({}, {
	["__tostring"] = function()
		return "ParticleModule"
	end
})
type ParticleModule = typeof(ParticleModule)
ParticleModule.__index = ParticleModule

function ParticleModule.new(...): ParticleModule
	local class = ParticleModule
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function ParticleModule.constructor(self: ParticleModule) end

function ParticleModule.attachParticleEmitter(self: ParticleModule, parent: Instance, info: ParticleEmitterConfig): ParticleEmitter
	local emitter = Make("ParticleEmitter", omit(info, { "Color", "Speed", "CharacterParticle" }))

	if info.Color then
		local color: Color3 | ColorSequence = info.Color
		local colorSequence: ColorSequence
		if typeof(color) == "ColorSequence" then
			colorSequence = info.Color
		else
			colorSequence = ColorSequence.new(info.Color)
		end
		emitter.Color = colorSequence
	end

	local texture: string? = info.Texture
	if texture == "" or not texture then
		emitter.Texture = RobloxImage.PARTICLE
	end

	if info.Speed ~= nil then
		local speed: number | NumberRange = info.Speed
		local speedRange: NumberRange
		if typeof(speed) == "NumberRange" then
			speedRange = info.Speed
		else
			speedRange = NumberRange.new(info.Speed, info.Speed)
		end
		emitter.Speed = speedRange
	end

	if info.CharacterParticle then
		emitter:SetAttribute(Attribute.CharacterParticle, true)
	end

	emitter.Enabled = true
	emitter.Parent = parent

	return emitter
end

function ParticleModule.playParticlesAtPosition(self: ParticleModule, position: Vector3, info: ParticleEmitterConfig): ParticleEmitter
	local part = Instance.new("Part")
	part.Name = "Particles"
	part.Position = position
	part.Size = Vector3.new(1, 1, 1)
	part.Massless = true
	part.CanCollide = false
	part.Anchored = true
	part.Transparency = 1

	local emitter = self:attachParticleEmitter(part, info)
	part.Parent = Workspace

	return emitter
end

function ParticleModule.destroyParticlesNicely(self: ParticleModule, emitter: ParticleEmitter, callback: (() -> ())?)
	emitter.Enabled = false

	task.spawn(function()
		task.wait(emitter.Lifetime.Max)
		if not callback then
			emitter:Destroy()
			return nil
		end
		callback()
	end)
end

function ParticleModule.explodeParticlesAtPosition(self: ParticleModule, position: Vector3, info: ParticleEmitterConfig): ParticleEmitter
	local part = Instance.new("Part")
	part.Name = "ExplosionParticles"
	part.Position = position
	part.Size = Vector3.new(1, 1, 1)
	part.Massless = true
	part.CanCollide = false
	part.Anchored = true
	part.Transparency = 1

	local emitter = self:attachParticleEmitter(part, omit(info, { "Count" }))
	emitter.Rate = 0
	part.Parent = Workspace
	emitter:Emit(info.Count)

	self:destroyParticlesNicely(emitter, function()
		part:Destroy()
	end)

	return emitter
end

Reflect.defineMetadata(ParticleModule, "identifier", "dm")
Reflect.decorate(ParticleModule, "V0", Singleton, {})

return {
	["ParticleModule"] = ParticleModule
}
