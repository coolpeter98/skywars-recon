-- CrateUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local ReplicatedStorage: ReplicatedStorage = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).ReplicatedStorage
local Particles =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "particle", "particles").Particles

type CrateUtil = {
	getRarity: (crate: { CosmeticId: string }) -> string,
	getDisplayName: (crate: { CosmeticId: string }) -> string,
	createCrateModel: (crateId: string) -> Model,
	createCrateParticleEmitter: (crateId: string, attachment: Attachment) -> unknown,
}

local CrateUtil: CrateUtil = {
	getRarity = function(crate: { CosmeticId: string })
		return Cosmetics[crate.CosmeticId].Rarity
	end,
	getDisplayName = function(crate: { CosmeticId: string })
		return Cosmetics[crate.CosmeticId].Name
	end,
}

local createCrateParticleEmitter: ((crateId: string, attachment: Attachment) -> unknown)? = nil

function CrateUtil.createCrateModel(crateId: string)
	local crateModel = ReplicatedStorage.Crate.Crates[crateId]:Clone()
	for _, descendant in crateModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end
	crateModel.RootPart.CanCollide = false
	local attachment = Instance.new("Attachment")
	createCrateParticleEmitter(crateId, attachment)
	attachment.Parent = crateModel.PrimaryPart
	return crateModel
end

createCrateParticleEmitter = function(crateId: string, attachment: Attachment)
	local crate = Crates[crateId]
	return Flamework.resolveDependency("dm"):attachParticleEmitter(attachment, Particles.crate(crate.Color))
end

CrateUtil.createCrateParticleEmitter = createCrateParticleEmitter

return {
	["CrateUtil"] = CrateUtil,
}
