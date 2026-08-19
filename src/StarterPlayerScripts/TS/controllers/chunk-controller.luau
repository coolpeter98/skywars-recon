-- ChunkController

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
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local ChunkUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "chunk", "chunk-util").ChunkUtil
local BufferDecoder =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "codec", "buffer-decoder").BufferDecoder
local BlocksSerialized =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").BlocksSerialized
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace

local ChunkTaskType = {}
local ChunkTaskTypeNames = setmetatable({}, {
	["__index"] = ChunkTaskType,
})
ChunkTaskTypeNames.Generate = 0
ChunkTaskType[0] = "Generate"
ChunkTaskTypeNames.Parent = 1
ChunkTaskType[1] = "Parent"
ChunkTaskTypeNames.Unload = 2
ChunkTaskType[2] = "Unload"

type ChunkTask = {
	Type: number,
	ChunkPosition: Vector2,
	GenChunk: any?,
	Model: Model?,
}

type ChunkController = {
	loadedChunks: { [Vector3]: Model },
	chunkTasks: { ChunkTask },
	pendingParenting: { [Vector3]: boolean },
}

local ChunkController = setmetatable({}, {
	["__tostring"] = function(): string
		return "ChunkController"
	end,
})
ChunkController.__index = ChunkController

function ChunkController.new(...): ChunkController
	local self = setmetatable({}, ChunkController)
	return self:constructor(...) or self
end

function ChunkController.constructor(self: ChunkController)
	self.loadedChunks = {}
	self.chunkTasks = {}
	self.pendingParenting = {}
end

function ChunkController.onStart(self: ChunkController)
	Events.ChunkData:connect(function(chunkPosition: Vector2, buffer: string)
		local decoder = BufferDecoder.new(buffer)
		local shapeCount = decoder:readVarInt()
		local hasStarted = false
		local i = 0
		local genChunk = {
			["GreedyShapes"] = {},
			["PrimitiveShapes"] = {},
		}
		while true do
			if hasStarted then
				i = i + 1
			else
				hasStarted = true
			end
			if i >= shapeCount then
				local chunkTasks = self.chunkTasks
				local task = {
					["Type"] = ChunkTaskType.Generate,
					["ChunkPosition"] = chunkPosition,
					["GenChunk"] = genChunk,
				}
				table.insert(chunkTasks, task)
				return
			end
			local shapeOffset = decoder:readVector()
			local baseX = chunkPosition.X * 16
			local baseY = chunkPosition.Y * 16
			local origin = shapeOffset + Vector3.new(baseX, 0, baseY)
			local size = decoder:readVector()
			local blockTypeId = decoder:readVarInt()
			local greedyShapes = genChunk.GreedyShapes
			local shape = {
				["Origin"] = origin,
				["Size"] = size,
				["Type"] = BlocksSerialized[blockTypeId].Name,
			}
			table.insert(greedyShapes, shape)
		end
	end)
	Events.ChunkUnloaded:connect(function(chunkPosition: Vector2)
		local chunkTasks = self.chunkTasks
		local task = {
			["Type"] = ChunkTaskType.Unload,
			["ChunkPosition"] = chunkPosition,
		}
		table.insert(chunkTasks, task)
	end)
end

function ChunkController.onTick(self: ChunkController, _)
	os.clock()
	local tasksProcessed = 0
	while true do
		local task: ChunkTask
		local handled = false
		while true do
			if #self.chunkTasks <= 0 or tasksProcessed ~= 0 then
				return
			end
			local chunkTasks = self.chunkTasks
			local lastIndex = #chunkTasks
			task = chunkTasks[lastIndex]
			chunkTasks[lastIndex] = nil
			if task.Type == ChunkTaskType.Generate then
				break
			end
			if task.Type ~= ChunkTaskType.Parent then
				if task.Type == ChunkTaskType.Unload then
					local pendingParenting = self.pendingParenting
					local chunkX = task.ChunkPosition.X
					local chunkY = task.ChunkPosition.Y
					pendingParenting[Vector3.new(chunkX, chunkY, 0)] = nil
					local chunkX = task.ChunkPosition.X
					local chunkY = task.ChunkPosition.Y
					local chunkKey = Vector3.new(chunkX, chunkY, 0)
					local loadedChunk = self.loadedChunks[chunkKey]
					if loadedChunk then
						loadedChunk:Destroy()
						self.loadedChunks[chunkKey] = nil
					end
				end
				handled = true
				break
			end
			local pendingParenting = self.pendingParenting
			local chunkX = task.ChunkPosition.X
			local chunkY = task.ChunkPosition.Y
			if pendingParenting[Vector3.new(chunkX, chunkY, 0)] ~= nil then
				local pendingParenting = self.pendingParenting
				local chunkX = task.ChunkPosition.X
				local chunkY = task.ChunkPosition.Y
				pendingParenting[Vector3.new(chunkX, chunkY, 0)] = nil
				task.Model.Parent = Workspace
				local loadedChunks = self.loadedChunks
				local chunkX = task.ChunkPosition.X
				local chunkY = task.ChunkPosition.Y
				loadedChunks[Vector3.new(chunkX, chunkY, 0)] = task.Model
				handled = true
				break
			end
		end
		if not handled then
			local chunkTasks = self.chunkTasks
			local parentTask = {
				["Type"] = ChunkTaskType.Parent,
				["ChunkPosition"] = task.ChunkPosition,
				["Model"] = ChunkUtil.generateRobloxChunk(task.GenChunk),
			}
			table.insert(chunkTasks, parentTask)
			local pendingParenting = self.pendingParenting
			local chunkX = task.ChunkPosition.X
			local chunkY = task.ChunkPosition.Y
			pendingParenting[Vector3.new(chunkX, chunkY, 0)] = true
		end
		tasksProcessed = tasksProcessed + 1
	end
end

Reflect.defineMetadata(ChunkController, "identifier", "9bw")
Reflect.defineMetadata(ChunkController, "flamework:implements", { "$:flamework@OnStart", "$:flamework@OnTick" })
Reflect.decorate(ChunkController, "$:flamework@Controller", Controller, {})
return {
	["ChunkController"] = ChunkController,
}
