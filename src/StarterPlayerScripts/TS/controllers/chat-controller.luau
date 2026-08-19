-- ChatController

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local FlameworkCore = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out")
local Reflect = FlameworkCore.Reflect
local Flamework = FlameworkCore.Flamework
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Players: Players = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local Ranks = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game-product", "ranks").Ranks
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color

type ChatController = {
	new: (...any) -> ChatController,
	constructor: (self: ChatController, ...any) -> (),
	onStart: (self: ChatController) -> (),
	__tostring: () -> string,
}

local ChatController = setmetatable({}, {
	["__tostring"] = function()
		return "ChatController"
	end,
})
ChatController.__index = ChatController

function ChatController.new(...)
	local class = ChatController
	local instance = setmetatable({}, class)
	return instance:constructor(...) or instance
end

function ChatController.constructor(self) end

function ChatController.onStart(self)
	game:GetService("TextChatService").OnIncomingMessage = function(message: TextChatMessage)
		local messageProperties = Instance.new("TextChatMessageProperties")
		local player: Player? = message.TextSource and Players:GetPlayerByUserId(message.TextSource.UserId)
		if player then
			local prefix: string = ""
			if player:GetAttribute(Attribute.Rank) ~= nil then
				local rank: string = player:GetAttribute(Attribute.Rank)
				if rank == "ADMIN" then
					prefix = ("<font color=\'#%*\'>[%* ADMIN]</font> "):format(Color.Red:ToHex(), Ranks.ADMIN.Icon)
				elseif rank == "EARLY_SUPPORTER" then
					prefix = ("<font color=\'#%*\'>[%* VIP]</font> "):format(Color.Purple:ToHex(), Ranks.EARLY_SUPPORTER.Icon)
				end
			end
			local team = Flamework.resolveDependency("x5"):getPlayerTeam(player)
			if team ~= nil then
				team = team.Color
			end
			if #prefix > 0 or team then
				local nameTag: string
				if team then
					nameTag = ("<font color=\'#%*\'>%*</font>"):format(team:ToHex(), player.DisplayName)
				else
					nameTag = ("%*"):format(player.DisplayName)
				end
				messageProperties.PrefixText = prefix .. nameTag
			end
		end
		return messageProperties
	end
end

Reflect.defineMetadata(ChatController, "identifier", "DO5")
Reflect.defineMetadata(ChatController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(ChatController, "$:flamework@Controller", Controller, {})

return {
	["ChatController"] = ChatController,
}
