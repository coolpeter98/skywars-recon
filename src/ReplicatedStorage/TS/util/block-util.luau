-- BlockUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Services = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
)
local Players: Players = Services.Players
local Workspace: Workspace = Services.Workspace

local BuildConstraints =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "build-constraint")
local BuildConstraint = BuildConstraints.BuildConstraint
local BuildConstraintType = BuildConstraints.BuildConstraintType

type BuildConstraintType = "BoundingBox" | "Radius" | "World"

type BuildConstraint = {
	Type: BuildConstraintType,
	Origin: Vector3?,
	Minimum: Vector3?,
	Maximum: Vector3?,
	Distance: number?,
	Whitelist: boolean?,
	Immutable: boolean?,
}

return {
	["BlockUtil"] = {
		["validateConstraints"] = function(position: Vector3, constraints: { BuildConstraint }): boolean
			local valid = false
			for _, constraint in constraints do
				if constraint.Type ~= BuildConstraintType.World then
					local isInConstraint = BuildConstraint.isInBuildConstraint(position, constraint)
					if constraint.Whitelist and isInConstraint then
						valid = true
					elseif not constraint.Whitelist and isInConstraint then
						return false
					end
				end
			end
			return valid
		end,
		["isWorldImmutable"] = function(constraints: { BuildConstraint }): boolean
			for _, constraint in constraints do
				if constraint.Type == BuildConstraintType.World and constraint.Immutable then
					return true
				end
			end
			return false
		end,
		["canPlace"] = function(position: Vector3, excludedPlayer: Player?): boolean
			if excludedPlayer == nil then
				excludedPlayer = nil
			end
			local playerBodyParts = {}
			for _, player in Players:GetPlayers() do
				if player ~= excludedPlayer and (player.Character and player.Character.PrimaryPart) then
					local head = player.Character:FindFirstChild("Head")
					local upperTorso = player.Character:FindFirstChild("UpperTorso")
					if head and upperTorso then
						table.insert(playerBodyParts, head)
						table.insert(playerBodyParts, upperTorso)
					end
				end
			end
			local partsInBox = Workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(2.9, 2.9, 2.9))
			local function isObstructing(part)
				local isObstructingPart = part:IsDescendantOf(Workspace.BlockContainer)
				if not isObstructingPart then
					local matchCount = 0
					local matchingParts = {}
					for index, bodyPart in playerBodyParts do
						local _ = index - 1
						if (part:IsDescendantOf(bodyPart) or part == bodyPart) == true then
							matchCount = matchCount + 1
							matchingParts[matchCount] = bodyPart
						end
					end
					if #matchingParts > 0 then
						isObstructingPart = true
					else
						isObstructingPart = false
					end
				end
				if isObstructingPart then
					isObstructingPart = part.Name ~= "UpperTorso" and true or part.Position.Y < position.Y
				end
				return isObstructingPart
			end
			local obstructionCount = 0
			local obstructingParts = {}
			for index, part in partsInBox do
				if isObstructing(part, index - 1, partsInBox) == true then
					obstructionCount = obstructionCount + 1
					obstructingParts[obstructionCount] = part
				end
			end
			return #obstructingParts == 0
		end,
		["hasAdjacentBlock"] = function(position: Vector3): boolean
			for dx = -1, 1 do
				for dz = -1, 1 do
					if dx ~= 0 or dz ~= 0 then
						local offset = Vector3.new(dx, 0, dz) * 3
						local matchCount = 0
						local matchingParts = {}
						for index, part in
							Workspace:GetPartBoundsInBox(CFrame.new(position + offset), Vector3.new(2.9, 2.9, 2.9))
						do
							local _ = index - 1
							if part:IsDescendantOf(Workspace.BlockContainer) == true then
								matchCount = matchCount + 1
								matchingParts[matchCount] = part
							end
						end
						if #matchingParts > 0 then
							return true
						end
					end
				end
			end
			for dy = -1, 1 do
				if dy ~= 0 then
					local offset = Vector3.new(0, dy, 0) * 3
					local matchCount = 0
					local matchingParts = {}
					for index, part in
						Workspace:GetPartBoundsInBox(CFrame.new(position + offset), Vector3.new(2.9, 2.9, 2.9))
					do
						local _ = index - 1
						if part:IsDescendantOf(Workspace.BlockContainer) == true then
							matchCount = matchCount + 1
							matchingParts[matchCount] = part
						end
					end
					if #matchingParts > 0 then
						return true
					end
				end
			end
			return false
		end,
	},
}
