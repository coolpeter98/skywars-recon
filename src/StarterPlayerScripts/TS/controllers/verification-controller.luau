-- VerificationController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
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
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local Constants = RuntimeLib.import(script, script.Parent.Parent, "util", "constants").Constants
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local VerifyScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "verify", "verify-screen").VerifyScreen

type VerificationController = {
	screenController: any,
	new: (...any) -> VerificationController,
	constructor: (self: VerificationController, screenController: any) -> (),
	onStart: (self: VerificationController) -> (),
	toggleScreen: (self: VerificationController) -> (),
	attemptVerification: (self: VerificationController) -> boolean,
	pollVerification: (self: VerificationController) -> boolean,
	isVerified: (self: VerificationController) -> boolean,
	setup: (self: VerificationController) -> (),
}

local VerificationController = setmetatable({}, {
	["__tostring"] = function()
		return "VerificationController"
	end,
})
VerificationController.__index = VerificationController
function VerificationController.new(...)
	local self = setmetatable({}, VerificationController)
	return self:constructor(...) or self
end
function VerificationController.constructor(self: VerificationController, screenController: any)
	self.screenController = screenController
end
function VerificationController.onStart(self: VerificationController)
	task.spawn(function()
		self:setup()
	end)
end
function VerificationController.toggleScreen(self: VerificationController)
	if self:isVerified() then
		return nil
	end
	local shouldOpen = self.screenController:toggle(VerifyScreen)
	Events.SetVerificationOpen:fire(shouldOpen)
	if shouldOpen then
		task.spawn(function()
			while self.screenController:isOpen("Verify") and not self:attemptVerification() do
				task.wait(5)
			end
		end)
	end
end
function VerificationController.attemptVerification(self: VerificationController)
	if self:isVerified() or not self:pollVerification() then
		return false
	end
	Events.RequestVerification:fire()
	return true
end
function VerificationController.pollVerification(_: VerificationController)
	return Players.LocalPlayer:IsInGroup(Constants.VOXELS_GROUP_ID)
end
function VerificationController.isVerified(_: VerificationController)
	return GlobalStore:getState().Profile.Ranks.VERIFIED ~= nil
end
function VerificationController.setup(_: VerificationController)
	if Flamework.resolveDependency("D8k"):isExternalLinkAllowed("Discord") then
		GlobalStore:dispatch({
			["type"] = "SetValue",
			["Key"] = "ShowVerify",
			["Value"] = true,
		})
	end
end
Reflect.defineMetadata(VerificationController, "identifier", "0dL")
Reflect.defineMetadata(VerificationController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(VerificationController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(VerificationController, "$:flamework@Controller", Controller, {})
return {
	["VerificationController"] = VerificationController,
}
