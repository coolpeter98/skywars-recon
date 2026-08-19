-- DockLayout

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
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PlayGameScreen = RuntimeLib.import(script, script.Parent.Parent, "play-game", "play-game-screen").PlayGameScreen
local MissionScreen = RuntimeLib.import(script, script.Parent.Parent, "mission", "mission-screen").MissionScreen
local LockerScreen = RuntimeLib.import(script, script.Parent.Parent, "locker", "locker-screen").LockerScreen

type DockOptions = {
	IsCustomGame: boolean,
	IsCustomOwner: boolean,
	IsCustomGameOverFull: boolean,
	IsPartyOwner: boolean,
}

type DockButton = {
	ButtonId: string,
	Disabled: boolean?,
}

local DockButtonId = {
	["SeasonPass"] = "SeasonPass",
	["Missions"] = "Missions",
	["Play"] = "Play",
	["Locker"] = "Locker",
	["Shop"] = "Shop",
	["Start"] = "Start",
	["Settings"] = "Settings",
}

local DockButtons = {
	["SeasonPass"] = {
		["Text"] = "SEASON 3",
		["Image"] = RobloxImage.Icon.CHEST,
		["Color"] = Color.Button.Red,
		["Activated"] = function()
			return Flamework.resolveDependency("vbD"):openShop({
				["ProductType"] = "SeasonPass",
			})
		end,
	},
	["Missions"] = {
		["Text"] = "MISSIONS",
		["Image"] = RobloxImage.Icon.LIST_CHECK,
		["Color"] = Color.Button.Purple,
		["Activated"] = function()
			return Flamework.resolveDependency("lB5"):toggle(MissionScreen)
		end,
	},
	["Play"] = {
		["Text"] = "PLAY",
		["Image"] = RobloxImage.Icon.GAMEPAD,
		["Color"] = Color.Button.Green,
		["Activated"] = function()
			return Flamework.resolveDependency("lB5"):toggle(PlayGameScreen)
		end,
	},
	["Locker"] = {
		["Text"] = "LOCKER",
		["Image"] = RobloxImage.Icon.CLOTHES_HANGER,
		["Color"] = Color.Button.Blue,
		["Activated"] = function()
			return Flamework.resolveDependency("lB5"):toggle(LockerScreen)
		end,
	},
	["Shop"] = {
		["Text"] = "SHOP",
		["Image"] = RobloxImage.Icon.SHOPPING_CART,
		["Color"] = Color.Button.Yellow,
		["HasUpdated"] = function()
			return Flamework.resolveDependency("9ll")
				:hasUpdated({ "GAME_PRODUCT_PLASMA_TITAN_BUNDLE", "GAME_PRODUCT_SEASON_PASS_3" })
		end,
		["Activated"] = function()
			Flamework.resolveDependency("vbD"):toggleShop()
			Flamework.resolveDependency("9ll")
				:addUpdatesToProfile({ "GAME_PRODUCT_PLASMA_TITAN_BUNDLE", "GAME_PRODUCT_SEASON_PASS_3" })
		end,
	},
	["Start"] = {
		["Text"] = "START",
		["Image"] = RobloxImage.Icon.GAMEPAD,
		["Color"] = Color.Button.Green,
		["Activated"] = function()
			return Flamework.resolveDependency("kXp"):startGame()
		end,
	},
	["Settings"] = {
		["Text"] = "SETTINGS",
		["Image"] = RobloxImage.Icon.SETTINGS,
		["Color"] = Color.Button.Yellow,
		["Activated"] = function()
			return Flamework.resolveDependency("kXp"):toggleCustomMatchSettings()
		end,
	},
}

return {
	["getDockLayout"] = function(dockOptions: DockOptions)
		local layout = {
			{
				["ButtonId"] = DockButtonId.SeasonPass,
			},
			{
				["ButtonId"] = DockButtonId.Missions,
			},
			{
				["ButtonId"] = DockButtonId.Locker,
			},
			{
				["ButtonId"] = DockButtonId.Shop,
			},
		}
		if dockOptions.IsCustomGame then
			if dockOptions.IsCustomOwner then
				local startButton = {
					["ButtonId"] = DockButtonId.Start,
					["Disabled"] = dockOptions.IsCustomGameOverFull,
				}
				table.insert(layout, 4, startButton)
				local settingsButton = {
					["ButtonId"] = DockButtonId.Settings,
				}
				table.insert(layout, 5, settingsButton)
			end
			return layout
		end
		local playButton = {
			["ButtonId"] = DockButtonId.Play,
			["Disabled"] = not dockOptions.IsPartyOwner,
		}
		table.insert(layout, 3, playButton)
		return layout
	end,
	["getDockButtons"] = function(buttons: { DockButton })
		local result = table.create(#buttons)
		for index, button in buttons do
			local _ = index - 1
			local clonedButton = table.clone(DockButtons[button.ButtonId])
			setmetatable(clonedButton, nil)
			clonedButton.Disabled = button.Disabled
			result[index] = clonedButton
		end
		return result
	end,
	["DockButtonId"] = DockButtonId,
	["DockButtons"] = DockButtons,
}
