-- PlayerIcon

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CornerRadius = RuntimeLib.import(script, script.Parent, "corner-radius").CornerRadius
local Image = RuntimeLib.import(script, script.Parent, "image").Image
local usePlayerIcon = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-player-icon").usePlayerIcon
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

type PlayerIconProps = {
	UserId: number,
	CornerRadius: UDim?,
	children: any?,
	[string]: any,
}

return {
	["PlayerIcon"] = function(props: PlayerIconProps)
		local icon = usePlayerIcon({
			["UserId"] = props.UserId,
		})
		local restProps = table.clone(props)
		setmetatable(restProps, nil)
		restProps.UserId = nil
		restProps.CornerRadius = nil
		restProps.children = nil
		local imageProps = {
			["key"] = "PlayerIcon",
			["Image"] = nil,
			["Image"] = icon,
		}
		for key, value in restProps do
			imageProps[key] = value
		end
		local createElement = React.createElement
		local imageComponent = Image
		local children = props.children
		local cornerRadiusElement
		if props.CornerRadius then
			cornerRadiusElement = React.createElement("uicorner", {
				["CornerRadius"] = props.CornerRadius,
			})
		else
			cornerRadiusElement = React.createElement(CornerRadius, {
				["Radius"] = 10,
			})
		end
		return createElement(imageComponent, imageProps, children, cornerRadiusElement)
	end,
}
