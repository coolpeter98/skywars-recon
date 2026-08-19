-- TitleController

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Events = RuntimeLib.import(script, script.Parent.Parent, "events").Events
local TitleScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "title", "title-screen").TitleScreen

type TitleData = {
	Text: string,
	Duration: number?,
	Color: Color3?,
	Styled: boolean?,
	SoundBefore: string?,
	SoundAfter: string?,
}

type TitleController = {
	new: (...any) -> TitleController,
	constructor: (self: TitleController, ...any) -> (),
	onStart: (self: TitleController) -> (),
	sendTitle: (self: TitleController, title: TitleData) -> (),
	getTitleData: (self: TitleController, title: TitleData) -> TitleData,
}

local TitleController = setmetatable({}, {
	["__tostring"] = function()
		return "TitleController"
	end,
})
TitleController.__index = TitleController
function TitleController.new(...)
	local self = setmetatable({}, TitleController)
	return self:constructor(...) or self
end
function TitleController.constructor(_) end
function TitleController.onStart(self: TitleController)
	Events["ceed3a3e-6157-4bdc-9ee6-10a9910c3b5d"]:connect(function(title)
		self:sendTitle(title)
	end)
end
function TitleController.sendTitle(self: TitleController, title: TitleData)
	local titleData = self:getTitleData(title)
	local screenController = Flamework.resolveDependency("lB5"):open(TitleScreen, {
		["Title"] = titleData.Text,
		["Color"] = titleData.Color,
		["Styled"] = titleData.Styled,
	})
	task.spawn(function()
		local soundBefore = titleData.SoundBefore
		if soundBefore ~= "" and soundBefore then
			Flamework.resolveDependency("jL9"):playSound(titleData.SoundBefore)
		end
		task.wait(titleData.Duration)
		if screenController:isOpen() then
			screenController:close()
		end
		local soundAfter = titleData.SoundAfter
		if soundAfter ~= "" and soundAfter then
			Flamework.resolveDependency("jL9"):playSound(titleData.SoundAfter)
		end
	end)
end
function TitleController.getTitleData(_, title: TitleData): TitleData
	local titleData = {
		["Text"] = title.Text,
	}
	local duration = title.Duration
	titleData.Duration = duration == nil and 2 or duration
	titleData.Color = title.Color or Color3.fromHex("77cfff")
	titleData.Styled = title.Styled == true
	titleData.SoundBefore = title.SoundBefore
	titleData.SoundAfter = title.SoundAfter
	return titleData
end
Reflect.defineMetadata(TitleController, "identifier", "XqN")
Reflect.defineMetadata(TitleController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(TitleController, "$:flamework@Controller", Controller, {})
return {
	["TitleController"] = TitleController,
}
