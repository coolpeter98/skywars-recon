-- MobileController

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
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local RaycastType = RuntimeLib.import(script, script.Parent, "block-raycast-controller").RaycastType
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local MobileButtonScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "mobile", "mobile-button-screen").MobileButtonScreen

export type MobileController = {
	blockRaycastController: any,
	hotbarController: any,
	sprintingController: any,
	screenController: any,
	maid: any,
	primaryButton: { Id: string, Screen: any }?,
	blockButton: { Id: string, Screen: any }?,
	sprintingButton: { Id: string, Screen: any }?,
	mounted: boolean,
}

local MobileController = setmetatable({}, {
	["__tostring"] = function()
		return "MobileController"
	end,
})
MobileController.__index = MobileController
function MobileController.new(...)
	local class = MobileController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function MobileController.constructor(
	self: MobileController,
	blockRaycastController,
	hotbarController,
	sprintingController,
	screenController
)
	self.blockRaycastController = blockRaycastController
	self.hotbarController = hotbarController
	self.sprintingController = sprintingController
	self.screenController = screenController
	self.maid = Maid.new()
	self.primaryButton = nil
	self.blockButton = nil
	self.sprintingButton = nil
	self.mounted = false
end
function MobileController.onStart(self: MobileController)
	if not ScreenUtil.isMobile() then
		return nil
	end
	self:enableButtons()
	self.screenController.ScreenOpenedEvent:bind(function(screenOpenedEvent)
		if screenOpenedEvent.screenHandler.Options.Focused then
			self:disableButtons()
		end
	end)
	self.screenController.ScreenClosedEvent:bind(function(screenClosedEvent)
		if screenClosedEvent.screenHandler.Options.Focused then
			self:enableButtons()
		end
	end)
end
function MobileController.enableButtons(self: MobileController)
	if self.mounted then
		return nil
	end
	self.mounted = true
	if self.sprintingController:getCanSprint() then
		self:openSprinting()
	end
	self:handleHeldItem(self.hotbarController:getHeldItemInfo())
	self.maid:GiveTask(self.hotbarController.ActiveItemUpdated:bind(function(activeItemEvent)
		self:handleHeldItem(activeItemEvent.heldItemInfo)
	end))
	self.maid:GiveTask(Flamework.resolveDependency("WXw").Ticked:bind(function()
		local blockRaycast = self.blockRaycastController:getBlockRaycastStored()
		if
			not blockRaycast
			or (blockRaycast.RaycastType == RaycastType.Paused or blockRaycast.RaycastType == RaycastType.Standard)
		then
			if self.blockButton then
				self.blockButton.Screen:close()
				self.blockButton = nil
			end
			return nil
		end
		if not self.blockButton then
			self:openButton("Block")
		end
	end))
end
function MobileController.disableButtons(self: MobileController)
	if not self.mounted then
		return nil
	end
	self.mounted = false
	self.maid:DoCleaning()
	local primaryButton = self.primaryButton
	if primaryButton ~= nil then
		primaryButton.Screen:close()
	end
	local sprintingButton = self.sprintingButton
	if sprintingButton ~= nil then
		sprintingButton.Screen:close()
	end
	local blockButton = self.blockButton
	if blockButton ~= nil then
		blockButton.Screen:close()
	end
	self.primaryButton = nil
	self.sprintingButton = nil
	self.blockButton = nil
end
function MobileController.handleHeldItem(self: MobileController, heldItemInfo)
	local melee
	if heldItemInfo == nil then
		melee = heldItemInfo
	else
		melee = heldItemInfo.Melee
	end
	if melee then
		self:openButton("Melee")
		return nil
	end
	local ranged
	if heldItemInfo == nil then
		ranged = heldItemInfo
	else
		ranged = heldItemInfo.Ranged
	end
	if ranged then
		self:openButton("Projectile")
		return nil
	end
	if heldItemInfo ~= nil then
		heldItemInfo = heldItemInfo.PowerUp
	end
	if heldItemInfo then
		self:openButton("PowerUp")
		return nil
	end
	if self.primaryButton then
		self.primaryButton.Screen:close()
		self.primaryButton = nil
	end
end
function MobileController.openButton(self: MobileController, buttonId: string)
	if self.mounted then
		local currentId = self.primaryButton
		if currentId ~= nil then
			currentId = currentId.Id
		end
		if currentId == buttonId then
			return nil
		else
			if self.primaryButton then
				self.primaryButton.Screen:close()
				self.primaryButton = nil
			end
			local screen = Flamework.resolveDependency("lB5"):open(MobileButtonScreen, {
				["MobileButtonId"] = buttonId,
			})
			if buttonId == "Block" then
				self.blockButton = {
					["Id"] = buttonId,
					["Screen"] = screen,
				}
			else
				self.primaryButton = {
					["Id"] = buttonId,
					["Screen"] = screen,
				}
			end
		end
	else
		return nil
	end
end
function MobileController.openSprinting(self: MobileController)
	if not self.mounted then
		return nil
	end
	self.sprintingButton = {
		["Id"] = "Sprint",
		["Screen"] = nil,
		["Screen"] = Flamework.resolveDependency("lB5"):open(MobileButtonScreen, {
			["MobileButtonId"] = "Sprint",
			["DefaultActive"] = nil,
			["DefaultActive"] = self.sprintingController:isSprinting(),
		}),
	}
end
function MobileController.setCanSprint(self: MobileController, canSprint: boolean)
	if ScreenUtil.isMobile() then
		if self.sprintingButton or not canSprint then
			if self.sprintingButton and not canSprint then
				self.sprintingButton.Screen:close()
				self.sprintingButton = nil
			end
		else
			self:openSprinting()
		end
	else
		return nil
	end
end
Reflect.defineMetadata(MobileController, "identifier", "o5O")
Reflect.defineMetadata(MobileController, "flamework:parameters", {
	"WXw",
	"Dqk",
	"a4X",
	"lB5",
})
Reflect.defineMetadata(MobileController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(MobileController, "$:flamework@Controller", Controller, {})
return {
	["MobileController"] = MobileController,
}
