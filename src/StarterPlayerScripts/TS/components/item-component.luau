-- ItemComponent

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local RunService: RunService = Services.RunService
local Workspace: Workspace = Services.Workspace
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent

type ItemComponent = {
	new: (...any) -> ItemComponent,
	constructor: (self: ItemComponent, ...any) -> (),
	onStart: (self: ItemComponent) -> (),
}

local ItemComponent = setmetatable({}, {
	["__tostring"] = function()
		return "ItemComponent"
	end,
	["__index"] = DisposableComponent,
})
ItemComponent.__index = ItemComponent

function ItemComponent.new(...)
	local selfClass = ItemComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function ItemComponent.constructor(self, ...)
	DisposableComponent.constructor(self, ...)
end

function ItemComponent.onStart(self)
	if not self.instance.PrimaryPart then
		self.instance:GetPropertyChangedSignal("PrimaryPart"):Wait()
		self.instance.PrimaryPart:WaitForChild("Handle")
	end

	local renderModel = Instance.new("Model")
	renderModel.Name = self.instance.Name .. "Render"
	local primaryPart = self.instance.PrimaryPart
	if not primaryPart then
		return nil
	end

	local handle = primaryPart:FindFirstChild("Handle"):Clone()
	for _, child in primaryPart:GetChildren() do
		if not child:IsA("TouchTransmitter") and (child:IsA("BasePart") or child:IsA("MeshPart")) then
			child.Transparency = 1
		end
	end

	for _, descendant in renderModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end

	handle.CanCollide = false
	handle.Anchored = true
	handle.Parent = renderModel
	renderModel.PrimaryPart = handle
	renderModel:SetPrimaryPartCFrame(CFrame.new(renderModel:GetPrimaryPartCFrame().Position))
	renderModel.Parent = self.instance.Parent

	local halfExtentsY = renderModel:GetExtentsSize().Y / 2
	local phaseOffset = math.random() * 10

	self.maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
		local primaryPart = self.instance.PrimaryPart
		if not primaryPart then
			return nil
		end

		if
			(Workspace.CurrentCamera.CFrame.Position - primaryPart.Position).Magnitude
			> BlockConstants.BLOCK_SIZE * 48
		then
			return nil
		end

		local renderCFrame = renderModel:GetPrimaryPartCFrame()
		local rotationCFrame = renderCFrame - renderCFrame.Position
		local angles = CFrame.Angles
		local rotationDegrees = 0.5 * (deltaTime / 0.016666666666666666)
		local rotatedCFrame = rotationCFrame * angles(0, math.rad(rotationDegrees), 0)
		local instanceCFrame = self.instance:GetPrimaryPartCFrame()
		local currentTime = os.clock() + phaseOffset
		local bobHeight = math.sin(currentTime) * 0.6 + halfExtentsY
		local bobOffset = Vector3.new(0, bobHeight, 0)
		renderModel:SetPrimaryPartCFrame(CFrame.new((instanceCFrame + bobOffset).Position) * rotatedCFrame)
	end))

	self.maid:GiveTask(renderModel)
end

Reflect.defineMetadata(ItemComponent, "identifier", "Od1")
Reflect.defineMetadata(ItemComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ItemComponent, "$c:components@Component", Component, {
	{
		["tag"] = "item",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})

return {
	["ItemComponent"] = ItemComponent,
}
