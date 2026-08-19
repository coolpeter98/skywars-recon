-- CosmeticTitleDisplayController

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
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local CosmeticDisplayDecorator =
	RuntimeLib.import(script, script.Parent, "util", "cosmetic-display-decorator").CosmeticDisplayDecorator
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local InstanceUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "instance-util").InstanceUtil
local ReactRoblox = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"react-roblox"
)
local createLegacyRoot = ReactRoblox.createLegacyRoot
local createPortal = ReactRoblox.createPortal
local NameTag = RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "name-tag", "name-tag").NameTag
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local Provider = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"ReactRedux"
).Provider

type Cosmetic = {
	Type: string,
	Character: Instance?,
	DisplayModel: Instance,
}

type Maid = {
	GiveTask: (self: Maid, task: () -> ()) -> (),
}

type CosmeticTitleDisplayController = {
	equip: (self: CosmeticTitleDisplayController, cosmetic: Cosmetic, cosmeticId: string) -> Maid,
	equipInViewport: (self: CosmeticTitleDisplayController, maid: Maid, cosmetic: Cosmetic, cosmeticId: string) -> (),
}

local CosmeticTitleDisplayController = setmetatable({}, {
	["__tostring"] = function()
		return "CosmeticTitleDisplayController"
	end,
})
CosmeticTitleDisplayController.__index = CosmeticTitleDisplayController

function CosmeticTitleDisplayController.new(...)
	local self = setmetatable({}, CosmeticTitleDisplayController)
	return self:constructor(...) or self
end

function CosmeticTitleDisplayController.constructor(_) end

function CosmeticTitleDisplayController.equip(
	self: CosmeticTitleDisplayController,
	cosmetic: Cosmetic,
	cosmeticId: string
): Maid
	local cosmeticConfig: Cosmetic = Cosmetics[cosmeticId]
	local maid = Maid.new()
	if cosmeticConfig.Type ~= "Title" or not cosmetic.Character then
		return maid
	end
	cosmetic.Character:SetAttribute(Attribute.DummyTitle, cosmeticId)
	if InstanceUtil.isViewportFrameDescendent(cosmetic.DisplayModel) then
		self:equipInViewport(maid, cosmetic, cosmeticId)
		return maid
	end
	cosmetic.Character:AddTag("character")
	maid:GiveTask(function()
		local characterParent = cosmetic.Character
		if characterParent ~= nil then
			characterParent = characterParent.Parent
		end
		if not characterParent then
			return nil
		end
		cosmetic.Character:SetAttribute(Attribute.DummyTitle, nil)
		cosmetic.Character:RemoveTag("character")
	end)
	return maid
end

function CosmeticTitleDisplayController.equipInViewport(_, maid: Maid, cosmetic: Cosmetic, _)
	local root = createLegacyRoot(Instance.new("Folder"))
	local viewportFrame = InstanceUtil.getViewportFrameAncestor(cosmetic.DisplayModel)
	local parent = viewportFrame.Parent
	local viewportWidth = viewportFrame.Size.X.Offset
	local xPosition = parent.Size.X.Offset - viewportWidth + viewportWidth / 2
	root:render(createPortal(
		React.createElement(
			Provider,
			{
				["key"] = "",
				["store"] = nil,
				["store"] = GlobalStore,
			},
			React.createElement(NameTag, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["IsBillboardGuiDescendant"] = false,
				["Player"] = nil,
				["Character"] = nil,
				["Dummy"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0, xPosition, 0, 0),
				["Player"] = Players.LocalPlayer,
				["Character"] = cosmetic.Character,
			})
		),
		viewportFrame.Parent
	))
	maid:GiveTask(function()
		root:unmount()
	end)
end

Reflect.defineMetadata(CosmeticTitleDisplayController, "identifier", "m0D")
Reflect.defineMetadata(CosmeticTitleDisplayController, "flamework:implements", { "g4k" })
Reflect.decorate(CosmeticTitleDisplayController, "MJo", CosmeticDisplayDecorator, { "Title" })
Reflect.decorate(CosmeticTitleDisplayController, "$:flamework@Controller", Controller, {})

return {
	["CosmeticTitleDisplayController"] = CosmeticTitleDisplayController,
}
