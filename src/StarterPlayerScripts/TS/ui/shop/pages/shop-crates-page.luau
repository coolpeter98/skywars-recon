-- ShopCratesPage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useProfile = RuntimeLib.import(script, script.Parent.Parent.Parent, "rodux", "global-store").useProfile
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local ShopCrate = RuntimeLib.import(script, script.Parent.Parent, "components", "shop-crate").ShopCrate
return {
	["ShopCratesPage"] = function(_)
		local shopContext = useContext(NewShopContext)
		useProfile()
		local _ = shopContext.PageSize.X
		return React.createElement(
			React.Fragment,
			nil,
			React.createElement(ShopCrate, {
				["CrateId"] = "NinjaCrate",
			}),
			React.createElement(ShopCrate, {
				["Position"] = nil,
				["CrateId"] = "KnightBruteCrate",
				["Position"] = UDim2.fromOffset(0, 400 + ScreenConstants.PADDING_2),
			})
		)
	end,
}
