-- EffectController

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
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Lighting: Lighting = Services.Lighting
local Workspace: Workspace = Services.Workspace
local Spr = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"spr",
	"spr"
)

export type EffectController = {
	new: (...any) -> EffectController,
	constructor: (self: EffectController, ...any) -> (),
	setBlur: (self: EffectController, size: number) -> (),
	springBlur: (self: EffectController, size: number, duration: number, ease: number) -> (),
	getBlur: (self: EffectController) -> BlurEffect,
	removeBlur: (self: EffectController) -> (),
	monochrome: (self: EffectController) -> (),
	polychrome: (self: EffectController) -> (),
}

local EffectController = setmetatable({}, {
	["__tostring"] = function()
		return "EffectController"
	end,
})
EffectController.__index = EffectController

function EffectController.new(...)
	local class = EffectController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function EffectController.constructor(self: EffectController) end

function EffectController.setBlur(self: EffectController, size: number)
	self:getBlur().Size = size
end

function EffectController.springBlur(self: EffectController, size: number, duration: number, ease: number)
	Spr.target(self:getBlur(), duration, ease, {
		["Size"] = size,
	})
end

function EffectController.getBlur(self: EffectController): BlurEffect
	local blurEffect = Workspace.CurrentCamera
	if blurEffect ~= nil then
		blurEffect = blurEffect:FindFirstChildOfClass("BlurEffect")
	end
	if not blurEffect then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 0
		blurEffect.Parent = Workspace.CurrentCamera
	end
	return blurEffect
end

function EffectController.removeBlur(self: EffectController)
	local camera = Workspace.CurrentCamera
	if camera ~= nil then
		local blurEffect = camera:FindFirstChildOfClass("BlurEffect")
		if blurEffect ~= nil then
			blurEffect:Destroy()
		end
	end
end

function EffectController.monochrome(self: EffectController)
	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	Spr.target(colorCorrection, 1, 3, {
		["Saturation"] = -1,
	})
end

function EffectController.polychrome(self: EffectController)
	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	Spr.target(colorCorrection, 1, 3, {
		["Saturation"] = 0.2,
	})
end

Reflect.defineMetadata(EffectController, "identifier", "Or")
Reflect.decorate(EffectController, "$:flamework@Controller", Controller, {})
return {
	["EffectController"] = EffectController,
}
