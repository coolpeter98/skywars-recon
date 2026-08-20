-- TopbarController

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
local TopbarPlus = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"topbar-plus",
	"out"
)
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local SettingsScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "settings", "settings-screen").SettingsScreen
local GuiService: GuiService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).GuiService
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
type TopbarController = {
	icons: { any },
	primaryIcon: any?,
}

local TopbarController = setmetatable({}, {
	["__tostring"] = function()
		return "TopbarController"
	end,
})
TopbarController.__index = TopbarController

function TopbarController.new(...)
	local self = setmetatable({}, TopbarController)
	return self:constructor(...) or self
end

function TopbarController.constructor(self: TopbarController)
	self.icons = {}
	self.primaryIcon = nil
end

function TopbarController.onStart(self: TopbarController)
	self:registerTopbarToggle(RobloxImage.Topbar.SETTINGS, RobloxImage.Topbar.SETTINGS, false, function(icon, selected)
		if not selected then
			return nil
		end
		icon:deselect()
		Flamework.resolveDependency("lB5"):toggle(SettingsScreen)
	end, 0.6)
	if not (ScreenUtil.isMobile() and (PlaceUtil.isGameServer() or PlaceUtil.isPrivateServer())) then
		return nil
	end
	self:registerTopbarToggle(RobloxImage.Topbar.SHIFT_UNLOCK, RobloxImage.Topbar.SHIFT_LOCK, false, function()
		Flamework.resolveDependency("VJk"):invertCameraLock()
	end, 0.8)
end

function TopbarController.registerTopbarToggle(
	self: TopbarController,
	deselectedImage,
	selectedImage,
	alignRight,
	onToggle,
	imageScale
)
	local scale = imageScale == nil and 1 or imageScale
	local icon = TopbarPlus.Icon
		.new()
		:setImage(deselectedImage, "Deselected")
		:setImage(selectedImage, "Selected")
		:autoDeselect(false)
	icon:align(alignRight and "Right" or "Left")
	icon:setImageScale(scale)
	icon.selected:Connect(function()
		onToggle(icon, true)
	end)
	icon.deselected:Connect(function()
		onToggle(icon, false)
	end)
	local icons = self.icons
	table.insert(icons, icon)
	if not self:shouldFurl() then
		return icon
	end
	if self.primaryIcon then
		for _, icon in self.icons do
			icon:leave()
		end
		self.primaryIcon:destroy()
	end
	self.primaryIcon = TopbarPlus.Icon.new():setLabel("Menu"):setImage(RobloxImage.Topbar.UNFURL)
	self.primaryIcon:setMenu(self.icons)
	return icon
end

function TopbarController.enableTopbar(self: TopbarController)
	if not self:shouldFurl() then
		for index, icon in self.icons do
			local _ = index - 1
			icon:setEnabled(true)
		end
		return nil
	end
	if self.primaryIcon then
		self.primaryIcon:setEnabled(true)
	end
end

function TopbarController.disableTopbar(self: TopbarController)
	if not self:shouldFurl() then
		for index, icon in self.icons do
			local _ = index - 1
			icon:setEnabled(false)
		end
		return nil
	end
	if self.primaryIcon then
		self.primaryIcon:deselect()
		self.primaryIcon:setEnabled(false)
	end
end

function TopbarController.shouldFurl(_)
	local result
	-- Studio's topbar inset can exceed the mobile threshold, which would
	-- furl the settings gear into a menu. Published places keep the
	-- original behavior; local testing matches production (no furl).
	if not RunService:IsStudio() and GuiService.TopbarInset.Height > 45 then
		result = ScreenUtil.isMobile()
	else
		result = false
	end
	return result
end

Reflect.defineMetadata(TopbarController, "identifier", "xWL")
Reflect.defineMetadata(TopbarController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(TopbarController, "$:flamework@Controller", Controller, {})
return {
	["TopbarController"] = TopbarController,
}
