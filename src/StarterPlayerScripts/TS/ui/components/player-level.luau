-- PlayerLevel

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayerIcon = RuntimeLib.import(script, script.Parent, "player-icon").PlayerIcon
local ExperienceUtil = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"experience-util"
).ExperienceUtil
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local useExperience = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-experience").useExperience
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type PlayerLevelProps = {
	AnchorPoint: UDim2?,
	Position: UDim2?,
	Size: UDim2?,
	UserId: number?,
	BackgroundColor3: Color3?,
	CornerRadius: UDim?,
}

return {
	["PlayerLevel"] = function(props: PlayerLevelProps)
		local experience: number = useExperience()
		local level: number = ExperienceUtil.getLevel(experience)
		local levelColour: Color3 = ColorUtil.getLevelColour(level)
		return React.createElement(PlayerIcon, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["UserId"] = nil,
			["BackgroundColor3"] = nil,
			["BackgroundTransparency"] = 0,
			["CornerRadius"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
			["UserId"] = props.UserId,
			["BackgroundColor3"] = levelColour,
			["CornerRadius"] = UDim.new(1),
		})
	end,
}
