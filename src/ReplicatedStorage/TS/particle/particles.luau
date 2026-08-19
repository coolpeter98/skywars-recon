-- Particles

local ColorUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "TS", "util", "color-util").ColorUtil
return {
	["Particles"] = {
		["crate"] = function(color: Color3, overrides: { [string]: any }?): { [string]: any }
			local properties = {
				["Color"] = nil,
				["Size"] = nil,
				["Rate"] = 50,
				["Speed"] = 3,
				["Lifetime"] = nil,
				["Rotation"] = nil,
				["LightInfluence"] = 5,
				["SpreadAngle"] = nil,
				["LockedToPart"] = false,
				["Transparency"] = nil,
				["Color"] = ColorUtil.getColorSequence({ ColorUtil.scaleValue(color, 1.2), color, ColorUtil.scaleValue(color, 0.8) }),
				["Size"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.1) }),
				["Lifetime"] = NumberRange.new(0.5, 1.5),
				["Rotation"] = NumberRange.new(0, 360),
				["SpreadAngle"] = Vector2.new(90, 90),
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(0.8, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				})
			}
			if overrides then
				for key, value in overrides do
					properties[key] = value
				end
			end
			return properties
		end,
		["sparkle"] = function(color: Color3, overrides: { [string]: any }?): { [string]: any }
			local properties = {
				["Brightness"] = 1,
				["Color"] = nil,
				["LightInfluence"] = 100,
				["Size"] = nil,
				["Transparency"] = nil,
				["EmissionDirection"] = nil,
				["Lifetime"] = nil,
				["Rate"] = 5,
				["Rotation"] = nil,
				["Speed"] = 0.5,
				["SpreadAngle"] = nil,
				["Color"] = ColorUtil.getColorSequence({ ColorUtil.scaleValue(color, 1), ColorUtil.scaleValue(color, 1.2), ColorUtil.scaleValue(color, 0.8) }),
				["Size"] = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.01, 0.2), NumberSequenceKeypoint.new(1, 0) }),
				["Transparency"] = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.05, 0),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(0.8, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				}),
				["EmissionDirection"] = Enum.NormalId.Bottom,
				["Lifetime"] = NumberRange.new(3, 6),
				["Rotation"] = NumberRange.new(0, 360),
				["SpreadAngle"] = Vector2.new(5, 5)
			}
			if overrides then
				for key, value in overrides do
					properties[key] = value
				end
			end
			return properties
		end
	}
}
