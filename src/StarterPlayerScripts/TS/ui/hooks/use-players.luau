-- usePlayers

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)

local Players: Players = services.Players
local RunService: RunService = services.RunService
local useState: <T>(initialState: T | (() -> T)) -> (T, (T) -> ()) = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"react"
).useState

local createMockPlayer = nil

local function getLocalPlayer(): Player?
	if RunService:IsRunning() then
		return Players.LocalPlayer
	else
		return createMockPlayer(1800687521)
	end
end

local function GetPlayerByUserId(userId: number): Player?
	if RunService:IsRunning() then
		return Players:GetPlayerByUserId(userId)
	else
		return createMockPlayer(userId)
	end
end

local mockUserIdCounter = 0

createMockPlayer = function(userId: number?)
	if userId == nil then
		userId = mockUserIdCounter
		mockUserIdCounter = mockUserIdCounter + 1
	end
	print((("Creating mock player with user id %*"):format(userId)))
	return {
		["UserId"] = userId,
		["Name"] = ("MockPlayer%*"):format(userId),
		["DisplayName"] = ("Player %*"):format(userId),
		["GetAttribute"] = function(_, _)
			return nil
		end,
		["GetAttributeChangedSignal"] = function(_, _)
			return Instance.new("BindableEvent").Event
		end,
		["IsFriendsWith"] = function(_, _)
			return false
		end,
		["HasAppearanceLoaded"] = function(_)
			return true
		end,
		["CharacterAppearanceLoaded"] = Instance.new("BindableEvent").Event,
	}
end

return {
	["usePlayers"] = function()
		return {
			["LocalPlayer"] = useState(getLocalPlayer),
			["GetPlayerByUserId"] = GetPlayerByUserId,
		}
	end,
	["createMockPlayer"] = createMockPlayer,
}
