-- ChangelogController

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
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ChangelogList =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "changelog", "changelog").ChangelogList
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ChangelogScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "changelog", "changelog-screen").ChangelogScreen

local ChangelogController = setmetatable({}, {
	["__tostring"] = function()
		return "ChangelogController"
	end,
})
ChangelogController.__index = ChangelogController

function ChangelogController.new(...)
	local self = ChangelogController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function ChangelogController.constructor(self) end

function ChangelogController.onStart(self) end

function ChangelogController.hasChangelogUpdated(self)
	Flamework.resolveDependency("zG"):awaitLoadedProfile()
	local profile = GlobalStore:getState().Profile
	local latestChangelog = nil
	for index, changelog in ChangelogList do
		local _ = index - 1
		if changelog.Timestamp > profile.PreviousJoinedTime == true then
			latestChangelog = changelog
			break
		end
	end
	return latestChangelog ~= nil
end

function ChangelogController.createChangelogIcon(self)
	Flamework.resolveDependency("xWL")
		:registerTopbarToggle(
			RobloxImage.Icon.LIST_CHECK,
			RobloxImage.Icon.HOUSE_LIGHT,
			false,
			function(controller, isToggled: boolean)
				if isToggled then
					controller:deselect()
				else
					Flamework.resolveDependency("lB5"):toggle(ChangelogScreen)
				end
			end,
			1
		)
		:setOrder(6)
end

Reflect.defineMetadata(ChangelogController, "identifier", "1oG")
Reflect.defineMetadata(ChangelogController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ChangelogController, "$:flamework@Controller", Controller, {})

return {
	["ChangelogController"] = ChangelogController,
}
