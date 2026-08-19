-- CosmeticSlot

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local CosmeticRarities = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"cosmetic",
	"util",
	"cosmetic-rarity"
).CosmeticRarities
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local TextService: TextService = Services.TextService
local Badge = RuntimeLib.import(script, script.Parent.Parent, "components", "badge").Badge
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local getLevelUnlocked = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"experience",
	"level-rewards"
).getLevelUnlocked
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local HoverGradient = RuntimeLib.import(script, script.Parent.Parent, "components", "hover-gradient").HoverGradient
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local CosmeticViewport =
	RuntimeLib.import(script, script.Parent.Parent, "viewport", "cosmetic-viewport").CosmeticViewport
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local Cosmetics =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics

type CosmeticSlotProps = {
	CosmeticId: string?,
	GemsReward: number?,
	DisplayName: string?,
	Rarity: string?,
	Size: any?,
	Locked: boolean?,
	NextReward: boolean?,
	SeasonPassPremium: boolean?,
	Active: boolean?,
	Seed: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	LayoutOrder: number?,
	ActivateReroute: any?,
	Activated: ((locked: boolean?) -> ())?,
	children: { any }?,
}

return {
	["CosmeticSlot"] = function(props: CosmeticSlotProps)
		local hovering, setHovering = useState(false)
		local cosmetic = props.CosmeticId
		if cosmetic then
			cosmetic = Cosmetics[props.CosmeticId]
		end
		local hasGemsReward = props.GemsReward ~= nil
		local displayName = props.DisplayName
		if displayName == nil then
			if cosmetic == nil then
				displayName = cosmetic
			else
				displayName = cosmetic.Name
			end
			if displayName == nil then
				displayName = not hasGemsReward and "Cosmetic"
					or ("%* Gem%*"):format(props.GemsReward, props.GemsReward == 1 and "" or "s")
			end
		end
		local rarity = props.Rarity
		if rarity == nil then
			local cosmeticRarity
			if cosmetic == nil then
				cosmeticRarity = cosmetic
			else
				cosmeticRarity = cosmetic.Rarity
			end
			rarity = cosmeticRarity == nil and "Common" or cosmeticRarity
		end
		local rarityData = CosmeticRarities[rarity]
		local size = props.Size or Size.new(210, 210)
		local isSmall: boolean = size.Y < 180
		local textSize: number = 0.11428571428571428 * size.X
		local displayNameSize = TextService:GetTextSize(
			displayName,
			textSize,
			Enum.Font.GothamBlack,
			Vector2.new(210, 210)
		) * 1.05
		local nextReward = props.Locked
		if nextReward then
			nextReward = props.NextReward
		end
		local localPlayerName = Players.LocalPlayer
		if localPlayerName ~= nil then
			localPlayerName = localPlayerName.DisplayName
		end
		local playerName = localPlayerName == nil and "BigManGamerGoudge" or localPlayerName
		local playerNameSize =
			TextService:GetTextSize(playerName, textSize, Enum.Font.GothamBlack, Vector2.new(1920, 1080))
		local lockIcon
		if props.Locked and props.SeasonPassPremium == nil then
			local level = getLevelUnlocked(props.CosmeticId)
			lockIcon = React.createElement(
				Image,
				{
					["key"] = "Lock",
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["Position"] = UDim2.fromScale(0.5, 0.5),
					["Size"] = UDim2.fromOffset(72, 82),
					["Image"] = RobloxImage.Icon.LOCK,
					["ImageColor3"] = Color.Red,
					["DropShadow"] = Vector2.new(0, 4),
					["ZIndex"] = 3,
				},
				React.createElement(Text, {
					["Position"] = UDim2.fromOffset(0, 31),
					["Size"] = UDim2.fromOffset(72, 48),
					["Bold"] = true,
					["DropShadow"] = Vector2.new(0, 3),
					["ZIndex"] = 5,
					["Text"] = tostring(level),
					["TextXAlignment"] = Enum.TextXAlignment.Center,
					["TextYAlignment"] = Enum.TextYAlignment.Center,
				})
			)
		else
			lockIcon = nil
		end
		local activeIcon
		if props.Active then
			activeIcon = React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(1, 0),
				["Position"] = UDim2.new(1, -10, 0, 10),
				["Size"] = UDim2.fromOffset(25, 25),
				["Image"] = RobloxImage.Icon.CIRCLE_CHECK,
				["ImageColor3"] = Color.Green,
			})
		else
			activeIcon = nil
		end
		local seasonPassIcon
		if props.SeasonPassPremium == nil or props.Active then
			seasonPassIcon = nil
		else
			local seasonPassIconImage = props.SeasonPassPremium and RobloxImage.Icon.SEASON_PASS_PREMIUM
				or RobloxImage.Icon.SEASON_PASS_FREE
			seasonPassIcon = React.createElement(
				Grid,
				{
					["AnchorPoint"] = Vector2.new(1, 0),
					["Position"] = UDim2.new(1, -10, 0, 10),
					["AutomaticSize"] = Enum.AutomaticSize.XY,
					["ZIndex"] = 5,
				},
				React.createElement(Image, {
					["Size"] = Size.new(0.2857142857142857, 0.19047619047619047):mul(size.X, size.Y):ToUDim2(),
					["Image"] = seasonPassIconImage,
					["ZIndex"] = 3,
					["LayoutOrder"] = 1,
				}),
				React.createElement(Text, {
					["Bold"] = true,
					["ZIndex"] = 5,
					["LayoutOrder"] = 2,
					["Text"] = props.SeasonPassPremium and "PREMIUM" or "FREE",
					["TextSize"] = 0.06666666666666667 * size.X,
				}),
				React.createElement(List, {
					["Vertical"] = true,
					["Padding"] = UDim.new(0, 6),
				})
			)
		end
		local badge
		if isSmall then
			badge = nil
		else
			badge = React.createElement(Badge, {
				["AnchorPoint"] = nextReward and Vector2.new(0.5, 1) or Vector2.new(0, 0),
				["Position"] = nextReward and UDim2.new(0.5, 0, 1, -40) or UDim2.new(0, 10, 0, 10),
				["Text"] = nextReward and "NEXT REWARD" or string.upper(rarityData.Id),
				["TextSize"] = 0.06666666666666667 * size.X,
				["Color"] = rarityData.Color,
				["Transparency"] = props.Locked and (not props.NextReward and props.SeasonPassPremium == nil) and 0.7
					or 0,
				["ZIndex"] = 5,
				["LayoutOrder"] = 1,
			})
		end
		local title = false
		if not title then
			local cosmeticType
			if cosmetic == nil then
				cosmeticType = cosmetic
			else
				cosmeticType = cosmetic.Type
			end
			title = cosmeticType == "Title"
			if title then
				local textColor
				if cosmeticType == "Title" then
					textColor = cosmetic.Color
				else
					textColor = Color.Red
				end
				local titleTextProps = {
					["Text"] = cosmeticType ~= "Title" and "COMING SOON" or string.upper(cosmetic.Title),
					["Bold"] = true,
					["TextSize"] = 0.11428571428571428 * size.X,
					["TextColor3"] = textColor,
					["DropShadow"] = Vector2.new(0, 2),
				}
				local titleText = React.createElement(Grid, {
					["AutomaticSize"] = Enum.AutomaticSize.XY,
				}, React.createElement(Text, titleTextProps))
				local playerNameElement
				if cosmeticType == "Title" then
					playerNameElement = React.createElement(
						Grid,
						{
							["AnchorPoint"] = Vector2.new(0.5, 0.5),
							["Position"] = UDim2.fromScale(0.5, 0.5),
							["AutomaticSize"] = Enum.AutomaticSize.XY,
						},
						React.createElement(
							Grid,
							{
								["Size"] = UDim2.fromOffset(math.min(playerNameSize.X, size.X - 10), playerNameSize.Y),
							},
							React.createElement(Text, {
								["Size"] = UDim2.fromOffset(math.min(playerNameSize.X, size.X - 10), playerNameSize.Y),
								["Text"] = playerName,
								["TextSize"] = 0.11428571428571428 * size.X,
								["TextColor3"] = Color.White,
								["TextScaled"] = playerNameSize.X >= size.X,
								["DropShadow"] = Vector2.new(0, 2),
								["Bold"] = true,
							})
						)
					)
				else
					playerNameElement = nil
				end
				title = React.createElement(
					Grid,
					{
						["AnchorPoint"] = Vector2.new(0.5, 0.5),
						["Position"] = UDim2.fromScale(0.5, 0.5),
						["AutomaticSize"] = Enum.AutomaticSize.XY,
					},
					titleText,
					playerNameElement,
					React.createElement(List, {
						["Vertical"] = true,
						["Padding"] = UDim.new(0, 0),
					})
				)
			end
		end
		local viewport
		if cosmetic then
			viewport = React.createElement(CosmeticViewport, {
				["key"] = "CosmeticViewport",
				["Seed"] = props.Seed,
				["Size"] = UDim2.fromScale(1, 1),
				["CosmeticId"] = cosmetic.Id,
				["ImageTransparency"] = props.Locked and props.SeasonPassPremium == nil and 0.7 or 0,
			})
		end
		local gemsIcon
		if hasGemsReward then
			gemsIcon = React.createElement(Image, {
				["key"] = "Gems",
				["Size"] = UDim2.fromScale(1, 1),
				["Image"] = RobloxImage.Icon.GEM_GREEN_256,
				["LayoutOrder"] = props.LayoutOrder,
			})
		end
		return React.createElement(
			Grid,
			{
				["key"] = props.CosmeticId,
				["AnchorPoint"] = props.AnchorPoint,
				["Position"] = props.Position,
				["Size"] = size:ToUDim2(),
				["BackgroundTransparency"] = 0.6,
				["Event"] = {
					["MouseEnter"] = function()
						if not props.Locked then
							setHovering(true)
						end
					end,
					["MouseLeave"] = function()
						if not props.Locked then
							setHovering(false)
						end
					end,
				},
				["Activated"] = function()
					if props.Activated then
						props.Activated(props.Locked)
					end
				end,
				["Selectable"] = true,
				["LayoutOrder"] = props.LayoutOrder,
				["ActivateReroute"] = props.ActivateReroute,
			},
			lockIcon,
			activeIcon,
			seasonPassIcon,
			badge,
			title,
			viewport,
			gemsIcon,
			React.createElement(Text, {
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -10),
				["Size"] = UDim2.fromOffset(displayNameSize.X, displayNameSize.Y),
				["AutomaticSize"] = Enum.AutomaticSize.None,
				["Text"] = displayName,
				["TextSize"] = textSize,
				["TextTransparency"] = props.Locked and props.SeasonPassPremium == nil and 0.7 or 0,
				["Bold"] = true,
				["TextWrapped"] = true,
				["ZIndex"] = 5,
				["LayoutOrder"] = 2,
			}),
			React.createElement(HoverGradient, {
				["BackgroundColor3"] = rarityData.Color,
				["BackgroundTransparency"] = props.Locked and props.SeasonPassPremium == nil and 0.7 or 0,
				["ZIndex"] = 2,
				["Hovering"] = hovering,
			}),
			props.children,
			React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		)
	end,
}
