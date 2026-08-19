-- PlayGameGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local PlayGameGroup = RuntimeLib.import(script, script.Parent, "play-game-group").PlayGameGroup
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local GameMode = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameMode
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen

type PlayGameGuiProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["PlayGameGui"] = function(props: PlayGameGuiProps)
		local screen = useScreen()
		local createElement = React.createElement
		local windowComponent = Window
		local windowProps = {
			["key"] = "PlayGameGui",
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 1,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(960, 630)
		}
		local createElement = React.createElement
		local playGameGroup = PlayGameGroup
		local skyWarsProps = {
			["key"] = "SkyWars",
			["Position"] = nil,
			["GroupImage"] = nil,
			["GameModes"] = nil,
			["Position"] = UDim2.fromOffset(0, 362),
			["GroupImage"] = RobloxImage.SKYWARS_LOGO,
			["GameModes"] = {
				{
					["GameModeName"] = "SOLOS",
					["GameModeIcon"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["RenderedImage"] = nil,
					["Activated"] = nil,
					["GameModeIcon"] = RobloxImage.Icon.PLAY,
					["Size"] = Size.new(338, 268),
					["Color"] = Color3.fromRGB(217, 139, 48),
					["RenderedImage"] = RobloxImage.GameMode.SOLO,
					["Activated"] = function()
						screen.Close()
						Flamework.resolveDependency("MMv"):joinQueue(GameMode.SkyWarsSolo)
					end
				},
				{
					["GameModeName"] = "DUOS",
					["GameModeIcon"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["RenderedImage"] = nil,
					["Activated"] = nil,
					["GameModeIcon"] = RobloxImage.Icon.PLAY,
					["Size"] = Size.new(338, 268),
					["Color"] = Color3.fromRGB(191, 75, 87),
					["RenderedImage"] = RobloxImage.GameMode.DUOS,
					["Activated"] = function()
						screen.Close()
						Flamework.resolveDependency("MMv"):joinQueue(GameMode.SkyWarsDuos)
					end
				}
			}
		}
		local skyWarsElement = createElement(playGameGroup, skyWarsProps)
		local createElement = React.createElement
		local playGameGroup = PlayGameGroup
		local eggWarsProps = {
			["key"] = "EggWars",
			["Position"] = nil,
			["GroupImage"] = nil,
			["GameModes"] = nil,
			["Position"] = UDim2.fromOffset(0, 32),
			["GroupImage"] = RobloxImage.EGGWARS_LOGO,
			["GameModes"] = {
				{
					["GameModeName"] = "SQUADS",
					["GameModeIcon"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["RenderedImage"] = nil,
					["Activated"] = nil,
					["GameModeIcon"] = RobloxImage.Icon.PLAY,
					["Size"] = Size.new(676, 268),
					["Color"] = Color3.fromRGB(106, 224, 208),
					["RenderedImage"] = RobloxImage.GameMode.EW_SQUADS,
					["Activated"] = function()
						screen.Close()
						Flamework.resolveDependency("MMv"):joinQueue(GameMode.EggWarsQuads)
					end
				}
			}
		}
		local eggWarsElement = createElement(playGameGroup, eggWarsProps)
		local createElement = React.createElement
		local playGameGroup = PlayGameGroup
		local customsProps = {
			["key"] = "Customs",
			["Position"] = nil,
			["GameModes"] = nil,
			["Position"] = UDim2.fromOffset(698, 362),
			["GameModes"] = {
				{
					["GameModeName"] = "CUSTOMS",
					["GameModeIcon"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["RenderedImage"] = nil,
					["Activated"] = nil,
					["GameModeIcon"] = RobloxImage.Icon.PLAY,
					["Size"] = Size.new(268, 268),
					["Color"] = Color3.fromRGB(83, 148, 227),
					["RenderedImage"] = RobloxImage.GameMode.CUSTOM,
					["Activated"] = function()
						Flamework.resolveDependency("kXp"):openCustomMatchBrowser()
					end
				}
			}
		}
		local customsElement = createElement(playGameGroup, customsProps)
		local createElement = React.createElement
		local playGameGroup = PlayGameGroup
		local bridgesProps = {
			["key"] = "Bridges",
			["Position"] = nil,
			["GameModes"] = nil,
			["Position"] = UDim2.fromOffset(698, 32),
			["GameModes"] = {
				{
					["GameModeName"] = "BRIDGES",
					["GameModeIcon"] = nil,
					["Size"] = nil,
					["Color"] = nil,
					["RenderedImage"] = nil,
					["Activated"] = nil,
					["GameModeIcon"] = RobloxImage.Icon.PLAY,
					["Size"] = Size.new(268, 268),
					["Color"] = Color3.fromRGB(179, 129, 223),
					["RenderedImage"] = RobloxImage.GameMode.BRIDGE,
					["Activated"] = function()
						screen.Close()
						Flamework.resolveDependency("MMv"):joinQueue(GameMode.DuelsSolo)
					end
				}
			}
		}
		return createElement(windowComponent, windowProps, skyWarsElement, eggWarsElement, customsElement, createElement(playGameGroup, bridgesProps))
	end
}
