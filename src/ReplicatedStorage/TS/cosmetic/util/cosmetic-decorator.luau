-- CosmeticDecorator

local Modding =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")).import(
		script,
		game:GetService("ReplicatedStorage"),
		"rbxts_include",
		"node_modules",
		"@flamework",
		"core",
		"out"
	).Modding

return {
	["getCosmeticConstructor"] = function(cosmeticId: string): any?
		local foundDecorator = nil
		for index, decorator in Modding.getDecorators("1YG") do
			local _ = index - 1
			if decorator.arguments[1] == cosmeticId == true then
				foundDecorator = decorator
				break
			end
		end
		if foundDecorator then
			return foundDecorator.object
		else
			return nil
		end
	end,
	["CosmeticDecorator"] = Modding.createMetaDecorator("Class"),
}
