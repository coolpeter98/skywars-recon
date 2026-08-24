--!strict

-- Recovery-only fallback. Public and future custom Egg Wars sessions use the
-- imported WorldData maps; these dimensions keep the generic arena builder
-- available if an imported asset is temporarily missing.
return {
	TeamCount = 4,
	IslandRadius = 90,
	IslandSize = Vector3.new(58, 4, 58),
	CenterSize = Vector3.new(76, 5, 76),
	ChestsPerIsland = 0,
}
