-- MobileButtons

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Flamework
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local RobloxImage =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local RaycastType =
	RuntimeLib.import(script, script.Parent.Parent, "controllers", "block-raycast-controller").RaycastType
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items

type MobileButton = {
	Id: string,
	Color: Color3?,
	Image: string?,
	Toggle: boolean,
	Active: boolean,
	Activated: ((...any) -> ())?,
}

local mobileButtons: { [string]: MobileButton } = {}
for _, button in
	{
		{
			["Id"] = "Sprint",
			["Color"] = nil,
			["Image"] = nil,
			["Toggle"] = true,
			["Active"] = true,
			["Activated"] = nil,
			["Color"] = Color.Mobile.Aqua,
			["Image"] = RobloxImage.Icon.SPRINTING,
			["Activated"] = function()
				Flamework.resolveDependency("a4X"):toggleSprinting()
			end,
		},
		{
			["Id"] = "Melee",
			["Color"] = nil,
			["Image"] = nil,
			["Toggle"] = false,
			["Active"] = true,
			["Activated"] = nil,
			["Color"] = Color.Mobile.Red,
			["Image"] = RobloxImage.Icon.SWORDS,
			["Activated"] = function(value)
				Flamework.resolveDependency("Gpz"):strike(value)
			end,
		},
		{
			["Id"] = "Projectile",
			["Color"] = nil,
			["Image"] = nil,
			["Toggle"] = false,
			["Active"] = false,
			["Activated"] = nil,
			["Color"] = Color.Mobile.Red,
			["Image"] = RobloxImage.Icon.ARROW,
			["Activated"] = function(value)
				Flamework.resolveDependency("vmD"):chargeBow(value)
			end,
		},
		{
			["Id"] = "Block",
			["Color"] = nil,
			["Image"] = nil,
			["Toggle"] = false,
			["Active"] = true,
			["Activated"] = nil,
			["Color"] = Color.Mobile.Yellow,
			["Image"] = RobloxImage.Icon.BLOCK,
			["Activated"] = function(_)
				local hotbarController = Flamework.resolveDependency("Dqk")
				local blockRaycastController = Flamework.resolveDependency("WXw")
				local item = hotbarController:getHeldItemInfo()
				if not item then
					return nil
				end
				local itemName = item.Name
				if item.Rewrite then
					local teamId = Flamework.resolveDependency("x5"):getPlayerTeamId()
					local team = teamId == nil and "White" or teamId
					item = Items[string.gsub(item.Rewrite.Type, "{TeamId}", team)]
				end
				if not item.Block then
					return nil
				end
				local blockRaycast = blockRaycastController:getBlockRaycastStored()
				if
					not blockRaycast
					or (
						blockRaycast.RaycastType == RaycastType.Paused
						or blockRaycast.RaycastType == RaycastType.Standard
					)
				then
					return nil
				end
				Flamework.resolveDependency("NaX")
					:placeBlock(blockRaycast.BlockPosition, itemName, item, blockRaycast.Rotation)
			end,
		},
		{
			["Id"] = "PowerUp",
			["Color"] = nil,
			["Image"] = nil,
			["Toggle"] = false,
			["Active"] = false,
			["Activated"] = nil,
			["Color"] = Color.Mobile.Blue,
			["Image"] = RobloxImage.Icon.POTION,
			["Activated"] = function(value)
				Flamework.resolveDependency("B51"):usePowerUp(value)
			end,
		},
	}
do
	mobileButtons[button.Id] = button
end
return {
	["MobileButtons"] = mobileButtons,
}
