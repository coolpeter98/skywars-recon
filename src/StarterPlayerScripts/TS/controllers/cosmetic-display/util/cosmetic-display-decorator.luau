-- CosmeticDisplayDecorator

local Modding = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Modding

return {
	["getCosmeticDisplays"] = function(): { { any } }
		local decorators = Modding.getDecorators("MJo")
		local results = table.create(#decorators)
		for index, decorator in decorators do
			local _ = index - 1
			results[index] = { decorator.arguments[1], decorator.object.new() }
		end
		return results
	end,
	["CosmeticDisplayDecorator"] = Modding.createMetaDecorator("Class"),
}
