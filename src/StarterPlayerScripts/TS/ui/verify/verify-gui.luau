-- VerifyGui

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local Grid = RuntimeLib.import(script, script.Parent.Parent, "components", "grid").Grid
local CornerRadius = RuntimeLib.import(script, script.Parent.Parent, "components", "corner-radius").CornerRadius
local RobloxImage = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "asset", "roblox", "roblox-image").RobloxImage
local Text = RuntimeLib.import(script, script.Parent.Parent, "components", "text").Text
local VerifyTask = RuntimeLib.import(script, script.Parent, "verify-task").VerifyTask
local Constants = RuntimeLib.import(script, script.Parent.Parent.Parent, "util", "constants").Constants
local usePolicy = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-policy").usePolicy
local Separator = RuntimeLib.import(script, script.Parent.Parent, "components", "separator").Separator
local Image = RuntimeLib.import(script, script.Parent.Parent, "components", "image").Image
local Color = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "color").Color
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local useVerify = RuntimeLib.import(script, script.Parent.Parent, "hooks", "use-verify").useVerify
local Window = RuntimeLib.import(script, script.Parent.Parent, "components", "window").Window
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useProfile = RuntimeLib.import(script, script.Parent.Parent, "rodux", "global-store").useProfile
local AbTestType = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "ab-test", "ab-test-type").AbTestType

return {
	["VerifyGui"] = function(_)
		local profile = useProfile()
		local policy = usePolicy()
		local isInGroup: boolean = useVerify().IsInGroup
		local _ = profile.DiscordVerification.Verified
		local requiredSteps: number = isInGroup and 4 or 0
		local followTarget: string = Flamework.resolveDependency("yAg"):isInTest(AbTestType.VerifyFollowJay) and "VoxelsJay" or "Brian1KB"
		local taskElements = { React.createElement(VerifyTask, {
				["Task"] = "Like the game",
				["Icon"] = nil,
				["Completed"] = nil,
				["LayoutOrder"] = 1,
				["Icon"] = RobloxImage.Icon.LIKE,
				["Completed"] = isInGroup
			}), React.createElement(VerifyTask, {
				["Task"] = nil,
				["Icon"] = nil,
				["Completed"] = nil,
				["LayoutOrder"] = 2,
				["Task"] = ("Follow <font color=\'rgb(224, 103, 103)\'>%*</font> on Roblox"):format(followTarget),
				["Icon"] = RobloxImage.Icon.ROBLOX,
				["Completed"] = isInGroup
			}), React.createElement(VerifyTask, {
				["Task"] = "Join the <font color=\'rgb(224, 103, 103)\'>Voxels Studio</font> Roblox Group",
				["Icon"] = nil,
				["Completed"] = nil,
				["LayoutOrder"] = 3,
				["Icon"] = RobloxImage.Icon.ROBLOX,
				["Completed"] = isInGroup
			}) }
		if policy.Discord then
			local discordTask = React.createElement(VerifyTask, {
				["Task"] = nil,
				["Icon"] = nil,
				["Completed"] = nil,
				["LayoutOrder"] = 4,
				["Task"] = ("Join <font color=\'rgb(155, 243, 255)\'>%*</font>"):format(Constants.DISCORD_URL),
				["Icon"] = RobloxImage.Icon.VERIFIED,
				["Completed"] = isInGroup
			})
			table.insert(taskElements, discordTask)
		end
		local stepCount: number = #taskElements
		local rewardsUnlocked: boolean = stepCount <= requiredSteps
		local createElement = React.createElement
		local windowComponent = Window
		local windowProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.7,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = ScreenUtil.getLobbyScreenPosition(),
			["Size"] = UDim2.fromOffset(890, 462)
		}
		local titleText = createElement(Text, {
			["Position"] = nil,
			["Text"] = "Verification",
			["TextSize"] = 36,
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(30, 30)
		})
		local subtitleText = createElement(Text, {
			["Position"] = nil,
			["Size"] = nil,
			["Text"] = "Support us by liking and following Roblox SkyWars! This can take a few minutes to update.",
			["TextSize"] = 24,
			["FixSize"] = true,
			["TextWrapped"] = true,
			["TextXAlignment"] = nil,
			["TextYAlignment"] = nil,
			["Position"] = UDim2.fromOffset(30, 76),
			["Size"] = UDim2.fromOffset(500, 72),
			["TextXAlignment"] = Enum.TextXAlignment.Left,
			["TextYAlignment"] = Enum.TextYAlignment.Top
		})
		local tasksGrid = createElement(Grid, {
			["Position"] = UDim2.fromOffset(30, 162),
			["Size"] = UDim2.fromOffset(500, ScreenUtil.getGridSize(60, 10, #taskElements))
		}, taskElements, createElement("uilistlayout", {
			["FillDirection"] = Enum.FillDirection.Vertical,
			["Padding"] = UDim.new(0, 10),
			["SortOrder"] = Enum.SortOrder.LayoutOrder
		}))
		local separator = createElement(Separator, {
			["Position"] = UDim2.fromOffset(560, 30),
			["Size"] = UDim2.fromOffset(3, 402)
		})
		local rewardsTitle = createElement(Text, {
			["Position"] = nil,
			["Text"] = "Rewards",
			["TextSize"] = 36,
			["Bold"] = true,
			["FixSize"] = true,
			["Position"] = UDim2.fromOffset(590, 30)
		})
		local rewardsImage = createElement(Image, {
			["Position"] = UDim2.fromOffset(590, 92),
			["Size"] = UDim2.fromOffset(270, 270),
			["Image"] = RobloxImage.VERIFIED_NAME_TAG
		}, createElement(CornerRadius, {
			["Radius"] = 10
		}))
		local createElement = React.createElement
		local gridComponent = Grid
		local gridProps = {
			["Position"] = nil,
			["Size"] = nil,
			["BackgroundTransparency"] = 0.6,
			["Position"] = UDim2.fromOffset(590, 372),
			["Size"] = UDim2.fromOffset(270, 60)
		}
		local createElement = React.createElement
		local textComponent = Text
		local textProps = {
			["AnchorPoint"] = nil,
			["Position"] = nil,
			["Size"] = nil,
			["TextColor3"] = nil,
			["Text"] = nil,
			["Bold"] = true,
			["RichText"] = true,
			["AnchorPoint"] = Vector2.new(0.5, 0.5),
			["Position"] = UDim2.fromScale(0.5, 0.5),
			["Size"] = UDim2.fromScale(1, 1)
		}
		local rewardsTextColor
		if rewardsUnlocked then
			rewardsTextColor = Color.HealthGreen
		else
			rewardsTextColor = Color.White
		end
		textProps.TextColor3 = rewardsTextColor
		textProps.Text = rewardsUnlocked and "Rewards Unlocked!" or ("<font color=\'rgb(224, 103, 103)\'>%*/%*</font> Steps Completed"):format(requiredSteps, stepCount)
		return createElement(windowComponent, windowProps, titleText, subtitleText, tasksGrid, separator, rewardsTitle, rewardsImage, createElement(gridComponent, gridProps, createElement(textComponent, textProps), React.createElement(CornerRadius, {
			["Radius"] = 10
		})))
	end
}
