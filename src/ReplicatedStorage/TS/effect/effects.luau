-- Effects: registry of all game effects, keyed by effect type

type EffectEntry = {
	Type: string,
	Effect: any,
}

local Effects: { [string]: EffectEntry } = {}

for _, effectData in
	{
		{
			["Type"] = "POWER_UP_EFFECT",
			["Effect"] = nil,
			["Effect"] = require(
				game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
			).import(script, game:GetService("ReplicatedStorage"), "TS", "effect", "power-up-effect").PowerUpEffect,
		},
	}
do
	Effects[effectData.Type] = effectData
end

return {
	["Effects"] = Effects,
}
