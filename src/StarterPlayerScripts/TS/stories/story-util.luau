-- StoryUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local CreateReactStory = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"ui-labs",
	"src"
).CreateReactStory
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local ReactRoblox = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"react-roblox"
)
local Modding = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Modding
local ShopScreen = RuntimeLib.import(script, script.Parent.Parent, "ui", "shop", "shop-screen").ShopScreen
local HttpService: HttpService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).HttpService
local useStoryCanvas = RuntimeLib.import(script, script.Parent.Parent, "ui", "hooks", "use-story-canvas").useStoryCanvas
local ReduxProvider = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"ReactRedux"
).Provider
local GlobalStore = RuntimeLib.import(script, script.Parent.Parent, "ui", "rodux", "global-store").GlobalStore
local ScreenContext = RuntimeLib.import(script, script.Parent.Parent, "ui", "context", "screen-context").ScreenContext
local CameraViewportContext =
	RuntimeLib.import(script, script.Parent.Parent, "ui", "context", "camera-viewport-context").CameraViewportContext

local StoryUtil = {}

type StoryProps = {
	target: any,
	children: any?,
}

local function StoryComponent(props: StoryProps)
	local screenOptions = Modding.getDecorator(ShopScreen, nil, "Az").arguments[1]
	local screenName
	if screenOptions.AllowMultiple == true then
		screenName = ("%*_%*"):format(screenOptions.ScreenId, HttpService:GenerateGUID(false))
	else
		screenName = screenOptions.ScreenId
	end
	local screenHandler = {
		["ScreenId"] = screenOptions.ScreenId,
		["ScreenName"] = screenName,
		["Options"] = screenOptions,
	}
	local storyCanvas = useStoryCanvas({
		["MobileScale"] = screenOptions.MobileScale,
		["Target"] = props.target,
	})
	local inverseScale = 1 / storyCanvas.Scale
	local createElement = React.createElement
	local provider = ReduxProvider
	local providerProps = {
		["store"] = GlobalStore,
	}
	local createElement = React.createElement
	local screenProvider = ScreenContext.Provider
	local screenContextValue = {
		["value"] = {
			["ScreenHandler"] = screenHandler,
			["IsOpen"] = function()
				return true
			end,
			["Close"] = function() end,
		},
	}
	local createElement = React.createElement
	local cameraViewportProvider = CameraViewportContext.Provider
	local cameraViewportValue = {
		["value"] = storyCanvas,
	}
	local createElement = React.createElement
	local frameType = "frame"
	local frameProps = {
		["key"] = "Wrapper",
		["Size"] = nil,
		["Size"] = UDim2.fromScale(inverseScale, inverseScale),
	}
	local children = props.children
	local uiScaleElement
	if screenOptions.DisableScaling then
		uiScaleElement = nil
	else
		uiScaleElement = createElement("uiscale", {
			["Scale"] = storyCanvas.Scale,
		})
	end
	return createElement(
		provider,
		providerProps,
		createElement(
			screenProvider,
			screenContextValue,
			createElement(
				cameraViewportProvider,
				cameraViewportValue,
				createElement(frameType, frameProps, children, uiScaleElement)
			)
		)
	)
end

function StoryUtil.createStory(story, children)
	return CreateReactStory({
		["react"] = React,
		["reactRoblox"] = ReactRoblox,
		["controls"] = story.controls,
		["name"] = story.name,
		["summary"] = story.name,
		["cleanup"] = story.cleanup,
	}, function(mountProps)
		local clonedProps = table.clone(mountProps)
		setmetatable(clonedProps, nil)
		return React.createElement(StoryComponent, clonedProps, children)
	end)
end

return {
	["StoryUtil"] = StoryUtil,
}
