-- KillEffectController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace
local Make = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"altmake",
	"out"
).Make
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local InstanceUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "instance-util").InstanceUtil

type Maid = typeof(Maid.new())

type KillEffectArgs = {
	Character: Model?,
	Killer: Player?,
	CosmeticId: string?,
	Parent: Folder?,
	IsInViewportFrame: boolean?,
	AnimationEnded: boolean,
	Maid: Maid?,
}

export type KillEffectController = {
	new: (...any) -> KillEffectController,
	constructor: (self: KillEffectController, cosmeticDecoratorModule: any) -> (),
	onStart: (self: KillEffectController) -> (),
	playKillEffect: (
		self: KillEffectController,
		character: Model,
		cosmeticId: string,
		killer: Player?,
		parent: Folder?
	) -> KillEffectArgs,
	stopAnimations: (self: KillEffectController, parent: Folder) -> (),
	cosmeticDecoratorModule: any,
	killEffectsFolder: Folder,
}

local KillEffectController: KillEffectController = setmetatable({}, {
	["__tostring"] = function()
		return "KillEffectController"
	end,
})
KillEffectController.__index = KillEffectController
function KillEffectController.new(...)
	local self = KillEffectController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function KillEffectController.constructor(self: KillEffectController, cosmeticDecoratorModule)
	self.cosmeticDecoratorModule = cosmeticDecoratorModule
	self.killEffectsFolder = Make("Folder", {
		["Name"] = "KillEffects",
		["Parent"] = nil,
		["Parent"] = Workspace,
	})
end
function KillEffectController.onStart(self: KillEffectController)
	Events.KillEffect:connect(function(character, cosmeticId, killer)
		local humanoid = Instance.new("Humanoid")
		humanoid.HipHeight = 2.192423105239868
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.Parent = character
		Instance.new("Animator").Parent = humanoid
		self:playKillEffect(character, cosmeticId, killer)
	end)
end
function KillEffectController.playKillEffect(
	self: KillEffectController,
	character: Model,
	cosmeticId: string,
	killer: Player?,
	parent: Folder?
): KillEffectArgs
	if parent == nil then
		parent = self.killEffectsFolder
	end
	local cosmetic = Cosmetics[cosmeticId]
	if not cosmetic or cosmetic.Type ~= "KillEffect" then
		return nil
	end
	local killEffect = self.cosmeticDecoratorModule:resolveKillEffect(cosmeticId)
	local isInViewportFrame = InstanceUtil.isViewportFrameDescendent(parent)
	local maid = Maid.new()
	local effectFolder = Make("Folder", {
		["Name"] = cosmeticId,
		["Parent"] = parent,
	})
	maid:GiveTask(effectFolder)
	local killEffectArgs = {
		["Character"] = nil,
		["Killer"] = nil,
		["CosmeticId"] = nil,
		["Parent"] = nil,
		["IsInViewportFrame"] = nil,
		["AnimationEnded"] = false,
		["Maid"] = nil,
		["Character"] = character,
		["Killer"] = killer,
		["CosmeticId"] = cosmeticId,
		["Parent"] = effectFolder,
		["IsInViewportFrame"] = isInViewportFrame,
		["Maid"] = maid,
	}
	maid:GiveTask(function()
		killEffectArgs.AnimationEnded = true
		self:stopAnimations(effectFolder)
	end)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanQuery = false
		end
	end
	character.Parent = effectFolder
	task.spawn(function()
		killEffect:playEffect(character, killEffectArgs)
		maid:DoCleaning()
	end)
	return killEffectArgs
end
function KillEffectController.stopAnimations(_, parent: Folder)
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("Animator") then
			for _, animationTrack in descendant:GetPlayingAnimationTracks() do
				animationTrack:Stop()
				animationTrack:Destroy()
			end
		end
	end
end
Reflect.defineMetadata(KillEffectController, "identifier", "Q83")
Reflect.defineMetadata(KillEffectController, "flamework:parameters", { "Jkb" })
Reflect.defineMetadata(KillEffectController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(KillEffectController, "$:flamework@Controller", Controller, {})
return {
	["KillEffectController"] = KillEffectController,
}
