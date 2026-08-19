-- AdvertBillboardController

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
local AdvertBillboard =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "ui", "advert", "advert-billboard").AdvertBillboard
local ProximityUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "proximity", "proximity-util").ProximityUtil
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

type ProximityPromptInfo = {
	ObjectText: string?,
	ActionText: string?,
	Triggered: (() -> ())?,
	MaxActivationDistance: number?,
}

type AdvertBillboardController = {
	new: (...any) -> AdvertBillboardController,
	mountBillboardGui: (self: AdvertBillboardController, props: any, parent: Instance) -> (),
	createProximityPrompt: (
		self: AdvertBillboardController,
		promptInfo: ProximityPromptInfo,
		parent: Instance
	) -> ProximityPrompt?,
	createBillboardGuiPart: (self: AdvertBillboardController, cframe: CFrame, parent: Instance) -> Part,
}

local AdvertBillboardController = setmetatable({}, {
	__tostring = function()
		return "AdvertBillboardController"
	end,
})
AdvertBillboardController.__index = AdvertBillboardController

function AdvertBillboardController.new(...)
	local self = setmetatable({}, AdvertBillboardController)
	return self:constructor(...) or self
end

function AdvertBillboardController.constructor(_) end

function AdvertBillboardController.mountBillboardGui(self, props, parent)
	if not props then
		return nil
	end

	local root = createLegacyRoot(Instance.new("Folder"))
	local clonedProps = table.clone(props)
	setmetatable(clonedProps, nil)
	root:render(createPortal(React.createElement(AdvertBillboard, clonedProps), parent))
end

function AdvertBillboardController.createProximityPrompt(self, promptInfo, parent)
	if not promptInfo then
		return nil
	end

	local prompt =
		ProximityUtil.createTriggeredPrompt(promptInfo.ObjectText, promptInfo.ActionText, promptInfo.Triggered)
	local maxActivationDistance = promptInfo.MaxActivationDistance
	prompt.MaxActivationDistance = maxActivationDistance == nil and 15 or maxActivationDistance
	prompt.Parent = parent
	return prompt
end

function AdvertBillboardController.createBillboardGuiPart(self, cframe, parent)
	local part = Instance.new("Part")
	part.CFrame = cframe
	part.Size = Vector3.new(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = parent
	return part
end

Reflect.defineMetadata(AdvertBillboardController, "identifier", "B4z")
Reflect.decorate(AdvertBillboardController, "$:flamework@Controller", Controller, {})

return {
	["AdvertBillboardController"] = AdvertBillboardController,
}
