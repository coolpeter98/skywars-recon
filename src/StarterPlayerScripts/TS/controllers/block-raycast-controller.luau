local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local CollectionService: CollectionService = Services.CollectionService
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local Util = RuntimeLib.import(script, script.Parent.Parent, "util", "util")
local GetCamera = Util.GetCamera
local GetCharacter = Util.GetCharacter
local VectorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil
local BlockConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local CameraUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "camera-util").CameraUtil
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage

local RaycastMode = {}
local RaycastModeNames = setmetatable({}, {
	["__index"] = RaycastMode
})
RaycastModeNames.SELECT = 0
RaycastMode[0] = "SELECT"
RaycastModeNames.PREVIEW = 1
RaycastMode[1] = "PREVIEW"

local AssistMode = {}
local AssistModeNames = setmetatable({}, {
	["__index"] = AssistMode
})
AssistModeNames.Standard = 0
AssistMode[0] = "Standard"
AssistModeNames.AssistOnly = 1
AssistMode[1] = "AssistOnly"
AssistModeNames.StandardOnly = 2
AssistMode[2] = "StandardOnly"

local RaycastType = {}
local RaycastTypeNames = setmetatable({}, {
	["__index"] = RaycastType
})
RaycastTypeNames.Standard = 0
RaycastType[0] = "Standard"
RaycastTypeNames.VoidCast = 1
RaycastType[1] = "VoidCast"
RaycastTypeNames.PillarCast = 2
RaycastType[2] = "PillarCast"
RaycastTypeNames.Paused = 3
RaycastType[3] = "Paused"

type BlockRaycastController = {
	hotbarController: any,
	Ticked: any,
	continueVoidBridge: boolean,
	blockRaycastStored: any,
	new: (...any) -> BlockRaycastController,
	constructor: (self: BlockRaycastController, hotbarController: any) -> (),
	onStart: (self: BlockRaycastController) -> (),
	getBlockRaycastStored: (self: BlockRaycastController) -> any,
	handleBlockEvent: (self: BlockRaycastController, blockPosition: Vector3) -> (),
	onTick: (self: BlockRaycastController, deltaTime: number) -> (),
	executeRaycast: (self: BlockRaycastController, screenPosition: Vector2, raycastMode: number, assistMode: number, item: any) -> any,
	raycastBlockLocation: (self: BlockRaycastController, screenPosition: Vector2, raycastMode: number, assistMode: number) -> any,
	manageState: (self: BlockRaycastController, showOutline: boolean?) -> (),
	select: (self: BlockRaycastController, blockPosition: Vector3) -> Part,
	preview: (self: BlockRaycastController, blockPosition: Vector3, raycastType: number, item: any, rotation: number) -> Part,
	pillarCast: (self: BlockRaycastController) -> any,
	voidCast: (self: BlockRaycastController) -> any,
	getPlayerFooting: (self: BlockRaycastController, character: Model, ignoredParts: { Instance }?) -> Vector3?,
}

local BlockRaycastController = setmetatable({}, {
	["__tostring"] = function()
		return "BlockRaycastController"
	end
})
BlockRaycastController.__index = BlockRaycastController

function BlockRaycastController.new(...)
	local self = BlockRaycastController
	local instance = setmetatable({}, self)
	return instance:constructor(...) or instance
end

function BlockRaycastController.constructor(self: BlockRaycastController, hotbarController)
	self.hotbarController = hotbarController
	self.Ticked = AsyncEvent.new()
	self.continueVoidBridge = false
end

function BlockRaycastController.onStart(self: BlockRaycastController)
	Flamework.resolveDependency("NaX").PlacedBlock:bind(function()
		if self.blockRaycastStored and self.blockRaycastStored.RaycastType == RaycastType.VoidCast then
			self.continueVoidBridge = true
		end
		self:onTick(0)
	end)
	Events.BlockRemoved:connect(function(blockPosition: Vector3)
		self:handleBlockEvent(blockPosition)
	end)
	Events.BlockBreakStatusCleared:connect(function(blockPosition: Vector3)
		self:handleBlockEvent(blockPosition)
	end)
end

function BlockRaycastController.getBlockRaycastStored(self: BlockRaycastController)
	if self.blockRaycastStored then
		return not self.blockRaycastStored.Container and {
			["RaycastType"] = RaycastType.Paused
		} or self.blockRaycastStored
	else
		return nil
	end
end

