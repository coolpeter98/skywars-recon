-- Extracts one map model from a whole Roblox place into a Rojo-mountable
-- binary model. This is useful for recovered client saves where the arena is
-- nested under Workspace.BlockContainer.Map instead of supplied as an rbxm.
--
-- Usage:
--   lune run tools/extract_map_from_place.luau <place.rbxl[x]> <map.rbxm>

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local inputPath = process.args[1]
local outputPath = process.args[2]

assert(inputPath ~= nil and outputPath ~= nil, "expected an input place and output model path")

local place = roblox.deserializePlace(fs.readFile(inputPath))
local workspace = place:GetService("Workspace")
local blockContainer = workspace:FindFirstChild("BlockContainer")
assert(blockContainer ~= nil, "place has no Workspace.BlockContainer")

local map = blockContainer:FindFirstChild("Map")
assert(map ~= nil and map:IsA("Model"), "place has no Workspace.BlockContainer.Map model")
assert(map:FindFirstChild("WorldData") ~= nil, "map has no WorldData folder")

-- Recovered live-place saves may already contain the original server's
-- generated runtime children. ServerStorage map assets are canonicalized to
-- the unpopulated format used by the supplied .rbxm maps; EggWarsMap rebuilds
-- these folders when the cage phase starts.
for _, folderName in { "SpawnLocations", "Generators", "Shops", "Chests" } do
	local folder = map:FindFirstChild(folderName)
	if folder ~= nil and folder:IsA("Folder") then
		folder:ClearAllChildren()
	end
end

map.Parent = nil
fs.writeFile(outputPath, roblox.serializeModel({ map }))

print(("extracted %s to %s (%d descendants)"):format(inputPath, outputPath, #map:GetDescendants()))
