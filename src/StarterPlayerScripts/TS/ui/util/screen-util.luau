-- ScreenUtil

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
local GuiService: GuiService = Services.GuiService
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService
local Workspace: Workspace = Services.Workspace
local InputUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "input-util").InputUtil

type ScreenUtil = {
	LobbyScreenAvailable: number,
	getLobbyScreenPosition: () -> UDim2,
	getScale: (scale: number?, baseWidth: number?, baseHeight: number?, viewportSize: Vector2?) -> number,
	isMobile: () -> boolean,
	isTablet: () -> boolean,
	getAspectRatio: () -> number,
	isSmallScreen: () -> boolean,
	getGridSize: (itemSize: number, spacing: number, columns: number) -> number,
	shouldClose: (input: InputObject) -> boolean,
	getGuiObjectsAtMouse: () -> { GuiObject },
}

local ScreenUtil = {
	["LobbyScreenAvailable"] = 750,
}

local isMobile: () -> boolean
local getAspectRatio: () -> number

function ScreenUtil.getLobbyScreenPosition(): UDim2
	if isMobile() then
		return UDim2.fromScale(0.5, 0.5)
	else
		return UDim2.new(0.5, 0, 0, 515)
	end
end

function ScreenUtil.getScale(scale, baseWidth, baseHeight, viewportSize): number
	local resolvedScale = scale == nil and 1.35 or scale
	local resolvedBaseWidth = baseWidth == nil and 1920 or baseWidth
	local resolvedBaseHeight = baseHeight == nil and 1080 or baseHeight
	if viewportSize == nil then
		viewportSize = Workspace.CurrentCamera
		if viewportSize ~= nil then
			viewportSize = viewportSize.ViewportSize
		end
		if viewportSize == nil then
			viewportSize = Vector2.new(1920, 1080)
		end
	end
	local scaleX = viewportSize.X / resolvedBaseWidth
	local scaleY = viewportSize.Y / resolvedBaseHeight
	return math.min(scaleX, scaleY) * (not isMobile() and 1 or resolvedScale)
end

isMobile = function(): boolean
	local mobile = not UserInputService.MouseEnabled
	if mobile then
		mobile = UserInputService.TouchEnabled
	end
	return mobile
end

ScreenUtil.isMobile = isMobile

function ScreenUtil.isTablet(): boolean
	return getAspectRatio() < 1.4
end

getAspectRatio = function(): number
	return Workspace.CurrentCamera.ViewportSize.X / Workspace.CurrentCamera.ViewportSize.Y
end

ScreenUtil.getAspectRatio = getAspectRatio

function ScreenUtil.isSmallScreen(): boolean
	local currentCamera = Workspace.CurrentCamera
	if not currentCamera then
		return false
	end
	local guiInset = GuiService:GetGuiInset()
	local size = currentCamera.ViewportSize - guiInset
	local width = size.X
	local height = size.Y
	return math.min(width, height) <= 500
end

function ScreenUtil.getGridSize(itemSize, spacing, columns): number
	return columns * itemSize + (columns - 1) * spacing
end

function ScreenUtil.shouldClose(input: InputObject): boolean
	if input.UserInputState == Enum.UserInputState.Change then
		return false
	elseif InputUtil.isModalInteract(input) then
		return #ScreenUtil.getGuiObjectsAtMouse() == 0
	else
		return false
	end
end

function ScreenUtil.getGuiObjectsAtMouse(): { GuiObject }
	local player = Players.LocalPlayer
	local playerGui = player.PlayerGui
	local mouse = player:GetMouse()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	local contextActionGui = playerGui:FindFirstChild("ContextActionGui")
	local hype = playerGui:FindFirstChild("Hype")
	local vignette = playerGui:FindFirstChild("Vignette")
	local keypoints = playerGui:FindFirstChild("Keypoints")
	local topbarPlus = playerGui:FindFirstChild("TopbarPlus")
	local actionBar = playerGui:FindFirstChild("ActionBar")
	local guiObjects = playerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
	local function isValidObject(guiObject: GuiObject): boolean
		if guiObject.Name == "CloseFrame" or (guiObject.Name == "Window" or guiObject.Name == "WindowContent") then
			return false
		elseif touchGui and guiObject:IsDescendantOf(touchGui) then
			return false
		elseif contextActionGui and guiObject:IsDescendantOf(contextActionGui) then
			return false
		elseif hype and guiObject:IsDescendantOf(hype) then
			return false
		elseif vignette and guiObject:IsDescendantOf(vignette) then
			return false
		elseif keypoints and guiObject:IsDescendantOf(keypoints) then
			return false
		elseif topbarPlus and guiObject:IsDescendantOf(topbarPlus) then
			return false
		else
			return not (actionBar and guiObject:IsDescendantOf(actionBar))
		end
	end
	local count = 0
	local filtered: { GuiObject } = {}
	for index, guiObject in guiObjects do
		if isValidObject(guiObject, index - 1, guiObjects) == true then
			count = count + 1
			filtered[count] = guiObject
		end
	end
	return filtered
end

return {
	["ScreenUtil"] = ScreenUtil,
}
