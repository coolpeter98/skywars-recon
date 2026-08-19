-- CosmeticViewport

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local RunService: RunService = Services.RunService
local SkinsUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local ToolUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "tool-util").ToolUtil
local ItemsModule = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item")
local Items = ItemsModule.Items
local ItemsByGroup = ItemsModule.ItemsByGroup
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local CosmeticId =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetic-id").CosmeticId
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local setupViewport = nil

type CosmeticViewportProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	ImageTransparency: number?,
	ZIndex: number?,
	LayoutOrder: number?,
	CosmeticId: string,
	Seed: number?,
}

local function CosmeticViewport(props: CosmeticViewportProps)
	local viewportRef = useRef()
	local maidRef = useRef(Maid.new())
	useEffect(function()
		local viewport = viewportRef.current
		if not viewport then
			return nil
		end
		viewport:ClearAllChildren()
		local cosmeticId = props.CosmeticId
		local maid = maidRef.current
		local seed = props.Seed
		setupViewport(viewport, cosmeticId, maid, seed == nil and 0 or seed)
	end, {})
	useEffect(function()
		return function()
			return maidRef.current:DoCleaning()
		end
	end, {})
	return React.createElement("viewportframe", {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["Ambient"] = nil,
		["LightColor"] = nil,
		["LightDirection"] = Vector3.new(0, -1, -0.5),
		["ImageTransparency"] = nil,
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 1,
		["BorderSizePixel"] = 0,
		["ZIndex"] = nil,
		["LayoutOrder"] = nil,
		["ref"] = nil,
		["AnchorPoint"] = props.AnchorPoint,
		["Position"] = props.Position,
		["Size"] = props.Size,
		["Ambient"] = Color3.fromRGB(162, 162, 162),
		["LightColor"] = Color.White,
		["ImageTransparency"] = props.ImageTransparency,
		["BackgroundColor3"] = Color.ViewportLightGrey,
		["ZIndex"] = props.ZIndex,
		["LayoutOrder"] = props.LayoutOrder,
		["ref"] = viewportRef,
	})
