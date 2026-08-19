-- SoundController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
local Controller = flameworkCore.Controller
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Debris: Debris = Services.Debris
local SoundService: SoundService = Services.SoundService
local Workspace: Workspace = Services.Workspace
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local SoundGroupType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "sound", "sound-group-type").SoundGroupType
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

type SoundProps = {
	Volume: number?,
	Looped: boolean?,
	SoundGroup: string?,
	RollOffMinDistance: number?,
	RollOffMaxDistance: number?,
}

type SoundController = {
	soundsGroups: { [string]: SoundGroup },
	soundsFolder: Folder,
}

local SoundController = setmetatable({}, {
	["__tostring"] = function()
		return "SoundController"
	end,
})
SoundController.__index = SoundController
function SoundController.new(...)
	local self = SoundController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end
function SoundController.constructor(self: SoundController)
	self.soundsGroups = {}
	self.soundsFolder = Instance.new("Folder")
	self.soundsFolder.Parent = Workspace
	for _, soundGroupName in ObjectUtils.values(SoundGroupType) do
		local soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = soundGroupName
		soundGroup.Parent = SoundService
		self.soundsGroups[soundGroupName] = soundGroup
	end
end
function SoundController.onStart(self: SoundController)
	Events.SoundPlayed:connect(function(soundName, soundId, position, soundProps)
		if position then
			self:playSoundAtPosition(soundId, position, soundProps, soundName)
		else
			self:playSound(soundId, soundProps, soundName)
		end
	end)
	Events.SoundStopped:connect(function(soundName)
		local sound = self.soundsFolder:FindFirstChild(soundName)
		if sound ~= nil then
			sound:Destroy()
		end
	end)
	self:setSoundVolume(SoundGroupType.Music, 0)
	Flamework.resolveDependency("7xl"):onSettingChanged("MusicVolume", function(volume)
		self:setSoundVolume(SoundGroupType.Music, volume)
	end)
	Flamework.resolveDependency("7xl"):onSettingChanged("SfxVolume", function(volume)
		self:setSoundVolume(SoundGroupType.World, volume)
	end)
end
function SoundController.createSound(self: SoundController, soundId: string, soundProps: SoundProps?): Sound
	local props = self:getSoundProps(soundProps)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.SoundGroup = self.soundsGroups[props.SoundGroup]
	sound.Volume = props.Volume
	sound.Looped = props.Looped
	if props.RollOffMinDistance ~= nil then
		sound.RollOffMinDistance = props.RollOffMinDistance
	end
	if props.RollOffMaxDistance ~= nil then
		sound.RollOffMaxDistance = props.RollOffMaxDistance
	end
	if not sound.Looped then
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	return sound
end
function SoundController.playSound(
	self: SoundController,
	soundId: string,
	soundProps: SoundProps?,
	soundName: string?
): Sound
	local sound = self:createSound(soundId, soundProps)
	if soundName ~= "" and soundName then
		sound.Name = soundName
	end
	sound.Parent = self.soundsFolder
	sound:Play()
	return sound
end
function SoundController.playSoundAtPosition(
	self: SoundController,
	soundId: string,
	position: Vector3,
	soundProps: SoundProps?,
	soundName: string?
): Sound
	local part = Instance.new("Part")
	if soundName ~= "" and soundName then
		part.Name = soundName
	end
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0, 0, 0)
	part.Position = position
	part.Transparency = 1
	part.Parent = self.soundsFolder
	return self:playSoundAttachedToPart(soundId, part, soundProps)
end
function SoundController.playSoundAttachedToPart(
	self: SoundController,
	soundId: string,
	part: BasePart,
	soundProps: SoundProps?
): Sound
	local sound = self:createSound(soundId, soundProps)
	sound.Parent = part
	sound:Play()
	if not sound.Looped then
		sound.Ended:Connect(function()
			Debris:AddItem(part, sound.TimeLength)
		end)
	end
	return sound
end
function SoundController.startSound(self: SoundController, soundGroup: string?)
	if soundGroup == nil then
		soundGroup = SoundGroupType.World
	end
	self.soundsGroups[soundGroup].Volume = 1
end
function SoundController.stopSound(self: SoundController, soundGroup: string?)
	if soundGroup == nil then
		soundGroup = SoundGroupType.World
	end
	self.soundsGroups[soundGroup].Volume = 0
end
function SoundController.setSoundVolume(self: SoundController, soundGroup: string?, volume: number)
	if soundGroup == nil then
		soundGroup = SoundGroupType.World
	end
	self.soundsGroups[soundGroup].Volume = volume / 100
end
function SoundController.getSoundProps(_, soundProps: SoundProps?): SoundProps
	local props = {}
	local volume
	if soundProps == nil then
		volume = soundProps
	else
		volume = soundProps.Volume
	end
	props.Volume = volume == nil and 1 or volume
	local looped
	if soundProps == nil then
		looped = soundProps
	else
		looped = soundProps.Looped
	end
	if looped == nil then
		looped = false
	end
	props.Looped = looped
	local soundGroup
	if soundProps == nil then
		soundGroup = soundProps
	else
		soundGroup = soundProps.SoundGroup
	end
	if soundGroup == nil then
		soundGroup = SoundGroupType.World
	end
	props.SoundGroup = soundGroup
	local rollOffMinDistance
	if soundProps == nil then
		rollOffMinDistance = soundProps
	else
		rollOffMinDistance = soundProps.RollOffMinDistance
	end
	props.RollOffMinDistance = rollOffMinDistance
	if soundProps ~= nil then
		soundProps = soundProps.RollOffMaxDistance
	end
	props.RollOffMaxDistance = soundProps
	return props
end
Reflect.defineMetadata(SoundController, "identifier", "jL9")
Reflect.defineMetadata(SoundController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(SoundController, "$:flamework@Controller", Controller, {})
return {
	["SoundController"] = SoundController,
}
