-- SeasonPassRewardsList

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useEffect = React.useEffect
local useRef = React.useRef
local SeasonPass = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass")
local SeasonPassRewards = SeasonPass.SeasonPassRewards
local SortedSeasonPassRewards = SeasonPass.SortedSeasonPassRewards
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local Stepper = RuntimeLib.import(script, script.Parent.Parent, "components", "stepper", "stepper").Stepper
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local SeasonUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-util").SeasonUtil
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local CameraViewportContext =
	RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext

type SeasonPassRewardsListProps = {
	ItemSize: Vector2,
	Padding: number,
	SelectedTierId: number,
	SeasonPassExperience: number,
	FrameSize: Vector2,
	DisableScrolling: boolean?,
	AnchorPoint: Vector2,
	Position: UDim2,
	StepperHeight: number,
	SetSelectedTierId: ((tierId: number) -> ())?,
}

type SeasonPassReward = {
	Type: string,
	CosmeticId: number?,
	Quantity: number?,
	Tier: number,
	Premium: boolean,
}

return {
	["SeasonPassRewardsList"] = function(props: SeasonPassRewardsListProps)
		local viewportContext = useContext(CameraViewportContext)
		local scrollingFrameRef = useRef()
		local hasScrolledRef = useRef(false)
		local rewardCount = 0
		for _ in SeasonPassRewards do
			rewardCount = rewardCount + 1
		end
		local itemsWidth = rewardCount * props.ItemSize.X
		local tierCount = 0
		for _ in SeasonPassRewards do
			tierCount = tierCount + 1
		end
		local canvasWidth = itemsWidth + (tierCount - 1) * props.Padding
		local selectedTierIndex = -1
		for index, reward in SortedSeasonPassRewards do
			local _ = index - 1
			if reward.Tier == props.SelectedTierId == true then
				selectedTierIndex = index - 1
				break
			end
		end
		local seasonProgress = SeasonUtil.getTier(props.SeasonPassExperience)
			+ SeasonUtil.getProgressDecimal(props.SeasonPassExperience)
		useEffect(function()
			if not scrollingFrameRef.current then
				return nil
			end
			if hasScrolledRef.current then
				TweenService:Create(scrollingFrameRef.current, TweenInfo.new(0.2), {
					["CanvasPosition"] = Vector2.new(
						selectedTierIndex * (props.ItemSize.X + props.Padding)
							+ (props.ItemSize.X + props.Padding) / 2
							- props.FrameSize.X / 2,
						0
					) * viewportContext.Scale,
				}):Play()
				return nil
			end
			hasScrolledRef.current = true
			scrollingFrameRef.current.CanvasPosition = Vector2.new(
				selectedTierIndex * (props.ItemSize.X + props.Padding)
					+ (props.ItemSize.X + props.Padding) / 2
					- props.FrameSize.X / 2,
				0
			) * viewportContext.Scale
		end, { scrollingFrameRef.current, selectedTierIndex })
		local disableScrolling = props.DisableScrolling == true
		local uiPadding = React.createElement("uipadding", {
			["PaddingLeft"] = UDim.new(0, props.Padding / 2),
			["PaddingRight"] = UDim.new(0, props.Padding / 2),
		})
		local selectedCosmetic = React.createElement(
			Grid,
			{
				["key"] = "SelectedCosmetic",
				["BackgroundTransparency"] = 0.4,
				["ZIndex"] = 0,
				["AnchorPoint"] = Vector2.new(0, 1),
				["Position"] = UDim2.new(
					0,
					-(props.Padding / 2) + selectedTierIndex * (props.ItemSize.X + props.Padding),
					1,
					-16
				),
				["Size"] = UDim2.fromOffset(
					props.ItemSize.X + props.Padding,
					props.ItemSize.Y + 10 + props.StepperHeight + 10
				),
				["BackgroundColor3"] = Color.White,
			},
			React.createElement("uigradient", {
				["Rotation"] = 270,
				["Color"] = ColorSequence.new(Color.White, Color3.fromRGB(155, 243, 255)),
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(1, 1, 0),
				}),
			}),
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
		local rewardElements = table.create(#SortedSeasonPassRewards)
		local function renderRewardSlot(reward: SeasonPassReward)
			local cosmeticId
			if reward.Type == "Cosmetic" then
				cosmeticId = reward.CosmeticId
			else
				cosmeticId = nil
			end
			local gemsReward
			if reward.Type == "Gems" then
				gemsReward = reward.Quantity
			else
				gemsReward = nil
			end
			return React.createElement(CosmeticSlot, {
				["ActivateReroute"] = true,
				["key"] = cosmeticId,
				["Size"] = props.ItemSize,
				["CosmeticId"] = cosmeticId,
				["GemsReward"] = gemsReward,
				["Locked"] = seasonProgress < reward.Tier,
				["SeasonPassPremium"] = reward.Premium,
				["Activated"] = function()
					if props.SetSelectedTierId then
						props.SetSelectedTierId(reward.Tier)
					end
				end,
				["LayoutOrder"] = reward.Tier,
			})
		end
		for index, reward in SortedSeasonPassRewards do
			rewardElements[index] = renderRewardSlot(reward, index - 1, SortedSeasonPassRewards)
		end
		local rewardsGrid = React.createElement(
			Grid,
			nil,
			rewardElements,
			React.createElement(List, {
				["Padding"] = UDim.new(0, props.Padding),
				["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
				["VerticalAlignment"] = Enum.VerticalAlignment.Top,
			})
		)
		local stepperProps = {
			["Position"] = UDim2.fromOffset(props.ItemSize.X / 2 - props.StepperHeight / 2, props.ItemSize.Y + 6),
		}
		local stepperLength = 0
		for _ in SeasonPassRewards do
			stepperLength = stepperLength + 1
		end
		stepperProps.Length = stepperLength
		local progressCap = 0
		for _ in SeasonPassRewards do
			progressCap = progressCap + 1
		end
		stepperProps.Progress = math.min(seasonProgress, progressCap)
		stepperProps.BarSize =
			Size.new(props.ItemSize.X + props.Padding - props.StepperHeight, 0.26666666666666666 * props.StepperHeight)
		stepperProps.CircleSize = props.StepperHeight
		return React.createElement("scrollingframe", {
			["key"] = "RewardList",
			["BackgroundTransparency"] = 1,
			["BorderSizePixel"] = 0,
			["Selectable"] = false,
			["ZIndex"] = 2,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.FrameSize:ToUDim2(),
			["CanvasSize"] = UDim2.fromOffset(canvasWidth + props.Padding, props.FrameSize.Y),
			["ScrollingEnabled"] = not disableScrolling,
			["ScrollBarImageTransparency"] = disableScrolling and 1 or 0,
			["ScrollingDirection"] = Enum.ScrollingDirection.X,
			["ScrollBarThickness"] = disableScrolling and 0 or 6,
			["ScrollBarImageColor3"] = Color.White,
			["ref"] = scrollingFrameRef,
		}, uiPadding, selectedCosmetic, rewardsGrid, React.createElement(Stepper, stepperProps))
	end,
}
