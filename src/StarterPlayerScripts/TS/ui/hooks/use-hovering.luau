-- useHovering

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState
local Maid = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"maid",
	"Maid"
)

return {
	["useHovering"] = function(ref: { current: GuiObject? }): boolean
		local isHovering, setIsHovering = useState(false)

		useEffect(function()
			if not ref.current then
				return nil
			end

			local maid = Maid.new()
			maid:GiveTask(ref.current.MouseEnter:Connect(function()
				return setIsHovering(true)
			end))
			maid:GiveTask(ref.current.MouseLeave:Connect(function()
				return setIsHovering(false)
			end))

			return function()
				return maid:DoCleaning()
			end
		end, {})

		return isHovering
	end,
}
