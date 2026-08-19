-- HealthUtil

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Debris: Debris = Services.Debris
local TweenService: TweenService = Services.TweenService
local Workspace: Workspace = Services.Workspace
local ColorUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
return {
	["HealthUtil"] = {
		["createDamageIndicator"] = function(character: Model, damage: number, shield: boolean?)
			if not character.PrimaryPart then
				return nil
			end
			if damage == 0 and not shield then
				return nil
			end
			local color: Color3
			if shield then
				color = Color.LightBlue
			else
				local getDamageColor = ColorUtil.getDamageColor
				local damageRatio = damage / 16
				color = getDamageColor((math.min(damageRatio, 1)))
			end
			local part = Instance.new("Part")
			part.Position = character.PrimaryPart.Position
			part.Size = Vector3.new(1, 1, 1)
			part.Anchored = false
			part.CanCollide = false
			part.Transparency = 1
			part.Massless = false
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.AlwaysOnTop = true
			billboardGui.Size = UDim2.fromScale(5, 2.5)
			billboardGui.Parent = part
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.BackgroundTransparency = 1
			frame.Size = UDim2.fromScale(0.5, 1)
			frame.Parent = billboardGui
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BorderSizePixel = 0
			imageLabel.BackgroundTransparency = 1
			local image: string
			if shield then
				image = RobloxImage.Icon.SHIELD
			elseif damage >= 0 then
				image = RobloxImage.WorldIcon.HEART_BROKEN
			else
				image = RobloxImage.WorldIcon.HEART
			end
			imageLabel.Image = image
			imageLabel.ImageColor3 = color
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromScale(0.8, 0.8)
			imageLabel.Parent = frame
			local textLabel = Instance.new("TextLabel")
			textLabel.Text = ("%*"):format(damage)
			textLabel.Size = UDim2.fromScale(0.5, 1)
			textLabel.Position = UDim2.fromScale(0.5, 0)
			textLabel.Font = Enum.Font.GothamBlack
			textLabel.TextColor3 = color
			textLabel.RichText = false
			textLabel.BackgroundTransparency = 1
			textLabel.TextScaled = true
			textLabel.Parent = billboardGui
			part.Parent = Workspace
			local impulseX = math.random() * 2.5 + 2
			local impulseY = math.random() * 2 + 30
			local impulseZ = math.random() * 2.5 + 2
			part:ApplyImpulse((Vector3.new(impulseX, impulseY, impulseZ)))
			TweenService:Create(billboardGui, TweenInfo.new(0.5), {
				["Size"] = UDim2.fromScale(2.5, 1.25)
			}):Play()
			Debris:AddItem(part, 0.5)
		end
	}
}
