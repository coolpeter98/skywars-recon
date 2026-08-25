local utils = require(script.Parent.utils)

export type Schema<T> = {
	read initial: T,
	read migrations: { (any) -> any },
}

local function create<T>(initial: T): Schema<T>
	local initial = utils.deepfreeze(initial)

	return table.freeze({
		initial = initial,
		migrations = table.freeze({} :: { (any) -> any }),
	})
end

local function migrate<T, U>(schema: Schema<T>, migration: (T) -> U): Schema<U>
	local initial = schema.initial
	local success, initial = utils.externcall(migration, initial)

	if not success then
		error("migration function failed on initial data")
	end

	local initial = utils.deepfreeze(initial)

	local migrations = table.clone(schema.migrations)
	table.insert(migrations, migration)
	table.freeze(migrations)
	
	return table.freeze({
		initial = initial,
		migrations = migrations,
	})
end

return table.freeze({
	create = create,
	migrate = migrate,
})
