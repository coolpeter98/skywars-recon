-- CosmeticsShopGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local FullscreenWindow = RuntimeLib.import(script, script.Parent.Parent, "components", "common", "fullscreen-window").FullscreenWindow
local ScrollingFrame = RuntimeLib.import(script, script.Parent.Parent, "components", "common", "scrolling-frame").ScrollingFrame
local ProductId = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "game-product").ProductId
local SeasonPassShopItem = RuntimeLib.import(script, script.Parent, "season-pass-shop-item").SeasonPassShopItem
local BundleShopItem = RuntimeLib.import(script, script.Parent, "bundle-shop-item").BundleShopItem
local ShopContext = RuntimeLib.import(script, script.Parent.Parent, "context", "shop-context").ShopContext
local CosmeticsShopSidebar = RuntimeLib.import(script, script.Parent, "sidebar", "cosmetics-shop-sidebar").CosmeticsShopSidebar
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local SeasonUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local ProfileGems = RuntimeLib.import(script, script.Parent.Parent, "components", "profile-gems").ProfileGems
local GemsShopList = RuntimeLib.import(script, script.Parent, "gems-shop-list").GemsShopList
local CrateShopList = RuntimeLib.import(script, script.Parent, "crate-shop-list").CrateShopList
local TweenService: TweenService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").TweenService
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local usePrevious = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-previous").usePrevious
local ScheduleUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "schedule-util").ScheduleUtil
local CameraViewportContext = RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local RobloxSound = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local useGlobalStore = GlobalStore.useGlobalStore
local useProfile = GlobalStore.useProfile
local CurrentSeason = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").CurrentSeason
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type ShopProductData = {
	ProductType: string,
	ProductId: string?,
	CrateId: string?,
}

local function getRow(product: ShopProductData): number?
	return product.ProductType == "SeasonPass" and 0 or (product.ProductType == "Crate" and product.CrateId == "NinjaCrate" and 1 or (product.ProductType == "Crate" and product.CrateId == "KnightBruteCrate" and 2 or (product.ProductType == "Bundle" and product.ProductId == ProductId.PLASMA_TITAN_BUNDLE and 3 or (product.ProductType == "Bundle" and product.ProductId == ProductId.SPACEMAN and 4 or (product.ProductType == "Bundle" and product.ProductId == ProductId.DWARVEN and 5 or (product.ProductType == "Bundle" and product.ProductId == ProductId.CRUSADER and 6 or (product.ProductType == "Gems" and 7 or nil)))))))
