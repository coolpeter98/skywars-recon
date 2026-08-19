-- CratesGui

type CrateDefinition = {
	Id: string,
	DisplayName: string,
	Image: string?,
}

type CratesGuiProps = {
	AnchorPoint: Vector2,
	Position: UDim2,
	SelectCrate: (crateId: string) -> (),
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local List = RuntimeLib.import(script, script.Parent.Parent, "components", "list").List
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ObjectUtils = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "object-utils")
local Crates = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "crates", "crates").Crates
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local getTextProps = RuntimeLib.import(script, script.Parent.Parent, "util", "text-util").getTextProps
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Button = RuntimeLib.import(script, script.Parent.Parent, "components", "button").Button
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local crates: { CrateDefinition } = ObjectUtils.values(Crates)
return {
	["CratesGui"] = function(props: CratesGuiProps)
		local crateElements = table.create(#crates)
		local function createCrateElement(crate: CrateDefinition)
			local textProps = getTextProps({
				["Text"] = nil,
				["Bold"] = true,
				["TextSize"] = 36,
				["FrameSize"] = nil,
				["Text"] = crate.DisplayName,
				["FrameSize"] = Vector2.new(240, 80)
			})
			local titleTextProps = {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 20)
			}
			for key, value in textProps do
				titleTextProps[key] = value
			end
			return React.createElement(Grid, {
				["key"] = nil,
				["Size"] = nil,
				["BackgroundTransparency"] = 0.6,
				["CornerRadius"] = 10,
				["key"] = crate.Id,
				["Size"] = UDim2.fromOffset(280, 616)
			}, React.createElement(Text, titleTextProps), React.createElement(Image, {
				["AnchorPoint"] = Vector2.new(0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0, 120),
				["Size"] = UDim2.fromOffset(251, 251),
				["Image"] = crate.Image
			}), React.createElement(Button, {
				["AnchorPoint"] = nil,
				["Position"] = nil,
				["Size"] = nil,
				["Text"] = "Open",
				["TextSize"] = 32,
				["Color"] = nil,
				["Activated"] = nil,
				["AnchorPoint"] = Vector2.new(0.5, 1),
				["Position"] = UDim2.new(0.5, 0, 1, -20),
				["Size"] = { 240, 65 },
				["Color"] = Color.Button.Green,
				["Activated"] = function()
					return props.SelectCrate(crate.Id)
				end
			}))
		end
		for index, crate in crates do
			crateElements[index] = createCrateElement(crate, index - 1, crates)
		end
		return React.createElement(Window, {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TitleImage"] = nil,
			["TitleText"] = "CRATES",
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = UDim2.fromOffset(1210, 710),
			["TitleImage"] = RobloxImage.Icon.SHOPPING_CART
		}, React.createElement(Grid, {
			["Position"] = UDim2.fromOffset(30, 64),
			["Size"] = UDim2.fromOffset(ScreenUtil.getGridSize(280, 10, 4), 616)
		}, crateElements, React.createElement(List, {
			["Padding"] = UDim.new(0, 10)
		})))
	end
}
