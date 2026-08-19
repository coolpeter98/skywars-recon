-- PrivateMatchSettingsMaps

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PrivateMatchSettingsMap = RuntimeLib.import(script, script.Parent, "private-match-settings-map").PrivateMatchSettingsMap
local MapUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "map", "map-util").MapUtil
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local GameModes = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameModes

return {
	PrivateMatchSettingsMaps = function(props)
		local gameType = GameModes[props.ServerData.Settings.GameMode].GameType
		local maps = MapUtil.getMaps({
			GameType = gameType,
			MapSize = (gameType == "Duels" or props.Settings.TeamSize == 1) and "Small" or "Large",
		})
		table.sort(maps, function(a, b)
			return a.DisplayName < b.DisplayName
		end)
		local randomMap = {
			Name = "",
			DisplayName = "Random",
			GameType = gameType,
			Image = RobloxImage.Map.HOME_TREE,
		}
		table.insert(maps, 1, randomMap)
		local rowCount = #maps / 3
		local rows = math.ceil(rowCount)
		local canvasHeight = rows * 265 + (rows - 1) * 10
		local elements = table.create(#maps)
		local function createMapElement(map)
			return React.createElement(PrivateMatchSettingsMap, {
				Map = map,
				Selected = map.Name == props.Settings.MapName,
				SelectMap = function()
					return Flamework.resolveDependency("kXp"):setMap(map.Name)
				end,
			})
		end
		for index, map in maps do
			elements[index] = createMapElement(map, index - 1, maps)
		end
		return React.createElement("scrollingframe", {
			ScrollBarThickness = 10,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Selectable = false,
			Position = UDim2.fromOffset(300, 30),
			Size = UDim2.fromOffset(690, 540),
			CanvasSize = UDim2.fromOffset(0, canvasHeight),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarImageColor3 = Color.White,
		}, elements, React.createElement("uigridlayout", {
			FillDirectionMaxCells = 3,
			FillDirection = Enum.FillDirection.Horizontal,
			CellSize = UDim2.fromOffset(210, 265),
			CellPadding = UDim2.fromOffset(10, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}))
	end,
}
