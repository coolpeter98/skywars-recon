-- PlayerUtil

local Players: Players = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players

type PlayerInfo = {
	UserId: number,
	UserName: string,
	DisplayName: string,
}

type VisitorInfo = {
	VisitorId: number,
	UserName: string,
	DisplayName: string,
}

return {
	["PlayerUtil"] = {
		["findNearestPlayer"] = function(players: { Player }, position: Vector3, excludePlayers: { Player }?): Player?
			local nearestPlayer = nil
			local bestDistance = 0
			for _, player in players do
				local isExcluded
				if excludePlayers == nil then
					isExcluded = excludePlayers
				else
					isExcluded = table.find(excludePlayers, player) ~= nil
				end
				if not isExcluded then
					local primaryPart = player.Character
					if primaryPart ~= nil then
						primaryPart = primaryPart.PrimaryPart
					end
					if primaryPart then
						if not player.Character:FindFirstChildOfClass("Humanoid") then
							return nil
						end
						local distance = (player.Character.PrimaryPart.Position - position).Magnitude
						if not nearestPlayer or distance < bestDistance then
							bestDistance = distance
							nearestPlayer = player
						end
					end
				end
			end
			return nearestPlayer
		end,
		["getPlayers"] = function(userIds: { number }): { Player }
			local players = {}
			for i = 1, #userIds do
				local userId = userIds[i]
				local _ = i - 1
				local player = Players:GetPlayerByUserId(userId)
				if player then
					table.insert(players, player)
				end
			end
			return players
		end,
		["toReplicated"] = function(player: Player | VisitorInfo): PlayerInfo
			local isPlayer = typeof(player) == "Instance"
			if isPlayer then
				isPlayer = player:IsA("Player")
			end
			return isPlayer
					and {
						["UserId"] = player.UserId,
						["UserName"] = player.Name,
						["DisplayName"] = player.DisplayName,
					}
				or {
					["UserId"] = player.VisitorId,
					["UserName"] = player.UserName,
					["DisplayName"] = player.DisplayName,
				}
		end,
	},
}
