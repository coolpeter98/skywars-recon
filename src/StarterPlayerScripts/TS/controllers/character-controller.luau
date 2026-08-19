-- CharacterController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local GetCharacter = RuntimeLib.import(script, script.Parent.Parent, "util", "util").GetCharacter
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")

type CharacterController = {
	maid: any,
	outlineStatus: boolean,
}

local CharacterController = setmetatable({}, {
	["__tostring"] = function()
		return "CharacterController"
	end
})
CharacterController.__index = CharacterController
function CharacterController.new(...): CharacterController
	local instance = setmetatable({}, CharacterController)
	return instance:constructor(...) or instance
end
function CharacterController.constructor(self: CharacterController)
	self.maid = Maid.new()
	self.outlineStatus = true
end
function CharacterController.setOutlineStatus(self: CharacterController, enabled: boolean)
	if enabled then
		self.maid:DoCleaning()
		self.outlineStatus = true
		return nil
	end
	if not self.outlineStatus then
		return nil
	end
	self.outlineStatus = false
	local character: Model? = GetCharacter()
	if not character then
		return nil
	end
	local highlight = character:FindFirstChild("PlayerHighlight")
	if not highlight then
		return nil
	end
	highlight:SetAttribute(Attribute.HighlightTransparency, highlight.OutlineTransparency)
	highlight.OutlineTransparency = 1
	self.maid:GiveTask(highlight:GetPropertyChangedSignal("OutlineTransparency"):Connect(function()
		highlight:SetAttribute(Attribute.HighlightTransparency, highlight.OutlineTransparency)
	end))
	self.maid:GiveTask(function()
		highlight.OutlineTransparency = highlight:GetAttribute(Attribute.HighlightTransparency)
	end)
end
Reflect.defineMetadata(CharacterController, "identifier", "ymg")
Reflect.decorate(CharacterController, "$:flamework@Controller", Controller, {})
return {
	["CharacterController"] = CharacterController
}
