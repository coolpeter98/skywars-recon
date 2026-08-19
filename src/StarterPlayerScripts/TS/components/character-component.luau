-- CharacterComponent

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local flameworkCore = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
)
local Reflect = flameworkCore.Reflect
local Flamework = flameworkCore.Flamework
local t = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out",
	"prelude"
).t
local Component = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"components",
	"out"
).Component
local services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = services.Players
local ReplicatedStorage: ReplicatedStorage = services.ReplicatedStorage
local Workspace: Workspace = services.Workspace
local Attribute = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "attribute").Attribute
local PlaceUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "place", "place-util").PlaceUtil
local GameMode = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "game", "game-mode").GameMode
local DisposableComponent = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"TS",
	"components",
	"disposable-component"
).DisposableComponent
local reactRoblox = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"react-roblox"
)
local createLegacyRoot = reactRoblox.createLegacyRoot
local createPortal = reactRoblox.createPortal
local react =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local globalStoreModule = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store")
local GlobalStore = globalStoreModule.GlobalStore
local GlobalStoreChanged = globalStoreModule.GlobalStoreChanged
local NameTagBillboardGui =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "name-tag", "name-tag-billboard-gui").NameTagBillboardGui
local Provider = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"ReactRedux"
).Provider

type CharacterComponent = {
	instance: Model,
	maid: { GiveTask: (self: any, ...any) -> any },
}

local CharacterComponent = setmetatable({}, {
	["__tostring"] = function()
		return "CharacterComponent"
	end,
	["__index"] = DisposableComponent,
})
CharacterComponent.__index = CharacterComponent

function CharacterComponent.new(...)
	local selfClass = CharacterComponent
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end

function CharacterComponent.constructor(self: CharacterComponent, ...)
	DisposableComponent.constructor(self, ...)
end

function CharacterComponent.onStart(self: CharacterComponent)
	self.instance:WaitForChild("Humanoid")
	local player = Players:GetPlayerFromCharacter(self.instance)
	local isDummy
	if player then
		isDummy = false
	else
		player = Players:FindFirstChild(self.instance.Name)
		isDummy = true
	end
	if not player then
		return nil
	end
	if not isDummy and PlaceUtil.getGameMode() == GameMode.EggWarsQuads then
		task.spawn(function()
			self:handleHighlight(player)
		end)
		self.maid:GiveTask(player:GetAttributeChangedSignal(Attribute.TeamId):Connect(function()
			self:handleHighlight(player)
		end))
	end
	if Players.LocalPlayer == player and not isDummy then
		return nil
	end
	if not isDummy then
		self:handleVisibility(player)
		self.maid:GiveTask(self.instance:GetAttributeChangedSignal(Attribute.Hidden):Connect(function()
			return self:handleVisibility(player)
		end))
		self.maid:GiveTask(player:GetAttributeChangedSignal(Attribute.Alive):Connect(function()
			return self:handleVisibility(player)
		end))
		self.maid:GiveTask(player:GetAttributeChangedSignal(Attribute.Spectating):Connect(function()
			return self:handleVisibility(player)
		end))
		Players.LocalPlayer:GetAttributeChangedSignal(Attribute.Alive):Connect(function()
			return self:handleVisibility(player)
		end)
		Players.LocalPlayer:GetAttributeChangedSignal(Attribute.Spectating):Connect(function()
			return self:handleVisibility(player)
		end)
		GlobalStoreChanged("GameState", function()
			return self:handleVisibility(player)
		end)
	end
	self:mountNametag(player, self.instance, isDummy)
end

function CharacterComponent.handleVisibility(self: CharacterComponent, player: Player)
	if self:isHidden(player) then
		if self.instance.Parent then
			self.instance.Parent = ReplicatedStorage
			return
		end
	elseif self.instance.Parent then
		self.instance.Parent = Workspace
	end
end

function CharacterComponent.isHidden(self: CharacterComponent, player: Player): boolean
	local isHidden = self.instance:GetAttribute(Attribute.Hidden) == true
	local result = Flamework.resolveDependency("Jj"):isInLobby(player)
	local localPlayerInLobby = Flamework.resolveDependency("Jj"):isInLobby(Players.LocalPlayer)
	if isHidden then
		result = isHidden
	elseif result then
		result = not localPlayerInLobby
	end
	return result
end

function CharacterComponent.handleHighlight(self: CharacterComponent, player: Player)
	if PlaceUtil.isGameServer() then
		Flamework.resolveDependency("zG"):awaitReplication("GameTeams")
	end
	local team = Flamework.resolveDependency("x5"):getPlayerTeam(player)
	local highlight = self.instance:FindFirstChild("PlayerHighlight")
	if not team then
		if highlight then
			highlight.OutlineTransparency = 1
		end
		return nil
	end
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "PlayerHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.Parent = self.instance
	end
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = team.Color
end

function CharacterComponent.mountNametag(self: CharacterComponent, player: Player, character: Model, isDummy: boolean)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local nametagPart = Instance.new("Part")
	nametagPart.Name = "Nametag"
	nametagPart.Transparency = 1
	nametagPart.Size = Vector3.new(1, 1, 1)
	nametagPart.CanCollide = false
	local rootPartPosition = humanoidRootPart.Position
	local offsetY = 4.5 * character:GetScale()
	nametagPart.Position = rootPartPosition + Vector3.new(0, offsetY, 0)
	nametagPart.Parent = character
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = nametagPart
	weldConstraint.Parent = nametagPart
	local root = createLegacyRoot(Instance.new("Folder"))
	local providerProps = {
		["key"] = "",
		["store"] = nil,
		["store"] = GlobalStore,
	}
	root:render(createPortal(
		react.createElement(
			Provider,
			providerProps,
			react.createElement(NameTagBillboardGui, {
				["Player"] = player,
				["Character"] = character,
				["Dummy"] = isDummy,
			})
		),
		nametagPart
	))
	self.maid:GiveTask(function()
		root:unmount()
	end)
end

Reflect.defineMetadata(CharacterComponent, "identifier", "o5r")
Reflect.defineMetadata(CharacterComponent, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(CharacterComponent, "$c:components@Component", Component, {
	{
		["tag"] = "character",
		["attributes"] = nil,
		["instanceGuard"] = nil,
		["attributes"] = {},
		["instanceGuard"] = t.instanceIsA("Model"),
	},
})
return {
	["CharacterComponent"] = CharacterComponent,
}
