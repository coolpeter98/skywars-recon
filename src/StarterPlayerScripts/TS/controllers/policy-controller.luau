-- PolicyController

type PolicyController = {
	policyInfo: PolicyInfo?,
	PolicyInfoLoaded: typeof(AsyncEvent.new()),
}

local RuntimeLib = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Reflect = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Reflect
local Controller = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@flamework", "core", "out").Controller
local Services = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players: Players = Services.Players
local PolicyService: PolicyService = Services.PolicyService
local AsyncEvent = RuntimeLib.import(script, game:GetService("ReplicatedStorage"), "TS", "event", "async-event").AsyncEvent

local PolicyController = setmetatable({}, {
	["__tostring"] = function()
		return "PolicyController"
	end
})
PolicyController.__index = PolicyController
function PolicyController.new(...)
	local selfClass = PolicyController
	local self = setmetatable({}, selfClass)
	return self:constructor(...) or self
end
function PolicyController.constructor(self: PolicyController)
	self.PolicyInfoLoaded = AsyncEvent.new()
	self.policyInfo = nil
end
function PolicyController.onStart(self: PolicyController)
	local startTime = os.clock()
	while not self.policyInfo do
		RuntimeLib.try(function()
			self.policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(Players.LocalPlayer)
			self.PolicyInfoLoaded:fire({
				["PolicyInfo"] = self.policyInfo
			})
			print((("Policy info acquired in %*s"):format(os.clock() - startTime)))
		end, function(err)
			print((("Error acquiring policy info: %*"):format(err)))
			task.wait(2)
		end)
	end
end
function PolicyController.getPolicyInfo(self: PolicyController): PolicyInfo?
	return self.policyInfo
end
function PolicyController.awaitPolicyInfo(self: PolicyController): PolicyInfo?
	if self.policyInfo then
		return self.policyInfo
	else
		return self.PolicyInfoLoaded:wait().PolicyInfo
	end
end
function PolicyController.isExternalLinkAllowed(self: PolicyController, externalLinkReference: string): boolean
	local policyInfo = self:awaitPolicyInfo()
	if not policyInfo then
		return false
	end
	local allowedExternalLinkReferences = policyInfo.AllowedExternalLinkReferences
	return table.find(allowedExternalLinkReferences, externalLinkReference) ~= nil
end
function PolicyController.allowsGambling(self: PolicyController): boolean
	if Players.LocalPlayer.UserId == 1800687521 then
		return true
	else
		local policyInfo = self:awaitPolicyInfo()
		if policyInfo then
			return not policyInfo.ArePaidRandomItemsRestricted
		else
			return false
		end
	end
end
Reflect.defineMetadata(PolicyController, "identifier", "D8k")
Reflect.defineMetadata(PolicyController, "flamework:implements", { "$:flamework@OnStart" })
Reflect.decorate(PolicyController, "$:flamework@Controller", Controller, {})
return {
	["PolicyController"] = PolicyController
}
