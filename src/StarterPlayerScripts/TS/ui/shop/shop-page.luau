-- ShopPage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
local useWindow = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-window").useWindow
local NewShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "new-shop-context").NewShopContext
local ShopHomePage = RuntimeLib.import(script, script.Parent, "pages", "shop-home-page").ShopHomePage
local ShopSeasonPassPage = RuntimeLib.import(script, script.Parent, "pages", "shop-season-pass-page").ShopSeasonPassPage
local ShopCratesPage = RuntimeLib.import(script, script.Parent, "pages", "shop-crates-page").ShopCratesPage
local ShopBundlesPage = RuntimeLib.import(script, script.Parent, "pages", "shop-bundles-page").ShopBundlesPage
local ShopGemsPage = RuntimeLib.import(script, script.Parent, "pages", "shop-gems-page").ShopGemsPage
return {
	["ShopPage"] = function(_)
		useWindow()
		useProfile()
		local selectedTabId: number = useContext(NewShopContext).SelectedTab.Id
		if selectedTabId == 0 then
			return React.createElement(ShopHomePage)
		end
		if selectedTabId == 1 then
			return React.createElement(ShopSeasonPassPage)
		end
		if selectedTabId == 2 then
			return React.createElement(ShopCratesPage)
		end
		if selectedTabId == 3 then
			return React.createElement(ShopBundlesPage)
		end
		if selectedTabId == 4 then
			return React.createElement(ShopGemsPage)
		end
	end,
}
