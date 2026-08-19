-- NameTagHealthBar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local NameTagHealthBarSegment =
	RuntimeLib.import(script, script.Parent, "name-tag-health-bar-segment").NameTagHealthBarSegment
local HealthConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "health", "health-constants").HealthConstants
local useAttribute = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-attribute").useAttribute
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local useArmour = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-armour").useArmour
local NameTagContext = RuntimeLib.import(script, script.Parent.Parent, "context", "name-tag-context").NameTagContext
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext

type NameTagHealthBarProps = {
	Player: Player,
	AnchorPoint: Vector2,
	Position: UDim2,
	ParentWidth: number,
	ParentHeight: number,
	HealthBarColor: Color3,
}

return {
	["NameTagHealthBar"] = function(props: NameTagHealthBarProps)
		local context = useContext(NameTagContext)
		local healthAttribute: number? = useAttribute(props.Player, Attribute.Health)
		local health: number = healthAttribute == nil and 0 or healthAttribute
		local shieldAttribute: number? = useAttribute(props.Player, Attribute.Shield)
		local shield: number = shieldAttribute == nil and 0 or shieldAttribute
		local armour: number = useArmour(props.Player)
		local armourHealth: number = Flamework.resolveDependency("JXb"):getArmourHealth(armour)
		local maxHealth: number = HealthConstants.MAX_HEALTH + shield + armourHealth
		local currentHealth: number = health + shield
		local rawSegmentCount: number = maxHealth / HealthConstants.HEALTH_PER_SEGMENT
		local segmentCount: number = math.floor(rawSegmentCount)
		local scaledPadding: number = 1 * context.ScaleX
		local padding: number = math.ceil(scaledPadding) * (1 / context.ScaleX)
		local totalPadding: number = (segmentCount - 1) * padding
		local scaledSegmentWidth: number = (280 - totalPadding) / segmentCount * context.ScaleX
		local segmentWidth: number = math.ceil(scaledSegmentWidth) * (1 / context.ScaleX)
		local totalWidth: number = segmentCount * segmentWidth + totalPadding
		local isFirstIteration: boolean = false
		local segmentIndex: number = 1
		local segments = {}
		while true do
			if isFirstIteration then
				segmentIndex = segmentIndex + 1
			else
				isFirstIteration = true
			end
			if segmentIndex > segmentCount then
				return React.createElement(
					Grid,
					{
						["AnchorPoint"] = nil,
						["Position"] = nil,
						["Size"] = nil,
						["BackgroundTransparency"] = 0.6,
						["BackgroundColor3"] = nil,
						["CornerRadius"] = 10,
						["AnchorPoint"] = props.AnchorPoint,
						["Position"] = props.Position,
						["Size"] = UDim2.fromScale((totalWidth + 20) / props.ParentWidth, 40 / props.ParentHeight),
						["BackgroundColor3"] = props.HealthBarColor,
					},
					React.createElement(
						Grid,
						{
							["AnchorPoint"] = Vector2.new(0.5, 0.5),
							["Position"] = UDim2.fromScale(0.5, 0.5),
							["Size"] = UDim2.fromScale(totalWidth / (totalWidth + 20), 0.5),
						},
						segments,
						React.createElement(List, {
							["Padding"] = UDim.new(padding / totalWidth, 0),
						})
					)
				)
			end
			local segmentElement = React.createElement(NameTagHealthBarSegment, {
				["SegmentId"] = nil,
				["SegmentWidth"] = nil,
				["CurrentHealth"] = nil,
				["MaxHealth"] = nil,
				["ParentWidth"] = nil,
				["ParentHeight"] = 20,
				["SegmentId"] = segmentIndex,
				["SegmentWidth"] = segmentWidth,
				["CurrentHealth"] = currentHealth,
				["MaxHealth"] = maxHealth,
				["ParentWidth"] = totalWidth,
			})
			table.insert(segments, segmentElement)
		end
	end,
}
