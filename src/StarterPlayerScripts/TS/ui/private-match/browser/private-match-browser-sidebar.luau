-- PrivateMatchBrowserSidebar

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState
local PrivateMatchSidebar = RuntimeLib.import(script, script.Parent.Parent, "private-match-sidebar").PrivateMatchSidebar
local Text = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text").Text
local Button = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "button").Button
local PRIVATE_SERVER_KEY_LENGTH = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"private-match",
	"private-match"
).PRIVATE_SERVER_KEY_LENGTH
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Separator = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "separator").Separator
local TextInput = RuntimeLib.import(script, script.Parent.Parent.Parent, "components", "text-input").TextInput
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local isValidKey: ((key: string, exactLength: boolean?) -> boolean)? = nil

local function PrivateMatchBrowserSidebar(_)
	local privacy, setPrivacy = useState("Public")
	local joinCode, setJoinCode = useState("")
	local loading, setLoading = useState(false)
	local isPublic = privacy == "Public"
	local isValidJoinCode = isValidKey(joinCode, true)
	local createElement = React.createElement
	local sidebar = PrivateMatchSidebar
	local sidebarProps = nil
	local hostMatchTitle = createElement(Text, {
		["AnchorPoint"] = nil,
		["Position"] = nil,
		["Text"] = "Host Match",
		["TextSize"] = 36,
		["Bold"] = true,
		["FixSize"] = true,
		["AnchorPoint"] = Vector2.new(0.5, 0),
		["Position"] = UDim2.fromScale(0.5, 0),
	})
	local createElement = React.createElement
	local button = Button
	local privacyButtonProps = {
		["Position"] = nil,
		["Size"] = nil,
		["Text"] = nil,
		["TextSize"] = 18,
		["Color"] = nil,
		["Activated"] = nil,
		["Position"] = UDim2.fromOffset(0, 52),
		["Size"] = { 210, 50 },
		["Text"] = ("Privacy: %*"):format(privacy),
	}
	local privacyColor
	if isPublic then
		privacyColor = Color.Button.Blue
	else
		privacyColor = Color.Button.Red
	end
	privacyButtonProps.Color = privacyColor
	function privacyButtonProps.Activated()
		setPrivacy(isPublic and "Private" or "Public")
	end
	return createElement(
		sidebar,
		sidebarProps,
		hostMatchTitle,
		createElement(button, privacyButtonProps),
		React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Host",
			["Icon"] = nil,
			["TextSize"] = 48,
			["Color"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(0, 112),
			["Size"] = { 210, 80 },
			["Icon"] = RobloxImage.Icon.HOST,
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				if loading then
					return nil
				end
				setLoading(true)
				Flamework.resolveDependency("kXp"):createPrivateServer(privacy)
				task.spawn(function()
					task.wait(10)
					setLoading(false)
				end)
			end,
		}),
		React.createElement(Separator, {
			["AnchorPoint"] = Vector2.new(0, 0.5),
			["Position"] = UDim2.fromOffset(0, 222),
			["Size"] = UDim2.fromOffset(210, 4),
		}),
		React.createElement(Text, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Text"] = "Join Match",
			["TextSize"] = 36,
			["Bold"] = true,
			["FixSize"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0),
			["Position"] = UDim2.new(0.5, 0, 0, 246),
		}),
		React.createElement(TextInput, {
			["Position"] = nil,
			["Size"] = nil,
			["PlaceholderText"] = "Enter code...",
			["Value"] = nil,
			["SetValue"] = nil,
			["OnChange"] = nil,
			["Position"] = UDim2.fromOffset(0, 298),
			["Size"] = UDim2.fromOffset(210, 50),
			["Value"] = joinCode,
			["SetValue"] = setJoinCode,
			["OnChange"] = function(value)
				local uppercased = string.upper(value)
				if PRIVATE_SERVER_KEY_LENGTH < #uppercased or not isValidKey(uppercased) then
					return nil
				else
					return uppercased
				end
			end,
		}),
		React.createElement(Button, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Play",
			["Icon"] = nil,
			["TextSize"] = 48,
			["Disabled"] = nil,
			["Color"] = nil,
			["Activated"] = nil,
			["Position"] = UDim2.fromOffset(0, 358),
			["Size"] = { 210, 80 },
			["Icon"] = RobloxImage.Icon.PLAY,
			["Disabled"] = not isValidJoinCode,
			["Color"] = Color.Button.Green,
			["Activated"] = function()
				if not isValidJoinCode or loading then
					return nil
				end
				setLoading(true)
				Flamework.resolveDependency("kXp"):joinPrivateServer(joinCode)
				task.spawn(function()
					task.wait(10)
					setLoading(false)
				end)
			end,
		})
	)
end
isValidKey = function(key: string, exactLength: boolean?): boolean
	if exactLength == nil then
		exactLength = false
	end
	local isValid = string.match(key, "^[%u%d]*$") ~= nil
	if isValid then
		if exactLength then
			return #key == PRIVATE_SERVER_KEY_LENGTH
		end
		isValid = true
	end
	return isValid
end
return {
	["PrivateMatchBrowserSidebar"] = PrivateMatchBrowserSidebar,
}