end
local findItemGroup = nil
local createKillEffectSchedule = nil
setupViewport = function(viewport: ViewportFrame, cosmeticId: string, maid, seed: number)
	local cosmetic = Cosmetics[cosmeticId]
	local model = nil
	local distance = 700
	local flipDistance = false
	local heightOffset = 0
	if cosmetic.Type == "Cage" then
		model = ReplicatedStorage.Cosmetic.Cage:FindFirstChild(cosmetic.Id)
		if model ~= nil then
			model = model:Clone()
		end
		model:SetPrimaryPartCFrame(CFrame.new())
		local extents = model:GetExtentsSize()
		local sizeX = extents.X
		local sizeY = extents.Y
		local sizeZ = extents.Z
		distance = math.max(sizeX, sizeY, sizeZ) * 45
		if cosmetic.Id == CosmeticId.CageClouds then
			heightOffset = 4
		end
	elseif cosmetic.Type == "Cape" then
		model = ReplicatedStorage.Cosmetic.Cape:FindFirstChild(cosmetic.Id)
		if model ~= nil then
			model = model:Clone()
		end
		model:SetPrimaryPartCFrame(CFrame.Angles(0, 3.141592653589793, 0))
		heightOffset = 0.5
		distance = 130
	elseif cosmetic.Type == "Skin" then
		local groupItems = ItemsByGroup[cosmetic.ItemGroup]
		local randomItem = groupItems[Random.new(seed):NextInteger(0, #groupItems - 1) + 1]
		local tool = SkinsUtil.getTool(randomItem.Name, cosmetic.Id)
		local viewportOptions = SkinsUtil.getViewportOptions(randomItem.Name, cosmetic.Id)
		if viewportOptions ~= nil then
			viewportOptions = viewportOptions.Rotate
		end
		model = ToolUtil.createToolModel(tool, viewportOptions)
		local itemGroup = randomItem.ItemGroup
		if itemGroup == ItemGroup.Leggings or itemGroup == ItemGroup.Chestplate then
			local attachmentCount = 0
			local attachments = {}
			for index, descendant in model:GetDescendants() do
				local _ = index - 1
				if descendant:IsA("Attachment") == true then
					attachmentCount = attachmentCount + 1
					attachments[attachmentCount] = descendant
				end
			end
			local lastIndex = #attachments
			local lastAttachment = attachments[lastIndex]
			attachments[lastIndex] = nil
			if lastAttachment then
				model:SetPrimaryPartCFrame(CFrame.new(model:GetPrimaryPartCFrame().Position) * CFrame.Angles(0, 0, 0))
				if lastAttachment.WorldOrientation.Y == 0 then
					model:SetPrimaryPartCFrame(
						CFrame.new(model:GetPrimaryPartCFrame().Position) * CFrame.Angles(0, 3.141592653589793, 0)
					)
				end
			end
		end
		distance = 180
	elseif cosmetic.Type == "Package" and cosmetic.PackageType == "Armour" then
		local helmet = nil
		for index, cosmeticId in cosmetic.Cosmetics do
			local _ = index - 1
			if findItemGroup(cosmeticId, ItemGroup.Helmet) ~= nil == true then
				helmet = cosmeticId
				break
			end
		end
		local chestplate = nil
		for index, cosmeticId in cosmetic.Cosmetics do
			local _ = index - 1
			if findItemGroup(cosmeticId, ItemGroup.Chestplate) ~= nil == true then
				chestplate = cosmeticId
				break
			end
		end
		local leggings = nil
		for index, cosmeticId in cosmetic.Cosmetics do
			local _ = index - 1
			if findItemGroup(cosmeticId, ItemGroup.Leggings) ~= nil == true then
				leggings = cosmeticId
				break
			end
		end
		if helmet and (chestplate and leggings) then
			local armourCosmetics = {
				[ItemGroup.Helmet] = Cosmetics[helmet],
				[ItemGroup.Chestplate] = Cosmetics[chestplate],
				[ItemGroup.Leggings] = Cosmetics[leggings],
			}
			model = Instance.new("Model")
			for itemGroup, cosmeticItem in armourCosmetics do
				local groupItems = ItemsByGroup[itemGroup]
				local randomItem = groupItems[Random.new(seed):NextInteger(0, #groupItems - 1) + 1]
				local tool = SkinsUtil.getTool(randomItem.Name, cosmeticItem.Id)
				local viewportOptions = SkinsUtil.getViewportOptions(randomItem.Name, cosmeticItem.Id)
				if viewportOptions ~= nil then
					viewportOptions = viewportOptions.Rotate
				end
				local partModel = ToolUtil.createToolModel(tool, viewportOptions)
				if itemGroup == ItemGroup.Helmet or itemGroup == ItemGroup.Leggings then
					local primaryCFrame = partModel:GetPrimaryPartCFrame()
					local newCFrame = CFrame.new
					local yOffset = itemGroup == ItemGroup.Helmet and 2.3 or -2.3
					partModel:SetPrimaryPartCFrame(primaryCFrame * newCFrame((Vector3.new(0, yOffset, 0))))
				end
				partModel:SetPrimaryPartCFrame(partModel:GetPrimaryPartCFrame() * CFrame.Angles(0, 0, 0))
				if itemGroup == ItemGroup.Leggings or itemGroup == ItemGroup.Chestplate then
					local attachmentCount = 0
					local attachments = {}
					for index, descendant in partModel:GetDescendants() do
						local _ = index - 1
						if descendant:IsA("Attachment") == true then
							attachmentCount = attachmentCount + 1
							attachments[attachmentCount] = descendant
						end
					end
					local lastIndex = #attachments
					local lastAttachment = attachments[lastIndex]
					attachments[lastIndex] = nil
					if lastAttachment then
						partModel:SetPrimaryPartCFrame(
							CFrame.new(partModel:GetPrimaryPartCFrame().Position) * CFrame.Angles(0, 0, 0)
						)
						if lastAttachment.WorldOrientation.Y == 0 then
							partModel:SetPrimaryPartCFrame(
								CFrame.new(partModel:GetPrimaryPartCFrame().Position)
									* CFrame.Angles(0, 3.141592653589793, 0)
							)
						end
					end
				end
				partModel.PrimaryPart.Name = itemGroup
				partModel.PrimaryPart.Parent = model
				if itemGroup == ItemGroup.Chestplate then
					model.PrimaryPart = partModel.PrimaryPart
				end
			end
			distance = 250
		end
	elseif cosmetic.Type == "Package" and cosmetic.PackageType == "Weapons" then
		for _, cosmeticId in cosmetic.Cosmetics do
			local cosmeticItem = Cosmetics[cosmeticId]
			if cosmeticItem and (cosmeticItem.Type == "Skin" and cosmeticItem.ItemGroup == ItemGroup.Sword) then
				setupViewport(viewport, cosmeticItem.Id, maid, seed)
				return nil
			end
		end
	elseif cosmetic.Type == "KillEffect" then
		local character
		if RunService:IsRunning() then
			character = Flamework.resolveDependency("Zw"):getCachedCharacter()
		else
			character = Players:CreateHumanoidModelFromDescription(
				Instance.new("HumanoidDescription"),
				Enum.HumanoidRigType.R15
			)
		end
		local animatedKillEffects =
			{ CosmeticId.KillEffectDownsizing, CosmeticId.KillEffectFirework, CosmeticId.KillEffectMidasTouch }
		if character then
			local killEffectId = cosmetic.Id
			if table.find(animatedKillEffects, killEffectId) == nil then
				createKillEffectSchedule(maid, viewport, character, cosmetic.Id)
				flipDistance = true
				distance = 600
			end
		end
	elseif cosmetic.Type == "ArrowTrailEffect" then
		local arrowItem = Items.Arrow
		model = ToolUtil.createToolModel(arrowItem.ToolRef:Clone(), arrowItem.ViewportOptions.Rotate)
		distance = 100
	end
	local displayModel = model or Instance.new("Model")
	displayModel.Parent = viewport
	local boundingBoxY = ({ displayModel:GetBoundingBox() })[1].Y + heightOffset
	local targetPosition = Vector3.new(0, boundingBoxY, 0)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 1
	local newCFrame = CFrame.new
	local cameraDistance
	if flipDistance then
		cameraDistance = -distance
	else
		cameraDistance = distance
	end
	local cameraHeight = distance / 1.5
	if flipDistance then
		distance = -distance
	end
	camera.CFrame = newCFrame(Vector3.new(cameraDistance, cameraHeight, distance), targetPosition)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	viewport.Ambient = Color3.fromRGB(162, 162, 162)
	viewport.LightColor = Color.White
	viewport.LightDirection = Vector3.new(0, -1, -0.5)
end
local playKillEffectAnimation = nil
createKillEffectSchedule = function(maid, viewport: ViewportFrame, character: Model, cosmeticId: string)
	local isActive = true
	local animation = nil
	maid:GiveTask(function()
		isActive = false
		if animation then
			animation.Maid:DoCleaning()
		end
	end)
	maid:GiveTask(ScheduleUtil.createSchedule(1, function()
		if animation and not animation.AnimationEnded then
			return nil
		end
		animation = playKillEffectAnimation(viewport, character, cosmeticId)
	end))
end
playKillEffectAnimation = function(viewport: ViewportFrame, character: Model, cosmeticId: string)
	if not (Players.LocalPlayer and viewport:IsDescendantOf(Players.LocalPlayer.PlayerGui)) then
		return nil
	end
	local characterClone = character:Clone()
	characterClone:PivotTo(CFrame.new(0, 0, 0))
	local worldModel = Instance.new("WorldModel")
	characterClone.Parent = worldModel
	worldModel.Parent = viewport
	local killEffect = Flamework.resolveDependency("Q83"):playKillEffect(characterClone, cosmeticId, nil, worldModel)
	if killEffect then
		killEffect.Maid:GiveTask(worldModel)
	end
	return killEffect
end
findItemGroup = function(cosmeticId: string, itemGroup: string)
	local cosmetic = Cosmetics[cosmeticId]
	if cosmetic and cosmetic.Type == "Skin" then
		if cosmetic.ItemGroup == itemGroup then
			return cosmetic
		else
			return nil
		end
	end
	return nil
end
return {
	["CosmeticViewport"] = CosmeticViewport,
}
