-- EmoteController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local GuiService: GuiService = Services.GuiService
local RunService: RunService = Services.RunService
local StarterGui: StarterGui = Services.StarterGui

type EmoteController = {}

local EmoteController = setmetatable({}, {
	["__tostring"] = function()
		return "EmoteController"
	end
})
EmoteController.__index = EmoteController

function EmoteController.new(...)
	local self = setmetatable({}, EmoteController)
	return self:constructor(...) or self
end

function EmoteController.constructor(_)
end

function EmoteController.onStart(self: EmoteController)
	Flamework.resolveDependency("xWL"):registerTopbarToggle("rbxasset://textures/ui/TopBar/emotesOff.png", "rbxasset://textures/ui/TopBar/emotesOn.png", false, function(toggle, enabled: boolean)
		if enabled then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
			GuiService:SetEmotesMenuOpen(true)
			local connection: RBXScriptConnection? = nil
			connection = RunService.Heartbeat:Connect(function()
				if not GuiService:GetEmotesMenuOpen() then
					connection:Disconnect()
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
					toggle:deselect()
				end
			end)
		elseif GuiService:GetEmotesMenuOpen() then
			GuiService:SetEmotesMenuOpen(false)
		end
	end):bindToggleKey(Enum.KeyCode.Period)
end

Reflect.defineMetadata(EmoteController, "identifier", "GbZ")
Reflect.defineMetadata(EmoteController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(EmoteController, "$:flamework@Controller", Controller, {})

return {
	["EmoteController"] = EmoteController
}
