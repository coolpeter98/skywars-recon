-- InstanceUtil

local InstanceUtil = {}

local getViewportFrameAncestor: (instance: Instance) -> ViewportFrame? = nil

function InstanceUtil.isViewportFrameDescendent(instance: Instance): boolean
	return getViewportFrameAncestor(instance) ~= nil
end

getViewportFrameAncestor = function(instance: Instance): ViewportFrame?
	local current: Instance? = instance.Parent
	local depth = 0
	while current ~= nil and depth < 10 do
		if current:IsA("ViewportFrame") then
			return current
		end
		current = current.Parent
		depth = depth + 1
	end
	return nil
end

InstanceUtil.getViewportFrameAncestor = getViewportFrameAncestor

return {
	["createInstance"] = function(name: string, className: string, parent: Instance?): Instance
		local instance = Instance.new(className, parent)
		instance.Name = name
		return instance
	end,
	["InstanceUtil"] = InstanceUtil,
}
