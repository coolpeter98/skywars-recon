-- ItemViewport

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
local Items = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "item", "item").Items
local ToolUtil = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "tool-util").ToolUtil
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local SkinsUtil =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "cosmetic", "util", "skins-util").SkinsUtil
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useRef = React.useRef

type ItemViewportProps = {
	ItemType: string?,
	Zoom: number?,
	Greyscale: boolean?,
	Frontal: boolean?,
	Visible: boolean?,
	ZIndex: number?,
}

type ItemDefinition = {
	Name: string,
	Rewrite: { Type: string }?,
	Block: { Ref: BasePart }?,
}

type ViewportOptions = {
	Rotate: boolean?,
	Zoom: number?,
}

local setupViewport: (frame: ViewportFrame, item: ItemDefinition, zoom: number?, greyscale: boolean?, frontal: boolean?) -> () =
	nil

local function ItemViewport(props: ItemViewportProps)
	local viewportRef: { current: ViewportFrame? } = useRef()
	useEffect(function()
		if not viewportRef.current then
			return nil
		end
		viewportRef.current:ClearAllChildren()
		local itemType = props.ItemType
		if itemType == "" or not itemType then
			return nil
		end
		local item = Items[props.ItemType]
		setupViewport(viewportRef.current, item, props.Zoom, props.Greyscale, props.Frontal)
	end, {
		viewportRef.current,
		props.ItemType,
		props.Greyscale,
		props.Frontal,
	})
	local elementProps = {
		["key"] = "ViewportFrame",
		["Size"] = nil,
		["Ambient"] = nil,
		["LightColor"] = nil,
		["LightDirection"] = Vector3.new(0, -1, -0.5),
		["BackgroundColor3"] = nil,
		["BackgroundTransparency"] = 1,
		["BorderSizePixel"] = 0,
		["ZIndex"] = nil,
		["ref"] = nil,
		["Size"] = UDim2.fromScale(1, 1),
		["Ambient"] = Color3.fromRGB(162, 162, 162),
		["LightColor"] = Color.White,
		["BackgroundColor3"] = Color.ViewportLightGrey,
		["ZIndex"] = props.ZIndex,
		["ref"] = viewportRef,
	}
	local visible = props.Visible
	elementProps.Visible = visible == nil and true or visible
	return React.createElement("viewportframe", elementProps)
end

setupViewport = function(
	frame: ViewportFrame,
	item: ItemDefinition,
	zoom: number?,
	greyscale: boolean?,
	frontal: boolean?
)
	local zoomScale = zoom == nil and 1 or zoom
	if greyscale == nil then
		greyscale = false
	end
	if frontal == nil then
		frontal = false
	end
	local lookAt: Vector3 = Vector3.new()
	local getViewportOptions = SkinsUtil.getViewportOptions
	local itemName = item.Name
	local activeSkin
	if RunService:IsRunning() then
		activeSkin = Flamework.resolveDependency("Ggz"):getActiveSkinFromItem(item.Name)
	else
		activeSkin = nil
	end
	local viewportOptions = getViewportOptions(itemName, activeSkin)
	if item.Rewrite then
		local teamId
		if RunService:IsRunning() then
			local playerTeamId = Flamework.resolveDependency("x5"):getPlayerTeamId()
			teamId = playerTeamId == nil and "White" or playerTeamId
		else
			teamId = "White"
		end
		setupViewport(frame, Items[string.gsub(item.Rewrite.Type, "{TeamId}", teamId)], zoomScale, greyscale)
		return nil
	end
	if item.Block then
		local blockRef = item.Block.Ref:Clone()
		blockRef.Position = Vector3.new()
		blockRef.Parent = frame
	else
		local tool
		if RunService:IsRunning() then
			tool = Flamework.resolveDependency("Ggz"):getTool(item.Name)
		else
			tool = SkinsUtil.getTool(item.Name)
		end
		local rotate
		if viewportOptions == nil then
			rotate = viewportOptions
		else
			rotate = viewportOptions.Rotate
		end
		local toolModel = ToolUtil.createToolModel(tool, rotate)
		toolModel.Parent = frame
		local sizeY = ({ toolModel:GetBoundingBox() })[1].Y
		lookAt = Vector3.new(0, sizeY, 0)
	end
	local baseDistance = item.Block and 220 or 190
	local viewportZoom
	if viewportOptions == nil then
		viewportZoom = viewportOptions
	else
		viewportZoom = viewportOptions.Zoom
	end
	if viewportZoom ~= 0 and (viewportZoom == viewportZoom and viewportZoom) then
		baseDistance = baseDistance - baseDistance * viewportOptions.Zoom
	end
	local distance = baseDistance * (1 / zoomScale)
	local camera = Instance.new("Camera") :: Camera
	camera.FieldOfView = 1
	local newCFrame = CFrame.new
	local cameraPosition
	if frontal then
		cameraPosition = Vector3.new(distance, 0, distance)
	else
		cameraPosition = Vector3.new(distance, distance, distance)
	end
	camera.CFrame = newCFrame(cameraPosition, lookAt)
	camera.Parent = frame
	frame.CurrentCamera = camera
	local ambient
	if greyscale then
		ambient = Color3.fromRGB(0, 0, 0)
	else
		ambient = Color3.fromRGB(162, 162, 162)
	end
	frame.Ambient = ambient
	local lightColor
	if greyscale then
		lightColor = Color3.fromRGB(90, 90, 90)
	else
		lightColor = Color.White
	end
	frame.LightColor = lightColor
	frame.LightDirection = Vector3.new(0, -1, -0.5)
end

return {
	["ItemViewport"] = ItemViewport,
}
