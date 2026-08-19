-- usePlayerIcon

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Players: Players = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).Players
local React =
	RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useEffect = React.useEffect
local useState = React.useState

type PlayerIconProps = {
	UserId: number,
	ThumbnailType: Enum.ThumbnailType?,
	ThumbnailSize: Enum.ThumbnailSize?,
}

return {
	["usePlayerIcon"] = function(props: PlayerIconProps): string?
		local icon, setIcon = useState(nil)
		useEffect(function()
			local cancelled = false
			task.spawn(function()
				local assetId, isReady = Players:GetUserThumbnailAsync(
					props.UserId,
					props.ThumbnailType or Enum.ThumbnailType.AvatarBust,
					props.ThumbnailSize or Enum.ThumbnailSize.Size420x420
				)
				if cancelled then
					return nil
				elseif isReady then
					setIcon(assetId)
				else
					setIcon(nil)
				end
			end)
			return function()
				cancelled = true
			end
		end, { props.UserId })
		return icon
	end,
}
