-- Screen

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
local HttpService: HttpService = Services.HttpService
local Players: Players = Services.Players
local GlobalStore = RuntimeLib.import(script, script.Parent, "rodux", "global-store").GlobalStore
local ScreenGui = RuntimeLib.import(script, script.Parent, "screen-gui").ScreenGui
local Modding = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@flamework",
	"core",
	"out"
).Modding
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
local createLegacyRoot = ReactRoblox.createLegacyRoot
local createPortal = ReactRoblox.createPortal
local Provider = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"ReactRedux"
).Provider
local ScreenContext = RuntimeLib.import(script, script.Parent, "context", "screen-context").ScreenContext

type Screen = {
	Component: any,
	props: any,
	Handler: any,
	root: any,
	mounted: boolean,
	closeHandlers: { () -> () },
}

return {
	["Screen"] = {
		["constructor"] = function(self: Screen, props: any)
			self.props = props
			self.closeHandlers = {}
			self.root = createLegacyRoot(Instance.new("Folder"))
			self.mounted = false
			local options = self:getOptions()
			local screenName
			if options.AllowMultiple == true then
				screenName = ("%*_%*"):format(options.ScreenId, HttpService:GenerateGUID(false))
			else
				screenName = options.ScreenId
			end
			self.Handler = {
				["ScreenId"] = options.ScreenId,
				["ScreenName"] = screenName,
				["Options"] = options,
			}
		end,
		["isOpen"] = function(self: Screen): boolean
			return self.mounted
		end,
		["addCloseHandler"] = function(self: Screen, handler: () -> ())
			local closeHandlers = self.closeHandlers
			table.insert(closeHandlers, handler)
		end,
		["open"] = function(self: Screen)
			local root = self.root
			local state = table.clone(GlobalStore:getState())
			setmetatable(state, nil)
			local props = self.props
			if props ~= 0 and (props == props and (props ~= "" and props)) then
				for key, value in props do
					state[key] = value
				end
			end
			state.Screen = self
			local createPortal = createPortal
			local createElement = React.createElement
			local provider = Provider
			local providerProps = {
				["key"] = "",
				["store"] = nil,
				["store"] = GlobalStore,
			}
			local createScreenElement = React.createElement
			local screenContextProvider = ScreenContext.Provider
			local contextValue = {
				["value"] = {
					["ScreenHandler"] = self.Handler,
					["Close"] = function()
						return self:close()
					end,
					["IsOpen"] = function()
						return self:isOpen()
					end,
				},
			}
			root:render(
				createPortal(
					createElement(
						provider,
						providerProps,
						createScreenElement(
							screenContextProvider,
							contextValue,
							React.createElement(ScreenGui, nil, React.createElement(self.Component, state))
						)
					),
					Players.LocalPlayer.PlayerGui
				)
			)
			self.mounted = true
		end,
		["close"] = function(self: Screen)
			self.mounted = false
			self.root:unmount()
			for index, handler in self.closeHandlers do
				local _ = index - 1
				handler()
			end
			table.clear(self.closeHandlers)
		end,
		["toggle"] = function(self: Screen): boolean
			if self:isOpen() then
				self:close()
				return false
			else
				self:open()
				return true
			end
		end,
		["getOptions"] = function(self: Screen)
			local decorator = Modding.getDecorator(self, nil, "Az")
			if not decorator then
				error(("Missing ScreenDecorator for screen %*"):format(self))
			end
			return decorator.arguments[1]
		end,
	},
}
