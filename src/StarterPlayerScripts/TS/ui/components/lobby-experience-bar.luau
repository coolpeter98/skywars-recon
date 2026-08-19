-- LobbyExperienceBar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ProgressBarNew = RuntimeLib.import(script, script.Parent, "progress-bar", "progress-bar-new").ProgressBarNew
local ExperienceUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"experience-util"
).ExperienceUtil
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["LobbyExperienceBar"] = function(props)
		local experience: number = props.Experience
		local level: number = ExperienceUtil.getLevel(props.Experience)
		local levelProgress: number = experience - ExperienceUtil.getExperience(level)
		local levelRequirement: number = ExperienceUtil.getExperience(level + 1) - ExperienceUtil.getExperience(level)

		return React.createElement(ProgressBarNew, {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
			["Progress"] = levelProgress / levelRequirement,
			["Image"] = RobloxImage.Icon.CIRCLE_STAR,
			["Text"] = ("LEVEL %*"):format(level),
			["Colors"] = { ColorUtil.getLevelColour(level) },
			["ZIndex"] = props.ZIndex,
		})
	end,
}
