-- PlayerName

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Text = RuntimeLib.import(script, script.Parent, "text").Text
local Grid = RuntimeLib.import(script, script.Parent, "grid").Grid
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local usePlayerTitle = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-player-title").usePlayerTitle
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type PlayerNameProps = {
	Player: Player,
	AnchorPoint: Vector2?,
	Position: UDim2?,
}

return {
	["PlayerName"] = function(props: PlayerNameProps)
		local titleProps = usePlayerTitle({
			["Player"] = props.Player,
		})
		if titleProps then
			titleProps = getTextProps({
				["Text"] = nil,
				["TextSize"] = 16,
				["Bold"] = true,
				["Color"] = nil,
				["Text"] = titleProps.Title,
				["Color"] = titleProps.Color,
			})
		end
		local playerNameTextProps = getTextProps({
			["Text"] = nil,
			["TextSize"] = 24,
			["Bold"] = true,
			["Text"] = props.Player.DisplayName,
		})
		local containerProps = {
			["key"] = ("%*_PlayerName"):format(props.Player.Name),
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
		}
		local titleWidthOrNil
		if titleProps == nil then
			titleWidthOrNil = titleProps
		else
			titleWidthOrNil = titleProps.Size.X.Offset
		end
		local titleWidth = titleWidthOrNil == nil and 0 or titleWidthOrNil
		local playerNameWidth = playerNameTextProps.Size.X.Offset
		local maxWidth = math.max(titleWidth, playerNameWidth)
		local titleHeightOrNil
		if titleProps == nil then
			titleHeightOrNil = titleProps
		else
			titleHeightOrNil = titleProps.Size.Y.Offset
		end
		local titleHeight = titleHeightOrNil == nil and 0 or titleHeightOrNil
		containerProps.Size = UDim2.fromOffset(maxWidth, titleHeight + playerNameTextProps.Size.Y.Offset)
		local titleElement
		if titleProps then
			local titleElementProps = {
				["key"] = "TitleText",
				["LayoutOrder"] = 1,
			}
			for key, value in titleProps do
				titleElementProps[key] = value
			end
			titleElement = React.createElement(Text, titleElementProps)
		else
			titleElement = nil
		end
		local playerNameElementProps = {
			["key"] = "PlayerNameText",
		}
		if titleProps ~= nil then
			titleProps = titleProps.Size.Y.Offset
		end
		playerNameElementProps.Position = UDim2.fromOffset(0, titleProps)
		playerNameElementProps.LayoutOrder = 2
		for key, value in playerNameTextProps do
			playerNameElementProps[key] = value
		end
		return React.createElement(
			Grid,
			containerProps,
			titleElement,
			React.createElement(Text, playerNameElementProps)
		)
	end,
}
