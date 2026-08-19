local Services =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@rbxts",
		"services"
	)

local Players: Players = Services.Players
local Workspace: Workspace = Services.Workspace

local GetCharacter: (player: Player?) -> Model?

local function GetHumanoid(player: Player?): Humanoid?
	if player == nil then
		player = Players.LocalPlayer
	end

	local character = GetCharacter(player)
	if character then
		return character:FindFirstChildOfClass("Humanoid")
	else
		return nil
	end
end

local function GetPlayerRoot(): BasePart?
	local character = GetCharacter()
	if character then
		return character.PrimaryPart
	else
		return nil
	end
end

GetCharacter = function(player: Player?): Model?
	if player == nil then
		player = Players.LocalPlayer
	end

	return player.Character
end

local function AwaitPlayerRoot(): BasePart
	local player = Players.LocalPlayer
	if player.Character then
		return player.Character:WaitForChild("HumanoidRootPart")
	else
		return player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
	end
end

local function AwaitCharacter(player: Player?): Model
	if player == nil then
		player = Players.LocalPlayer
	end

	if player.Character then
		return player.Character
	else
		return player.CharacterAdded:Wait()
	end
end

local function AwaitHumanoid(player: Player?): Humanoid
	if player == nil then
		player = Players.LocalPlayer
	end

	if player == nil then
		player = Players.LocalPlayer
	end

	local character: Model
	if player.Character then
		character = player.Character
	else
		character = player.CharacterAdded:Wait()
	end

	return character:WaitForChild("Humanoid")
end

local function GetCamera(): Camera?
	return Workspace.CurrentCamera
end

return {
	["AwaitPlayerRoot"] = AwaitPlayerRoot,
	["AwaitCharacter"] = AwaitCharacter,
	["AwaitHumanoid"] = AwaitHumanoid,
	["GetHumanoid"] = GetHumanoid,
	["GetPlayerRoot"] = GetPlayerRoot,
	["GetCharacter"] = GetCharacter,
	["GetCamera"] = GetCamera,
}
