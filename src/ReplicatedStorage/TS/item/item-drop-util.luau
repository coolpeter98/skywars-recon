-- ItemDropUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local scaleDescendants = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"scale-model",
	"out"
).scaleDescendants
local CollectionService: CollectionService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).CollectionService
local CollisionGroup =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "collision", "collision-group").CollisionGroup

type ItemConfig = {
	ToolRef: {
		Handle: BasePart,
	},
	Block: boolean?,
	Currency: number | string?,
}

return {
	["ItemDropUtil"] = {
		["createItemDropModel"] = function(itemId: string): Model?
			local item: ItemConfig? = Items[itemId]
			if not item then
				return nil
			end

			local handle = item.ToolRef.Handle:Clone()
			for _, descendant in handle:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.CanTouch = false
					descendant.CanCollide = false
				end
			end

			local hitbox = Instance.new("Part")
			hitbox.Name = "Hitbox"
			hitbox.Size = BlockConstants.BLOCK_DIMENSION / 2
			hitbox.Anchored = false
			hitbox.CanCollide = true
			hitbox.CanTouch = true
			hitbox.Position = handle.Position
			hitbox.Transparency = 1
			handle.Parent = hitbox

			local scale: number
			if item.Block then
				scale = 1
			else
				local currency = item.Currency
				scale = (currency == 0 or (currency ~= currency or (currency == "" or not currency))) and 0.5 or 0.75
			end

			scaleDescendants(hitbox, scale, handle.Position, true)

			local model = Instance.new("Model")
			model.Name = itemId
			hitbox.Parent = model
			model.PrimaryPart = hitbox

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = hitbox
			weld.Part1 = handle
			weld.Parent = hitbox

			hitbox.CollisionGroup = CollisionGroup.PLAYER_COLLISION_GROUP
			CollectionService:AddTag(model, "item")

			return model
		end,
	},
}