function BlockRaycastController.handleBlockEvent(self: BlockRaycastController, blockPosition: Vector3)
	if not self.blockRaycastStored then
		self:onTick(0)
		return nil
	end
	if (self.blockRaycastStored.BlockPosition - blockPosition).Magnitude < 16 then
		self:onTick(0)
	end
end

function BlockRaycastController.onTick(self: BlockRaycastController, _)
	local heldItem = self.hotbarController:getHeldItemInfo()
	if not heldItem then
		self:manageState()
		self.Ticked:fire()
		return nil
	end
	if heldItem.Rewrite then
		local teamId = Flamework.resolveDependency("x5"):getPlayerTeamId()
		local teamName = teamId == nil and "White" or teamId
		heldItem = Items[string.gsub(heldItem.Rewrite.Type, "{TeamId}", teamName)]
	end
	if not (heldItem and (heldItem.Pickaxe or heldItem.Block)) then
		self:manageState()
		self.Ticked:fire()
		return nil
	end
	local noAssist = heldItem.Block
	if noAssist then
		noAssist = heldItem.Block.NoAssist
	end
	if noAssist and UserInputService.TouchEnabled then
		self:manageState()
		self.Ticked:fire()
		return nil
	end
	local screenPosition: Vector2
	if UserInputService.TouchEnabled then
		screenPosition = Workspace.CurrentCamera.ViewportSize / 2
	else
		screenPosition = UserInputService:GetMouseLocation()
	end
	local raycastMode
	if heldItem.Block then
		raycastMode = RaycastMode.PREVIEW
	else
		raycastMode = RaycastMode.SELECT
	end
	local assistMode
	if UserInputService.TouchEnabled then
		assistMode = AssistMode.AssistOnly
	elseif noAssist then
		assistMode = AssistMode.StandardOnly
	else
		assistMode = AssistMode.Standard
	end
	self:executeRaycast(screenPosition, raycastMode, assistMode, heldItem)
	self.Ticked:fire()
end

function BlockRaycastController.executeRaycast(self: BlockRaycastController, screenPosition: Vector2, raycastMode: number, assistMode: number, item)
	if not Players.LocalPlayer.Character or Flamework.resolveDependency("lB5"):isFocused() then
		self:manageState()
		return nil
	end
	local raycastResult = self:raycastBlockLocation(screenPosition, raycastMode, assistMode)
	if not raycastResult then
		self:manageState()
		return nil
	end
	if raycastResult.RaycastType == RaycastType.Paused then
		if self.blockRaycastStored then
			local container = self.blockRaycastStored.Container
			if container ~= nil then
				container:Destroy()
			end
			self.blockRaycastStored.Container = nil
		end
		return {
			["RaycastType"] = RaycastType.Paused
		}
	end
	local same = self.blockRaycastStored
	if same then
		if self.blockRaycastStored.RaycastType == raycastResult.RaycastType and self.blockRaycastStored.BlockPosition == raycastResult.BlockPosition then
			same = self.blockRaycastStored.RaycastMode == raycastMode
		else
			same = false
		end
	end
	if same then
		local containerName = self.blockRaycastStored.Container
		if containerName ~= nil then
			containerName = containerName.Name
		end
		same = containerName == item.Name
	end
	if same then
		return self.blockRaycastStored
	end
	self:manageState(raycastResult.RaycastType ~= RaycastType.VoidCast)
	local _, yawRadians = Workspace.CurrentCamera.CFrame:ToOrientation()
	local yawDegrees = math.deg(yawRadians) / 90
	local rotation = math.round(yawDegrees) * 90
	local container
	if raycastMode == RaycastMode.SELECT then
		container = self:select(raycastResult.BlockPosition)
	else
		container = self:preview(raycastResult.BlockPosition, raycastResult.RaycastType, item, rotation)
	end
	self.blockRaycastStored = {
		["RaycastMode"] = raycastMode,
		["RaycastType"] = raycastResult.RaycastType,
		["BlockPosition"] = raycastResult.BlockPosition,
		["Container"] = container,
		["CameraDirection"] = CameraUtil.getDirection(),
		["Rotation"] = rotation
	}
	return self.blockRaycastStored
end

