-- ActionBarController

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
local ActionBarScreen =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "action-bar", "action-bar-screen").ActionBarScreen
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local InventoryStoreActionType = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"rodux",
	"inventory-store"
).InventoryStoreActionType

type ActionBarController = {
	new: (...any) -> ActionBarController,
	constructor: (ActionBarController) -> (),
	onStart: (ActionBarController) -> (),
	displayActionBar: (ActionBarController, string, string, Color3) -> (),
	removeActionBar: (ActionBarController, string) -> (),
	mountActionBarScreen: (ActionBarController) -> (),
}

local ActionBarController = setmetatable({}, {
	__tostring = function()
		return "ActionBarController"
	end,
})

ActionBarController.__index = ActionBarController

function ActionBarController.new(...)
	local self = setmetatable({}, ActionBarController)
	return self:constructor(...) or self
end

function ActionBarController.constructor(_) end

function ActionBarController.onStart(self: ActionBarController)
	Events["8c84ed0f-84a1-4988-900e-10f532b65dc3"]:connect(function(image: string, text: string, color: Color3)
		self:displayActionBar(image, text, color)
	end)
	self:mountActionBarScreen()
end

function ActionBarController.displayActionBar(_: ActionBarController, image: string, text: string, color: Color3)
	GlobalStore:dispatch({
		["type"] = InventoryStoreActionType.AddActionBar,
		["Image"] = image,
		["Text"] = text,
		["Color"] = color,
	})
end

function ActionBarController.removeActionBar(_: ActionBarController, actionBarId: string)
	GlobalStore:dispatch({
		["type"] = InventoryStoreActionType.RemoveActionBar,
		["ActionBarId"] = actionBarId,
	})
end

function ActionBarController.mountActionBarScreen(_: ActionBarController)
	Flamework.resolveDependency("lB5"):open(ActionBarScreen, {})
end

Reflect.defineMetadata(ActionBarController, "identifier", "gkk")
Reflect.defineMetadata(ActionBarController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ActionBarController, "$:flamework@Controller", Controller, {})

return {
	["ActionBarController"] = ActionBarController,
}
