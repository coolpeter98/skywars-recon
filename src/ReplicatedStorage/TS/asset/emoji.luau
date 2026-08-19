-- Emoji

type EmojiMap = { [string]: string }

local Emoji: EmojiMap = {
	["Trophy"] = "\240\159\143\134",
	["CrossedSwords"] = "\226\154\148",
	["Skull"] = "\240\159\146\128",
	["Flame"] = "\240\159\148\165",
	["Dizzy"] = "\240\159\146\171",
	["Shield"] = "\240\159\155\161\239\184\143",
	["Hashtag"] = "#\239\184\143\226\131\163\239\184\143",
	["CheckMark"] = "\226\156\133",
	["Crown"] = "\240\159\145\145",
}

return {
	["Emoji"] = Emoji,
}
