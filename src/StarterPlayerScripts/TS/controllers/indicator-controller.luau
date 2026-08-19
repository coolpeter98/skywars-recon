-- IndicatorController

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
local GlobalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store")
local GlobalStore = GlobalStoreModule.GlobalStore
local GlobalStoreChanged = GlobalStoreModule.GlobalStoreChanged
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local Workspace: Workspace = Services.Workspace

type IndicatorController = {
	indicator: Model?,
}

local IndicatorController = setmetatable({}, {
	["__tostring"] = function()
		return "IndicatorController"
	end,
})
IndicatorController.__index = IndicatorController

function IndicatorController.new(...)
	local class = IndicatorController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function IndicatorController.constructor(_) end

function IndicatorController.onStart(self: IndicatorController)
	self:setupIndicator(GlobalStore:getState().IndicatorPosition)
	GlobalStoreChanged("IndicatorPosition", function(position)
		self:setupIndicator(position)
	end)
end

function IndicatorController.onTick(self: IndicatorController, deltaTime: number)
	if not self.indicator then
		return nil
	end
	self.indicator:SetPrimaryPartCFrame(self.indicator:GetPrimaryPartCFrame() * CFrame.Angles(0, 2.5 * deltaTime, 0))
end

function IndicatorController.setupIndicator(self: IndicatorController, position: CFrame?)
	if not position then
		local indicator = self.indicator
		if indicator ~= nil then
			indicator:Destroy()
		end
		self.indicator = nil
		return nil
	end
	self.indicator = ReplicatedStorage.Misc.Indicator:Clone()
	self.indicator:SetPrimaryPartCFrame(CFrame.new(position))
	self.indicator.Parent = Workspace
end

Reflect.defineMetadata(IndicatorController, "identifier", "Zj3")
Reflect.defineMetadata(IndicatorController, "flamework:implements", { "$:flamework@OnStart", "$:flamework@OnTick" })
Reflect.decorate(IndicatorController, "$:flamework@Controller", Controller, {})
return nil
