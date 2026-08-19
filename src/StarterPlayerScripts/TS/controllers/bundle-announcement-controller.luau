-- BundleAnnouncementController

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
local ProductId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "ui", "util", "screen-util").ScreenUtil

type BundleAnnouncementController = {
	new: (...any) -> BundleAnnouncementController,
	constructor: (self: BundleAnnouncementController, ...any) -> (),
	onLobbyStart: (self: BundleAnnouncementController, ...any) -> (),
	openBundleAnnouncementScreen: (self: BundleAnnouncementController, ...any) -> (),
}

local _ = { ProductId.CRUSADER, ProductId.ROMAN, ProductId.ARABIAN_KNIGHT }
local BundleAnnouncementController = setmetatable({}, {
	["__tostring"] = function()
		return "BundleAnnouncementController"
	end,
})
BundleAnnouncementController.__index = BundleAnnouncementController
function BundleAnnouncementController.new(...)
	local class = BundleAnnouncementController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end
function BundleAnnouncementController.constructor(self) end
function BundleAnnouncementController.onLobbyStart(self, _)
	if ScreenUtil.isMobile() then
		return nil
	end
end
function BundleAnnouncementController.openBundleAnnouncementScreen(self, _)
	if GlobalStore:getState().Profile.InitialSession then
		return nil
	end
end
Reflect.defineMetadata(BundleAnnouncementController, "identifier", "mbD")
Reflect.defineMetadata(BundleAnnouncementController, "flamework:implements", { "09p" })
Reflect.decorate(BundleAnnouncementController, "$:flamework@Controller", Controller, {})
return {
	["BundleAnnouncementController"] = BundleAnnouncementController,
}
