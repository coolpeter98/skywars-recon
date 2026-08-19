-- BundleAnnouncementGui

local React = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

local bundleColors = {
	Color3.fromRGB(241, 197, 18),
	Color3.fromRGB(208, 35, 35),
	Color3.fromRGB(75, 115, 255),
	Color3.fromRGB(141, 56, 207),
	Color3.fromRGB(68, 187, 68)
}

return {
	["BundleAnnouncementGui"] = function(_)
		return React.createElement(React.Fragment)
	end
}
