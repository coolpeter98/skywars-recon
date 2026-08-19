-- RadialPrompt

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BlockConstants = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")

return {
	["RadialPrompt"] = function(props: { Model: Model, children: any? })
		return React.createElement("billboardgui", {
			["key"] = "RadialPromptBillboardGui",
			["Size"] = nil,
			["ExtentsOffset"] = Vector3.new(0, 0, 0),
			["MaxDistance"] = nil,
			["AlwaysOnTop"] = true,
			["Adornee"] = nil,
			["ZIndexBehavior"] = nil,
			["Size"] = UDim2.fromOffset(500, 500),
			["MaxDistance"] = 32 * BlockConstants.BLOCK_SIZE,
			["Adornee"] = props.Model,
			["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
		}, props.children)
	end
}
