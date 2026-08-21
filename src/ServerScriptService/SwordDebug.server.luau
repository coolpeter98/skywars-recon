-- SwordDebug: temporary live diagnostics for melee strikes (remove after debugging)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MELEE_STRIKE_ID = "bf26abfd-c509-43b4-9b49-5ae3a5521cd4"
local START_PRIVATE_MATCH_ID = "d887b207-66e8-4bf5-9cf8-f4b83ceefa37"
local MAX_MELEE_RANGE = 15
local LOS_MARGIN = 1.5

local function findRemote(id: string)
	for _, container in { ReplicatedStorage:FindFirstChild("aYZ"), ReplicatedStorage:FindFirstChild("dYE") } do
		if container then
			for _, remote in container:GetChildren() do
				if remote:GetAttribute("id") == id then
					return remote
				end
			end
		end
	end
	return nil
end

local roundStartedAt = nil

local function getRoot(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function formatHealth(player: Player): string
	return ("hp=%s shield=%s alive=%s spectating=%s team=%s"):format(
		tostring(player:GetAttribute("Health")),
		tostring(player:GetAttribute("Shield")),
		tostring(player:GetAttribute("Alive")),
		tostring(player:GetAttribute("Spectating")),
		tostring(player:GetAttribute("TeamId"))
	)
end

-- Replicates the combat service's line-of-sight ray.
local function losResult(attackerRoot: BasePart, targetRoot: BasePart): string
	local direction = targetRoot.Position - attackerRoot.Position
	local distance = direction.Magnitude
	if distance <= LOS_MARGIN then
		return "clear (point-blank)"
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { attackerRoot.Parent, targetRoot.Parent }
	local hit = Workspace:Raycast(attackerRoot.Position, direction.Unit * (distance - LOS_MARGIN), params)
	return if hit then "BLOCKED by " .. hit.Instance:GetFullName() else "clear"
end

local startRemote = findRemote(START_PRIVATE_MATCH_ID)
if startRemote then
	startRemote.OnServerEvent:Connect(function(player)
		roundStartedAt = os.clock()
		print("[SWORD] StartPrivateMatch fired by " .. player.Name .. " - combat gate opens ~5s later")
	end)
end

for _, player in Players:GetPlayers() do
	print("[SWORD] existing player at boot: " .. player.Name)
end

Players.PlayerAdded:Connect(function(player)
	print("[SWORD] player joined: " .. player.Name)
	player:GetAttributeChangedSignal("Health"):Connect(function()
		print("[SWORD] " .. player.Name .. " Health -> " .. tostring(player:GetAttribute("Health")))
	end)
	player:GetAttributeChangedSignal("Alive"):Connect(function()
		print("[SWORD] " .. player.Name .. " Alive -> " .. tostring(player:GetAttribute("Alive")))
	end)
end)

local meleeRemote = findRemote(MELEE_STRIKE_ID)
if meleeRemote == nil then
	print("[SWORD] FATAL: MeleeStrike remote not found")
else
	print("[SWORD] hooked MeleeStrike remote (" .. meleeRemote.Name .. ")")
	meleeRemote.OnServerEvent:Connect(function(attacker, target)
		local roundInfo
		if roundStartedAt == nil then
			roundInfo = "no StartPrivateMatch seen"
		else
			roundInfo = string.format("%.1fs after StartPrivateMatch", os.clock() - roundStartedAt)
		end
		print(
			string.format(
				"[SWORD] STRIKE attacker=%s target=%s | %s",
				attacker.Name,
				target and target.Name or "nil",
				roundInfo
			)
		)
		print(
			"   attacker: "
				.. formatHealth(attacker)
				.. " hitbox="
				.. tostring(attacker.Character and attacker.Character:FindFirstChild("Hitbox") ~= nil)
		)
		if target then
			print(
				"   target:   "
					.. formatHealth(target)
					.. " hitbox="
					.. tostring(target.Character and target.Character:FindFirstChild("Hitbox") ~= nil)
			)
			local attackerRoot = getRoot(attacker)
			local targetRoot = getRoot(target)
			if attackerRoot and targetRoot then
				local distance = (targetRoot.Position - attackerRoot.Position).Magnitude
				print(
					string.format(
						"   distance=%.1f (limit %.1f) | LOS: %s",
						distance,
						MAX_MELEE_RANGE,
						losResult(attackerRoot, targetRoot)
					)
				)
			else
				print(
					"   root missing: attacker="
						.. tostring(attackerRoot ~= nil)
						.. " target="
						.. tostring(targetRoot ~= nil)
				)
			end
		end
	end)
end
