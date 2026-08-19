-- Crosshair

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local CrosshairSegment = RuntimeLib.import(script, script.Parent.Parent, "components", "crosshair-segment").CrosshairSegment
local Events = RuntimeLib.import(script, script.Parent.Parent.Parent, "events").Events
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CircularProgress = RuntimeLib.import(script, script.Parent.Parent, "components", "circular-progress").CircularProgress
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState
local useGlobalStore = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useGlobalStore
return {
	["Crosshair"] = function(props)
		local inventory = useGlobalStore("Inventory")
		local activeSlot = useGlobalStore("ActiveSlot")
		local cooldowns = useGlobalStore("Cooldowns")
		local item = inventory.Contents[activeSlot]
		local transparency, setTransparency = useState(1)
		local crosshairLength, setCrosshairLength = useState(25)
		useEffect(function()
			local maid = Maid.new()
			local shotTimes = {}
			local lastShotTime = nil
			maid:GiveTask(Events.DamageDealt:connect(function(_, _, _, _, _, player: Player)
				if player and player == Players.LocalPlayer then
					local shots = shotTimes
					local shotTime = os.clock()
					table.insert(shots, shotTime)
					lastShotTime = os.clock()
				end
			end))
			maid:GiveTask(RunService.Heartbeat:Connect(function()
				local recentShotCount = 0
				local recentShots = {}
				for index, shotTime in shotTimes do
					local _ = index - 1
					if os.clock() - shotTime < 3 == true then
						recentShotCount = recentShotCount + 1
						recentShots[recentShotCount] = shotTime
					end
				end
				shotTimes = recentShots
				if #shotTimes == 0 then
					setTransparency(1)
					setCrosshairLength(0)
					return nil
				else
					local fadeProgress = (os.clock() - lastShotTime) / 1.5
					local clampedProgress = math.max(fadeProgress, 0.2)
					setTransparency((math.min(clampedProgress, 1)))
					if #shotTimes <= 2 then
						setCrosshairLength(25)
						return
					elseif #shotTimes <= 4 then
						setCrosshairLength(35)
					else
						setCrosshairLength(45)
					end
				end
			end))
			return function()
				return maid:DoCleaning()
			end
		end, {})
		local cooldownProgress, setCooldownProgress = useState(0)
		useEffect(function()
			local cooldown = item
			if cooldown then
				cooldown = cooldowns[item.Type]
			end
			if cooldown then
				local heartbeatConnection = RunService.Heartbeat:Connect(function()
					local setProgress = setCooldownProgress
					local progress = (cooldown.ExpireTime - os.clock()) / cooldown.Duration
					setProgress((math.max(progress, 0)))
				end)
				return function()
					return heartbeatConnection:Disconnect()
				end
			else
				setCooldownProgress(0)
				return nil
			end
		end, { item, cooldowns })
		local createElement = React.createElement
		local Fragment = React.Fragment
		local fragmentProps = nil
		local dotElement = createElement(Image, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Image"] = nil,
			["ImageTransparency"] = 0.2,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromOffset(13, 13),
			["Image"] = RobloxImage.Crosshair.DOT
		})
		local topLeftSegment = createElement(CrosshairSegment, {
			["Name"] = "TopLeft",
			["Position"] = nil,
			["Size"] = nil,
			["Rotation"] = 45,
			["Transparency"] = nil,
			["Position"] = UDim2.new(0.5, -12, 0.5, -12),
			["Size"] = UDim2.fromOffset(crosshairLength, 9),
			["Transparency"] = transparency
		})
		local topRightSegment = createElement(CrosshairSegment, {
			["Name"] = "TopRight",
			["Position"] = nil,
			["Size"] = nil,
			["Rotation"] = 135,
			["Transparency"] = nil,
			["Position"] = UDim2.new(0.5, 12, 0.5, -12),
			["Size"] = UDim2.fromOffset(crosshairLength, 9),
			["Transparency"] = transparency
		})
		local bottomLeftSegment = createElement(CrosshairSegment, {
			["Name"] = "BottomLeft",
			["Position"] = nil,
			["Size"] = nil,
			["Rotation"] = -45,
			["Transparency"] = nil,
			["Position"] = UDim2.new(0.5, -12, 0.5, 12),
			["Size"] = UDim2.fromOffset(crosshairLength, 9),
			["Transparency"] = transparency
		})
		local bottomRightSegment = createElement(CrosshairSegment, {
			["Name"] = "BottomRight",
			["Position"] = nil,
			["Size"] = nil,
			["Rotation"] = 225,
			["Transparency"] = nil,
			["Position"] = UDim2.new(0.5, 12, 0.5, 12),
			["Size"] = UDim2.fromOffset(crosshairLength, 9),
			["Transparency"] = transparency
		})
		local cooldownElement
		if cooldownProgress > 0 then
			cooldownElement = createElement(CircularProgress, {
				["key"] = "CircularProgress",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Color"] = nil,
				["Progress"] = nil,
				["ZIndex"] = 2,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0.5),
				["Size"] = UDim2.fromOffset(50, 50),
				["Color"] = Color.White,
				["Progress"] = cooldownProgress
			})
		else
			cooldownElement = nil
		end
		return createElement(Fragment, fragmentProps, dotElement, topLeftSegment, topRightSegment, bottomLeftSegment, bottomRightSegment, cooldownElement)
	end
}
