-- EndGameGui

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CurrentSeason =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "season", "season-pass").CurrentSeason
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local EndGameShop = RuntimeLib.import(script, script.Parent, "end-game-shop").EndGameShop
local TweenUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "tween-util").TweenUtil
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local EndGameStats = RuntimeLib.import(script, script.Parent, "end-game-stats").EndGameStats
local EndGameSeasonPass = RuntimeLib.import(script, script.Parent, "end-game-season-pass").EndGameSeasonPass
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store")
local useGlobalStore = GlobalStore.useGlobalStore
local useProfile = GlobalStore.useProfile
local ObjectUtils = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"object-utils"
)

type AnimationHandle = {
	Frame: GuiObject,
	Play: (duration: number) -> (),
	Completed: () -> boolean,
}

local PANEL_OFFSET = UDim2.fromOffset(50, 0)
local setupAnimation: ((frame: GuiObject, delay: number, direction: string) -> AnimationHandle)? = nil

local function EndGameGui(props)
	local profile = useProfile()
	local gameStats = useGlobalStore("GameStats")
	local seasonData = profile.Season.SeasonData[CurrentSeason]
	local ownsPremium = profile.Season.OwnedPasses[CurrentSeason] ~= nil
	ArrayUtil.sum(ObjectUtils.values(gameStats.ExperienceMap))
	local statsRef = useRef()
	local seasonPassRef = useRef()
	local shopRef = useRef()
	local animationsRef = useRef({})
	local _, setAnimationsComplete = useState(false)
	useEffect(function()
		local statsAnimation = statsRef.current
		local seasonPassAnimation = seasonPassRef.current
		local shopAnimation = shopRef.current
		local animations = animationsRef
		local filterDefined = ArrayUtil.filterDefined
		local animationList = {}
		if statsAnimation then
			statsAnimation = setupAnimation(statsAnimation, 0, "left")
		end
		if seasonPassAnimation then
			seasonPassAnimation = setupAnimation(seasonPassAnimation, 1, "left")
		end
		if shopAnimation then
			shopAnimation = setupAnimation(shopAnimation, 2, "right")
		end
		__set_list(animationList, 1, { statsAnimation, seasonPassAnimation, shopAnimation })
		animations.current = filterDefined(animationList)
		task.spawn(function()
			task.wait(#animationsRef.current * 1)
			setAnimationsComplete(true)
		end)
	end, {})
	return React.createElement(
		Grid,
		{
			["key"] = "GameResults",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.new(0.5, 0, 0.5, ScreenUtil.isMobile() and -40 or 30),
			["Size"] = UDim2.fromOffset(1242, 520),
		},
		React.createElement(EndGameStats, {
			["Position"] = nil,
			["Winner"] = nil,
			["GameEnded"] = nil,
			["Visible"] = false,
			["FrameRef"] = nil,
			["Position"] = UDim2.fromOffset(0, 0) + PANEL_OFFSET,
			["Winner"] = props.Winner,
			["GameEnded"] = props.GameEnded,
			["FrameRef"] = statsRef,
		}),
		React.createElement(EndGameSeasonPass, {
			["Position"] = nil,
			["Profile"] = nil,
			["SeasonData"] = nil,
			["OwnsPremium"] = nil,
			["Visible"] = false,
			["FrameRef"] = nil,
			["Position"] = UDim2.fromOffset(300, 0) + PANEL_OFFSET,
			["Profile"] = profile,
			["SeasonData"] = seasonData,
			["OwnsPremium"] = ownsPremium,
			["FrameRef"] = seasonPassRef,
		}),
		React.createElement(EndGameShop, {
			["Position"] = nil,
			["OwnedProducts"] = nil,
			["Visible"] = false,
			["FrameRef"] = nil,
			["Position"] = UDim2.fromOffset(700, 0) - PANEL_OFFSET,
			["OwnedProducts"] = profile.OwnedProducts,
			["FrameRef"] = shopRef,
		})
	)
end
local function tweenPosition(frame: GuiObject, targetPosition: UDim2, duration: number): Tween
	local tween =
		TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			["Position"] = targetPosition,
		})
	tween:Play()
	return tween
end
setupAnimation = function(frame: GuiObject, delay: number, direction: string): AnimationHandle
	local completed = false
	local function play(duration: number)
		local fadeTween = TweenUtil.fadeOutAsync(frame, 0)
		local completedEvent = fadeTween.Completed
		if completedEvent ~= nil then
			completedEvent:Connect(function()
				frame.Visible = true
				return frame.Visible
			end)
		end
		TweenUtil.restoreTween(fadeTween, duration)
		local targetPosition
		if direction == "left" then
			targetPosition = frame.Position - PANEL_OFFSET
		else
			targetPosition = frame.Position + PANEL_OFFSET
		end
		tweenPosition(frame, targetPosition, duration).Completed:Connect(function()
			completed = true
		end)
	end
	task.spawn(function()
		task.wait(delay)
		if completed then
			return nil
		end
		play(0.5)
	end)
	return {
		["Frame"] = frame,
		["Play"] = play,
		["Completed"] = function()
			return completed
		end,
	}
end
return {
	["EndGameGui"] = EndGameGui,
}
