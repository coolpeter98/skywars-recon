-- CrateRewardsGui

type CrateRewardsGuiProps = {
	CrateRewardResults: { any },
}

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
local CrateRewardResultType =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").CrateRewardResultType
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local CrateUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crate-util").CrateUtil
local RobloxSound =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-sound").RobloxSound
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
return {
	["CrateRewardsGui"] = function(props: CrateRewardsGuiProps)
		local profile = useProfile()
		local currentIndex: number, setCurrentIndex = useState(Flamework.resolveDependency("wm8"):getCurrentIndex())
		local reward = props.CrateRewardResults[currentIndex + 1]
		local displayName: string = CrateUtil.getDisplayName(reward)
		local rarity = CosmeticRarities[CrateUtil.getRarity(reward)]
		local isDuplicate: boolean = reward.Type == CrateRewardResultType.Duplicate
		local counterTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Text"] = ("%* / %*"):format(currentIndex + 1, #props.CrateRewardResults),
		})
		local titleTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 48,
			["Bold"] = true,
			["Text"] = displayName,
		})
		local rarityTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 20,
			["Bold"] = true,
			["Text"] = string.upper(rarity.Id),
		})
		local duplicateTextProps
		if isDuplicate then
			duplicateTextProps = getTextProps({
				["Text"] = nil,
				["TextSize"] = 20,
				["Bold"] = true,
				["Text"] = ("Duplicate! +%* Gems"):format(reward.GemsQuantity),
			})
		else
			duplicateTextProps = nil
		end
		local canGoBack: boolean = currentIndex > 0
		local canGoForward: boolean = currentIndex < #props.CrateRewardResults - 1
		local isEquipped: boolean = Flamework.resolveDependency("Ggz"):isActive(reward.CosmeticId, profile.Cosmetics)
		local counterTextElementProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		for key, value in counterTextProps do
			counterTextElementProps[key] = value
		end
		local counterElement = React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 100,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 34),
			["Size"] = UDim2.fromOffset(counterTextProps.Size.X.Offset + 48, 44),
		}, React.createElement(Text, counterTextElementProps))
		local rarityTextElementProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		for key, value in rarityTextProps do
			rarityTextElementProps[key] = value
		end
		local rarityElement = React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundColor3"] = nil,
			["CornerRadius"] = 100,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 98),
			["Size"] = UDim2.fromOffset(rarityTextProps.Size.X.Offset + 24, 36),
			["BackgroundColor3"] = rarity.Color,
		}, React.createElement(Text, rarityTextElementProps))
		local titleTextElementProps = {
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
		}
		for key, value in titleTextProps do
			titleTextElementProps[key] = value
		end
		local titleElement = React.createElement(Grid, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 100,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 154),
			["Size"] = UDim2.fromOffset(titleTextProps.Size.X.Offset + 60, 88),
		}, React.createElement(Text, titleTextElementProps))
		local duplicateElement
		if duplicateTextProps then
			local duplicateTextElementProps = {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
			}
			for key, value in duplicateTextProps do
				duplicateTextElementProps[key] = value
			end
			duplicateElement = React.createElement(Grid, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["BackgroundColor3"] = nil,
				["CornerRadius"] = 100,
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 262),
				["Size"] = UDim2.fromOffset(duplicateTextProps.Size.X.Offset + 24, 36),
				["BackgroundColor3"] = rarity.Color,
			}, React.createElement(Text, duplicateTextElementProps))
		else
			duplicateElement = nil
		end
		local createElement = React.createElement
		local Fragment = React.Fragment
		local fragmentProps = nil
		local backButton
		if canGoBack then
			backButton = React.createElement(Button, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Icon"] = nil,
				["IconRotation"] = 180,
				["Activated"] = nil,
				["AnchorPoint"] = Vector2.new(1, 0.5),
				["Position"] = UDim2.new(0.5, -260, 0.5, 0),
				["Size"] = { 96, 96 },
				["Icon"] = RobloxImage.NEXT_ARROW,
				["Activated"] = function()
					local previousIndex: number? = Flamework.resolveDependency("wm8"):previous()
					if previousIndex ~= nil then
						setCurrentIndex(previousIndex)
					end
				end,
			})
		else
			backButton = nil
		end
		local nextButton
		if canGoForward then
			nextButton = React.createElement(Button, {
				["AnchorPoint"] = Vector2.new(0, 0.5),
				["Position"] = UDim2.new(0.5, 260, 0.5, 0),
				["Size"] = { 96, 96 },
				["Icon"] = RobloxImage.NEXT_ARROW,
				["Activated"] = function()
					local nextIndex: number? = Flamework.resolveDependency("wm8"):next()
					if nextIndex ~= nil then
						setCurrentIndex(nextIndex)
					end
				end,
			})
		else
			nextButton = nil
		end
		return createElement(
			Fragment,
			fragmentProps,
			counterElement,
			rarityElement,
			titleElement,
			duplicateElement,
			backButton,
			nextButton,
			React.createElement(Button, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = nil,
				["Disabled"] = nil,
				["Muted"] = true,
				["Activated"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, -104, 1, -32),
				["Size"] = { 188, 50 },
				["Text"] = isEquipped and "Equipped" or "Equip",
				["Disabled"] = isEquipped,
				["Activated"] = function()
					Flamework.resolveDependency("jL9"):playSound(RobloxSound.Inventory.MOVE_ITEM, {
						["Volume"] = 1,
					})
					Flamework.resolveDependency("Ggz"):enableCosmetic(reward.CosmeticId)
				end,
			}),
			React.createElement(Button, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = "Exit",
				["Activated"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 104, 1, -32),
				["Size"] = { 188, 50 },
				["Activated"] = function()
					Flamework.resolveDependency("dyD"):stopAnimation()
				end,
			})
		)
	end,
}
