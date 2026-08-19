-- PlayGameGroup

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local ArrayUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "array-util").ArrayUtil
local TweenService: TweenService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).TweenService
local PlayGameCard = RuntimeLib.import(script, script.Parent, "play-game-card").PlayGameCard

type GameMode = {
	Size: Vector2,
	GameModeName: string,
	[string]: any,
}

type PlayGameGroupProps = {
	GameModes: { [string]: GameMode },
	GroupImage: string,
	Position: UDim2?,
}

return {
	["PlayGameGroup"] = function(props: PlayGameGroupProps)
		local isHovered: boolean, setIsHovered = useState(false)
		local uiscaleRef = useRef()
		local gameModes = props.GameModes
		local sizes: { number } = table.create(#gameModes)
		for index, gameMode in gameModes do
			local _ = index - 1
			sizes[index] = gameMode.Size.X
		end
		local totalWidth: number = ArrayUtil.sum(sizes)
		useEffect(function()
			local uiscale: UIScale? = uiscaleRef.current
			if uiscale then
				local tweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				if isHovered then
					TweenService:Create(uiscale, tweenInfo, {
						["Scale"] = 1.03,
					}):Play()
				else
					TweenService:Create(uiscale, tweenInfo, {
						["Scale"] = 1,
					}):Play()
				end
			else
				return nil
			end
		end, { isHovered })
		local gridProps = {
			["key"] = "PlayGameGroup",
			["AnchorPoint"] = nil,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = (props.Position or UDim2.new()) + UDim2.fromOffset((totalWidth + 20) / 2, 134),
			["Size"] = UDim2.fromOffset(totalWidth, 268),
			["Event"] = {
				["MouseEnter"] = function()
					setIsHovered(true)
				end,
				["MouseLeave"] = function()
					setIsHovered(false)
				end,
			},
		}
		local uiscaleElement = React.createElement("uiscale", {
			["ref"] = nil,
			["Scale"] = 1,
			["ref"] = uiscaleRef,
		})
		local groupImage = props.GroupImage
		local groupImageElement
		if groupImage == "" or not groupImage then
			groupImageElement = nil
		else
			groupImageElement = React.createElement(Image, {
				["key"] = "GroupImage",
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Image"] = nil,
				["ZIndex"] = 10,
				["ScaleType"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = UDim2.fromScale(0.5, 0),
				["Size"] = UDim2.fromOffset(400, 84),
				["Image"] = props.GroupImage,
				["ScaleType"] = Enum.ScaleType.Stretch,
			})
		end
		local gameModes = props.GameModes
		local cards = table.create(#gameModes)
		for index, gameMode in gameModes do
			local _ = index - 1
			local cardProps = {
				["key"] = gameMode.GameModeName,
			}
			for key, value in gameMode do
				cardProps[key] = value
			end
			cards[index] = React.createElement(PlayGameCard, cardProps)
		end
		return React.createElement(
			Grid,
			gridProps,
			uiscaleElement,
			groupImageElement,
			React.createElement(
				Grid,
				{
					["Size"] = UDim2.fromScale(1, 1),
				},
				cards,
				React.createElement(List, {
					["VerticalAlignment"] = Enum.VerticalAlignment.Top,
					["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
					["Padding"] = UDim.new(0),
				})
			)
		)
	end,
}
