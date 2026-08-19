-- ChestController

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
local CHEST_SIZE =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "inventory", "inventory-constants").CHEST_SIZE
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local ChestScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "chest", "chest-screen").ChestScreen

type ChestController = {
	chest: Model?,
	screenController: any,
	constructor: (self: ChestController, screenController: any) -> (),
	onStart: (self: ChestController) -> (),
	openChest: (self: ChestController, chest: Model) -> (),
	updateChest: (self: ChestController, _: any, slotId: number, itemType: string) -> (),
	closeChest: (self: ChestController) -> (),
	getOpenedChest: (self: ChestController) -> Model?,
	isChestOpen: (self: ChestController) -> boolean,
}

local ChestController = setmetatable({}, {
	["__tostring"] = function()
		return "ChestController"
	end,
})
ChestController.__index = ChestController
function ChestController.new(...)
	local self = setmetatable({}, ChestController)
	return self:constructor(...) or self
end
function ChestController.constructor(self, screenController)
	self.screenController = screenController
end
function ChestController.onStart(self)
	-- Server notifies us that the opened chest's contents changed.
	Events["2686e385-ef93-4bdf-8d3f-0a318fefa8cb"]:connect(function(chest, items, shouldOpen)
		if self.chest ~= chest then
			return nil
		end
		local contents = {}
		local chestData = {}
		for i = 1, #items do
			local item = items[i]
			local _ = i - 1
			local _ = Items[item.Type]
			contents[item.Slot] = item
		end
		chestData.Contents = contents
		chestData.Size = CHEST_SIZE
		Flamework.resolveDependency("zG"):setValue("Chest", chestData)
		if shouldOpen then
			self.screenController:open(ChestScreen, {}):addCloseHandler(function()
				return self:closeChest()
			end)
		end
	end)
end
function ChestController.openChest(self, chest)
	self.chest = chest
	Events["09b88f40-1d56-492e-a1a8-361aa848f96b"](chest)
end
function ChestController.updateChest(self, _, slotId, itemType)
	if not self.chest then
		return nil
	end
	Events["0c591ef1-540e-4db6-8752-2bf060fda5f1"](self.chest, slotId, itemType)
end
function ChestController.closeChest(self)
	if not self.chest then
		return nil
	end
	Flamework.resolveDependency("zG"):setValue("Chest", nil)
	Events["a0d91e14-5b6f-4353-8977-fefd74b6e398"](self.chest)
	self.chest = nil
end
function ChestController.getOpenedChest(self)
	return self.chest
end
function ChestController.isChestOpen(self)
	return self.screenController:isOpen("Chest")
end
Reflect.defineMetadata(ChestController, "identifier", "4El")
Reflect.defineMetadata(ChestController, "flamework:parameters", { "lB5" })
Reflect.defineMetadata(ChestController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ChestController, "$:flamework@Controller", Controller, {})
return {
	["ChestController"] = ChestController,
}
