-- Loading: shows a custom loading screen when arriving via TeleportService

local TeleportService: TeleportService = game:GetService("TeleportService")
local Players: Players = game:GetService("Players")
local ReplicatedFirst: ReplicatedFirst = game:GetService("ReplicatedFirst")

local arrivingGui: ScreenGui? = TeleportService:GetArrivingTeleportGui()
print("customLoadingScreen " .. (not arrivingGui and "nil" or arrivingGui.Name))

if arrivingGui then
	local playerGui: PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	arrivingGui.Parent = playerGui
end
