-- BlockController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService: RunService = Services.RunService
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local RobloxSound = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local RobloxAnimation = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation
local BlockRaycastController = RuntimeLib.import(script, script.Parent, "block-raycast-controller")
local AssistMode = BlockRaycastController.AssistMode
local RaycastMode = BlockRaycastController.RaycastMode
local RaycastType = BlockRaycastController.RaycastType
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local BlockUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "block-util").BlockUtil
local InputUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "input-util").InputUtil
local BlockConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore

type BlockController = {
	hotbarController: any,
	blockRaycastController: any,
	animationController: any,
	PlacedBlock: any,
	predictedBlocks: { [Vector3]: BasePart },
	breakStatusBlocks: { [Vector3]: BasePart },
}

local BlockController = setmetatable({}, {
	["__tostring"] = function()
		return "BlockController"
	end
})
BlockController.__index = BlockController

function BlockController.new(...)
	local self = setmetatable({}, BlockController)
	return self:constructor(...) or self
end

function BlockController.constructor(self: BlockController, hotbarController: any, blockRaycastController: any, animationController: any)
	self.hotbarController = hotbarController
	self.blockRaycastController = blockRaycastController
	self.animationController = animationController
	self.PlacedBlock = AsyncEvent.new()
	self.predictedBlocks = {}
	self.breakStatusBlocks = {}
end

function BlockController.onStart(self: BlockController)
	Events.BlockRemoved:connect(function(position: Vector3)
		local predictedBlock = self.predictedBlocks[position]
		if not predictedBlock then
			return nil
		end
		self.predictedBlocks[position] = nil
		predictedBlock:Destroy()
	end)
	Events.BlockBreakStatusCleared:connect(function(position: Vector3)
		local block = self.breakStatusBlocks[position]
		if block then
			block:Destroy()
		end
		self.breakStatusBlocks[position] = nil
	end)
	Events.BlockBreakProgress:connect(function(position: Vector3, progress: number)
		local block = self.breakStatusBlocks[position]
		if block and progress == 0 then
			block:Destroy()
			self.breakStatusBlocks[position] = nil
			return nil
		end
		if not block then
			block = Instance.new("Part")
			block.Size = BlockConstants.BLOCK_DIMENSION
			block.Anchored = true
			block.Position = position
			block.CanCollide = false
			block.Transparency = 1
			block.Material = Enum.Material.Fabric
			block.Parent = Workspace
			self.breakStatusBlocks[position] = block
		end
		for _, normalId in Enum.NormalId:GetEnumItems() do
			local value = normalId.Value
			local texture = block:FindFirstChild(("Texture-%*"):format(value))
			if not texture then
				texture = Instance.new("Texture")
				texture.Name = ("Texture-%*"):format(value)
				texture.Face = normalId
				texture.Texture = RobloxImage.CRACK_REEL
				texture.StudsPerTileU = BlockConstants.BLOCK_SIZE * BlockConstants.BLOCK_BREAK_SEGMENTS
				texture.StudsPerTileV = BlockConstants.BLOCK_SIZE
				texture.Parent = block
			end
			local segment = progress * BlockConstants.BLOCK_BREAK_SEGMENTS
			texture.OffsetStudsU = math.floor(segment) * BlockConstants.BLOCK_SIZE
		end
	end)
	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isWorldInteract(inputObject) then
			return nil
		end
		if InputUtil.isMovementInteract(inputObject.Position) then
			return nil
		end
		local heldItemInfo = self.hotbarController:getHeldItemInfo()
		if not (heldItemInfo and heldItemInfo.Pickaxe) then
			return nil
		end
		local breakStartTime = nil
		local breakAnimation = nil
		while inputObject.UserInputState ~= Enum.UserInputState.Cancel and inputObject.UserInputState ~= Enum.UserInputState.End do
			local raycastResult = self.blockRaycastController:executeRaycast(UserInputService:GetMouseLocation(), RaycastMode.SELECT, AssistMode.Standard, heldItemInfo)
			if raycastResult and raycastResult.RaycastType ~= RaycastType.Paused then
				if breakAnimation == nil and breakStartTime == nil then
					breakAnimation = self:startBreakingAnimation()
					breakStartTime = os.clock()
				end
				self:hitBlock(raycastResult.BlockPosition)
				RunService.Heartbeat:Wait()
			else
				if breakStartTime ~= nil and breakAnimation ~= nil then
					self:stopBreakingAnimation(breakAnimation, breakStartTime)
					breakStartTime = nil
					breakAnimation = nil
				end
				RunService.Heartbeat:Wait()
			end
		end
		if breakStartTime ~= nil and breakAnimation ~= nil then
			self:stopBreakingAnimation(breakAnimation, breakStartTime)
		end
	end)
	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		if gameProcessed then
			return nil
		end
		if not InputUtil.isPcInteract(inputObject) then
			return nil
		end
		local heldItemInfo = self.hotbarController:getHeldItemInfo()
		if not heldItemInfo then
			return nil
		end
		local itemName = heldItemInfo.Name
		if heldItemInfo.Rewrite then
			local teamId = Flamework.resolveDependency("x5"):getPlayerTeamId()
			local teamName = teamId == nil and "White" or teamId
			heldItemInfo = Items[string.gsub(heldItemInfo.Rewrite.Type, "{TeamId}", teamName)]
		end
		if not heldItemInfo.Block then
			return nil
		end
		local raycastResult = self.blockRaycastController:executeRaycast(UserInputService:GetMouseLocation(), RaycastMode.PREVIEW, AssistMode.Standard, heldItemInfo)
		if not raycastResult or raycastResult.RaycastType == RaycastType.Paused then
			return nil
		end
		self:placeBlock(raycastResult.BlockPosition, itemName, heldItemInfo, raycastResult.Rotation)
	end)
	UserInputService.TouchTapInWorld:Connect(function(position: Vector3, gameProcessed)
		if gameProcessed then
			return nil
		end
		local heldItemInfo = self.hotbarController:getHeldItemInfo()
		if not heldItemInfo then
			return nil
		end
		local itemName = heldItemInfo.Name
		if heldItemInfo.Rewrite then
			local teamId = Flamework.resolveDependency("x5"):getPlayerTeamId()
			local teamName = teamId == nil and "White" or teamId
			heldItemInfo = Items[string.gsub(heldItemInfo.Rewrite.Type, "{TeamId}", teamName)]
		end
		if not heldItemInfo.Block then
			return nil
		end
		local raycastResult = self.blockRaycastController:executeRaycast(position, RaycastMode.PREVIEW, AssistMode.Standard, heldItemInfo)
		if not raycastResult or raycastResult.RaycastType == RaycastType.Paused then
			return nil
		end
		self:placeBlock(raycastResult.BlockPosition, itemName, heldItemInfo, raycastResult.Rotation)
	end)
