-- ProximityPromptComponent

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
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent
local ProximityPromptScreen = RuntimeLib.import(
	script,
	script.Parent.Parent,
	"ui",
	"proximity-prompt",
	"proximity-prompt-screen"
).ProximityPromptScreen
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players

type ProximityPromptComponent = {
	new: (...any) -> ProximityPromptComponent,
	constructor: (self: ProximityPromptComponent, ...any) -> (),
	onStart: (self: ProximityPromptComponent) -> (),
	destroy: (self: ProximityPromptComponent) -> (),
	closeScreen: (self: ProximityPromptComponent) -> (),
}

local ProximityPromptComponent = setmetatable({}, {
	["__tostring"] = function()
		return "ProximityPromptComponent"
	end,
	["__index"] = DisposableComponent,
})
ProximityPromptComponent.__index = ProximityPromptComponent

function ProximityPromptComponent.new(...)
	local self = ProximityPromptComponent
	local obj = setmetatable({}, self)
	return obj:constructor(...) or obj
end

function ProximityPromptComponent.constructor(self, ...)
	DisposableComponent.constructor(self, ...)
end

function ProximityPromptComponent.onStart(self)
	self.instance.Style = Enum.ProximityPromptStyle.Custom
	self.maid:GiveTask(self.instance.PromptShown:Connect(function(inputType)
		local parent = self.instance.Parent
		if parent ~= nil then
			parent = parent:IsA("PVInstance")
		end
		local isInvalid = not parent
		if isInvalid then
			local attachmentParent = self.instance.Parent
			if attachmentParent ~= nil then
				attachmentParent = attachmentParent:IsA("Attachment")
			end
			isInvalid = not attachmentParent
		end
		if isInvalid then
			return nil
		end
		local screen = Flamework.resolveDependency("lB5"):open(ProximityPromptScreen, {
			["ProximityPrompt"] = self.instance,
			["InputType"] = inputType,
		})
		local existingGui = Players.LocalPlayer.PlayerGui:FindFirstChild(screen.Handler.ScreenName)
		if existingGui and existingGui:IsA("BillboardGui") then
			existingGui.Adornee = self.instance.Parent
		end
		self.proximityPromptScreen = screen
	end))
	self.maid:GiveTask(self.instance.PromptHidden:Connect(function()
		self:closeScreen()
	end))
end

function ProximityPromptComponent.destroy(self)
	DisposableComponent.destroy(self)
	self:closeScreen()
end

function ProximityPromptComponent.closeScreen(self)
	if self.proximityPromptScreen then
		self.proximityPromptScreen:close()
		self.proximityPromptScreen = nil
	end
end

Reflect.defineMetadata(ProximityPromptComponent, "identifier", "zko")
Reflect.defineMetadata(ProximityPromptComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ProximityPromptComponent, "$c:components@Component", Component, {
	{
		["tag"] = "proximity_prompt",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("ProximityPrompt"),
	},
})

return {
	["ProximityPromptComponent"] = ProximityPromptComponent,
}
