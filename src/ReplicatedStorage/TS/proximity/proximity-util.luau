-- ProximityUtil

type ProximityUtil = {
	createProximityActivator: (maxActivationDistance: number) -> ProximityPrompt,
	createTriggeredPrompt: (objectText: string?, actionText: string?, onTriggered: (() -> ())?) -> ProximityPrompt,
	createProximityPrompt: (objectText: string?, actionText: string?) -> ProximityPrompt,
}

local ProximityUtil: ProximityUtil = {
	createProximityActivator = function(maxActivationDistance: number): ProximityPrompt
		local prompt = ProximityUtil.createProximityPrompt(nil, nil)
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = maxActivationDistance
		prompt.Style = Enum.ProximityPromptStyle.Custom
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
		return prompt
	end,
	createTriggeredPrompt = function(
		objectText: string?,
		actionText: string?,
		onTriggered: (() -> ())?
	): ProximityPrompt
		local prompt = ProximityUtil.createProximityPrompt(objectText, actionText)
		if onTriggered then
			prompt.Triggered:Connect(onTriggered)
		end
		return prompt
	end,
	createProximityPrompt = function(objectText: string?, actionText: string?): ProximityPrompt
		local prompt = Instance.new("ProximityPrompt")
		if objectText ~= "" and objectText then
			prompt.ObjectText = objectText
		end
		if actionText ~= "" and actionText then
			prompt.ActionText = actionText
		end
		prompt.ClickablePrompt = true
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
		prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.MaxActivationDistance = 20
		prompt.RequiresLineOfSight = false
		return prompt
	end,
}
return {
	ProximityUtil = ProximityUtil,
}
