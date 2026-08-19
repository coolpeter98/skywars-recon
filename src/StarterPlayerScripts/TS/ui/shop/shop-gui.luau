-- ShopGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local FullscreenWindow = RuntimeLib.import(script, script.Parent.Parent, "components", "common", "fullscreen-window").FullscreenWindow
local ProfileGems = RuntimeLib.import(script, script.Parent.Parent, "components", "profile-gems").ProfileGems
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local useGlobalStore = GlobalStore.useGlobalStore
local useProfile = GlobalStore.useProfile
local useTabs = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-tabs").useTabs
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local useWindow = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-window").useWindow
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local ShopPage = RuntimeLib.import(script, script.Parent, "shop-page").ShopPage
local NewShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "new-shop-context").NewShopContext
local ShopTabs = RuntimeLib.import(script, script.Parent, "components", "shop-tabs").ShopTabs
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil

local function getTabId(product: { ProductType: string }): number?
	local productType = product.ProductType
	if productType == "undefined" then
		return 0
	end
	if productType == "SeasonPass" then
		return 1
	end
	if productType == "Bundle" then
		return 3
	end
	if productType == "Crate" then
		return 2
	end
	if productType == "Gems" then
		return 4
	end
end
return {
	["ShopGui"] = function(_)
		local window = useWindow()
		local profile = useProfile()
		local selectedShopProductData = useGlobalStore("SelectedShopProductData")
		local tabs = useTabs({
			["Tabs"] = ArrayUtil.filterDefined({
				{
					["Id"] = 0,
					["Text"] = "HOME",
					["Icon"] = nil,
					["Icon"] = RobloxImage.Icon.HOME_OUTLINE_256
				},
				{
					["Id"] = 1,
					["Text"] = "SEASON",
					["Icon"] = nil,
					["Icon"] = RobloxImage.Icon.DAILY_REWARDS_OUTLINE_256
				},
				RunService:IsRunning() and Flamework.resolveDependency("D8k"):allowsGambling() and {
					["Id"] = 2,
					["Text"] = "CRATES",
					["Icon"] = nil,
					["Icon"] = RobloxImage.Icon.CHEST_MEDIUM_2_OUTLINE_256
				} or nil,
				{
					["Id"] = 3,
					["Text"] = "BUNDLES",
					["Icon"] = nil,
					["Icon"] = RobloxImage.Icon.SWORD_OUTLINE_256
				},
				{
					["Id"] = 4,
					["Text"] = "GEMS",
					["Icon"] = nil,
					["Icon"] = RobloxImage.Icon.GEM_GREEN_OUTLINE_256
				}
			})
		})
		local lastClickTime = useState(os.clock())
		useEffect(function()
			local tabId = getTabId(selectedShopProductData)
			tabs.SetTab(tabId)
		end, { selectedShopProductData })
		local contentWidth: number = window.ContentFrameSize.X
		local contentHeight: number = window.ContentFrameSize.Y
		local topBarHeight: number = 100 + ScreenConstants.PADDING_3
		local pageHeight: number = contentHeight - topBarHeight
		local shopContext = {
			["PageSize"] = Vector2.new(contentWidth, pageHeight),
			["SelectedTab"] = tabs.Selected,
			["SetSelectedTab"] = function(tabId)
				if TimeUtil.elapsed(lastClickTime, 0.2) then
					tabs.SetTab(tabId)
				end
			end,
			["CanPurchase"] = function(productId, price, gems)
				local canPurchase = RunService:IsRunning()
				if canPurchase then
					canPurchase = Flamework.resolveDependency("YOK"):canPurchase(productId, price, gems)
				end
				return canPurchase
			end,
			["Purchase"] = function(productId, price, gems)
				if RunService:IsRunning() and TimeUtil.elapsed(lastClickTime, 0.2) then
					Flamework.resolveDependency("YOK"):promptPurchase(productId, price, gems)
				end
			end
		}
		local windowProps = {
			["key"] = "CosmeticsShopGui",
			["Text"] = "SHOP",
			["TopBarChildren"] = nil
		}
		local topBarChildren
		if InputUtil.isGamepadEnabled() then
			topBarChildren = React.createElement(React.Fragment)
		else
			topBarChildren = React.createElement(ProfileGems, {
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.new(1, -138, 0.5, 0),
				["Gems"] = profile.Gems
			})
		end
		windowProps.TopBarChildren = React.createElement(React.Fragment, nil, topBarChildren)
		return React.createElement(FullscreenWindow, windowProps, React.createElement(NewShopContext.Provider, {
			["value"] = shopContext
		}, React.createElement(ShopTabs, {
			["key"] = "Tabs",
			["Tabs"] = nil,
			["Tabs"] = tabs.Tabs
		}), React.createElement(Grid, {
			["key"] = "Page",
			["Position"] = nil,
			["Size"] = nil,
			["Position"] = UDim2.fromOffset(0, topBarHeight),
			["Size"] = UDim2.fromOffset(contentWidth, pageHeight)
		}, React.createElement(ShopPage))))
	end
}
