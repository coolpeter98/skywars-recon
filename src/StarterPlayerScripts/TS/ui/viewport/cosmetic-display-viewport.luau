-- CosmeticDisplayViewport

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local Maid = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef
local usePlayers = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-players").usePlayers
local RunService: RunService = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local RobloxAnimation = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-animation").RobloxAnimation
local Cosmetics = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "cosmetics").Cosmetics

type CosmeticDisplayViewportProps = {
	FieldOfView: number?,
	Cosmetics: { [number]: string },
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	Ambient: Color3?,
	LightColor: Color3?,
	BackgroundColor3: Color3?,
	Visible: boolean?,
	ZIndex: number?,
}

return {
	["CosmeticDisplayViewport"] = function(props: CosmeticDisplayViewportProps)
		if not RunService:IsRunning() then
			return nil
		end
		usePlayers()
		local viewportRef: { current: ViewportFrame? } = useRef()
		local maidRef = useRef(Maid.new())
		useEffect(function()
			local viewport: ViewportFrame? = viewportRef.current
			if not viewport then
				return nil
			end
			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = viewport
			local baseCFrame = CFrame.new(0, 0, 0)
			local camera: Camera = Instance.new("Camera")
			local fieldOfView = props.FieldOfView
			camera.FieldOfView = fieldOfView == nil and 50 or fieldOfView
			local basePosition = baseCFrame.Position
			camera.CFrame = CFrame.new(Vector3.new(-1.5, 5, -7.5), basePosition + Vector3.new(0, 3.5, 0))
			camera.Parent = worldModel
			local humanoidDescription = Flamework.resolveDependency("Zw"):getCachedHumanoidDescription()
			local idleAnimationId
			if humanoidDescription == nil then
				idleAnimationId = humanoidDescription
			else
				idleAnimationId = humanoidDescription.IdleAnimation
			end
			local idleAnimation
			if idleAnimationId == 0 or (idleAnimationId ~= idleAnimationId or not idleAnimationId) then
				idleAnimation = RobloxAnimation.IDLE_DEFAULT
			else
				local animationId = humanoidDescription.IdleAnimation
				idleAnimation = "rbxassetid://" .. tostring(animationId)
			end
			local killEffectCount = 0
			local killEffects = {}
			for index, cosmeticId in props.Cosmetics do
				local _ = index - 1
				local cosmeticType = Cosmetics[cosmeticId]
				if cosmeticType ~= nil then
					cosmeticType = cosmeticType.Type
				end
				if cosmeticType == "KillEffect" == true then
					killEffectCount = killEffectCount + 1
					killEffects[killEffectCount] = cosmeticId
				end
			end
			local hasKillEffects = #killEffects ~= 0
			local displayController = Flamework.resolveDependency("Wyw")
			local cosmetics = props.Cosmetics
			local cosmeticsList = table.create(#cosmetics)
			local displayProps = {
				["Position"] = baseCFrame,
				["Parent"] = worldModel,
				["Scale"] = hasKillEffects and 0.5 or 1
			}
			for index, cosmeticId in cosmetics do
				local _ = index - 1
				cosmeticsList[index] = {
					["Id"] = cosmeticId
				}
			end
			displayProps.Cosmetics = cosmeticsList
			displayProps.Animation = {
				["Idle"] = idleAnimation
			}
			local display = displayController:createDisplay(displayProps)
			maidRef.current:GiveTask(display.Maid)
			maidRef.current:GiveTask(worldModel)
			viewport.CurrentCamera = camera
			return function()
				return maidRef.current:DoCleaning()
			end
		end, { props.Cosmetics })
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
		local visible = props.Visible
		viewportProps.Visible = visible == nil and true or visible
		viewportProps.ZIndex = props.ZIndex
		return React.createElement("viewportframe", viewportProps)
	end
}
