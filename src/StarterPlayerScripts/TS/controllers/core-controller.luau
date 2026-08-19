-- CoreController

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
local ProximityPromptService: ProximityPromptService = Services.ProximityPromptService
local StarterGui: StarterGui = Services.StarterGui

type CoreController = {
	new: (...any) -> CoreController,
	constructor: (self: CoreController) -> (),
	onStart: (self: CoreController) -> (),
	disableProximityPrompts: (self: CoreController) -> (),
	enableProximityPrompts: (self: CoreController) -> (),
	disableDefault: (self: CoreController) -> (),
	setCoreSafe: (self: CoreController, key: string, value: any) -> (),
	getCoreSafe: (self: CoreController, key: string) -> ...any,
	enableChat: (self: CoreController) -> (),
	disableChat: (self: CoreController) -> (),
	enableJoystick: (self: CoreController) -> (),
	disableJoystick: (self: CoreController) -> (),
	getJoystickFrame: (self: CoreController) -> Frame?,
}

local CoreController = setmetatable({}, {
	["__tostring"] = function()
		return "CoreController"
	end,
})

CoreController.__index = CoreController

function CoreController.new(...)
	local self = setmetatable({}, CoreController)
	return self:constructor(...) or self
end

function CoreController.constructor(self: CoreController) end

function CoreController.onStart(self: CoreController)
	self:disableDefault()
end

function CoreController.disableProximityPrompts(self: CoreController)
	ProximityPromptService.MaxPromptsVisible = 0
end

function CoreController.enableProximityPrompts(self: CoreController)
	ProximityPromptService.MaxPromptsVisible = 16
end

function CoreController.disableDefault(self: CoreController)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	self:setCoreSafe("ResetButtonCallback", false)
	self:setCoreSafe("AvatarContextMenuEnabled", false)
end

function CoreController.setCoreSafe(self: CoreController, key: string, value: any)
	task.spawn(function()
		repeat
			local success, _ = RuntimeLib.try(function()
				StarterGui:SetCore(key, value)
				return RuntimeLib.TRY_BREAK
			end, function()
				task.wait(0.1)
			end)
		until success
	end)
end

function CoreController.getCoreSafe(self: CoreController, key: string): ...any
	repeat
		local success, results = RuntimeLib.try(function()
			return RuntimeLib.TRY_RETURN, { StarterGui:GetCore(key) }
		end, function()
			task.wait(0.1)
		end)
	until success
	return unpack(results)
end

function CoreController.enableChat(self: CoreController)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end

function CoreController.disableChat(self: CoreController)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
end

function CoreController.enableJoystick(self: CoreController)
	local joystickFrame = self:getJoystickFrame()
	if not joystickFrame then
		return nil
	end
	if self.thumbstickFrameSize == nil then
		return nil
	end
	joystickFrame.Size = self.thumbstickFrameSize
	self.thumbstickFrameSize = nil
end

function CoreController.disableJoystick(self: CoreController)
	local joystickFrame = self:getJoystickFrame()
	if not joystickFrame then
		return nil
	end
	if self.thumbstickFrameSize ~= nil then
		return nil
	end
	self.thumbstickFrameSize = joystickFrame.Size
	joystickFrame.Size = UDim2.new()
end

function CoreController.getJoystickFrame(self: CoreController): Frame?
	local frame = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
	if frame ~= nil then
		frame = frame:FindFirstChild("TouchControlFrame")
		if frame ~= nil then
			frame = frame:FindFirstChild("DynamicThumbstickFrame")
		end
	end
	if frame and frame:IsA("Frame") then
		return frame
	else
		return nil
	end
end

Reflect.defineMetadata(CoreController, "identifier", "lw")
Reflect.defineMetadata(CoreController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CoreController, "$:flamework@Controller", Controller, {})

return {
	["CoreController"] = CoreController,
}
