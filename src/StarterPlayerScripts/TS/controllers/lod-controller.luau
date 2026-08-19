-- LodController

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
local LOD_ENABLED = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "lod", "lod").LOD_ENABLED
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local CollectionService: CollectionService = Services.CollectionService
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local Workspace: Workspace = Services.Workspace
local GetPlayerRoot = RuntimeLib.import(script, script.Parent.Parent, "util", "util").GetPlayerRoot
local VectorUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil
local CollectionTagged = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"collection",
	"collection-util"
).CollectionTagged

type LodController = {
	lodTiers: { [number]: { [number]: Instance } },
}

local LodController = setmetatable({}, {
	["__tostring"] = function()
		return "LodController"
	end,
})
LodController.__index = LodController

function LodController.new(...)
	local self = setmetatable({}, LodController)
	return self:constructor(...) or self
end

function LodController.constructor(self: LodController)
	self.lodTiers = {}
	for tier = 0, 2 do
		self.lodTiers[tier] = {}
	end
end

function LodController.onStart(self: LodController)
	if not LOD_ENABLED then
		return nil
	end

	CollectionTagged("lod:group", function(instance)
		local lodData = LodController:getLodData(instance)
		local tier = lodData[1]
		local origin = lodData[2]
		self.lodTiers[tier][origin] = instance
	end)

	CollectionService:GetInstanceRemovedSignal("lod:group"):Connect(function(instance)
		local lodData = LodController:getLodData(instance)
		local tier = lodData[1]
		local origin = lodData[2]
		self.lodTiers[tier][origin] = nil
	end)
end

function LodController.onTick(self: LodController, _)
	for tier, origins in self.lodTiers do
		for origin, instance in origins do
			self:setRender(instance, self:shouldRender(tier, origin, instance))
		end
	end
end

function LodController.shouldRender(_, _, _, _)
	return true
end

function LodController.setRender(self: LodController, instance, shouldRender)
	local inWorkspace = instance.Parent ~= ReplicatedStorage
	if shouldRender and not inWorkspace then
		instance.Parent = Workspace
	elseif not shouldRender and inWorkspace then
		instance.Parent = ReplicatedStorage
	end
end

function LodController.getChunkPosition(self: LodController)
	local root = GetPlayerRoot()
	if not root then
		return nil
	end
	local position = root.Position
	local flooredPosition = VectorUtil.floorVector(position)
	return flooredPosition - VectorUtil.modVector(flooredPosition, 192)
end

function LodController.getLodData(self: LodController, instance)
	return { instance:GetAttribute("LodTier"), instance:GetAttribute("LodOrigin") }
end

Reflect.defineMetadata(LodController, "identifier", "z5o")
Reflect.defineMetadata(LodController, "flamework:implements", { "$:flamework@OnStart", "$:flamework@OnTick" })
Reflect.decorate(LodController, "$:flamework@Controller", Controller, {})
return {
	["LodController"] = LodController,
}
