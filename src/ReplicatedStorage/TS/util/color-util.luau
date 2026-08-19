-- ColorUtil

local Color =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"TS",
		"color"
	).Color
local ColorUtil = {}
local WHITE_POINT: Vector2 = Vector2.new(0.19783981802579834, 0.46833630128129905)
local lerpMultiColorRgbViaCieluv = nil

function ColorUtil.getHealthColor(progress: number): Color3
	return lerpMultiColorRgbViaCieluv(progress, Color.HealthGreen, Color.Yellow, Color.HealthOrange, Color.HealthRed)
end

function ColorUtil.getDamageColor(progress: number): Color3
	return lerpMultiColorRgbViaCieluv(progress, Color.Yellow, Color.HealthOrange, Color.HealthRed)
end

function ColorUtil.getLevelColour(level: number): Color3
	local fraction = level / 100
	local clampedFraction = math.min(1, fraction)
	local tierColors = {
		Color.Level.TierOne,
		Color.Level.TierTwo,
		Color.Level.TierThree,
		Color.Level.TierFour,
		Color.Level.TierFive,
		Color.Level.TierSix,
		Color.Level.TierSeven,
		Color.Level.TierEight,
		Color.Level.TierNine,
		Color.Level.TierTen,
	}
	local maxIndex = #tierColors - 1
	local scaledIndex = clampedFraction * #tierColors
	local flooredIndex = math.floor(scaledIndex)
	return tierColors[math.min(maxIndex, flooredIndex) + 1]
end

function ColorUtil.color3ToVector3(color: Color3): Vector3
	local red = color.R
	local green = color.G
	local blue = color.B
	return Vector3.new(red, green, blue)
end

local function vector3ToColor3(vector3: Vector3): Color3
	return Color3.new(vector3.X, vector3.Y, vector3.Z)
end
ColorUtil.vector3ToColor3 = vector3ToColor3

local inverseGammaCorrect = nil
local function rgbToXyz(color: Color3): Vector3
	local rgb = inverseGammaCorrect(color) * 100
	local x = rgb.X * 0.4124 + rgb.Y * 0.3576 + rgb.Z * 0.1805
	local y = rgb.X * 0.2126 + rgb.Y * 0.7152 + rgb.Z * 0.0722
	local z = rgb.X * 0.0193 + rgb.Y * 0.1192 + rgb.Z * 0.9505
	return Vector3.new(x, y, z)
end
ColorUtil.rgbToXyz = rgbToXyz

local xyzToCieluv = nil
function ColorUtil.rgbToCieluv(color: Color3): Vector3
	return xyzToCieluv(rgbToXyz(color))
end

local gammaCorrect = nil
local function xyzToRgb(xyz: Vector3): Color3
	local scaledXyz = xyz / 100
	local red = scaledXyz.X * 3.2406 + scaledXyz.Y * -1.5372 + scaledXyz.Z * -0.4986
	local green = scaledXyz.X * -0.9689 + scaledXyz.Y * 1.8758 + scaledXyz.Z * 0.0415
	local blue = scaledXyz.X * 0.0557 + scaledXyz.Y * -0.204 + scaledXyz.Z * 1.057
	return gammaCorrect(Vector3.new(red, green, blue))
end
ColorUtil.xyzToRgb = xyzToRgb

xyzToCieluv = function(xyz: Vector3): Vector3
	local uPrime = 4 * xyz.X / (xyz.X + 15 * xyz.Y + 3 * xyz.Z)
	local vPrime = 9 * xyz.Y / (xyz.X + 15 * xyz.Y + 3 * xyz.Z)
	local fY
	if xyz.Y / 100 > 0.008856 then
		local normalizedY = xyz.Y / 100
		fY = math.pow(normalizedY, 0.3333333333333333)
	else
		fY = 7.787 * xyz.Y / 100 + 0.13793103448275862
	end
	local lightness = 116 * fY - 16
	local uStar = 13 * lightness * (uPrime - WHITE_POINT.X)
	local vStar = 13 * lightness * (vPrime - WHITE_POINT.Y)
	return Vector3.new(lightness, uStar, vStar)
end
ColorUtil.xyzToCieluv = xyzToCieluv

local function cieluvToXyz(cieluv: Vector3): Vector3
	local fY = (cieluv.X + 16) / 116
	local normalizedY
	if math.pow(fY, 3) > 0.008856 then
		normalizedY = math.pow(fY, 3)
	else
		normalizedY = (fY - 0.13793103448275862) / 7.787
	end
	local uPrime = cieluv.Y / (13 * cieluv.X) + WHITE_POINT.X
	local vPrime = cieluv.Z / (13 * cieluv.X) + WHITE_POINT.Y
	local y = normalizedY * 100
	local x = -(9 * y * uPrime) / ((uPrime - 4) * vPrime - uPrime * vPrime)
	local z = (9 * y - 15 * vPrime * y - vPrime * x) / (3 * vPrime)
	return Vector3.new(x, y, z)
