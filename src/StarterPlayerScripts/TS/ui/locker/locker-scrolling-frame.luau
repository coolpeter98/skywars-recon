-- LockerScrollingFrame

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Flamework = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Flamework
local ScreenUtil = RuntimeLib.import(script, script.Parent.Parent, "util", "screen-util").ScreenUtil
local ScrollingFrame = RuntimeLib.import(script, script.Parent.Parent, "components", "common", "scrolling-frame").ScrollingFrame
local CameraViewportContext = RuntimeLib.import(script, script.Parent.Parent, "context", "camera-viewport-context").CameraViewportContext
local ScreenConstants = RuntimeLib.import(script, script.Parent.Parent, "screen-constants").ScreenConstants
local CosmeticSlot = RuntimeLib.import(script, script.Parent.Parent, "cosmetics", "cosmetic-slot").CosmeticSlot
local Size = RuntimeLib.import(script, script.Parent.Parent, "size").Size
local TimeUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "time-util").TimeUtil
local React = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react")
local useContext = React.useContext
local useState = React.useState
return {
	["LockerScrollingFrame"] = function(props)
		local seed = useState(math.random() * os.clock())
		local inverseScale = 1 - useContext(CameraViewportContext).Scale
		local scaleFactor = math.clamp(inverseScale, 0, 1) + 1
		local width = props.Size.X.Offset
		local columnCountRaw = width / (scaleFactor * 210)
		local columns = math.floor(columnCountRaw)
		local totalPadding = (columns - 1) * ScreenConstants.PADDING_1
		local cellSizeRaw = (width - 40 - totalPadding) / columns
		local cellSize = math.floor(cellSizeRaw)
		local rowsRaw = #props.LockerCosmeticsState.Cosmetics / columns
		local rows = math.ceil(rowsRaw)
		local cosmetics = props.LockerCosmeticsState.Cosmetics
		local slots = table.create(#cosmetics)
		local function createCosmeticSlot(cosmetic, layoutOrder)
			return React.createElement(CosmeticSlot, {
				["Size"] = nil,
				["CosmeticId"] = nil,
				["Active"] = nil,
				["Locked"] = nil,
				["LayoutOrder"] = nil,
				["Seed"] = nil,
				["Activated"] = nil,
				["ActivateReroute"] = true,
				["Size"] = Size.new(cellSize, cellSize),
				["CosmeticId"] = cosmetic.Id,
				["Active"] = props.LockerCosmeticsState.IsActive(cosmetic),
				["Locked"] = not props.LockerCosmeticsState.IsOwned(cosmetic),
				["LayoutOrder"] = layoutOrder,
				["Seed"] = seed,
				["Activated"] = function(activated)
					if not TimeUtil.elapsed(props.LockerCosmeticsState.CosmeticTypeFilterChangedTime, 0.2) then
						return nil
					end
					if not activated then
						Flamework.resolveDependency("Ggz"):enableCosmetic(cosmetic.Id)
					end
				end
			})
		end
		for index, cosmetic in cosmetics do
			slots[index] = createCosmeticSlot(cosmetic, index - 1, cosmetics)
		end
		local createElement = React.createElement
		local scrollingFrame = ScrollingFrame
		local scrollingFrameProps = {
			["AnchorPoint"] = props.AnchorPoint,
			["Position"] = props.Position,
			["Size"] = props.Size,
			["CanvasHeight"] = ScreenUtil.getGridSize(cellSize, ScreenConstants.PADDING_1, rows),
			["GridLayout"] = {
				["CellSize"] = UDim2.fromOffset(cellSize, cellSize),
				["CellPadding"] = UDim2.fromOffset(10, 10)
			}
		}
		return createElement(scrollingFrame, scrollingFrameProps, slots)
	end
}
