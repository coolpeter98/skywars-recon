-- CameraUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local UserInputService: UserInputService = RuntimeLib.UserInputService
local Workspace: Workspace = RuntimeLib.Workspace
return {
	["CameraUtil"] = {
		["getDirection"] = function()
			local camera = Workspace.CurrentCamera
			local viewportCenter = camera.ViewportSize / 2
			return camera:ViewportPointToRay(viewportCenter.X, viewportCenter.Y).Direction
		end,
		["getCursorDirection"] = function()
			local camera = Workspace.CurrentCamera
			local mouseLocation = UserInputService:GetMouseLocation()
			return camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y).Direction
		end
	}
}