end

function BlockController.startBreakingAnimation(self: BlockController): AnimationTrack
	return self.animationController:playHumanoidAnimation(RobloxAnimation.PICKAXE_BREAK_LOOPED)
end

function BlockController.stopBreakingAnimation(_, animation: AnimationTrack, startTime: number)
	if os.clock() - startTime > 0.1 then
		animation:Stop()
		return nil
	end
	animation.DidLoop:Wait()
	animation:Stop(0.1)
	task.wait(0.1)
	animation:Destroy()
end

function BlockController.placeBlock(self: BlockController, position: Vector3, itemId: string, item: any, rotation: number?)
	rotation = rotation == nil and 0 or rotation
	if not (BlockUtil.canPlace(position) and (BlockUtil.hasAdjacentBlock(position) and BlockUtil.validateConstraints(position, GlobalStore:getState().BuildConstraints))) then
		return nil
	end
	self.PlacedBlock:fire()
	local blockInstance = item.Block.Ref:Clone()
	blockInstance.Position = position
	blockInstance.Parent = Workspace.BlockContainer
	self.predictedBlocks[position] = blockInstance
	self.animationController:playHumanoidAnimation(RobloxAnimation.BLOCK_PLACE)
	Flamework.resolveDependency("jL9"):playSoundAtPosition(RobloxSound.Block.PLACE, position, {
		["Volume"] = 0.8
	})
	local predictionId = Flamework.resolveDependency("qOA"):registerItemPrediction(itemId, -1)
	if predictionId == "" or not predictionId then
		return nil
	end
	Events.PlaceBlock(position, rotation, predictionId)
end

function BlockController.hitBlock(_, position: Vector3)
	Events.HitBlock:fire(position)
end

Reflect.defineMetadata(BlockController, "identifier", "NaX")
Reflect.defineMetadata(BlockController, "flamework:parameters", { "Dqk", "WXw", "Kp" })
Reflect.defineMetadata(BlockController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(BlockController, "$:flamework@Controller", Controller, {})
return {
	["BlockController"] = BlockController
}
