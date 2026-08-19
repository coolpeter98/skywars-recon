-- ShopHomePage

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
local useCallback = React.useCallback
local useContext = React.useContext
local useRef = React.useRef
local useProfile = RuntimeLib.import(script, script.Parent.Parent.Parent, "rodux", "global-store").useProfile
local useWindow = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-window").useWindow
local NewShopContext =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "context", "new-shop-context").NewShopContext
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent.Parent, "screen-constants").ScreenConstants
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local ShopHomeImage = RuntimeLib.import(script, script.Parent.Parent, "components", "shop-home-image").ShopHomeImage
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local getTextProps = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "text-util").getTextProps
local useUpdateLog = RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-update-log").useUpdateLog
local Badge = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "badge").Badge

local PAGE_WIDTH = 1160 + ScreenConstants.PADDING_2 + 680

type TextProps = {
	Text: string,
	TextSize: number,
	Bold: boolean,
	Color: Color3,
	Size: UDim2,
	TextColor3: Color3?,
}

local getCountdownTextProps: ((seconds: number) -> TextProps)?

local function ShopHomePage(_)
	useWindow()
	useProfile()
	local updateLog = useUpdateLog()
	local shopContext = useContext(NewShopContext)
	local countdownRef: { current: TextLabel? } = useRef()

	useCallback(function(seconds: number)
		local countdownLabel = countdownRef.current
		if not countdownLabel then
			return nil
		end
		local textProps = getCountdownTextProps(seconds)
		countdownLabel.Size = textProps.Size
		countdownLabel.Text = textProps.Text
		countdownLabel.TextColor3 = textProps.TextColor3 or Color.White
	end, { countdownRef.current })

	local pageInnerHeight = shopContext.PageSize.Y - ScreenConstants.PADDING_2 * 2
	local seasonPassHeight = pageInnerHeight * 0.6666666666666666 + ScreenConstants.PADDING_2
	local crateHeight = pageInnerHeight * 0.3333333333333333
	local bundleHeight = pageInnerHeight * 0.3333333333333333
	local cratesOffsetX = 1160 + ScreenConstants.PADDING_2
	local bundlesOffsetY = seasonPassHeight + ScreenConstants.PADDING_2
	local secondCrateOffsetY = crateHeight + ScreenConstants.PADDING_2
	local bundleWidth = 450 + ScreenConstants.PADDING_2
	local secondBundleOffsetX = bundleWidth + 450 + ScreenConstants.PADDING_2
	local thirdBundleOffsetX = secondBundleOffsetX + 450 + ScreenConstants.PADDING_2

	local allowsGambling = RunService:IsRunning()
	if allowsGambling then
		allowsGambling = Flamework.resolveDependency("D8k"):allowsGambling()
	end
	local seasonPassWidth = allowsGambling and 1160 or PAGE_WIDTH

	local createElement = React.createElement
	local grid = Grid
	local gridProps = {
		["Position"] = UDim2.fromOffset((shopContext.PageSize.X - PAGE_WIDTH) / 2, 0),
		["Size"] = UDim2.fromOffset(PAGE_WIDTH, shopContext.PageSize.Y),
	}

	local createElement2 = React.createElement
	local shopHomeImage = ShopHomeImage
	local seasonPassProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["Image"] = nil,
		["Text"] = "SEASON PASS",
		["TextSize"] = 72,
		["Color"] = nil,
		["TabId"] = 1,
		["AnchorPoint"] = Vector2.new(0.5, 0.5),
		["Position"] = UDim2.fromOffset(seasonPassWidth / 2, seasonPassHeight / 2),
		["Size"] = UDim2.fromOffset(seasonPassWidth, seasonPassHeight),
		["Image"] = RobloxImage.GameProduct.SEASON_3_RENDER_16_9,
		["TextPosition"] = UDim2.new(0, ScreenConstants.PADDING_3, 0, ScreenConstants.PADDING_2),
		["Color"] = Color.Shop.SeasonPassRed,
	}
	local seasonPassBadge = updateLog.HasUpdated("GAME_PRODUCT_SEASON_PASS_3")
	if seasonPassBadge then
		seasonPassBadge = React.createElement(Badge, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "NEW",
			["TextSize"] = 24,
			["Color"] = nil,
			["Rotation"] = 20,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.new(1, -10, 0, 10),
			["Color"] = Color.Red,
		})
	end
	local seasonPassElement = createElement2(shopHomeImage, seasonPassProps, seasonPassBadge)
	if allowsGambling then
		allowsGambling = React.createElement(
			React.Fragment,
			nil,
			React.createElement(ShopHomeImage, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["Text"] = "NINJA CRATE",
				["TextSize"] = 36,
				["Color"] = nil,
				["TabId"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromOffset(cratesOffsetX + 340, crateHeight / 2),
				["Size"] = UDim2.fromOffset(680, crateHeight),
				["Image"] = RobloxImage.GameProduct.NINJA_RENDER_16_9,
				["Color"] = Color.Shop.NinjaCrate,
			}),
			React.createElement(ShopHomeImage, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["Text"] = "KNIGHT BRUTE CRATE",
				["TextSize"] = 36,
				["Color"] = nil,
				["TabId"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromOffset(cratesOffsetX + 340, secondCrateOffsetY + crateHeight / 2),
				["Size"] = UDim2.fromOffset(680, crateHeight),
				["Image"] = RobloxImage.GameProduct.KNIGHT_RENDER_BRUTE_16_9,
				["Color"] = Color.Shop.KnightBruteCrate,
			})
		)
	end
	local createElement3 = React.createElement
	local shopHomeImage2 = ShopHomeImage
	local plasmaBundleProps = {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["Image"] = nil,
		["Text"] = "PLASMA TITAN BUNDLE",
		["TextSize"] = 36,
		["Color"] = nil,
		["TabId"] = 3,
		["AnchorPoint"] = Vector2.new(0.5, 0.5),
		["Position"] = UDim2.fromOffset(225, bundlesOffsetY + bundleHeight / 2),
		["Size"] = UDim2.fromOffset(450, bundleHeight),
		["Image"] = RobloxImage.GameProduct.PLASMA_TITAN_RENDER_16_9,
		["Color"] = Color.Shop.BundleGreen,
	}
	local plasmaBundleBadge = updateLog.HasUpdated("GAME_PRODUCT_PLASMA_TITAN_BUNDLE")
	if plasmaBundleBadge then
		plasmaBundleBadge = React.createElement(Badge, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "NEW",
			["TextSize"] = 24,
			["Color"] = nil,
			["Rotation"] = 20,
			["ZIndex"] = 5,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.new(1, -10, 0, 10),
			["Color"] = Color.Red,
		})
	end
	return createElement(
		grid,
		gridProps,
		seasonPassElement,
		allowsGambling,
		createElement3(shopHomeImage2, plasmaBundleProps, plasmaBundleBadge),
		React.createElement(ShopHomeImage, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["Text"] = "SPACEMAN BUNDLE",
			["TextSize"] = 36,
			["Color"] = nil,
			["TabId"] = 3,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromOffset(bundleWidth + 225, bundlesOffsetY + bundleHeight / 2),
			["Size"] = UDim2.fromOffset(450, bundleHeight),
			["Image"] = RobloxImage.GameProduct.SPACEMAN_RENDER_16_9,
			["Color"] = Color.Shop.BundleGreen,
		}),
		React.createElement(ShopHomeImage, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["Text"] = "DWARVEN BUNDLE",
			["TextSize"] = 36,
			["Color"] = nil,
			["TabId"] = 3,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromOffset(secondBundleOffsetX + 225, bundlesOffsetY + bundleHeight / 2),
			["Size"] = UDim2.fromOffset(450, bundleHeight),
			["Image"] = RobloxImage.GameProduct.DWARVEN_RENDER_16_9,
			["Color"] = Color.Shop.BundleGreen,
		}),
		React.createElement(ShopHomeImage, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["Text"] = "CRUSADER BUNDLE",
			["TextSize"] = 36,
			["Color"] = nil,
			["TabId"] = 3,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromOffset(thirdBundleOffsetX + 225, bundlesOffsetY + bundleHeight / 2),
			["Size"] = UDim2.fromOffset(450, bundleHeight),
			["Image"] = RobloxImage.GameProduct.CRUSADER_RENDER_16_9,
			["Color"] = Color.Shop.BundleGreen,
		})
	)
end

getCountdownTextProps = function(seconds: number)
	local countdownText = ("\240\159\149\146 ENDING IN %*"):format((string.upper(TimeUtil.formatTime(seconds, true))))
	local roundedText
	if seconds < 86400 then
		local truncateIndex = #countdownText - 2
		roundedText = string.sub(countdownText, 0, truncateIndex) .. "00"
	else
		roundedText = countdownText
	end
	local textProps = getTextProps({
		["Text"] = nil,
		["TextSize"] = 48,
		["Bold"] = true,
		["Color"] = nil,
		["Text"] = roundedText,
		["Color"] = Color.White,
	})
	local clonedProps = table.clone(textProps)
	setmetatable(clonedProps, nil)
	clonedProps.Text = countdownText
	return clonedProps
end

return {
	["ShopHomePage"] = ShopHomePage,
}
