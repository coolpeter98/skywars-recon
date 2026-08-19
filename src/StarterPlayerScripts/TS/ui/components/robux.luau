-- Robux

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local TextImage = RuntimeLib.import(script, script.Parent, "text-image").TextImage
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
return {
	["Robux"] = function(props)
		local propsCopy = table.clone(props)
		setmetatable(propsCopy, nil)
		propsCopy.Price = nil
		local imageProps = {
			["key"] = "Robux",
			["Image"] = nil,
			["Text"] = nil,
			["Padding"] = 4,
			["Image"] = RobloxImage.Icon.ROBUX,
			["Text"] = ("%*"):format(props.Price),
		}
		for key, value in propsCopy do
			imageProps[key] = value
		end
		return React.createElement(TextImage, imageProps)
	end,
}
