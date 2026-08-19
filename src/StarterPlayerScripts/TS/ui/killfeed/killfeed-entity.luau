-- KillfeedEntityType

local KillfeedEntityTypeNames = {}
local KillfeedEntityType = setmetatable({}, {
	["__index"] = KillfeedEntityTypeNames,
})
KillfeedEntityType.Player = 0
KillfeedEntityTypeNames[0] = "Player"
KillfeedEntityType.Abstract = 1
KillfeedEntityTypeNames[1] = "Abstract"
return {
	["KillfeedEntityType"] = KillfeedEntityType,
}
