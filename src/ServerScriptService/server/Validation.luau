--!strict

type Arguments = {
	n: number,
	[number]: any,
}
export type ValueValidator = (value: any) -> boolean

local Validation = {}

local function isFinite(value: number): boolean
	return value == value and value ~= math.huge and value ~= -math.huge
end

function Validation.any(_: any): boolean
	return true
end

function Validation.boolean(value: any): boolean
	return type(value) == "boolean"
end

function Validation.string(value: any): boolean
	return type(value) == "string"
end

function Validation.nonEmptyString(value: any): boolean
	return type(value) == "string" and #value > 0
end

function Validation.finiteNumber(value: any): boolean
	return type(value) == "number" and isFinite(value)
end

function Validation.numberRange(minimum: number, maximum: number): ValueValidator
	return function(value: any): boolean
		return Validation.finiteNumber(value) and value >= minimum and value <= maximum
	end
end

function Validation.integer(value: any): boolean
	return Validation.finiteNumber(value) and value % 1 == 0
end

function Validation.finiteVector3(value: any): boolean
	return typeof(value) == "Vector3" and isFinite(value.X) and isFinite(value.Y) and isFinite(value.Z)
end

function Validation.instance(className: string?): ValueValidator
	return function(value: any): boolean
		if typeof(value) ~= "Instance" then
			return false
		end
		return className == nil or value:IsA(className)
	end
end

function Validation.optional(validator: ValueValidator): ValueValidator
	return function(value: any): boolean
		return value == nil or validator(value)
	end
end

function Validation.literal(values: { string }): ValueValidator
	local allowed: { [string]: boolean } = {}
	for _, value in values do
		allowed[value] = true
	end
	return function(value: any): boolean
		return type(value) == "string" and allowed[value] == true
	end
end

function Validation.arrayOf(validator: ValueValidator, maximumLength: number?): ValueValidator
	return function(value: any): boolean
		if type(value) ~= "table" then
			return false
		end
		local length = #value
		if maximumLength ~= nil and length > maximumLength then
			return false
		end
		for key in value do
			if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > length then
				return false
			end
		end
		for index = 1, length do
			if not validator(value[index]) then
				return false
			end
		end
		return true
	end
end

function Validation.tuple(
	validators: { ValueValidator },
	minimumArity: number?
): (arguments: Arguments) -> (boolean, string?)
	local minimum = minimumArity == nil and #validators or minimumArity
	return function(arguments: Arguments): (boolean, string?)
		if arguments.n < minimum or arguments.n > #validators then
			return false, ("expected %d..%d arguments, received %d"):format(minimum, #validators, arguments.n)
		end
		for index = 1, #validators do
			if index <= arguments.n and not validators[index](arguments[index]) then
				return false, ("argument %d has an invalid type or value"):format(index)
			end
		end
		return true
	end
end

function Validation.settingUpdate(arguments: Arguments): (boolean, string?)
	if arguments.n ~= 2 or type(arguments[1]) ~= "string" then
		return false, "expected a setting name and value"
	end
	local settingValidators: { [string]: ValueValidator } = {
		MusicVolume = Validation.numberRange(0, 100),
		SfxVolume = Validation.numberRange(0, 100),
		PartyInvitePrivacy = Validation.literal({ "Friends", "Public", "Private" }),
		AutoQueue = Validation.boolean,
		FieldOfView = Validation.numberRange(50, 90),
	}
	local validator = settingValidators[arguments[1]]
	if validator == nil then
		return false, "unknown setting name"
	end
	if not validator(arguments[2]) then
		return false, "setting value has an invalid type or value"
	end
	return true
end

return Validation
