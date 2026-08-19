--!nonstrict
--[[
	AtomicBinding — restored Roblox default helper module.

	The decompiled copy in this place was an empty stub ("original file
	contained no code; skipped by decompiler"), which broke the default
	RbxCharacterSounds script (require returned no value).

	This is a faithful reimplementation of Roblox's default AtomicBinding:
	it binds a callback to a set of class-typed descendants of a root
	instance, waiting until every one of them exists, and re-binds when a
	resolved instance is removed (e.g. when a character resets).
]]

local AtomicBinding = {}
AtomicBinding.__index = AtomicBinding

local function findInstanceByClass(root: Instance, className: string): Instance?
	if root:IsA(className) then
		return root
	end
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA(className) then
			return descendant
		end
	end
	return nil
end

function AtomicBinding.new(instances: { [string]: string }, callback: ({ [string]: Instance }) -> (() -> ())?)
	local self = setmetatable({}, AtomicBinding)
	self._instances = instances
	self._callback = callback
	self._bindings = {}
	return self
end

function AtomicBinding:bindRoot(root: Instance)
	if self._bindings[root] then
		return
	end

	local resolved: { [string]: Instance } = {}
	local terminate: (() -> ())? = nil
	local connections: { RBXScriptConnection } = {}

	local function tryBind()
		if terminate then
			return
		end

		local allFound = true
		for alias, className in pairs(self._instances) do
			local instance = resolved[alias]
			if instance == nil or instance.Parent == nil then
				instance = findInstanceByClass(root, className)
				resolved[alias] = instance
			end
			if instance == nil then
				allFound = false
			end
		end

		if allFound then
			terminate = self._callback(resolved)
		end
	end

	tryBind()

	connections[1] = root.DescendantAdded:Connect(function()
		task.defer(tryBind)
	end)

	-- Re-bind when a resolved instance is removed (e.g. character reset).
	connections[2] = root.DescendantRemoving:Connect(function(instance)
		for alias, found in pairs(resolved) do
			if found == instance then
				if terminate then
					terminate()
					terminate = nil
				end
				resolved[alias] = nil
			end
		end
	end)

	self._bindings[root] = {
		connections = connections,
		terminate = terminate,
	}
end

function AtomicBinding:unbindRoot(root: Instance)
	local binding = self._bindings[root]
	if binding then
		for _, connection in ipairs(binding.connections) do
			connection:Disconnect()
		end
		if binding.terminate then
			binding.terminate()
		end
		self._bindings[root] = nil
	end
end

return AtomicBinding
