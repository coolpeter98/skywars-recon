-- OpenInventorySlot

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ItemSlot = RuntimeLib.import(script, script.Parent, "item-slot").ItemSlot
local Image = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
return {
	["OpenInventorySlot"] = function(props: { BackgroundColor3: Color3 })
		return React.createElement(
			ItemSlot,
			{
				["BackgroundColour3"] = nil,
				["SlotId"] = 9,
				["Text"] = "E",
				["OnInteract"] = nil,
				["BackgroundColour3"] = props.BackgroundColor3,
				["OnInteract"] = function()
					return Flamework.resolveDependency("qOA"):toggleInventory()
				end,
			},
			React.createElement(Image, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 1,
				["Image"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromOffset(32, 8),
				["Image"] = RobloxImage.OPEN_INVENTORY_ICON,
			})
		)
	end,
}
