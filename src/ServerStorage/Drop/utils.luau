local callbacks = require(script.Parent.callbacks)

local function deepfreeze<T>(tbl: T): T
	if table.isfrozen(tbl) then
		return tbl
	end

	for _, v in tbl :: { [any]: any } do
		if type(v) == "table" then
			deepfreeze(v)
		end
	end

	return table.freeze(tbl :: any)
end

local function externcall<Arg, Ret>(fn: (Arg) -> Ret, arg: Arg): (boolean, Ret)
	return xpcall(function(fn: (any) -> any, arg: any)
		for ret in fn, arg do
			return ret
		end
	end, function(err)
		callbacks.externerror(err)
		return err
	end, fn, arg)
end

return table.freeze({
	deepfreeze = deepfreeze,
	externcall = externcall,
})