function BlockRaycastController.raycastBlockLocation(self: BlockRaycastController, screenPosition: Vector2, raycastMode: number, assistMode: number)
	local allowAssist = assistMode == AssistMode.Standard and true or assistMode == AssistMode.AssistOnly
	if (not UserInputService.TouchEnabled or UserInputService.TouchEnabled and raycastMode == RaycastMode.PREVIEW) and allowAssist then
		local pillarResult = self:pillarCast()
		if pillarResult.successful and pillarResult.blockPosition then
			local blockPosition = pillarResult.blockPosition
			if raycastMode == RaycastMode.SELECT then
				blockPosition = blockPosition - Vector3.new(0, 3, 0)
			end
			return {
				["BlockPosition"] = blockPosition,
				["RaycastType"] = RaycastType.PillarCast
			}
		end
	end
	local shouldVoidBridge
	if raycastMode == RaycastMode.PREVIEW then
		shouldVoidBridge = self.continueVoidBridge
	else
		shouldVoidBridge = false
	end
	if shouldVoidBridge then
		shouldVoidBridge = self.blockRaycastStored
		if shouldVoidBridge ~= nil then
			shouldVoidBridge = shouldVoidBridge.CameraDirection
		end
		if shouldVoidBridge then
			shouldVoidBridge = allowAssist
		end
	end
	if shouldVoidBridge then
		local directionDifference = (self.blockRaycastStored.CameraDirection - CameraUtil.getDirection()).Magnitude
		if directionDifference < 0.35 then
			local voidResult = self:voidCast()
			if voidResult.successful and voidResult.blockPosition then
				return {
					["BlockPosition"] = voidResult.blockPosition,
					["RaycastType"] = RaycastType.VoidCast
				}
			end
			if voidResult.successful then
				return {
					["RaycastType"] = RaycastType.Paused
				}
			end
		elseif not PlaceUtil.isProduction() then
			Flamework.resolveDependency("gkk"):displayActionBar(RobloxImage.Icon.EXCLAMATION, (("DIR MAG SKIP %*"):format(directionDifference)))
			print("SKIPPING PAUSE DUE TO DIR MAG")
		end
	end
	if raycastMode == RaycastMode.PREVIEW and assistMode == AssistMode.AssistOnly then
		local voidResult = self:voidCast()
		return voidResult.successful and voidResult.blockPosition and {
			["BlockPosition"] = voidResult.blockPosition,
			["RaycastType"] = RaycastType.VoidCast
		} or nil
	end
	local cameraRay = GetCamera():ViewportPointToRay(screenPosition.X, screenPosition.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = { Workspace.BlockContainer }
	local raycastResult = Workspace:Raycast(cameraRay.Origin, cameraRay.Direction * 35, raycastParams)
	local hitModel
	if raycastResult == nil then
		hitModel = raycastResult
	else
		hitModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
	end
	local isChest
	if hitModel == nil then
		isChest = false
	else
		isChest = CollectionService:HasTag(hitModel, "block:chest")
	end
	if not raycastResult or isChest then
		if raycastMode == RaycastMode.SELECT or not allowAssist then
			return nil
		end
		local voidResult = self:voidCast()
		return voidResult.successful and voidResult.blockPosition and {
			["BlockPosition"] = voidResult.blockPosition,
			["RaycastType"] = RaycastType.VoidCast
		} or nil
	end
	local blockPart = raycastResult.Instance
	if Items[blockPart.Name] == nil then
		return nil
	end
	local blockCFrame = blockPart.CFrame
	local hitCFrame = CFrame.new(raycastResult.Position)
	local blockPosition = blockCFrame.Position
	local halfSize = blockPart.Size / 2
	local snapOrigin = CFrame.new(blockPosition - halfSize)
	local normal = raycastResult.Normal
	local normalOffset = raycastMode == RaycastMode.SELECT and -0.01 or 0.01
	local snappedPosition = (snapOrigin + VectorUtil.floorVector(snapOrigin:ToObjectSpace(hitCFrame + normal * normalOffset).Position / 3) * 3 + BlockConstants.BLOCK_DIMENSION / 2).Position
	if VectorUtil.modVector(snappedPosition / 3, 1).Magnitude ~= 0 then
		return nil
	end
	if (snappedPosition - Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude < BlockConstants.MAXIMUM_PLACE_RANGE * 3 then
		return {
			["BlockPosition"] = snappedPosition,
			["RaycastType"] = RaycastType.Standard
		}
	end
	if raycastMode == RaycastMode.SELECT or not allowAssist then
		return nil
	end
	local voidResult = self:voidCast()
	return voidResult.successful and voidResult.blockPosition and {
		["BlockPosition"] = voidResult.blockPosition,
		["RaycastType"] = RaycastType.VoidCast
	} or nil
end

function BlockRaycastController.manageState(self: BlockRaycastController, showOutline)
	showOutline = showOutline == nil and true or showOutline
	local stored = self.blockRaycastStored
	if stored ~= nil then
		local container = stored.Container
		if container ~= nil then
			container:Destroy()
		end
	end
	self.blockRaycastStored = nil
	if showOutline then
		self.continueVoidBridge = false
		Flamework.resolveDependency("ymg"):setOutlineStatus(true)
	else
		Flamework.resolveDependency("ymg"):setOutlineStatus(false)
	end
end

function BlockRaycastController.select(_, blockPosition: Vector3): Part
	local part = Instance.new("Part")
	part.Name = "Select"
	part.Transparency = 1
	part.Position = blockPosition
	part.CanCollide = false
	part.Size = BlockConstants.BLOCK_DIMENSION
	part.Anchored = true
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = Color.White
	selectionBox.LineThickness = 0.05
	selectionBox.Adornee = part
	selectionBox.Parent = part
	part.Parent = Workspace
	return part
end

function BlockRaycastController.preview(_, blockPosition: Vector3, raycastType: number, item, rotation: number): Part
	local nonStandard = raycastType ~= RaycastType.Standard
	local previewPart = item.Block.Ref:Clone()
	previewPart.Name = "Preview"
	previewPart.Position = blockPosition
	previewPart.CanCollide = false
	previewPart.Size = BlockConstants.BLOCK_DIMENSION
	previewPart.Transparency = nonStandard and 0 or 1
	local material
	if nonStandard then
		material = Enum.Material.Plastic
	else
		material = previewPart.Material
	end
	previewPart.Material = material
	previewPart.Anchored = true
	if item.Block.Rotation then
		previewPart.Orientation = Vector3.new(0, rotation, 0)
	end
	for _, child in previewPart:GetChildren() do
		if child:IsA("Texture") then
			child.Transparency = 0.3
		end
	end
	if nonStandard then
		local highlight = Instance.new("Highlight")
		local hue, saturation, value = item.Block.PrimaryColor:ToHSV()
		local scaledSaturation = saturation * 1.5
		local scaledValue = value * 1.5
		highlight.FillColor = Color3.fromHSV(hue, scaledSaturation, scaledValue)
		highlight.FillTransparency = 0.6
		highlight.Parent = previewPart
	else
		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Color3 = Color.White
		selectionBox.LineThickness = 0.05
		selectionBox.Adornee = previewPart
		selectionBox.Parent = previewPart
	end
	previewPart.Parent = Workspace
	return previewPart
end

function BlockRaycastController.pillarCast(self: BlockRaycastController)
	local character = GetCharacter()
	if not (character and character.PrimaryPart) then
		return {
			["successful"] = false
		}
	end
	local footing = self:getPlayerFooting(character)
	if not footing then
		return {
			["successful"] = false
		}
	end
	local pitchRadians = Workspace.CurrentCamera.CFrame:ToOrientation()
	if math.deg(pitchRadians) > (Flamework.resolveDependency("VJk"):isFirstPerson() and -75 or -65) then
		return {
			["successful"] = false
		}
	end
	local blockPosition = (footing + Vector3.new(0, 1, 0)) * BlockConstants.BLOCK_SIZE
	local count = 0
	local parts = {}
	for index, part in Workspace:GetPartBoundsInBox(CFrame.new(blockPosition), Vector3.new(1.5, 1.5, 1.5)) do
		local _ = index - 1
		if part:IsDescendantOf(Workspace.BlockContainer) == true then
			count = count + 1
			parts[count] = part
		end
	end
	return #parts == 0 and {
		["blockPosition"] = nil,
		["successful"] = true,
		["blockPosition"] = blockPosition
	} or {
		["successful"] = false
	}
end

function BlockRaycastController.voidCast(self: BlockRaycastController)
	local character = GetCharacter()
	if not (character and character.PrimaryPart) then
		return {
			["successful"] = false
		}
	end
	local primaryPart = character.PrimaryPart
	local footing = self:getPlayerFooting(character)
	if not footing then
		return {
			["successful"] = false
		}
	end
	local lookVector = primaryPart.CFrame.LookVector * Vector3.new(1, 0, 1)
	for i = 0, 2 do
		local basePosition = footing * BlockConstants.BLOCK_SIZE
		local halfDimension = BlockConstants.BLOCK_DIMENSION / 2
		local offset = lookVector * ((i + 1) * 3)
		local blockPosition = VectorUtil.floorVector((basePosition + halfDimension + offset) / 3) * BlockConstants.BLOCK_SIZE
		local count = 0
		local parts = {}
		for index, part in Workspace:GetPartBoundsInBox(CFrame.new(blockPosition), Vector3.new(1.5, 1.5, 1.5)) do
			local _ = index - 1
			if part:IsDescendantOf(Workspace.BlockContainer) == true then
				count = count + 1
				parts[count] = part
			end
		end
		if #parts == 0 then
			return {
				["blockPosition"] = nil,
				["successful"] = true,
				["blockPosition"] = blockPosition
			}
		end
	end
	for i = 0, 2 do
		local basePosition = footing * BlockConstants.BLOCK_SIZE
		local halfDimension = BlockConstants.BLOCK_DIMENSION / 2
		local offset = lookVector * ((i + 4) * 3)
		local blockPosition = VectorUtil.floorVector((basePosition + halfDimension + offset) / 3) * BlockConstants.BLOCK_SIZE
		local count = 0
		local parts = {}
		for index, part in Workspace:GetPartBoundsInBox(CFrame.new(blockPosition), Vector3.new(1.5, 1.5, 1.5)) do
			local _ = index - 1
			if part:IsDescendantOf(Workspace.BlockContainer) == true then
				count = count + 1
				parts[count] = part
			end
		end
		if #parts == 0 then
			return {
				["blockPosition"] = nil,
				["successful"] = true
			}
		end
	end
	return {
		["successful"] = false
	}
end

function BlockRaycastController.getPlayerFooting(_, character: Model, ignoredParts)
	ignoredParts = ignoredParts == nil and {} or ignoredParts
	local primaryPart = character.PrimaryPart
	local footY = primaryPart.Position.Y - primaryPart.Size.Y / 2
	local hipHeight = character:FindFirstChildOfClass("Humanoid")
	if hipHeight ~= nil then
		hipHeight = hipHeight.HipHeight
	end
	local footingY = footY - (hipHeight == nil and 0 or hipHeight) + 0.5
	local position = primaryPart.Position
	local count = 0
	local parts = {}
	for index, part in Workspace:GetPartBoundsInBox(CFrame.new(position - Vector3.new(0, 6, 0)), Vector3.new(3, 12, 3)) do
		local _ = index - 1
		local isCandidate
		if part.Position.Y + part.Size.Y / 2 < footingY and part.Size.Y >= 3 then
			isCandidate = part:IsDescendantOf(Workspace.BlockContainer)
		else
			isCandidate = false
		end
		if isCandidate then
			local isIgnored = table.find(ignoredParts, part) ~= nil
			isCandidate = not isIgnored
		end
		if isCandidate == true then
			count = count + 1
			parts[count] = part
		end
	end
	table.sort(parts, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	local lastIndex = #parts
	local topPart = parts[lastIndex]
	parts[lastIndex] = nil
	if not topPart then
		return nil
	end
	local x = primaryPart.Position.X
	local topY = topPart.Position.Y + topPart.Size.Y / 2
	local z = primaryPart.Position.Z
	local footPosition = Vector3.new(x, topY, z) + BlockConstants.BLOCK_DIMENSION / 2 * Vector3.new(1, 0, 1)
	local blockSize = BlockConstants.BLOCK_SIZE
	local blockPosition = VectorUtil.floorVector(footPosition / blockSize)
	local blockCount = 0
	local blockParts = {}
	for index, part in Workspace:GetPartBoundsInBox(CFrame.new(blockPosition * 3), BlockConstants.BLOCK_DIMENSION * 0.8) do
		local _ = index - 1
		if part:IsDescendantOf(Workspace.BlockContainer) == true then
			blockCount = blockCount + 1
			blockParts[blockCount] = part
		end
	end
	return blockPosition
end

Reflect.defineMetadata(BlockRaycastController, "identifier", "WXw")
Reflect.defineMetadata(BlockRaycastController, "flamework:parameters", { "Dqk" })
Reflect.defineMetadata(BlockRaycastController, "flamework:implements", { "$:flamework@OnStart", "$:flamework@OnTick" })
Reflect.decorate(BlockRaycastController, "$:flamework@Controller", Controller, {})
return {
	["RaycastMode"] = RaycastMode,
	["AssistMode"] = AssistMode,
	["RaycastType"] = RaycastType,
	["BlockRaycastController"] = BlockRaycastController
}
