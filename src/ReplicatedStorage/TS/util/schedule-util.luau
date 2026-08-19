-- ScheduleUtil

local RuntimeLib =
	require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RunService: RunService = RuntimeLib.import(
	script,
	game:GetService("ReplicatedStorage"),
	"rbxts_include",
	"node_modules",
	"@rbxts",
	"services"
).RunService
local MathUtil = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "util", "math-util").MathUtil
return {
	["ScheduleUtil"] = {
		["createSchedule"] = function(interval: number, callback: () -> ()): RBXScriptConnection
			local elapsed = 0
			return RunService.Heartbeat:Connect(function(dt: number)
				elapsed = elapsed + dt
				if elapsed < interval then
					return nil
				end
				elapsed = elapsed - interval
				callback()
			end)
		end,
		["createIntermittentSchedule"] = function(
			intervalRange: Vector2,
			callback: () -> number?,
			initialDelay: number?
		): RBXScriptConnection
			local timer = initialDelay == nil and 0 or initialDelay
			return RunService.Heartbeat:Connect(function(dt: number)
				timer = timer - dt
				if timer > 0 then
					return nil
				end
				timer = MathUtil.random(intervalRange.X, intervalRange.Y)
				local result = callback()
				if result ~= nil then
					timer = timer + result
				end
			end)
		end,
		["runTask"] = function(callback: () -> (), delay: number?)
			task.spawn(function()
				if delay == nil or delay <= 0 then
					RunService.Heartbeat:Wait()
				else
					task.wait(delay)
				end
				callback()
			end)
		end,
	},
}
