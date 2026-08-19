-- ProjectileConstants

export type ProjectileConstants = {
	COOLDOWN: number,
	ORIGIN_OFFSET: CFrame,
}

local projectileConstants: ProjectileConstants = {
	COOLDOWN = 0.05,
	ORIGIN_OFFSET = CFrame.new(Vector3.new(0.5, 1.3, -2)),
}

return projectileConstants
