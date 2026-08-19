-- PrivateMatchBrowserPage

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local PrivateMatchBrowserServer =
	RuntimeLib.import(script, script.Parent, "private-match-browser-server").PrivateMatchBrowserServer
local useCustomServers =
	RuntimeLib.import(script, script.Parent.Parent.Parent, "hooks", "use-custom-servers").useCustomServers
return {
	["PrivateMatchBrowserPage"] = function(_)
		local servers = useCustomServers()
		local serverCount = #servers
		local canvasHeight = serverCount * 100 + (serverCount - 1) * 10
		local children: { any } = table.create(#servers)
		for index, server in servers do
			local _ = index - 1
			children[index] = React.createElement(PrivateMatchBrowserServer, {
				["ServerData"] = server,
			})
		end
		return React.createElement(
			"scrollingframe",
			{
				["Position"] = nil,
				["Size"] = nil,
				["CanvasSize"] = nil,
				["ScrollingDirection"] = nil,
				["ScrollBarThickness"] = 10,
				["ScrollBarImageColor3"] = nil,
				["BackgroundTransparency"] = 1,
				["BorderSizePixel"] = 0,
				["Selectable"] = false,
				["Position"] = UDim2.fromOffset(300, 30),
				["Size"] = UDim2.fromOffset(690, 540),
				["CanvasSize"] = UDim2.fromOffset(0, canvasHeight),
				["ScrollingDirection"] = Enum.ScrollingDirection.Y,
				["ScrollBarImageColor3"] = Color.White,
			},
			children,
			React.createElement("uilistlayout", {
				["FillDirection"] = Enum.FillDirection.Vertical,
				["Padding"] = UDim.new(0, 10),
				["SortOrder"] = Enum.SortOrder.LayoutOrder,
			})
		)
	end,
}
