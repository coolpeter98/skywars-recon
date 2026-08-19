-- OpenCrate

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics
local GradientCard = RuntimeLib.import(script, script.Parent.Parent, "components", "gradient-card").GradientCard
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local CosmeticRarities = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "cosmetic-rarity").CosmeticRarities
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local CosmeticViewport = RuntimeLib.import(script, script.Parent.Parent, "viewport", "cosmetic-viewport").CosmeticViewport
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Badge = RuntimeLib.import(script, script.Parent.Parent, "components", "badge").Badge
local NumberInput = RuntimeLib.import(script, script.Parent.Parent, "components", "number-input").NumberInput
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Price = RuntimeLib.import(script, script.Parent.Parent, "components", "price").Price
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState

type OpenCrateProps = {
	CrateId: string,
	AnchorPoint: Vector2,
	Position: UDim2,
}

type CrateReward = {
	CosmeticId: string?,
	Probability: number,
}

return {
	["OpenCrate"] = function(props: OpenCrateProps)
		local crate = Crates[props.CrateId]
		local rowCount = #crate.Rewards / 5
		local rows = math.ceil(rowCount)
		local gridSize = ScreenUtil.getGridSize(210, 10, rows)
		local _, setQuantity = useState(1)
		local gridElement = React.createElement(Grid, {
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["CornerRadius"] = 10,
			["Position"] = UDim2.fromOffset(30, 64),
			["Size"] = UDim2.fromOffset(1120, 240)
		}, React.createElement(Text, {
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 36,
			["Bold"] = true,
			["Position"] = UDim2.fromOffset(20, 20),
			["Text"] = crate.DisplayName
		}), React.createElement(Text, {
			["Position"] = nil,
			["Text"] = nil,
			["TextSize"] = 24,
			["Position"] = UDim2.fromOffset(20, 76),
			["Text"] = crate.Description
		}), React.createElement(NumberInput, {
			["Position"] = nil,
			["MinValue"] = 1,
			["ValueChanged"] = nil,
			["Position"] = UDim2.fromOffset(20, 120),
			["ValueChanged"] = function(value: number)
				return setQuantity(value)
			end
		}), React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Color"] = nil,
			["Text"] = "Open",
			["TextSize"] = 48,
			["Icon"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(220, 120),
			["Size"] = { 285, 100 },
			["Color"] = Color.Button.Green,
			["Icon"] = RobloxImage.Icon.KEY,
			["Activated"] = function()
			end
		}), React.createElement(Price, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromOffset(525, 170)
		}), React.createElement(Image, {
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, 0, 0.5, 0),
			["Size"] = UDim2.fromOffset(200, 200),
			["Image"] = crate.Image
		}))
		local rewards = crate.Rewards
		local rewardElements = table.create(#rewards)
		local function createRewardElement(reward: CrateReward, index: number)
			local cosmetic = Cosmetics[reward.CosmeticId]
			local cardProps = {
				["key"] = index,
				["Size"] = Size.new(210, 210),
				["Color"] = CosmeticRarities[cosmetic.Rarity].Color,
				["StrokeThickness"] = 10,
				["CornerRadius"] = 10,
				["ScalingDisabled"] = true,
				["FooterHeight"] = 0,
				["FooterComponent"] = React.createElement(React.Fragment),
				["LayoutOrder"] = reward.Probability
			}
			local createElement = React.createElement
			local badge = Badge
			local badgeProps = {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Text"] = nil,
				["TextSize"] = 14,
				["Color"] = nil,
				["ZIndex"] = 5,
				["LayoutOrder"] = 1,
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.new(1, -10, 0, 10)
			}
			local probability = reward.Probability * 1000
			badgeProps.Text = ("%*%%"):format(math.round(probability) / 10)
			badgeProps.Color = Color.LightGrey
			local badgeElement = createElement(badge, badgeProps)
			local itemNameProps = {
				["key"] = "ItemNameText",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["TextWrapped"] = true,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -10)
			}
			for key, value in getTextProps({
				["Text"] = nil,
				["TextSize"] = 20,
				["Bold"] = true,
				["FrameSize"] = nil,
				["Text"] = cosmetic.Name,
				["FrameSize"] = Vector2.new(210, 210)
			}) do
				itemNameProps[key] = value
			end
			itemNameProps.ZIndex = 5
			local itemNameElement = createElement(Text, itemNameProps)
			local image = cosmetic.Image
			local createElement = React.createElement
			local gradientCard = GradientCard
			local mediaElement
			if image == "" or not image then
				mediaElement = createElement(CosmeticViewport, {
					["key"] = "CosmeticViewport",
					["Position"] = nil,
					["Size"] = nil,
					["CosmeticId"] = nil,
					["ZIndex"] = 5,
					["Position"] = UDim2.fromOffset(0, 20),
					["Size"] = UDim2.fromScale(1, 1),
					["CosmeticId"] = cosmetic.Id
				})
			else
				mediaElement = createElement(Image, {
					["key"] = "CosmeticImage",
					["Size"] = nil,
					["Image"] = nil,
					["ZIndex"] = 5,
					["ScaleType"] = nil,
					["Size"] = UDim2.fromScale(1, 1),
					["Image"] = cosmetic.Image,
					["ScaleType"] = Enum.ScaleType.Crop
				})
			end
			return createElement(gradientCard, cardProps, badgeElement, itemNameElement, mediaElement)
		end
		for index, reward in rewards do
			rewardElements[index] = createRewardElement(reward, index - 1, rewards)
		end
		return React.createElement(Window, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleImage"] = nil,
			["TitleText"] = "CRATES",
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1180, 710),
			["TitleImage"] = RobloxImage.Icon.SHOPPING_CART
		}, gridElement, React.createElement("scrollingframe", {
			["Position"] = nil,
			["Size"] = nil,
			["CanvasSize"] = nil,
			["ScrollingDirection"] = nil,
			["ScrollBarThickness"] = 10,
			["ScrollBarImageColor3"] = nil,
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["Position"] = UDim2.fromOffset(30, 324),
			["Size"] = UDim2.fromOffset(1120, 356),
			["CanvasSize"] = UDim2.fromOffset(0, gridSize),
			["ScrollingDirection"] = Enum.ScrollingDirection.Y,
			["ScrollBarImageColor3"] = Color.White
		}, rewardElements, React.createElement("uigridlayout", {
			["key"] = "GridLayout",
			["FillDirection"] = nil,
			["FillDirectionMaxCells"] = 5,
			["CellPadding"] = nil,
			["CellSize"] = nil,
			["VerticalAlignment"] = nil,
			["HorizontalAlignment"] = nil,
			["SortOrder"] = nil,
			["FillDirection"] = Enum.FillDirection.Horizontal,
			["CellPadding"] = UDim2.fromOffset(10, 10),
			["CellSize"] = UDim2.fromOffset(210, 210),
			["VerticalAlignment"] = Enum.VerticalAlignment.Top,
			["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		})))
	end
}
