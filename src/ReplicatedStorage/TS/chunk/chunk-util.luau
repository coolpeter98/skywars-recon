-- ChunkUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants

type GreedyShape = {
	Type: string,
	Size: Vector3,
	Origin: Vector3,
}

type GenChunk = {
	GreedyShapes: { GreedyShape },
}

return {
	["ChunkUtil"] = {
		["generateRobloxChunk"] = function(chunk: GenChunk): Model
			local model: Model = Instance.new("Model")
			model.Name = ""
			for _, greedyShape in chunk.GreedyShapes do
				local block: BasePart = Items[greedyShape.Type].Block.Ref:Clone()
				block.Size = greedyShape.Size * BlockConstants.BLOCK_SIZE
				block.Position = (greedyShape.Origin + greedyShape.Size / 2) * 3 - Vector3.new(0, 500, 0)
				block.Parent = model
			end
			return model
		end,
	},
}
