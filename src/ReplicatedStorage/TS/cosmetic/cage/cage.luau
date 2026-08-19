-- Cage

local VectorUtil = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "TS", "util", "vector-util").VectorUtil

export type Cage = {
	createCageGuard: (
		self: Cage,
		maid: { GiveTask: (task: unknown) -> () },
		part: BasePart,
		parent: Instance,
		createDown: boolean?
	) -> (),
	createPart: (self: Cage, cframe: CFrame, parent: Instance) -> Part,
}

local Cage: Cage = {
	["constructor"] = function(self: Cage) end,
	["createCageGuard"] = function(
		self: Cage,
		maid: { GiveTask: (task: unknown) -> () },
		part: BasePart,
		parent: Instance,
		createDown: boolean?
	)
		if createDown == nil then
			createDown = false
		end
		local center = part.Position + Vector3.new(0, 6, 0) - Vector3.new(0, 0, 0)
		for _, normal in VectorUtil.NORMALS do
			if not createDown or normal ~= VectorUtil.DOWN then
				local offset = normal * 6
				maid:GiveTask((self:createPart(CFrame.new(center + offset, center), parent)))
			end
		end
	end,
	["createPart"] = function(self: Cage, cframe: CFrame, parent: Instance)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CFrame = cframe
		part.Size = Vector3.new(15, 15, 3)
		part.Material = Enum.Material.Plastic
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = parent
		return part
	end,
}
return {
	["Cage"] = Cage,
}
