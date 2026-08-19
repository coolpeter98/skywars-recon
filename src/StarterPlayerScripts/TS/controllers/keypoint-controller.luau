-- KeypointController

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
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local Workspace: Workspace = Services.Workspace
local ConstrainedMarkers = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"constrained-markers",
	"src"
)
local GetCharacter = RuntimeLib.import(script, script.Parent.Parent, "util", "util").GetCharacter
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
local Keypoint = RuntimeLib.import(script, script.Parent.Parent, "ui", "keypoint", "keypoint").Keypoint
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type KeypointMarkerSetup = {
	HideDistance: number,
	WrapperFrame: Frame,
	ReactRobloxRoot: any,
}

type KeypointController = {
	screenGui: ScreenGui,
	constrainedMarkers: any,
	markerSetup: { [any]: KeypointMarkerSetup },
	new: (...any) -> KeypointController,
	constructor: (self: KeypointController) -> (),
	onStart: (self: KeypointController) -> (),
	addKeypoint: (
		self: KeypointController,
		target: Vector3 | CFrame | Instance,
		markerSetup: KeypointMarkerSetup
	) -> any,
	removeKeypoint: (self: KeypointController, marker: any) -> (),
	clearKeypoints: (self: KeypointController) -> (),
	getPositionFromTarget: (self: KeypointController, target: Vector3 | CFrame | Instance) -> Vector3?,
	getDistanceToTarget: (self: KeypointController, target: Vector3) -> number?,
}

local KeypointController = setmetatable({}, {
	["__tostring"] = function()
		return "KeypointController"
	end,
})
KeypointController.__index = KeypointController

function KeypointController.new(...)
	local self = setmetatable({}, KeypointController)
	return self:constructor(...) or self
end

function KeypointController.constructor(self)
	self.markerSetup = {}
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "Keypoints"
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.DisplayOrder = -10
	self.screenGui.ResetOnSpawn = false
	local boundaryFrame = Instance.new("Frame")
	boundaryFrame.Name = "KeypointBoundary"
	boundaryFrame.BackgroundTransparency = 1
	boundaryFrame.BorderSizePixel = 0
	boundaryFrame.Visible = true
	boundaryFrame.Position = UDim2.fromScale(0.05, 0.05)
	boundaryFrame.Size = UDim2.fromScale(0.9, 0.9)
	boundaryFrame.Parent = self.screenGui
	self.constrainedMarkers = ConstrainedMarkers.New(boundaryFrame, false)
end

function KeypointController.onStart(self)
	self.screenGui.Parent = Players.LocalPlayer.PlayerGui
	local constrainedMarkers = self.constrainedMarkers
	RunService:BindToRenderStep("Random", Enum.RenderPriority.Camera.Value + 2, function()
		for _, marker in self.constrainedMarkers:Markers() do
			local setup = self.markerSetup[marker]
			local targetPosition = self:getPositionFromTarget(marker.Target)
			if targetPosition then
				local distance = self:getDistanceToTarget(targetPosition)
				local hideDistance = setup.HideDistance
				if
					hideDistance == 0
					or (
						hideDistance ~= hideDistance
						or (not hideDistance or (distance == nil or distance >= setup.HideDistance))
					)
				then
					setup.ReactRobloxRoot:render(createPortal(
						React.createElement(Keypoint, {
							["key"] = "Extract",
							["Distance"] = nil,
							["MarkerSetup"] = nil,
							["Distance"] = distance,
							["MarkerSetup"] = setup,
						}),
						setup.WrapperFrame
					))
					if targetPosition then
						constrainedMarkers:renderMarker(marker, Workspace.CurrentCamera, targetPosition)
					else
						constrainedMarkers:hideMarker(marker)
					end
				else
					constrainedMarkers:hideMarker(marker)
				end
			end
		end
	end)
	Flamework.resolveDependency("lB5").ScreenOpenedEvent:bind(function()
		if Flamework.resolveDependency("lB5"):isFocused() then
			self.screenGui.Enabled = false
		end
	end)
	Flamework.resolveDependency("lB5").ScreenClosedEvent:bind(function()
		if not Flamework.resolveDependency("lB5"):isFocused() then
			self.screenGui.Enabled = true
		end
	end)
end

function KeypointController.addKeypoint(self, target, markerSetup)
	local distance = self:getDistanceToTarget((self:getPositionFromTarget(target)))
	local wrapperFrame = Instance.new("Frame")
	markerSetup.WrapperFrame = wrapperFrame
	markerSetup.ReactRobloxRoot = createLegacyRoot(Instance.new("Frame"))
	markerSetup.ReactRobloxRoot:render(createPortal(
		React.createElement(Keypoint, {
			["key"] = "Extract",
			["Distance"] = nil,
			["MarkerSetup"] = nil,
			["Distance"] = distance,
			["MarkerSetup"] = markerSetup,
		}),
		wrapperFrame
	))
	local markerData = {
		["Target"] = nil,
		["BodyGUI"] = nil,
		["ArrowEnabled"] = false,
		["Target"] = target,
		["BodyGUI"] = wrapperFrame:FindFirstChild("Extract"),
	}
	local marker = self.constrainedMarkers:CreateMarker(markerData)
	self.markerSetup[marker] = markerSetup
	return marker
end

function KeypointController.removeKeypoint(self, marker)
	self.constrainedMarkers:RemoveMarkers(marker)
	self.markerSetup[marker] = nil
end

function KeypointController.clearKeypoints(self)
	self.constrainedMarkers:RemoveAllMarkers()
	table.clear(self.markerSetup)
end

function KeypointController.getPositionFromTarget(_, target)
	local position = nil
	if typeof(target) == "Vector3" then
		return target
	end
	if typeof(target) == "CFrame" then
		return target.Position
	end
	if typeof(target) == "Instance" then
		if target:IsA("BasePart") then
			return target.Position
		end
		if target:IsA("Attachment") then
			return target.WorldPosition
		end
		if target:IsA("Model") and target.PrimaryPart then
			position = target:GetPivot().Position
		end
	end
	return position
end

function KeypointController.getDistanceToTarget(_, target)
	local character = GetCharacter()
	if character ~= nil then
		character = character.PrimaryPart
	end
	if character then
		return (character.Position - target).Magnitude
	else
		return nil
	end
end

Reflect.defineMetadata(KeypointController, "identifier", "04V")
Reflect.defineMetadata(KeypointController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(KeypointController, "$:flamework@Controller", Controller, {})
return {
	["KeypointController"] = KeypointController,
}
