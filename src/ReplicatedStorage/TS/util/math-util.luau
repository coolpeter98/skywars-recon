-- MathUtil

return {
	["MathUtil"] = {
		["random"] = function(min: number, max: number): number
			return math.random() * (max - min) + min
		end,
		["toRomanNumeral"] = function(num: number): string
			local result = {}
			for _, pair in
				{
					{ "M", 1000 },
					{ "CM", 900 },
					{ "D", 500 },
					{ "CD", 400 },
					{ "C", 100 },
					{ "XC", 90 },
					{ "L", 50 },
					{ "XL", 40 },
					{ "X", 10 },
					{ "IX", 9 },
					{ "V", 5 },
					{ "IV", 4 },
					{ "I", 1 },
				}
			do
				local symbol = pair[1]
				local amount = pair[2]
				while amount <= num do
					table.insert(result, symbol)
					num = num - amount
				end
			end
			return table.concat(result, "")
		end,
		["isWholeNumber"] = function(num: number): boolean
			local isWhole
			if num == num then
				isWhole = num % 1 == 0
			else
				isWhole = false
			end
			return isWhole
		end,
	},
}
