-- useLevel hook

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

return {
	["useLevel"] = function(player): number
		local isPlayer = typeof(player) == "Instance"
		if isPlayer then
			isPlayer = player:IsA("Player")
		end
		if not isPlayer then
			if type(player) ~= "number" then
				player = player.UserId
			end
			player = Players:GetPlayerByUserId(player)
		end
		if not player then
			return 0
		end

		local function getLevel()
			return player:GetAttribute(Attribute.Level)
		end

		local level, setLevel = useState(getLevel)

		useEffect(function()
			local connection = player:GetAttributeChangedSignal(Attribute.Level):Connect(function()
				setLevel(getLevel)
			end)

			return function()
				connection:Disconnect()
			end
		end, {})

		return level == nil and 0 or level
	end,
}
