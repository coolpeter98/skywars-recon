-- ShopTabs

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local List = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "list").List
local ShopTab = RuntimeLib.import(script, script.Parent, "shop-tab").ShopTab
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local ShopScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "shop-screen-constants").ShopScreenConstants

return {
	["ShopTabs"] = function(props)
		local shopContext = useContext(NewShopContext)
		local tabs = props.Tabs
		local elements = table.create(#tabs)
		for index, tab in tabs do
			local _ = index - 1
			elements[index] = React.createElement(ShopTab, {
				["key"] = tab.Id,
				["Tab"] = tab,
			})
		end
		return React.createElement(
			Grid,
			{
				["key"] = "Tabs",
				["Size"] = nil,
				["Size"] = UDim2.fromOffset(shopContext.PageSize.X, ShopScreenConstants.TAB_SIZE_Y),
			},
			elements,
			React.createElement(List, {
				["Padding"] = UDim.new(0, ScreenConstants.PADDING_2),
			})
		)
	end,
}
