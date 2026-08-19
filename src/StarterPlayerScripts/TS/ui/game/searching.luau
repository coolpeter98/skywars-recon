-- Searching

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
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CircularProgress =
	RuntimeLib.import(script, script.Parent.Parent, "components", "circular-progress").CircularProgress
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").GlobalStore
local PartyUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "party", "party-instance").PartyUtil
local PlayerUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "player-util").PlayerUtil
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local useScreenDependency =
	RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-screen-dependency").useScreenDependency
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type SearchingProps = {
	QueueStartTime: number?,
	InLobby: boolean,
	HasGameEnded: boolean,
	Party: unknown,
}

local startCountdown

local function Searching(props: SearchingProps)
	local searchingTextRef = useRef()
	local timerTextRef = useRef()
	local screenDependency = useScreenDependency({
		["ScreenId"] = "EndGame",
	})
	useEffect(function()
		if searchingTextRef.current and timerTextRef.current then
			local maid = Maid.new()
			if props.QueueStartTime == nil then
				maid:DoCleaning()
				return nil
			else
				startCountdown(maid, searchingTextRef.current, timerTextRef.current, props.QueueStartTime)
				return function()
					return maid:DoCleaning()
				end
			end
		else
			return nil
		end
	end, { searchingTextRef.current, timerTextRef.current, props.QueueStartTime })
	local createElement = React.createElement
	local grid = Grid
	local gridProps = {
		["key"] = "Searching",
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Size"] = nil,
		["BackgroundTransparency"] = 0.6,
		["AnchorPoint"] = Vector2.new(0.5, 0),
	}
	local udim2New = UDim2.new
	local xScale = 0.5
	local xOffset = 0
	local yScale = 0
	local yOffset
	if props.InLobby then
		yOffset = 208
	elseif screenDependency.IsOpen then
		yOffset = ScreenUtil.isMobile() and 10 or 198
	else
		yOffset = props.HasGameEnded and 198 or 258
	end
	gridProps.Position = udim2New(xScale, xOffset, yScale, yOffset)
	gridProps.Size = UDim2.fromOffset(500, 80)
	return createElement(
		grid,
		gridProps,
		createElement(CircularProgress, {
			["Position"] = UDim2.fromOffset(20, 20),
			["Size"] = UDim2.fromOffset(40, 40),
			["Color"] = Color.White,
		}),
		createElement(Text, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Searching for a game",
			["TextXAlignment"] = nil,
			["Bold"] = true,
			["Ref"] = nil,
			["Position"] = UDim2.fromOffset(80, 10),
			["Size"] = UDim2.fromOffset(262, 24),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["Ref"] = searchingTextRef,
		}),
		createElement(Image, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromOffset(80, 57),
			["Size"] = UDim2.fromOffset(26, 26),
			["Image"] = RobloxImage.Icon.FONTAWESOME_CLOCK,
		}),
		createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["AutomaticSize"] = nil,
			["Text"] = "00:00",
			["TextXAlignment"] = nil,
			["Bold"] = true,
			["Ref"] = nil,
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromOffset(115, 57),
			["Size"] = UDim2.fromOffset(262, 24),
			["AutomaticSize"] = Enum.AutomaticSize.None,
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["Ref"] = timerTextRef,
		}),
		createElement(Button, {
			["AbsorbInput"] = true,
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Cancel",
			["Color"] = nil,
			["Activated"] = nil,
			["Disabled"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -20, 0.5, 0),
			["Size"] = { 118, 40 },
			["Color"] = Color.Button.Red,
			["Activated"] = function()
				Flamework.resolveDependency("MMv"):leaveQueue()
			end,
			["Disabled"] = not PartyUtil.canQueue(PlayerUtil.toReplicated(Players.LocalPlayer), props.Party),
		}),
		createElement(CornerRadius, {
			["Radius"] = 10,
		})
	)
end

local getQueueText

startCountdown = function(maid, searchingLabel: TextLabel, timerLabel: TextLabel, queueStartTime: number)
	local queueStarted
	if queueStartTime == 0 or (queueStartTime ~= queueStartTime or not queueStartTime) then
		queueStarted = false
	else
		queueStarted = os.time() - queueStartTime >= 0
	end
	local joinedQueue
	if queueStarted and not GlobalStore:getState().QueueServerAcknowledged then
		Flamework.resolveDependency("MMv"):joinQueue()
		joinedQueue = true
	else
		joinedQueue = false
	end
	maid:GiveTask(RunService.Heartbeat:Connect(function()
		if queueStartTime == 0 or (queueStartTime ~= queueStartTime or not queueStartTime) then
			return nil
		end
		local elapsed = os.time() - queueStartTime
		local queueText = getQueueText(queueStartTime)
		local mainText = queueText[1]
		local timeText = queueText[2]
		searchingLabel.Text = mainText
		timerLabel.Text = timeText
		if queueStarted or (joinedQueue or elapsed < 0) then
			return nil
		end
		Flamework.resolveDependency("MMv"):joinQueue()
		joinedQueue = true
	end))
end

getQueueText = function(queueStartTime: number): { string }
	local elapsed = os.time() - queueStartTime
	local totalMinutes = math.abs(elapsed) / 60
	local minutes = math.floor(totalMinutes)
	local seconds = math.abs(elapsed) % 60
	local formattedTime = string.format("%.02d:%.02d", minutes, seconds)
	return elapsed < 0 and { "Joining queue in", formattedTime } or { "Searching for a game", formattedTime }
end

return {
	["Searching"] = Searching,
}
