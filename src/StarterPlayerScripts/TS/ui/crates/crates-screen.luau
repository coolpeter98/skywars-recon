-- CratesScreen

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Reflect
local ScreenDecorator = RuntimeLib.import(script, script.Parent.Parent, "screen-decorator").ScreenDecorator
local Screen = RuntimeLib.import(script, script.Parent.Parent, "screen").Screen
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local CratesGui = RuntimeLib.import(script, script.Parent, "crates-gui").CratesGui
local OpenCrate = RuntimeLib.import(script, script.Parent, "open-crate").OpenCrate
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useState = React.useState

type CratesScreen = typeof(Screen) & {
	new: (...any) -> CratesScreen,
	constructor: (self: CratesScreen, ...any) -> (),
}

local CratesScreen = setmetatable({}, {
	["__tostring"] = function(): string
		return "CratesScreen"
	end,
	["__index"] = Screen,
})
CratesScreen.__index = CratesScreen

function CratesScreen.new(...)
	local class = CratesScreen
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function CratesScreen.constructor(self: CratesScreen, ...)
	Screen.constructor(self, ...)
	function self.Component()
		local crateId, selectCrate = useState(nil)
		if crateId then
			return React.createElement(OpenCrate, {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = ScreenUtil.getLobbyScreenPosition(),
				["CrateId"] = crateId,
			})
		else
			return React.createElement(CratesGui, {
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["Position"] = ScreenUtil.getLobbyScreenPosition(),
				["SelectCrate"] = selectCrate,
			})
		end
	end
end

Reflect.defineMetadata(CratesScreen, "identifier", "0Yp")
Reflect.decorate(CratesScreen, "Az", ScreenDecorator, {
	{
		["ScreenId"] = "Crates",
		["Focused"] = true,
		["DisableHealthBar"] = true,
	},
})

return {
	["CratesScreen"] = CratesScreen,
}
