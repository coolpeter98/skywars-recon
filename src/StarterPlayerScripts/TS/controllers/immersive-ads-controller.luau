-- ImmersiveAdsController

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
local CollectionService: CollectionService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).CollectionService
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local CollectionTagged = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"collection",
	"collection-util"
).CollectionTagged
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil

type ImmersiveAdsController = {}

local ImmersiveAdsController = setmetatable({}, {
	["__tostring"] = function()
		return "ImmersiveAdsController"
	end,
})
ImmersiveAdsController.__index = ImmersiveAdsController
function ImmersiveAdsController.new(...)
	local self = setmetatable({}, ImmersiveAdsController)
	return self:constructor(...) or self
end
function ImmersiveAdsController.constructor(_) end
function ImmersiveAdsController.onStart(self: ImmersiveAdsController)
	CollectionTagged("ad_gui", function(adGui: Instance)
		if PlaceUtil.isLobbyServer() or not adGui:IsA("AdGui") then
			return nil
		end
		if adGui.Status ~= Enum.AdUnitStatus.Active then
			local parent = adGui.Parent
			if parent ~= nil then
				local grandparent = parent.Parent
				if grandparent ~= nil then
					grandparent:Destroy()
				end
			end
		end
	end)
	Flamework.resolveDependency("lB5").ScreenOpenedEvent:bind(function(screenEvent)
		if screenEvent.screenHandler.Options.Focused then
			self:setAdsEnabled(false)
		end
	end)
	Flamework.resolveDependency("lB5").ScreenClosedEvent:bind(function(screenEvent)
		if screenEvent.screenHandler.Options.Focused then
			ScheduleUtil.runTask(function()
				if not Flamework.resolveDependency("lB5"):isFocused() then
					self:setAdsEnabled(true)
				end
			end, 0.1)
		end
	end)
end
function ImmersiveAdsController.setAdsEnabled(_, enabled: boolean)
	for _, adGui: Instance in CollectionService:GetTagged("ad_gui") do
		if adGui:IsA("AdGui") then
			adGui.Enabled = enabled
		end
	end
end
Reflect.defineMetadata(ImmersiveAdsController, "identifier", "x56")
Reflect.defineMetadata(ImmersiveAdsController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ImmersiveAdsController, "$:flamework@Controller", Controller, {})
return {
	["ImmersiveAdsController"] = ImmersiveAdsController,
}
