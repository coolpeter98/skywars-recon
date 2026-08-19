-- CharacterViewport

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local CharacterUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "character-util").CharacterUtil
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
return {
	["CharacterViewport"] = function(props)
		local players: { LocalPlayer: Player? } = usePlayers()
		local character: Model? = props.Character or players.LocalPlayer.Character
		local viewportRef: { current: ViewportFrame? } = useRef()
		local maidRef = useRef(Maid.new())
		useEffect(function()
			local viewportFrame = viewportRef.current
			if not viewportFrame then
				return nil
			end
			local camera: Camera = Instance.new("Camera")
			local fieldOfView: number? = props.FieldOfView
			camera.FieldOfView = fieldOfView == nil and 35 or fieldOfView
			camera.Parent = viewportFrame
			local sourceCharacter = character
			local characterModel: Model?
			if sourceCharacter then
				sourceCharacter.Archivable = true
				characterModel = Instance.new("Model")
				characterModel.Name = sourceCharacter.Name
			else
				characterModel = CharacterUtil.createCharacter(1800687521)
			end
			local partMap: { [BasePart]: BasePart } = {}
			local function rebuildModel()
				if not viewportRef.current then
					return nil
				end
				if not players.LocalPlayer:HasAppearanceLoaded() then
					players.LocalPlayer.CharacterAppearanceLoaded:Wait()
				end
				for _, child in characterModel:GetChildren() do
					child:Destroy()
				end
				table.clear(partMap)
				if character then
					for _, descendant in character:GetDescendants() do
						if descendant:IsA("Humanoid") or (descendant:IsA("Pants") or descendant:IsA("Shirt")) then
							descendant:Clone().Parent = characterModel
						elseif descendant:IsA("BasePart") and not descendant:FindFirstChildOfClass("WrapLayer") then
							local clonedPart = descendant:Clone()
							clonedPart.Parent = characterModel
							if descendant == character.PrimaryPart then
								characterModel.PrimaryPart = clonedPart
							end
							partMap[descendant] = clonedPart
						end
					end
				end
				characterModel.Parent = viewportFrame
				if character then
					maidRef.current:GiveTask(character.DescendantAdded:Connect(function(descendant)
						if descendant:IsA("Humanoid") or (descendant:IsA("Pants") or (descendant:IsA("Shirt") or (descendant:IsA("BasePart") or (descendant:IsA("Texture") or descendant:IsA("SurfaceAppearance"))))) then
							maidRef.current:DoCleaning()
							rebuildModel()
						end
					end))
					maidRef.current:GiveTask(character.DescendantRemoving:Connect(function(descendant)
						if descendant:IsA("Humanoid") or (descendant:IsA("Pants") or (descendant:IsA("Shirt") or (descendant:IsA("BasePart") or (descendant:IsA("Texture") or (descendant:IsA("SurfaceAppearance") or descendant:IsA("Model")))))) then
							task.defer(function()
								maidRef.current:DoCleaning()
								rebuildModel()
							end)
						end
					end))
				end
			end
			if characterModel.PrimaryPart then
				camera.CFrame = CFrame.new(Vector3.new(2.5, 2, -14), characterModel:GetPrimaryPartCFrame().Position)
			end
			if character then
				local renderConnection = nil
				renderConnection = RunService.RenderStepped:Connect(function()
					if not viewportRef.current then
						renderConnection:Disconnect()
					end
					for _, part in character:GetDescendants() do
						if part:IsA("BasePart") then
							local clonedPart = partMap[part]
							if clonedPart then
								clonedPart.CFrame = part.CFrame
							end
						end
					end
					if characterModel.PrimaryPart then
						local primaryPartCFrame = characterModel:GetPrimaryPartCFrame()
						local offsetCFrame = CFrame.new(Vector3.new(2.5, 2, -14))
						camera.CFrame = CFrame.new((primaryPartCFrame * offsetCFrame).Position, characterModel:GetPrimaryPartCFrame().Position)
					end
				end)
				maidRef.current:GiveTask(renderConnection)
			end
			viewportFrame.CurrentCamera = camera
			rebuildModel()
			return function()
				return maidRef.current:DoCleaning()
			end
		end, { character })
		local viewportProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["Ambient"] = nil,
			["LightColor"] = nil,
			["LightDirection"] = Vector3.new(0, -1, -0.5),
			["BackgroundTransparency"] = 1,
			["BackgroundColor3"] = nil,
			["BorderSizePixel"] = 0,
			["ref"] = nil,
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size or UDim2.fromScale(1, 1),
			["Ambient"] = Color3.fromRGB(255, 255, 255),
			["LightColor"] = Color.White,
			["BackgroundColor3"] = Color.ViewportGrey,
			["ref"] = viewportRef
		}
		local visible: boolean? = props.Visible
		viewportProps.Visible = visible == nil and true or visible
		viewportProps.ZIndex = props.ZIndex
		return React.createElement("viewportframe", viewportProps)
	end
}