end
return {
	["CosmeticsShopGui"] = function(_)
		local selectedShopProductData = useGlobalStore("SelectedShopProductData")
		local profile = useProfile()
		local seasonData = profile.Season.SeasonData[CurrentSeason]
		local ownsPremium: boolean = profile.Season.OwnedPasses[CurrentSeason] ~= nil
		local cameraViewport = useContext(CameraViewportContext)
		local sidebarRef = useRef()
		local contentFrameRef = useRef()
		local scrollingFrameRef = useRef()
		local gemsListRef = useRef()
		local selectedProduct, setSelectedProduct = useState({
			["ProductType"] = "undefined"
		})
		local lastSelectionTime: number = useState(os.clock())
		local previousSelectedProduct = usePrevious(selectedProduct)
		local gamblingAllowed: boolean = Flamework.resolveDependency("D8k"):getPolicyInfo() == nil and true or Flamework.resolveDependency("D8k"):allowsGambling()
		useEffect(function()
			setSelectedProduct(selectedShopProductData)
		end, { selectedShopProductData })
		useEffect(function()
			local sidebarFrame = sidebarRef.current
			local contentFrame = contentFrameRef.current
			local scrollingFrame = scrollingFrameRef.current
			if not (sidebarFrame and (contentFrame and scrollingFrame)) then
				return nil
			end
			ScheduleUtil.runTask(function()
				local rowIndex = getRow(selectedProduct)
				if rowIndex ~= nil then
					if rowIndex >= 1 and not gamblingAllowed then
						rowIndex = rowIndex - 1
					end
					local targetOffset = rowIndex * 300 + 150 - 484
					local clampedOffset = math.max(targetOffset, 0)
					local maxScrollOffset = scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.Size.Y.Offset
					local scrollOffset = math.min(clampedOffset, maxScrollOffset)
					local targetCanvasPosition = Vector2.new(0, scrollOffset) * cameraViewport.Scale
					local positionDelta = targetCanvasPosition.Y - scrollingFrame.CanvasPosition.Y
					if math.abs(positionDelta) > 5 then
						local tween = TweenService:Create(scrollingFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							["CanvasPosition"] = targetCanvasPosition
						})
						tween:Play()
						tween.Completed:Wait()
					end
				end
				if selectedProduct.ProductType == "undefined" and previousSelectedProduct.ProductType == "undefined" then
					sidebarFrame.Visible = false
					return nil
				elseif selectedProduct.ProductType == "undefined" or previousSelectedProduct.ProductType == "undefined" then
					local hasSelection = selectedProduct.ProductType ~= "undefined"
					local anchorPoint = Vector2.new(hasSelection and 0 or 0.5, 0)
					local productSelected = selectedProduct.ProductType ~= "undefined"
					local tweenProperties = {
						["AnchorPoint"] = anchorPoint,
						["Position"] = UDim2.new(0.5, productSelected and -383 or 0, 0, 0)
					}
					local positionTween = TweenService:Create(contentFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), tweenProperties)
					if selectedProduct.ProductType == "undefined" then
						local fadeTween = TweenUtil.fadeOutAsync(sidebarFrame, 0.1)
						local completed = fadeTween.Completed
						if completed ~= nil then
							completed:Wait()
						end
						positionTween:Play()
						sidebarFrame.Visible = false
						TweenUtil.restoreTween(fadeTween)
					else
						sidebarFrame.Visible = false
						local fadeTween = TweenUtil.fadeOutAsync(sidebarFrame, 0)
						positionTween:Play()
						positionTween.Completed:Wait()
						sidebarFrame.Visible = true
						TweenUtil.restoreTween(fadeTween, 0.1)
					end
				else
					return nil
				end
			end)
		end, { selectedProduct })
		local shopContextValue = {
			["SelectedProductData"] = selectedProduct,
			["SetSelectedProductData"] = function(product)
				if TimeUtil.elapsed(lastSelectionTime, 0.2) then
					setSelectedProduct(product)
					Flamework.resolveDependency("jL9"):playSound(RobloxSound.Button.DOWN)
				end
			end,
			["Purchase"] = function(gameProductId, purchaseType, cosmeticId)
				return Flamework.resolveDependency("YOK"):promptPurchase(gameProductId, purchaseType, cosmeticId)
			end
		}
		local createElement = React.createElement
		local Provider = ShopContext.Provider
		local providerProps = {
			["value"] = shopContextValue
		}
		local createElement = React.createElement
		local fullscreenWindow = FullscreenWindow
		local windowProps = {
			["key"] = "CosmeticsShopGui",
			["Text"] = "SHOP",
			["TopBarChildren"] = nil
		}
		local createElement = React.createElement
		local Fragment = React.Fragment
		local fragmentProps = nil
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
		windowProps.TopBarChildren = createElement(Fragment, fragmentProps, topBarChildren)
		local sidebarElement = React.createElement(CosmeticsShopSidebar, {
			["Position"] = UDim2.new(0.5, -837, 0, 0),
			["SeasonData"] = seasonData,
			["OwnsPremium"] = ownsPremium,
			["FrameRef"] = sidebarRef
		})
		local createElement = React.createElement
		local scrollingFrameComponent = ScrollingFrame
		local scrollingFrameProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["CanvasHeight"] = nil,
			["ZIndex"] = 2,
			["ListLayout"] = nil,
			["Ref"] = nil,
			["FrameRef"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 0),
			["Size"] = UDim2.new(0, 1220, 1, 0),
			["CanvasHeight"] = ScreenUtil.getGridSize(280, 20, gamblingAllowed and 8 or 6),
			["ListLayout"] = {
				["Padding"] = UDim.new(0, 20),
				["FillDirection"] = Enum.FillDirection.Vertical
			},
			["Ref"] = scrollingFrameRef,
			["FrameRef"] = contentFrameRef
		}
		local seasonPassElement = React.createElement(SeasonPassShopItem, {
			["SeasonPassTier"] = nil,
			["OwnsPremium"] = nil,
			["Color"] = nil,
			["LayoutOrder"] = 1,
			["SeasonPassTier"] = SeasonUtil.getTier(seasonData.Experience),
			["OwnsPremium"] = ownsPremium,
			["Color"] = Color.Shop.SeasonPass
		})
		local crateElements
		if gamblingAllowed then
			crateElements = React.createElement(React.Fragment, nil, React.createElement(CrateShopList, {
				["CrateId"] = "NinjaCrate",
				["Color"] = nil,
				["LayoutOrder"] = 2,
				["Color"] = Color.Shop.Crate
			}), React.createElement(CrateShopList, {
				["CrateId"] = "KnightBruteCrate",
				["Color"] = nil,
				["LayoutOrder"] = 3,
				["Color"] = Color.Shop.Crate
			}))
		else
			crateElements = nil
		end
		return createElement(Provider, providerProps, createElement(fullscreenWindow, windowProps, sidebarElement, createElement(scrollingFrameComponent, scrollingFrameProps, seasonPassElement, crateElements, React.createElement(BundleShopItem, {
			["ProductId"] = nil,
			["Color"] = nil,
			["LayoutOrder"] = 4,
			["ProductId"] = ProductId.PLASMA_TITAN_BUNDLE,
			["Color"] = Color.Shop.Bundle
		}), React.createElement(BundleShopItem, {
			["ProductId"] = nil,
			["Color"] = nil,
			["LayoutOrder"] = 5,
			["ProductId"] = ProductId.SPACEMAN,
			["Color"] = Color.Shop.Bundle
		}), React.createElement(BundleShopItem, {
			["ProductId"] = nil,
			["Color"] = nil,
			["LayoutOrder"] = 6,
			["ProductId"] = ProductId.DWARVEN,
			["Color"] = Color.Shop.Bundle
		}), React.createElement(BundleShopItem, {
			["ProductId"] = nil,
			["Color"] = nil,
			["LayoutOrder"] = 7,
			["ProductId"] = ProductId.CRUSADER,
			["Color"] = Color.Shop.Bundle
		}), React.createElement(GemsShopList, {
			["LayoutOrder"] = 7,
			["FrameRef"] = nil,
			["FrameRef"] = gemsListRef
		}))))
	end
}
