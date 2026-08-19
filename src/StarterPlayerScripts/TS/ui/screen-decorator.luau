-- ScreenDecorator

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
	["getScreenOptions"] = function(screen)
		local matchedDecorator = nil
		for index, decorator in Modding.getDecorators("Az") do
			local _ = index - 1
			local matches
			if type(screen) == "string" then
				matches = decorator.arguments[1].ScreenId == screen
			else
				matches = decorator.object == screen
			end
			if matches == true then
				matchedDecorator = decorator
				break
			end
		end
		if not matchedDecorator then
			error((("Missing ScreenDecorator for screen %*"):format(screen)))
		end
		return { matchedDecorator.arguments[1], matchedDecorator.object }
	end,
	["ScreenDecorator"] = Modding.createMetaDecorator("Class"),
}
