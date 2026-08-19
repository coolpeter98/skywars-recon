-- RaycastUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace: Workspace = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Workspace
local BlockConstants =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "block", "block-constants").BlockConstants

return {
	["RaycastUtil"] = {
		["isCharacterVisible"] = function(
			character: PVInstance,
			raycastParams: RaycastParams?,
			iterations: number?
		): boolean
			local iterations: number = iterations == nil and 2 or iterations
			local cameraCFrame: CFrame = Workspace.CurrentCamera.CFrame
			local baseCFrame: CFrame = character:GetPivot() - Vector3.new(0.65, 2.5, 1.25)
			local firstIteration: boolean = false
			local x: number = 0
			while true do
				if firstIteration then
					x = x + 1
				else
					firstIteration = true
				end
				if x > iterations then
					return false
				end
				local firstIteration: boolean = false
				local y: number = 0
				while true do
					if true then
						if firstIteration then
							y = y + 1
						else
							firstIteration = true
						end
					end
					if y > iterations then
						break
					end
					local firstIteration: boolean = false
					local z: number = 0
					while true do
						if true then
							if firstIteration then
								z = z + 1
							else
								firstIteration = true
							end
						end
						if z > iterations then
							break
						end
						local xFraction: number = x / iterations
						local yFraction: number = y / iterations
						local zFraction: number = z / iterations
						local rayOrigin: Vector3 = (baseCFrame + Vector3.new(1.3, 5, 2.5) * Vector3.new(
							xFraction,
							yFraction,
							zFraction
						)).Position
						if
							not Workspace:Raycast(
								rayOrigin,
								(cameraCFrame.Position - rayOrigin).Unit * 10,
								raycastParams
							)
						then
							return true
						end
					end
				end
			end
		end,
		["isModelVisible"] = function(model: PVInstance, raycastParams: RaycastParams?, iterations: number?): boolean
			local iterations: number = iterations == nil and 2 or iterations
			local cameraCFrame: CFrame = Workspace.CurrentCamera.CFrame
			local pivot: CFrame = model:GetPivot()
			local blockSize: Vector3 = BlockConstants.BLOCK_DIMENSION * Vector3.new(0.7, 0.7, 0.7)
			local halfBlockSize: Vector3 = BlockConstants.BLOCK_SIZE / 2
			local baseCFrame: CFrame = pivot + Vector3.new(0, halfBlockSize, 0) - blockSize / 2
			local firstIteration: boolean = false
			local x: number = 0
			while true do
				if firstIteration then
					x = x + 1
				else
					firstIteration = true
				end
				if x > iterations then
					return false
				end
				local firstIteration: boolean = false
				local y: number = 0
				while true do
					if true then
						if firstIteration then
							y = y + 1
						else
							firstIteration = true
						end
					end
					if y > iterations then
						break
					end
					local firstIteration: boolean = false
					local z: number = 0
					while true do
						if true then
							if firstIteration then
								z = z + 1
							else
								firstIteration = true
							end
						end
						if z > iterations then
							break
						end
						local xFraction: number = x / iterations
						local yFraction: number = y / iterations
						local zFraction: number = z / iterations
						local rayOrigin: Vector3 = (baseCFrame + blockSize * Vector3.new(
							xFraction,
							yFraction,
							zFraction
						)).Position
						if
							not Workspace:Raycast(
								rayOrigin,
								(cameraCFrame.Position - rayOrigin).Unit * 10,
								raycastParams
							)
						then
							return true
						end
					end
				end
			end
		end,
	},
}
