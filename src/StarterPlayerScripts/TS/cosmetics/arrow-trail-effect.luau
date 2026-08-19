-- ArrowTrailEffect

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
local Queue = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "queue").Queue
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local CollectionService: CollectionService = Services.CollectionService
local Players: Players = Services.Players
local Workspace: Workspace = Services.Workspace
local ScheduleUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local ItemDropUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-drop-util").ItemDropUtil
local scaleDescendants = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"scale-model",
	"out"
).scaleDescendants
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Make = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"altmake",
	"out"
).Make
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local VectorUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil

type ArrowTrailAttachments = { FrontAttachment: Attachment, BackAttachment: Attachment }
type ItemTrailProps = {
	ItemScale: number,
	ItemDuration: number,
	UpdateInterval: number,
	MaxDistance: number,
	OnItemAdded: ((model: Model, distance: number) -> boolean)?,
	OnItemRemoved: ((model: Model, distance: number) -> boolean)?,
}

return {
	["ArrowTrailEffect"] = {
		["constructor"] = function(_) end,
		["createTrail"] = function(_, attachments: ArrowTrailAttachments, color: Color3): Trail
			local trail = Instance.new("Trail")
			trail.Name = "ArrowTrail"
			trail.Color = ColorUtil.getColorSequence(color)
			trail.LightEmission = 0
			trail.LightInfluence = 1
			trail.Lifetime = 0.25
			trail.MinLength = 0.1
			trail.WidthScale = NumberSequence.new(0.2)
			trail.Transparency = NumberSequence.new(0.5)
			trail.FaceCamera = true
			trail.Attachment0 = attachments.FrontAttachment
			trail.Attachment1 = attachments.BackAttachment
			return trail
		end,
		["createParticleEmitter"] = function(_, part: BasePart, color: Color3): ParticleEmitter
			local particleEmitter = Flamework.resolveDependency("dm"):attachParticleEmitter(part, {
				Rate = 50,
				Speed = 3,
				LightInfluence = 10,
				Color = ColorUtil.getColorSequence(color),
				Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.1) }),
				Lifetime = NumberRange.new(0.5, 1.5),
				Rotation = NumberRange.new(0, 360),
				SpreadAngle = Vector2.new(180, 180),
			})
			particleEmitter.LockedToPart = false
			particleEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.8, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			})
			return particleEmitter
		end,
		["createItemTrail"] = function(self, part: BasePart, lifecycle, item, options: ItemTrailProps?)
			local itemModel = ItemDropUtil.createItemDropModel(item)
			CollectionService:RemoveTag(itemModel, "item")
			return self:createModelTrail(part, lifecycle, itemModel, options)
		end,
		["createModelTrail"] = function(self, part: BasePart, lifecycle, model: Model, options: ItemTrailProps?)
			local props = self:getItemTrailProps(options)
			local basePosition: Vector3 = part.Position
			local folder = Make("Folder", {
				Name = "ArrowTrailItems",
				Parent = Workspace,
			})
			local queue = Queue.new()
			queue:setOnRemoveHandler(function(entry)
				local distance: number = VectorUtil.distance(basePosition, entry.Value:GetPivot().Position)
				if not props.OnItemRemoved or props.OnItemRemoved(entry.Value, distance) then
					entry.Value:Destroy()
				end
			end)
			lifecycle:GiveTask(ScheduleUtil.createSchedule(props.UpdateInterval, function()
				self:pollQueue(queue, props.ItemDuration)
				local position: Vector3 = part.Position
				local offsetX: number = (math.random() - 0.5) * 1.5
				local offsetY: number = (math.random() - 0.5) * 1.5
				local offsetZ: number = (math.random() - 0.5) * 1.5
				local spawnPosition: Vector3 = position + Vector3.new(offsetX, offsetY, offsetZ)
				local distance: number = VectorUtil.distance(basePosition, spawnPosition)
				if props.MaxDistance < distance then
					return nil
				end
				local item = self:createModel(spawnPosition, model, props.ItemScale)
				if not item then
					return nil
				end
				queue:add(item)
				if props.OnItemAdded then
					props.OnItemAdded(item, distance)
				end
				item.Parent = folder
			end))
			lifecycle:GiveTask(function()
				task.spawn(function()
					local startTime: number = os.clock()
					while true do
						local nextItem = not queue:isEmpty() and (not TimeUtil.elapsed(startTime, 5) and queue:peek())
						if not nextItem then
							break
						end
						if TimeUtil.elapsed(nextItem.Timestamp, props.ItemDuration) then
							queue:poll()
						else
							task.wait(props.UpdateInterval)
						end
					end
				end)
			end)
			return queue
		end,
		["pollQueue"] = function(_, queue, duration: number)
			while not queue:isEmpty() do
				local entry = queue:peek()
				if not (entry and TimeUtil.elapsed(entry.Timestamp, duration)) then
					break
				end
				queue:poll()
			end
		end,
		["getItemTrailProps"] = function(_, options: ItemTrailProps?): ItemTrailProps
			local props = {}
			local itemScale
			if options == nil then
				itemScale = options
			else
				itemScale = options.ItemScale
			end
			props.ItemScale = itemScale == nil and 0.65 or itemScale
			local itemDuration
			if options == nil then
				itemDuration = options
			else
				itemDuration = options.ItemDuration
			end
			props.ItemDuration = itemDuration == nil and 0.3 or itemDuration
			local updateInterval
			if options == nil then
				updateInterval = options
			else
				updateInterval = options.UpdateInterval
			end
			props.UpdateInterval = updateInterval == nil and 0.05 or updateInterval
			local maxDistance
			if options == nil then
				maxDistance = options
			else
				maxDistance = options.MaxDistance
			end
			props.MaxDistance = maxDistance == nil and 150 or maxDistance
			local onItemAdded
			if options == nil then
				onItemAdded = options
			else
				onItemAdded = options.OnItemAdded
			end
			props.OnItemAdded = onItemAdded
			local onItemRemoved
			if options == nil then
				onItemRemoved = options
			else
				onItemRemoved = options.OnItemRemoved
			end
			props.OnItemRemoved = onItemRemoved
			return props
		end,
		["getShooter"] = function(_, character: Model): Player?
			local userId: number? = character:GetAttribute(Attribute.Shooter)
			if userId == nil then
				return nil
			else
				return Players:GetPlayerByUserId(userId)
			end
		end,
		["createModel"] = function(_, position: Vector3, model: Model, scale: number): Model
			local clone = model:Clone()
			clone.PrimaryPart.Anchored = true
			local positionCFrame = CFrame.new(position)
			local angles = CFrame.Angles
			local rotation: number = math.random() * 360
			clone:PivotTo(positionCFrame * angles(0, math.rad(rotation), 0))
			scaleDescendants(clone, scale, position, true)
			return clone
		end,
	},
}
