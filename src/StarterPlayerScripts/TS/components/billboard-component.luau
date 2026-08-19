-- BillboardComponent

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
local t = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out",
	"prelude"
).t
local Component = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"components",
	"out"
).Component
local Billboard =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "billboard", "billboard").Billboard
local PersonalBillboard =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "billboard", "personal-billboard").PersonalBillboard
local EggWarsBillboard =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "billboard", "egg-wars-billboard").EggWarsBillboard
local SkyWarsBillboard =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "billboard", "sky-wars-billboard").SkyWarsBillboard
local TimerBillboard =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "billboard", "timer-billboard").TimerBillboard
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
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

type BillboardComponent = {
	instance: BasePart,
}

local BillboardComponent = setmetatable({}, {
	["__tostring"] = function()
		return "BillboardComponent"
	end,
	["__index"] = DisposableComponent,
})
BillboardComponent.__index = BillboardComponent

function BillboardComponent.new(...)
	local selfClass = BillboardComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function BillboardComponent.constructor(self: BillboardComponent, ...)
	DisposableComponent.constructor(self, ...)
end

function BillboardComponent.onStart(self: BillboardComponent)
	local root = createLegacyRoot(Instance.new("Folder"))
	local partName = self.instance.Name
	if partName == Billboard.Personal then
		root:render(createPortal(React.createElement(PersonalBillboard), self.instance))
		return
	elseif partName == Billboard.EggWars then
		root:render(createPortal(React.createElement(EggWarsBillboard), self.instance))
		return
	elseif partName == Billboard.SkyWars then
		root:render(createPortal(React.createElement(SkyWarsBillboard), self.instance))
	elseif partName == Billboard.Timer then
		root:render(createPortal(
			React.createElement(TimerBillboard, {
				["ZoneId"] = "Middle",
			}),
			self.instance
		))
	end
end

Reflect.defineMetadata(BillboardComponent, "identifier", "zky")
Reflect.defineMetadata(BillboardComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(BillboardComponent, "$c:components@Component", Component, {
	{
		["tag"] = "billboard",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("BasePart"),
	},
})

return {
	["BillboardComponent"] = BillboardComponent,
}
