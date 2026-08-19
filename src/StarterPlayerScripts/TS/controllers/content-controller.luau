-- ContentController

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
local Players: Players = Services.Players
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local RunService: RunService = Services.RunService
local Workspace: Workspace = Services.Workspace
local ObjectUtils: ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
local RobloxAnimation = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"asset",
	"roblox",
	"roblox-animation"
).RobloxAnimation
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local Event = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "event").Event
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Spr = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"spr",
	"spr"
)
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage

export type ContentController = {
	maid: any,
	loadedProgress: any,
	loadedEvent: any,
	loaded: boolean,
	loadedAmount: number,
	didLoadingScreenEvent: any,
	didLoadingScreen: boolean?,
}

local ContentController = setmetatable({}, {
	["__tostring"] = function()
		return "ContentController"
	end,
})
ContentController.__index = ContentController

function ContentController.new(...)
	local class = ContentController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function ContentController.constructor(self: ContentController)
	self.maid = Maid.new()
	self.loadedProgress = Event.new()
	self.loadedEvent = Event.new()
	self.loaded = false
	self.loadedAmount = 0
	self.didLoadingScreenEvent = Event.new()
	self.didLoadingScreen = nil
end

function ContentController.onStart(self: ContentController)
	task.spawn(function()
		self:attachLoadingScreen()
	end)
	local preloadList = {}
	local skinsFolder = ReplicatedStorage.Skins
	table.insert(preloadList, skinsFolder)
	local miscFolder = ReplicatedStorage.Misc
	table.insert(preloadList, miscFolder)
	local itemsFolder = ReplicatedStorage.Items
	table.insert(preloadList, itemsFolder)
	local blocksFolder = ReplicatedStorage.Blocks
	table.insert(preloadList, blocksFolder)
	for _, animationId in ObjectUtils.values(RobloxAnimation) do
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		table.insert(preloadList, animation)
	end
	for _, soundGroup in ObjectUtils.values(RobloxSound) do
		for _, soundId in ObjectUtils.values(soundGroup) do
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			table.insert(preloadList, sound)
		end
	end
	for _, image in ObjectUtils.values(RobloxImage) do
		if type(image) == "string" then
			local texture = Instance.new("Texture")
			texture.Texture = image
			table.insert(preloadList, texture)
		else
			for _, imageId in ObjectUtils.values(image) do
				local texture = Instance.new("Texture")
				texture.Texture = imageId
				table.insert(preloadList, texture)
			end
		end
	end
	task.spawn(function()
		task.wait(10)
		if self:setLoaded() then
			print("Bypassed loading screen")
		end
	end)
	local camera = Workspace.CurrentCamera
	if camera.CameraSubject ~= nil then
		self:setLoaded()
		return nil
	end
	camera:GetPropertyChangedSignal("CameraSubject"):Wait()
	self:setLoaded()
end

function ContentController.setLoaded(self: ContentController)
	if self.loaded then
		return false
	end
	self.loaded = true
	self.loadedEvent:fire()
	print((("Preloaded %* assets!"):format(self.loadedAmount)))
	return true
end

function ContentController.didUseLoadingScreen(self: ContentController)
	if self.didLoadingScreen == nil then
		self.didLoadingScreenEvent:wait()
	end
	local result = self.didLoadingScreen
	return result == nil and true or result
end

function ContentController.attachLoadingScreen(self: ContentController)
	local loadingScreen = Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen")
	print((("attachLoadingScreen %*"):format(loadingScreen)))
	if not loadingScreen then
		self.didLoadingScreen = false
		self.didLoadingScreenEvent:fire()
		return nil
	end
	self.didLoadingScreen = true
	self.didLoadingScreenEvent:fire()
	print("Attached to loading screen!")
	if self.loaded then
		self:destroyLoadingScreen(loadingScreen)
		return nil
	end
	self.maid:GiveTask(self.loadedEvent:bind(function()
		self:destroyLoadingScreen(loadingScreen)
	end))
	local progressBar = loadingScreen:FindFirstChild("Background")
	if progressBar ~= nil then
		progressBar = progressBar:FindFirstChild("ScaleContainer")
		if progressBar ~= nil then
			progressBar = progressBar:FindFirstChild("ProgressBar")
		end
	end
	if not progressBar then
		return nil
	end
	local circularProgressContainer = loadingScreen
		:FindFirstChild("Background")
		:FindFirstChild("ScaleContainer")
		:FindFirstChild("CircularProgressContainer")
	local progressText = circularProgressContainer:FindFirstChildOfClass("TextLabel")
	local leftGradient = circularProgressContainer
		:FindFirstChild("CircularProgress")
		:FindFirstChild("Left")
		:FindFirstChildOfClass("ImageLabel")
		:FindFirstChildOfClass("UIGradient")
	local rightGradient = circularProgressContainer
		:FindFirstChild("CircularProgress")
		:FindFirstChild("Right")
		:FindFirstChildOfClass("ImageLabel")
		:FindFirstChildOfClass("UIGradient")
	self.maid:GiveTask(self.loadedProgress:bind(function()
		self:updateProgress(progressBar, progressText)
	end))
	local progress = 0
	self.maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime)
		progress = (progress + 0.01 * (deltaTime / 0.016666666666666666)) % 2
		local progressFraction
		if progress > 1 then
			progressFraction = 1 - progress
		else
			progressFraction = progress
		end
		local degrees = progressFraction * 360
		local leftRotation
		if progressFraction >= 0 then
			leftRotation = math.clamp(degrees, 180, 360)
		else
			local absDegrees = math.abs(degrees) - 180
			leftRotation = math.clamp(absDegrees, 0, 180)
		end
		local rightRotation
		if progressFraction >= 0 then
			rightRotation = math.clamp(degrees, 0, 180)
		else
			local absDegrees = math.abs(degrees) + -180
			rightRotation = math.clamp(absDegrees, -360, 0)
		end
		leftGradient.Rotation = leftRotation
		rightGradient.Rotation = rightRotation
	end))
	self:updateProgress(progressBar, progressText)
end

function ContentController.updateProgress(self: ContentController, progressBar, progressText)
	local progressClipping = progressBar:FindFirstChild("ProgressClipping")
	local progress = progressClipping:FindFirstChild("Progress")
	local progressRatio = self.loadedAmount / 475
	local clampedRatio = math.min(progressRatio, 1)
	if clampedRatio == 1 then
		progressText.Text = "Waiting for server"
	else
		progressText.Text = "Loading assets"
	end
	Spr.target(progressClipping, 1, 1, {
		["Size"] = UDim2.fromScale(clampedRatio, 1),
	})
	Spr.target(progress, 1, 1, {
		["Size"] = UDim2.new(1, self:getSizeOffset(clampedRatio, progressBar.Size.Width.Offset, 10), 1, 0),
	})
end

function ContentController.getSizeOffset(_, ratio, widthOffset, padding)
	return padding - (ratio * widthOffset - (widthOffset - padding))
end

function ContentController.destroyLoadingScreen(self: ContentController, loadingScreen)
	self.maid:DoCleaning()
	loadingScreen:Destroy()
end

Reflect.defineMetadata(ContentController, "identifier", "Xlg")
Reflect.defineMetadata(ContentController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ContentController, "$:flamework@Controller", Controller, {})
return {
	["ContentController"] = ContentController,
}
