-- AfkController

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
)
local Reflect = Flamework.Reflect
local _ = Flamework.Flamework
local Controller = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Controller
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local _ = Services.Players
local _ = Services.RunService
local AwaitHumanoid = RuntimeLib.import(script, script.Parent.Parent, "util", "util").AwaitHumanoid
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local _ =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "warning-message", "warning-message-screen").WarningMessageScreen
local AsyncEvent =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent

type AfkController = {
	timeLastMoved: number?,
	PlayerAfkEvent: {
		fire: (self: any, ...any) -> (),
	},
}

local AfkController = setmetatable({}, {
	["__tostring"] = function()
		return "AfkController"
	end,
})
AfkController.__index = AfkController

function AfkController.new(...)
	local class = AfkController
	local self = setmetatable({}, class)
	return self:constructor(...) or self
end

function AfkController.constructor(self: AfkController)
	self.PlayerAfkEvent = AsyncEvent.new()
end

function AfkController.onStart(_)
	return nil
end

function AfkController.isAfk(self: AfkController): boolean
	return self.timeLastMoved == nil
end

function AfkController.pollStatus(self: AfkController)
	task.spawn(function()
		while true do
			local timeLastMoved = self.timeLastMoved
			if timeLastMoved ~= 0 and (timeLastMoved == timeLastMoved and timeLastMoved) then
				local now = os.clock()
				if (PlaceUtil.isLobbyServer() and 1080 or 120) - 10 <= now - self.timeLastMoved then
					self.timeLastMoved = nil
					self.PlayerAfkEvent:fire()
				end
			end
			task.wait(1)
		end
	end)
end

function AfkController.setup(self: AfkController)
	local humanoid = AwaitHumanoid()
	self.timeLastMoved = os.clock()
	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		self.timeLastMoved = os.clock()
	end)
end

Reflect.defineMetadata(AfkController, "identifier", "Ezz")
Reflect.defineMetadata(AfkController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(AfkController, "$:flamework@Controller", Controller, {})

return {
	["AfkController"] = AfkController,
}
