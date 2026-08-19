-- Size

-- The original TS/ui/components/size module was lost during the Rojo syncback
-- of the place. Every other importer of the Size value type uses TS/ui/size
-- (same API: Size.new(x, y) with X/Y), so re-export it here to keep
-- personal-billboard's compiled import path working.

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))

local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size

return {
	["Size"] = Size,
}
