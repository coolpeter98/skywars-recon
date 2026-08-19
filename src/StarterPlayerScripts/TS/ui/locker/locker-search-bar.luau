-- LockerSearchBar

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local TextInput = RuntimeLib.import(script, script.Parent.Parent, "components", "text-input").TextInput
local Dropdown = RuntimeLib.import(script, script.Parent.Parent, "components", "dropdown", "dropdown").Dropdown
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local ItemGroup = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item-group").ItemGroup
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type LockerCosmeticsState = {
	DisplayNameFilter: string,
	CosmeticTypeFilter: string,
	SetDisplayNameFilter: (filter: string) -> (),
	SetCosmeticTypeFilter: (filter: string) -> (),
}

type LockerSearchBarProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2,
	LockerCosmeticsState: LockerCosmeticsState,
}

return {
	["LockerSearchBar"] = function(props: LockerSearchBarProps)
		local searchBarHeight: number = props.Size.Y.Offset
		local createElement = React.createElement
		local grid = Grid
		local gridProps = {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
		}
		local textInputElement = createElement(TextInput, {
			["Size"] = nil,
			["PlaceholderText"] = "Search items...",
			["Value"] = nil,
			["SetValue"] = nil,
			["Size"] = UDim2.fromOffset(500, searchBarHeight),
			["Value"] = props.LockerCosmeticsState.DisplayNameFilter,
			["SetValue"] = props.LockerCosmeticsState.SetDisplayNameFilter,
		})
		local createElement = React.createElement
		local dropdown = Dropdown
		local dropdownProps = {
			["Position"] = UDim2.fromOffset(510, 0),
			["Size"] = Size.new(210, 50),
			["SelectedId"] = props.LockerCosmeticsState.CosmeticTypeFilter,
			["SetSelectedId"] = function(selectedId: string)
				return props.LockerCosmeticsState.SetCosmeticTypeFilter(selectedId)
			end,
			["Items"] = {
				{
					["Id"] = "ALL",
					["Text"] = "All",
				},
				{
					["Id"] = "ArrowTrailEffect",
					["Text"] = "Arrow Trail",
				},
				{
					["Id"] = "Cage",
					["Text"] = "Cage",
				},
				{
					["Id"] = "Cape",
					["Text"] = "Cape",
				},
				{
					["Id"] = "KillEffect",
					["Text"] = "Kill Effect",
				},
				{
					["Id"] = "Skin",
					["Text"] = "Skin",
				},
				{
					["Id"] = "Title",
					["Text"] = "Title",
				},
				{
					["Id"] = nil,
					["Text"] = "Sword",
					["Id"] = ItemGroup.Sword,
				},
				{
					["Id"] = nil,
					["Text"] = "Bow",
					["Id"] = ItemGroup.Bow,
				},
				{
					["Id"] = nil,
					["Text"] = "Helmet",
					["Id"] = ItemGroup.Helmet,
				},
				{
					["Id"] = nil,
					["Text"] = "Chestplate",
					["Id"] = ItemGroup.Chestplate,
				},
				{
					["Id"] = nil,
					["Text"] = "Leggings",
					["Id"] = ItemGroup.Leggings,
				},
				{
					["Id"] = nil,
					["Text"] = "Pickaxe",
					["Id"] = ItemGroup.Pickaxe,
				},
			},
		}
		return createElement(grid, gridProps, textInputElement, createElement(dropdown, dropdownProps))
	end,
}
