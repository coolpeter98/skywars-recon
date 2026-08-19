-- ReportGui

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
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local Confirmation = RuntimeLib.import(script, script.Parent.Parent, "confirmation", "confirmation").Confirmation
local useScreen = RuntimeLib.import(script, script.Parent.Parent, "context", "screen-context").useScreen

type ReportGuiProps = {
	Player: Player,
}

return {
	["ReportGui"] = function(props: ReportGuiProps)
		local screen = useScreen()
		return React.createElement(Confirmation, {
			["Text"] = nil,
			["OnConfirm"] = nil,
			["IsOpen"] = nil,
			["Close"] = nil,
			["SubmittedText"] = "Thank you for submitting a report!",
			["CloseDelay"] = 2,
			["Text"] = ("Are you sure you would like to report %*?"):format(props.Player.DisplayName),
			["OnConfirm"] = function()
				return Flamework.resolveDependency("JEd"):submitReport(props.Player.UserId)
			end,
			["IsOpen"] = screen.IsOpen,
			["Close"] = screen.Close,
		})
	end,
}
