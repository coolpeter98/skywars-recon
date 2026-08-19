-- PrivateMatchBrowserServer

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Grid = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "corner-radius").CornerRadius
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local PlayerIcon = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "player-icon").PlayerIcon
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local GameModes = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameModes

type PrivateMatchBrowserServerProps = {
	ServerData: {
		ServerName: string,
		OwnerId: number,
		OwnerDisplayName: string,
		PlayersOnline: number,
		SpectatorsOnline: number,
		ServerKey: string,
		Settings: {
			GameMode: string,
			MapName: string,
		},
	},
}

return {
	["PrivateMatchBrowserServer"] = function(props: PrivateMatchBrowserServerProps)
		local gameMode = GameModes[props.ServerData.Settings.GameMode]
		return React.createElement(Grid, {
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["LayoutOrder"] = nil,
			["Size"] = UDim2.fromOffset(650, 100),
			["LayoutOrder"] = -props.ServerData.PlayersOnline
		}, React.createElement(PlayerIcon, {
			["Position"] = UDim2.fromOffset(10, 10),
			["Size"] = UDim2.fromOffset(80, 80),
			["UserId"] = props.ServerData.OwnerId
		}), React.createElement(Grid, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.new(0, 100, 0.5, 0),
			["AutomaticSize"] = Enum.AutomaticSize.XY
		}, React.createElement(Text, {
			["Text"] = nil,
			["Bold"] = true,
			["FixSize"] = true,
			["LayoutOrder"] = 1,
			["Text"] = props.ServerData.ServerName
		}), React.createElement(Text, {
			["Text"] = nil,
			["TextSize"] = 15,
			["Bold"] = true,
			["FixSize"] = true,
			["LayoutOrder"] = 2,
			["Text"] = ("Hosted by %*"):format(props.ServerData.OwnerDisplayName)
		}), React.createElement(Text, {
			["Text"] = nil,
			["TextSize"] = 18,
			["Bold"] = true,
			["FixSize"] = true,
			["LayoutOrder"] = 3,
			["Text"] = ("\240\159\145\165 %*/%* (%* watching)        %*        %*"):format(props.ServerData.PlayersOnline, gameMode.TeamSize * gameMode.MaxTeams, props.ServerData.SpectatorsOnline, gameMode.DisplayName, props.ServerData.Settings.MapName)
		}), React.createElement("uilistlayout", {
			["FillDirection"] = Enum.FillDirection.Vertical,
			["SortOrder"] = Enum.SortOrder.LayoutOrder,
			["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
			["VerticalAlignment"] = Enum.VerticalAlignment.Center,
			["Padding"] = UDim.new(0, 4)
		})), React.createElement(Button, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Join",
			["TextSize"] = 24,
			["Color"] = nil,
			["Activated"] = nil,
			["AnchorPoint"] = Vector2.new(1, 0.5),
			["Position"] = UDim2.new(1, -30, 0.5, 0),
			["Size"] = { 150, 50 },
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				Flamework.resolveDependency("kXp"):joinPrivateServer(props.ServerData.ServerKey)
			end
		}), React.createElement(CornerRadius, {
			["Radius"] = 10
		}))
	end
}
