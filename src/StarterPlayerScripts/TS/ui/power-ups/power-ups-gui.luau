-- PowerUpsGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local PowerUpCard = RuntimeLib.import(script, script.Parent, "power-up-card").PowerUpCard
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)
return {
	["PowerUpsGui"] = function(_)
		local powerUps = useGlobalStore("PowerUps")
		local entries = ObjectUtils.entries(powerUps)
		local children = table.create(#entries)
		for index, entry in entries do
			local _ = index - 1
			local props = {
				["PowerUp"] = entry[1],
				["StartTime"] = entry[2],
			}
			children[index] = React.createElement(PowerUpCard, props)
		end
		return React.createElement(
			Grid,
			{
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 75),
				["AutomaticSize"] = Enum.AutomaticSize.XY,
			},
			children,
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Horizontal,
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
				["Padding"] = UDim.new(0, 10),
				["VerticalAlignment"] = Enum.VerticalAlignment.Center,
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Center,
			})
		)
	end,
}
