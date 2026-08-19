-- TeamPicker

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local usePicker = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-picker").usePicker
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type Team = {
	Name: string,
	Color: Color3,
	Id: string,
}

type TeamPickerProps = {
	Teams: { Team },
	PlayerTeam: Team,
	OnSelect: (team: Team) -> (),
}

type TeamIcon = {
	Team: Team,
	Offset: number,
	Frame: Frame,
}

type Picker = {
	View: { [Team]: number },
	Index: number,
	Next: () -> Team,
	Previous: () -> Team,
	SetValue: (team: Team) -> (),
}

local ICON_SIZES = { UDim2.fromOffset(26, 26), UDim2.fromOffset(16, 16), UDim2.fromOffset(0, 0) }

local function getPosition(offset: number): UDim2
	return UDim2.new(0.5, 31 * offset, 0.5, 0)
end

local function getSize(offset: number): UDim2
	return ICON_SIZES[math.abs(offset) + 1]
end

local function addStroke(frame: Frame)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color.White
	stroke.Thickness = 2 * ScreenUtil.getScale()
	stroke.Parent = frame
end

local function moveTeamIcon(frame: Frame, offset: number, onComplete: () -> (), onCleanup: () -> ())
	local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = getSize(offset),
		Position = getPosition(offset),
	})
	local connection: RBXScriptConnection?
	connection = tween.Completed:Connect(function(playbackState: Enum.PlaybackState)
		connection:Disconnect()
		if playbackState == Enum.PlaybackState.Completed and offset == 0 then
			onComplete()
		elseif math.abs(offset) > 1 then
			frame:Destroy()
			onCleanup()
		end
	end)
	tween:Play()
end

local function createTeamIcon(team: Team, offset: number): Frame
	local frame = Instance.new("Frame")
	frame.Name = team.Name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = getPosition(offset)
	frame.Size = getSize(offset)
	frame.BackgroundColor3 = team.Color
	local id = team.Id
	frame.BackgroundTransparency = (id == "" or not id) and 1 or 0
	frame.BorderSizePixel = 0
	if id == "" or not id then
		local cancelIcon = Instance.new("ImageLabel")
		cancelIcon.Size = UDim2.fromScale(1, 1)
		cancelIcon.Image = RobloxImage.Icon.CANCEL
		cancelIcon.BackgroundTransparency = 1
		cancelIcon.Parent = frame
	end
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	if offset == 0 then
		addStroke(frame)
	end
	return frame
end

local function TeamPicker(props: TeamPickerProps)
	local gridRef: { current: Frame? } = useRef()
	local picker: Picker = usePicker(props.Teams, props.PlayerTeam, 3)
	local iconsRef: { current: { TeamIcon } } = useRef({})
	local animatingRef: { current: boolean } = useRef(false)
	local needsRebuildRef: { current: boolean } = useRef(false)

	local function shiftIcons(delta: number)
		animatingRef.current = true
		for _, icon in iconsRef.current do
			local stroke = icon.Frame:FindFirstChildOfClass("UIStroke")
			if stroke ~= nil then
				stroke:Destroy()
			end
			icon.Offset = icon.Offset + delta
			moveTeamIcon(icon.Frame, icon.Offset, function()
				addStroke(icon.Frame)
				props.OnSelect(icon.Team)
			end, function()
				local index = (table.find(iconsRef.current, icon) or 0) - 1
				if index >= 0 then
					table.remove(iconsRef.current, index + 1)
				end
			end)
		end
	end

	useEffect(function()
		if not gridRef.current then
			return nil
		end
		for team, offset in picker.View do
			local frame = createTeamIcon(team, offset)
			frame.Parent = gridRef.current
			table.insert(iconsRef.current, {
				Team = team,
				Offset = offset,
				Frame = frame,
			})
		end
	end, { gridRef.current })

	useEffect(function()
		if not needsRebuildRef.current then
			animatingRef.current = true
			return nil
		end
		needsRebuildRef.current = false
		for _, icon in iconsRef.current do
			icon.Frame:Destroy()
		end
		table.clear(iconsRef.current)
		for team, offset in picker.View do
			local frame = createTeamIcon(team, offset)
			frame.Parent = gridRef.current
			table.insert(iconsRef.current, {
				Team = team,
				Offset = offset,
				Frame = frame,
			})
		end
	end, { picker.Index })

	useEffect(function()
		if animatingRef.current then
			animatingRef.current = false
		else
			needsRebuildRef.current = true
			picker.SetValue(props.PlayerTeam)
		end
	end, { props.PlayerTeam.Id })

	local gridProps = {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -187, 1, -20),
		Size = UDim2.fromOffset(130, 26),
	}

	local textElement = React.createElement(Text, {
		TextSize = 18,
		Bold = true,
		FixSize = true,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -10),
		Text = props.Teams[picker.Index + 1].Name,
		TextColor3 = Color.White,
	})

	local prevButton = React.createElement("imagebutton", {
		Rotation = 180,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		Image = RobloxImage.NEXT_ARROW,
		Event = {
			Activated = function()
				local team = picker.Previous()
				local frame = createTeamIcon(team, -2)
				frame.Parent = gridRef.current
				table.insert(iconsRef.current, {
					Team = team,
					Offset = -2,
					Frame = frame,
				})
				shiftIcons(1)
			end,
		},
	})

	local gridElement = React.createElement(Grid, {
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(88, 30),
		Ref = gridRef,
	})

	local nextButton = React.createElement("imagebutton", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(16, 16),
		Image = RobloxImage.NEXT_ARROW,
		Event = {
			Activated = function()
				local team = picker.Next()
				local frame = createTeamIcon(team, 2)
				frame.Parent = gridRef.current
				table.insert(iconsRef.current, {
					Team = team,
					Offset = 2,
					Frame = frame,
				})
				shiftIcons(-1)
			end,
		},
	})

	return React.createElement(Grid, gridProps, textElement, prevButton, gridElement, nextButton)
end

return {
	TeamPicker = TeamPicker,
}
