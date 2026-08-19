-- CosmeticDecoratorModule

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
local Singleton = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "singleton").Singleton
local Modding = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Modding

type CosmeticDecoratorModule = {
	new: <T>(...any) -> T,
	constructor: (self: CosmeticDecoratorModule, ...any) -> (),
	resolveArrowTrail: (self: CosmeticDecoratorModule, arrowTrailId: string) -> any,
	resolveKillEffect: (self: CosmeticDecoratorModule, killEffectId: string) -> any,
	resolveCage: (self: CosmeticDecoratorModule, cageId: string) -> any,
	resolveWinEffect: (self: CosmeticDecoratorModule, winEffectId: string) -> any,
	resolveDependency: (self: CosmeticDecoratorModule, decoratorId: string) -> any,
	isArrowTrail: (self: CosmeticDecoratorModule, arrowTrail: any) -> boolean,
	isKillEffect: (self: CosmeticDecoratorModule, killEffect: any) -> boolean,
	isCage: (self: CosmeticDecoratorModule, cage: any) -> boolean,
	isWinEffect: (self: CosmeticDecoratorModule, winEffect: any) -> boolean,
}

local CosmeticDecoratorModule = setmetatable({}, {
	["__tostring"] = function(): string
		return "CosmeticDecoratorModule"
	end,
})
CosmeticDecoratorModule.__index = CosmeticDecoratorModule

function CosmeticDecoratorModule.new<T>(...): T
	local cls: CosmeticDecoratorModule = CosmeticDecoratorModule
	local self = setmetatable({}, cls)
	return self:constructor(...) or self
end

function CosmeticDecoratorModule.constructor(self: CosmeticDecoratorModule) end

function CosmeticDecoratorModule.resolveArrowTrail(self: CosmeticDecoratorModule, arrowTrailId: string)
	local arrowTrail = self:resolveDependency(arrowTrailId)
	if not self:isArrowTrail(arrowTrail) then
		error(("ArrowTrail %* is missing playEffect method."):format(arrowTrailId))
	end
	return arrowTrail
end

function CosmeticDecoratorModule.resolveKillEffect(self: CosmeticDecoratorModule, killEffectId: string)
	local killEffect = self:resolveDependency(killEffectId)
	if not self:isKillEffect(killEffect) then
		error(("KillEffect %* is missing playEffect method."):format(killEffectId))
	end
	return killEffect
end

function CosmeticDecoratorModule.resolveCage(self: CosmeticDecoratorModule, cageId: string)
	local cage = self:resolveDependency(cageId)
	if not self:isCage(cage) then
		error(("Cage %* is missing createCage method."):format(cageId))
	end
	return cage
end

function CosmeticDecoratorModule.resolveWinEffect(self: CosmeticDecoratorModule, winEffectId: string)
	local winEffect = self:resolveDependency(winEffectId)
	if not self:isWinEffect(winEffect) then
		error(("WinEffect %* is missing createWinEffect method."):format(winEffectId))
	end
	return winEffect
end

function CosmeticDecoratorModule.resolveDependency(self: CosmeticDecoratorModule, decoratorId: string)
	local foundDecorator = nil
	for index, decorator in Modding.getDecorators("1YG") do
		local _ = index - 1
		if decorator.arguments[1] == decoratorId == true then
			foundDecorator = decorator
			break
		end
	end
	local constructor
	if foundDecorator == nil then
		constructor = foundDecorator
	else
		constructor = foundDecorator.constructor
	end
	if not constructor then
		error(("Missing Cosmetic module for %*."):format(decoratorId))
	end
	return Modding.resolveSingleton(foundDecorator.constructor)
end

function CosmeticDecoratorModule.isArrowTrail(self: CosmeticDecoratorModule, arrowTrail)
	return arrowTrail.playEffect ~= nil
end

function CosmeticDecoratorModule.isKillEffect(self: CosmeticDecoratorModule, killEffect)
	return killEffect.playEffect ~= nil
end

function CosmeticDecoratorModule.isCage(self: CosmeticDecoratorModule, cage)
	return cage.createCage ~= nil
end

function CosmeticDecoratorModule.isWinEffect(self: CosmeticDecoratorModule, winEffect)
	return winEffect.createWinEffect ~= nil
end

Reflect.defineMetadata(CosmeticDecoratorModule, "identifier", "Jkb")
Reflect.decorate(CosmeticDecoratorModule, "V0", Singleton, {})

return {
	["CosmeticDecoratorModule"] = CosmeticDecoratorModule,
}