end
ColorUtil.cieluvToXyz = cieluvToXyz

local lerpColorRgbViaCieluv = nil
lerpMultiColorRgbViaCieluv = function(progress: number, ...): Color3
	local colors = { ... }
	local segmentCount = #colors - 1
	local scaledIndex = segmentCount * progress
	local lowerIndex = math.floor(scaledIndex)
	local upperIndex = lowerIndex + 1
	if segmentCount < upperIndex then
		return colors[lowerIndex + 1]
	end
	local lowerFraction = lowerIndex / segmentCount
	local upperFraction = upperIndex / segmentCount - lowerFraction
	return lerpColorRgbViaCieluv(
		colors[lowerIndex + 1],
		colors[upperIndex + 1],
		(progress - lowerFraction) / upperFraction
	)
end
ColorUtil.lerpMultiColorRgbViaCieluv = lerpMultiColorRgbViaCieluv

local lerpCieluv = nil
lerpColorRgbViaCieluv = function(colorA: Color3, colorB: Color3, progress: number): Color3
	local vector3ToColor3 = vector3ToColor3
	local xyzToRgb = xyzToRgb
	local cieluvToXyz = cieluvToXyz
	local lerpCieluv = lerpCieluv
	local redA = colorA.R
	local greenA = colorA.G
	local blueA = colorA.B
	local cieluvA = xyzToCieluv(rgbToXyz(Vector3.new(redA, greenA, blueA)))
	local redB = colorB.R
	local greenB = colorB.G
	local blueB = colorB.B
	return vector3ToColor3(
		xyzToRgb(cieluvToXyz(lerpCieluv(cieluvA, xyzToCieluv(rgbToXyz(Vector3.new(redB, greenB, blueB))), progress)))
	)
end
ColorUtil.lerpColorRgbViaCieluv = lerpColorRgbViaCieluv

local lerp = nil
lerpCieluv = function(from: Vector3, to: Vector3, progress: number): Vector3
	local lerpedX = lerp(from.X, to.X, progress)
	local lerpedY = lerp(from.Y, to.Y, progress)
	local lerp = lerp
	local fromZ = from.Z
	local toZ = to.Z
	return Vector3.new(lerpedX, lerpedY, lerp(fromZ, toZ, progress))
end
ColorUtil.lerpCieluv = lerpCieluv

local gammaCorrectValue = nil
gammaCorrect = function(color: Vector3): Vector3
	local red = gammaCorrectValue(color.X)
	local green = gammaCorrectValue(color.Y)
	local gammaCorrectValue = gammaCorrectValue
	local blue = color.Z
	return Vector3.new(red, green, gammaCorrectValue(blue))
end
ColorUtil.gammaCorrect = gammaCorrect

local inverseGammaCorrectValue = nil
inverseGammaCorrect = function(color: Vector3): Vector3
	local red = inverseGammaCorrectValue(color.X)
	local green = inverseGammaCorrectValue(color.Y)
	local inverseGammaCorrectValue = inverseGammaCorrectValue
	local blue = color.Z
	return Vector3.new(red, green, inverseGammaCorrectValue(blue))
end
ColorUtil.inverseGammaCorrect = inverseGammaCorrect

gammaCorrectValue = function(value: number): number
	if value > 0.0031308 then
		return math.pow(value, 0.4166666666666667) * 1.055 - 0.055
	else
		return 12.92 * value
	end
end
ColorUtil.gammaCorrectValue = gammaCorrectValue

inverseGammaCorrectValue = function(value: number): number
	if value <= 0.04045 then
		return value / 12.92
	end
	local scaledValue = (value + 0.055) / 1.055
	return math.pow(scaledValue, 2.4)
end

lerp = function(from: number, to: number, progress: number): number
	return (1 - progress) * from + progress * to
end

function ColorUtil.getColorSequence(colors: { Color3 }?): ColorSequence
	if not colors or #colors == 0 then
		return ColorSequence.new(Color3.fromRGB(255, 255, 255))
	end
	if #colors == 1 then
		return ColorSequence.new(colors[1])
	end
	local keypoints = table.create(#colors)
	for index, color in colors do
		local keypointIndex = index - 1
		keypoints[index] = ColorSequenceKeypoint.new(keypointIndex / (#colors - 1), color)
	end
	return ColorSequence.new(keypoints)
end

function ColorUtil.scaleValue(color: Color3, scale: number): Color3
	local hue, saturation, value = color:ToHSV()
	local fromHSV = Color3.fromHSV
	local scaledValue = value * scale
	return fromHSV(hue, saturation, math.clamp(scaledValue, 0, 1))
end

return {
	["ColorUtil"] = ColorUtil,
}
