-- Changelog

export type ChangelogEntry = {
	Name: string,
	Timestamp: number,
	Changes: { any },
}

return {
	["ChangelogList"] = {
		{
			["Name"] = "Plasma Bundle Update",
			["Timestamp"] = DateTime.fromUniversalTime(2025, 3, 9, 10).UnixTimestamp,
			["Changes"] = {},
		},
	},
}
