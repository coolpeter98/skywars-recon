-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

local v_u_1 = {
	["__mode"] = "k"
}
local function v7(p_u_2, p3) -- name: makeEnum
	local v4 = {}
	for _, v5 in ipairs(p3) do
		v4[v5] = v5
	end
	return setmetatable(v4, {
		["__index"] = function(_, p6) -- name: __index
			-- upvalues: (copy) p_u_2
			error(string.format("%s is not in %s!", p6, p_u_2), 2)
		end,
		["__newindex"] = function() -- name: __newindex
			-- upvalues: (copy) p_u_2
			error(string.format("Creating new members in %s is not allowed!", p_u_2), 2)
		end
	})
end
local v_u_8 = {
	["Kind"] = v7("Promise.Error.Kind", {
		"ExecutionError",
		"AlreadyCancelled",
		"NotResolvedInTime",
		"TimedOut"
	})
}
v_u_8.__index = v_u_8
function v_u_8.new(p9, p10) -- name: new
	-- upvalues: (ref) v_u_8
	local v11 = p9 or {}
	local v12 = {}
	local v13 = v11.error
	v12.error = tostring(v13) or "[This error has no error text.]"
	v12.trace = v11.trace
	v12.context = v11.context
	v12.kind = v11.kind
	v12.parent = p10
	v12.createdTick = os.clock()
	v12.createdTrace = debug.traceback()
	local v14 = v_u_8
	return setmetatable(v12, v14)
end
function v_u_8.is(p15) -- name: is
	if type(p15) == "table" then
		local v16 = getmetatable(p15)
		if type(v16) == "table" then
			local v17
			if rawget(p15, "error") == nil then
				v17 = false
			else
				local v18 = rawget(v16, "extend")
				v17 = type(v18) == "function"
			end
			return v17
		end
	end
	return false
end
function v_u_8.isKind(p19, p20) -- name: isKind
	-- upvalues: (ref) v_u_8
	local v21 = p20 ~= nil
	assert(v21, "Argument #2 to Promise.Error.isKind must not be nil")
	local v22 = v_u_8.is(p19)
	if v22 then
		v22 = p19.kind == p20
	end
	return v22
end
function v_u_8.extend(p23, p24) -- name: extend
	-- upvalues: (ref) v_u_8
	local v25 = p24 or {}
	v25.kind = v25.kind or p23.kind
	return v_u_8.new(v25, p23)
end
function v_u_8.getErrorChain(p26) -- name: getErrorChain
	local v27 = { p26 }
	while v27[#v27].parent do
		local v28 = v27[#v27].parent
		table.insert(v27, v28)
	end
	return v27
end
function v_u_8.__tostring(p29) -- name: __tostring
	local v30 = { string.format("-- Promise.Error(%s) --", p29.kind or "?") }
	for _, v31 in ipairs(p29:getErrorChain()) do
		local v32 = table.concat
		local v33 = { v31.trace or v31.error, v31.context }
		table.insert(v30, v32(v33, "\n"))
	end
	return table.concat(v30, "\n")
end
local function v_u_34(...) -- name: pack
	return select("#", ...), { ... }
end
local function v_u_36(p35, ...) -- name: packResult
	return p35, select("#", ...), { ... }
end
local function v_u_43(p_u_37, p38, ...) -- name: runExecutor
	-- upvalues: (copy) v_u_36, (ref) v_u_8
	local v39 = v_u_36
	local v40 = xpcall
	local v41 = p_u_37 ~= nil
	assert(v41, "traceback is nil")
	return v39(v40(p38, function(p42)
		-- upvalues: (ref) v_u_8, (copy) p_u_37
		if type(p42) == "table" then
			return p42
		else
			return v_u_8.new({
				["error"] = p42,
				["kind"] = v_u_8.Kind.ExecutionError,
				["trace"] = debug.traceback(tostring(p42), 2),
				["context"] = "Promise created at:\n\n" .. p_u_37
			})
		end
	end, ...))
end
local v_u_44 = {
	["Error"] = v_u_8,
	["Status"] = v7("Promise.Status", {
		"Started",
		"Resolved",
		"Rejected",
		"Cancelled"
	}),
	["_getTime"] = os.clock,
	["_timeEvent"] = game:GetService("RunService").Heartbeat,
	["_unhandledRejectionCallbacks"] = {},
	["prototype"] = {}
}
v_u_44.__index = v_u_44.prototype
function v_u_44._new(p45, p_u_46, p47) -- name: _new
	-- upvalues: (copy) v_u_44, (copy) v_u_1, (copy) v_u_43
	if p47 ~= nil and not v_u_44.is(p47) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end
	local v_u_48 = {
		["_thread"] = nil,
		["_source"] = nil,
		["_status"] = nil,
		["_values"] = nil,
		["_valuesLength"] = -1,
		["_unhandledRejection"] = true,
		["_queuedResolve"] = nil,
		["_queuedReject"] = nil,
		["_queuedFinally"] = nil,
		["_cancellationHook"] = nil,
		["_parent"] = nil,
		["_consumers"] = nil,
		["_source"] = p45,
		["_status"] = v_u_44.Status.Started,
		["_queuedResolve"] = {},
		["_queuedReject"] = {},
		["_queuedFinally"] = {},
		["_parent"] = p47
	}
	local v49 = v_u_1
	v_u_48._consumers = setmetatable({}, v49)
	if p47 and p47._status == v_u_44.Status.Started then
		p47._consumers[v_u_48] = true
	end
	local v50 = v_u_44
	setmetatable(v_u_48, v50)
	local function v_u_51(...) -- name: resolve
		-- upvalues: (copy) v_u_48
		v_u_48:_resolve(...)
	end
	local function v_u_52(...) -- name: reject
		-- upvalues: (copy) v_u_48
		v_u_48:_reject(...)
	end
	local function v_u_54(p53) -- name: onCancel
		-- upvalues: (copy) v_u_48, (ref) v_u_44
		if p53 then
			if v_u_48._status == v_u_44.Status.Cancelled then
				p53()
			else
				v_u_48._cancellationHook = p53
			end
		end
		return v_u_48._status == v_u_44.Status.Cancelled
	end
	v_u_48._thread = coroutine.create(function()
		-- upvalues: (ref) v_u_43, (copy) v_u_48, (copy) p_u_46, (copy) v_u_51, (copy) v_u_52, (copy) v_u_54
		local v55, _, v56 = v_u_43(v_u_48._source, p_u_46, v_u_51, v_u_52, v_u_54)
		if not v55 then
			v_u_52(v56[1])
		end
	end)
	task.spawn(v_u_48._thread)
	return v_u_48
end
function v_u_44.new(p57) -- name: new
	-- upvalues: (copy) v_u_44
	return v_u_44._new(debug.traceback(nil, 2), p57)
end
function v_u_44.__tostring(p58) -- name: __tostring
	return string.format("Promise(%s)", p58._status)
end
function v_u_44.defer(p_u_59) -- name: defer
	-- upvalues: (copy) v_u_44, (copy) v_u_43
	local v_u_60 = debug.traceback(nil, 2)
	return v_u_44._new(v_u_60, function(p_u_61, p_u_62, p_u_63)
		-- upvalues: (ref) v_u_44, (ref) v_u_43, (copy) v_u_60, (copy) p_u_59
		local v_u_64 = nil
		v_u_64 = v_u_44._timeEvent:Connect(function()
			-- upvalues: (ref) v_u_64, (ref) v_u_43, (ref) v_u_60, (ref) p_u_59, (copy) p_u_61, (copy) p_u_62, (copy) p_u_63
			v_u_64:Disconnect()
			local v65, _, v66 = v_u_43(v_u_60, p_u_59, p_u_61, p_u_62, p_u_63)
			if not v65 then
				p_u_62(v66[1])
			end
		end)
	end)
end
v_u_44.async = v_u_44.defer
function v_u_44.resolve(...) -- name: resolve
	-- upvalues: (copy) v_u_34, (copy) v_u_44
	local v_u_67, v_u_68 = v_u_34(...)
	return v_u_44._new(debug.traceback(nil, 2), function(p69)
		-- upvalues: (copy) v_u_68, (copy) v_u_67
		local v70 = v_u_68
		local v71 = v_u_67
		p69(unpack(v70, 1, v71))
	end)
end
function v_u_44.reject(...) -- name: reject
	-- upvalues: (copy) v_u_34, (copy) v_u_44
	local v_u_72, v_u_73 = v_u_34(...)
	return v_u_44._new(debug.traceback(nil, 2), function(_, p74)
		-- upvalues: (copy) v_u_73, (copy) v_u_72
		local v75 = v_u_73
		local v76 = v_u_72
		p74(unpack(v75, 1, v76))
	end)
end
function v_u_44._try(p77, p_u_78, ...) -- name: _try
	-- upvalues: (copy) v_u_34, (copy) v_u_44
	local v_u_79, v_u_80 = v_u_34(...)
	return v_u_44._new(p77, function(p81)
		-- upvalues: (copy) p_u_78, (copy) v_u_80, (copy) v_u_79
		local v82 = v_u_80
		local v83 = v_u_79
		p81(p_u_78(unpack(v82, 1, v83)))
	end)
end
function v_u_44.try(p84, ...) -- name: try
	-- upvalues: (copy) v_u_44
	return v_u_44._try(debug.traceback(nil, 2), p84, ...)
end
function v_u_44._all(p85, p_u_86, p_u_87) -- name: _all
	-- upvalues: (copy) v_u_44
	if type(p_u_86) ~= "table" then
		error(string.format("Please pass a list of promises to %s", "Promise.all"), 3)
	end
	for v88, v89 in pairs(p_u_86) do
		if not v_u_44.is(v89) then
			error(string.format("Non-promise value passed into %s at index %s", "Promise.all", (tostring(v88))), 3)
		end
	end
	if #p_u_86 == 0 or p_u_87 == 0 then
		return v_u_44.resolve({})
	else
		return v_u_44._new(p85, function(p_u_90, p_u_91, p92)
			-- upvalues: (copy) p_u_87, (copy) p_u_86
			local v_u_93 = {}
			local v_u_94 = {}
			local v_u_95 = 0
			local v_u_96 = 0
			local v_u_97 = false
			local function v_u_100(p98, ...) -- name: resolveOne
				-- upvalues: (ref) v_u_97, (ref) v_u_95, (ref) p_u_87, (copy) v_u_93, (ref) p_u_86, (copy) p_u_90, (copy) v_u_94
				if not v_u_97 then
					v_u_95 = v_u_95 + 1
					if p_u_87 == nil then
						v_u_93[p98] = ...
					else
						v_u_93[v_u_95] = ...
					end
					if v_u_95 >= (p_u_87 or #p_u_86) then
						v_u_97 = true
						p_u_90(v_u_93)
						for _, v99 in ipairs(v_u_94) do
							v99:cancel()
						end
					end
				end
			end
			p92(function() -- name: cancel
				-- upvalues: (copy) v_u_94
				for _, v101 in ipairs(v_u_94) do
					v101:cancel()
				end
			end)
			local v_u_102 = v_u_97
			for v_u_103, v104 in ipairs(p_u_86) do
				v_u_94[v_u_103] = v104:andThen(function(...)
					-- upvalues: (copy) v_u_100, (copy) v_u_103
					v_u_100(v_u_103, ...)
				end, function(...)
					-- upvalues: (ref) v_u_96, (ref) p_u_87, (ref) p_u_86, (copy) v_u_94, (ref) v_u_102, (copy) p_u_91
					v_u_96 = v_u_96 + 1
					if p_u_87 == nil or #p_u_86 - v_u_96 < p_u_87 then
						for _, v105 in ipairs(v_u_94) do
							v105:cancel()
						end
						v_u_102 = true
						p_u_91(...)
					end
				end)
			end
			if v_u_102 then
				for _, v106 in ipairs(v_u_94) do
					v106:cancel()
				end
			end
		end)
	end
end
function v_u_44.all(p107) -- name: all
	-- upvalues: (copy) v_u_44
	return v_u_44._all(debug.traceback(nil, 2), p107)
end
function v_u_44.fold(p108, p_u_109, p110) -- name: fold
	-- upvalues: (copy) v_u_44
	local v111 = type(p108) == "table"
	assert(v111, "Bad argument #1 to Promise.fold: must be a table")
	local v112
	if type(p_u_109) == "function" then
		v112 = true
	elseif type(p_u_109) == "table" then
		local v113 = getmetatable(p_u_109)
		if v113 then
			local v114 = rawget(v113, "__call")
			v112 = type(v114) == "function"
		else
			v112 = false
		end
	else
		v112 = false
	end
	assert(v112, "Bad argument #2 to Promise.fold: must be a function")
	local v_u_115 = v_u_44.resolve(p110)
	return v_u_44.each(p108, function(p_u_116, p_u_117)
		-- upvalues: (ref) v_u_115, (copy) p_u_109
		v_u_115 = v_u_115:andThen(function(p118)
			-- upvalues: (ref) p_u_109, (copy) p_u_116, (copy) p_u_117
			return p_u_109(p118, p_u_116, p_u_117)
		end)
	end):andThen(function()
		-- upvalues: (ref) v_u_115
		return v_u_115
	end)
end
function v_u_44.some(p119, p120) -- name: some
	-- upvalues: (copy) v_u_44
	local v121 = type(p120) == "number"
	assert(v121, "Bad argument #2 to Promise.some: must be a number")
	return v_u_44._all(debug.traceback(nil, 2), p119, p120)
end
function v_u_44.any(p122) -- name: any
	-- upvalues: (copy) v_u_44
	return v_u_44._all(debug.traceback(nil, 2), p122, 1):andThen(function(p123)
		return p123[1]
	end)
end
function v_u_44.allSettled(p_u_124) -- name: allSettled
	-- upvalues: (copy) v_u_44
	if type(p_u_124) ~= "table" then
		error(string.format("Please pass a list of promises to %s", "Promise.allSettled"), 2)
	end
	for v125, v126 in pairs(p_u_124) do
		if not v_u_44.is(v126) then
			error(string.format("Non-promise value passed into %s at index %s", "Promise.allSettled", (tostring(v125))), 2)
		end
	end
	if #p_u_124 == 0 then
		return v_u_44.resolve({})
	else
		return v_u_44._new(debug.traceback(nil, 2), function(p_u_127, _, p128)
			-- upvalues: (copy) p_u_124
			local v_u_129 = {}
			local v_u_130 = {}
			local v_u_131 = 0
			local function v_u_133(p132, ...) -- name: resolveOne
				-- upvalues: (ref) v_u_131, (copy) v_u_129, (ref) p_u_124, (copy) p_u_127
				v_u_131 = v_u_131 + 1
				v_u_129[p132] = ...
				if v_u_131 >= #p_u_124 then
					p_u_127(v_u_129)
				end
			end
			p128(function()
				-- upvalues: (copy) v_u_130
				for _, v134 in ipairs(v_u_130) do
					v134:cancel()
				end
			end)
			for v_u_135, v136 in ipairs(p_u_124) do
				v_u_130[v_u_135] = v136:finally(function(...)
					-- upvalues: (copy) v_u_133, (copy) v_u_135
					v_u_133(v_u_135, ...)
				end)
			end
		end)
	end
end
function v_u_44.race(p_u_137) -- name: race
	-- upvalues: (copy) v_u_44
	local v138 = type(p_u_137) == "table"
	local v139 = string.format
	assert(v138, v139("Please pass a list of promises to %s", "Promise.race"))
	for v140, v141 in pairs(p_u_137) do
		local v142 = v_u_44.is(v141)
		local v143 = string.format
		local v144 = tostring(v140)
		assert(v142, v143("Non-promise value passed into %s at index %s", "Promise.race", v144))
	end
	return v_u_44._new(debug.traceback(nil, 2), function(p_u_145, p_u_146, p147)
		-- upvalues: (copy) p_u_137
		local v_u_148 = {}
		local v_u_149 = false
		if not p147(function(...)
			-- upvalues: (copy) v_u_148, (ref) v_u_149, (copy) p_u_146
			for _, v150 in ipairs(v_u_148) do
				v150:cancel()
			end
			v_u_149 = true
			return p_u_146(...)
		end) then
			local v_u_151 = v_u_149
			for v152, v153 in ipairs(p_u_137) do
				v_u_148[v152] = v153:andThen(function(...)
					-- upvalues: (copy) v_u_148, (ref) v_u_151, (copy) p_u_145
					for _, v154 in ipairs(v_u_148) do
						v154:cancel()
					end
					v_u_151 = true
					return p_u_145(...)
				end, function(...)
					-- upvalues: (copy) v_u_148, (ref) v_u_151, (copy) p_u_146
					for _, v155 in ipairs(v_u_148) do
						v155:cancel()
					end
					v_u_151 = true
					return p_u_146(...)
				end)
			end
			if v_u_151 then
				for _, v156 in ipairs(v_u_148) do
					v156:cancel()
				end
			end
		end
	end)
end
function v_u_44.each(p_u_157, p_u_158) -- name: each
	-- upvalues: (copy) v_u_44, (ref) v_u_8
	local v159 = type(p_u_157) == "table"
	local v160 = string.format
	assert(v159, v160("Please pass a list of promises to %s", "Promise.each"))
	local v161
	if type(p_u_158) == "function" then
		v161 = true
	elseif type(p_u_158) == "table" then
		local v162 = getmetatable(p_u_158)
		if v162 then
			local v163 = rawget(v162, "__call")
			v161 = type(v163) == "function"
		else
			v161 = false
		end
	else
		v161 = false
	end
	local v164 = string.format
	assert(v161, v164("Please pass a handler function to %s!", "Promise.each"))
	return v_u_44._new(debug.traceback(nil, 2), function(p165, p166, p167)
		-- upvalues: (copy) p_u_157, (ref) v_u_44, (ref) v_u_8, (copy) p_u_158
		local v168 = {}
		local v_u_169 = {}
		local v_u_170 = false
		p167(function()
			-- upvalues: (ref) v_u_170, (copy) v_u_169
			v_u_170 = true
			for _, v171 in ipairs(v_u_169) do
				v171:cancel()
			end
		end)
		local v172 = v_u_170
		local v173 = {}
		for v174, v175 in ipairs(p_u_157) do
			if v_u_44.is(v175) then
				if v175:getStatus() == v_u_44.Status.Cancelled then
					for _, v176 in ipairs(v_u_169) do
						v176:cancel()
					end
					return p166(v_u_8.new({
						["error"] = "Promise is cancelled",
						["kind"] = nil,
						["context"] = nil,
						["kind"] = v_u_8.Kind.AlreadyCancelled,
						["context"] = string.format("The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s", v174, v175._source)
					}))
				end
				if v175:getStatus() == v_u_44.Status.Rejected then
					for _, v177 in ipairs(v_u_169) do
						v177:cancel()
					end
					return p166(select(2, v175:await()))
				end
				local v178 = v175:andThen(function(...)
					return ...
				end)
				table.insert(v_u_169, v178)
				v173[v174] = v178
			else
				v173[v174] = v175
			end
		end
		for v179, v182 in ipairs(v173) do
			if v_u_44.is(v182) then
				local v181, v182 = v182:await()
				if not v181 then
					for _, v183 in ipairs(v_u_169) do
						v183:cancel()
					end
					return p166(v182)
				end
			end
			if v172 then
				return
			end
			local v184 = v_u_44.resolve(p_u_158(v182, v179))
			table.insert(v_u_169, v184)
			local v185, v186 = v184:await()
			if not v185 then
				for _, v187 in ipairs(v_u_169) do
					v187:cancel()
				end
				return p166(v186)
			end
			v168[v179] = v186
		end
		p165(v168)
	end)
end
function v_u_44.is(p188) -- name: is
	-- upvalues: (copy) v_u_44
	if type(p188) ~= "table" then
		return false
	end
	local v189 = getmetatable(p188)
	if v189 == v_u_44 then
		return true
	end
	if v189 ~= nil then
		if type(v189) == "table" then
			local v190 = rawget(v189, "__index")
			if type(v190) == "table" then
				local v191 = rawget(v189, "__index")
				local v192 = rawget(v191, "andThen")
				local v193
				if type(v192) == "function" then
					v193 = true
				else
					local v194 = type(v192) == "table" and getmetatable(v192)
					if v194 then
						local v195 = rawget(v194, "__call")
						v193 = type(v195) == "function"
					else
						v193 = false
					end
				end
				if v193 then
					return true
				end
			end
		end
		return false
	end
	local v196 = p188.andThen
	if type(v196) == "function" then
		return true
	end
	local v197 = type(v196) == "table" and getmetatable(v196)
	if v197 then
		local v198 = rawget(v197, "__call")
		if type(v198) == "function" then
			return true
		end
	end
	return false
end
function v_u_44.promisify(p_u_199) -- name: promisify
	-- upvalues: (copy) v_u_44
	return function(...)
		-- upvalues: (ref) v_u_44, (copy) p_u_199
		return v_u_44._try(debug.traceback(nil, 2), p_u_199, ...)
	end
end
local v_u_200 = nil
local v_u_201 = nil
function v_u_44.delay(p202) -- name: delay
	-- upvalues: (copy) v_u_44, (ref) v_u_201, (ref) v_u_200
	local v203 = type(p202) == "number"
	assert(v203, "Bad argument #1 to Promise.delay, must be a number.")
	local v_u_204 = (p202 < 0.016666666666666666 or p202 == (1 / 0)) and 0.016666666666666666 or p202
	return v_u_44._new(debug.traceback(nil, 2), function(p205, _, p206)
		-- upvalues: (ref) v_u_44, (ref) v_u_204, (ref) v_u_201, (ref) v_u_200
		local v207 = v_u_44._getTime()
		local v208 = v207 + v_u_204
		local v_u_209 = {
			["resolve"] = p205,
			["startTime"] = v207,
			["endTime"] = v208
		}
		if v_u_201 == nil then
			v_u_200 = v_u_209
			v_u_201 = v_u_44._timeEvent:Connect(function()
				-- upvalues: (ref) v_u_44, (ref) v_u_200, (ref) v_u_201
				local v210 = v_u_44._getTime()
				while v_u_200 ~= nil and v_u_200.endTime < v210 do
					local v211 = v_u_200
					v_u_200 = v211.next
					if v_u_200 == nil then
						v_u_201:Disconnect()
						v_u_201 = nil
					else
						v_u_200.previous = nil
					end
					v211.resolve(v_u_44._getTime() - v211.startTime)
				end
			end)
		elseif v_u_200.endTime < v208 then
			local v212 = v_u_200
			local v213 = v212.next
			while v213 ~= nil and v213.endTime < v208 do
				local v214 = v213.next
				v212 = v213
				v213 = v214
			end
			v212.next = v_u_209
			v_u_209.previous = v212
			if v213 ~= nil then
				v_u_209.next = v213
				v213.previous = v_u_209
			end
		else
			v_u_209.next = v_u_200
			v_u_200.previous = v_u_209
			v_u_200 = v_u_209
		end
		p206(function()
			-- upvalues: (copy) v_u_209, (ref) v_u_200, (ref) v_u_201
			local v215 = v_u_209.next
			if v_u_200 == v_u_209 then
				if v215 == nil then
					v_u_201:Disconnect()
					v_u_201 = nil
				else
					v215.previous = nil
				end
				v_u_200 = v215
			else
				local v216 = v_u_209.previous
				v216.next = v215
				if v215 ~= nil then
					v215.previous = v216
				end
			end
		end)
	end)
end
local function v221(p217, p_u_218, p_u_219) -- name: timeout
	-- upvalues: (copy) v_u_44, (ref) v_u_8
	local v_u_220 = debug.traceback(nil, 2)
	return v_u_44.race({ v_u_44.delay(p_u_218):andThen(function()
			-- upvalues: (ref) v_u_44, (copy) p_u_219, (ref) v_u_8, (copy) p_u_218, (copy) v_u_220
			return v_u_44.reject(p_u_219 == nil and v_u_8.new({
				["kind"] = nil,
				["error"] = "Timed out",
				["context"] = nil,
				["kind"] = v_u_8.Kind.TimedOut,
				["context"] = string.format("Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s", p_u_218, v_u_220)
			}) or p_u_219)
		end), p217 })
end
v_u_44.prototype.timeout = v221
function v_u_44.prototype.getStatus(p222) -- name: getStatus
	return p222._status
end
function v_u_44.prototype._andThen(p_u_223, p_u_224, p_u_225, p_u_226) -- name: _andThen
	-- upvalues: (copy) v_u_44, (copy) v_u_43
	p_u_223._unhandledRejection = false
	if p_u_223._status ~= v_u_44.Status.Cancelled then
		return v_u_44._new(p_u_224, function(p_u_227, p_u_228, p229)
			-- upvalues: (copy) p_u_225, (copy) p_u_224, (ref) v_u_43, (copy) p_u_226, (copy) p_u_223, (ref) v_u_44
			local v_u_230
			if p_u_225 then
				local v_u_231 = p_u_224
				local v_u_232 = p_u_225
				v_u_230 = function(...)
					-- upvalues: (ref) v_u_43, (copy) v_u_231, (copy) v_u_232, (copy) p_u_227, (copy) p_u_228
					local v233, v234, v235 = v_u_43(v_u_231, v_u_232, ...)
					if v233 then
						p_u_227(unpack(v235, 1, v234))
					else
						p_u_228(v235[1])
					end
				end
			else
				v_u_230 = p_u_227
			end
			if p_u_226 then
				local v_u_236 = p_u_224
				local v_u_237 = p_u_226
				p_u_228 = function(...)
					-- upvalues: (ref) v_u_43, (copy) v_u_236, (copy) v_u_237, (copy) p_u_227, (copy) p_u_228
					local v238, v239, v240 = v_u_43(v_u_236, v_u_237, ...)
					if v238 then
						p_u_227(unpack(v240, 1, v239))
					else
						p_u_228(v240[1])
					end
				end
			end
			if p_u_223._status == v_u_44.Status.Started then
				local v241 = p_u_223._queuedResolve
				table.insert(v241, v_u_230)
				local v242 = p_u_223._queuedReject
				table.insert(v242, p_u_228)
				p229(function()
					-- upvalues: (ref) p_u_223, (ref) v_u_44, (ref) v_u_230, (ref) p_u_228
					if p_u_223._status == v_u_44.Status.Started then
						table.remove(p_u_223._queuedResolve, table.find(p_u_223._queuedResolve, v_u_230))
						table.remove(p_u_223._queuedReject, table.find(p_u_223._queuedReject, p_u_228))
					end
				end)
			elseif p_u_223._status == v_u_44.Status.Resolved then
				local v243 = p_u_223._values
				local v244 = p_u_223._valuesLength
				v_u_230(unpack(v243, 1, v244))
			elseif p_u_223._status == v_u_44.Status.Rejected then
				local v245 = p_u_223._values
				local v246 = p_u_223._valuesLength
				p_u_228(unpack(v245, 1, v246))
			end
		end, p_u_223)
	end
	local v247 = v_u_44.new(function() end)
	v247:cancel()
	return v247
end
function v_u_44.prototype.andThen(p248, p249, p250) -- name: andThen
	local v251
	if p249 == nil or type(p249) == "function" then
		v251 = true
	elseif type(p249) == "table" then
		local v252 = getmetatable(p249)
		if v252 then
			local v253 = rawget(v252, "__call")
			v251 = type(v253) == "function"
		else
			v251 = false
		end
	else
		v251 = false
	end
	local v254 = string.format
	assert(v251, v254("Please pass a handler function to %s!", "Promise:andThen"))
	local v255
	if p250 == nil or type(p250) == "function" then
		v255 = true
	elseif type(p250) == "table" then
		local v256 = getmetatable(p250)
		if v256 then
			local v257 = rawget(v256, "__call")
			v255 = type(v257) == "function"
		else
			v255 = false
		end
	else
		v255 = false
	end
	local v258 = string.format
	assert(v255, v258("Please pass a handler function to %s!", "Promise:andThen"))
	return p248:_andThen(debug.traceback(nil, 2), p249, p250)
end
function v_u_44.prototype.catch(p259, p260) -- name: catch
	local v261
	if p260 == nil or type(p260) == "function" then
		v261 = true
	elseif type(p260) == "table" then
		local v262 = getmetatable(p260)
		if v262 then
			local v263 = rawget(v262, "__call")
			v261 = type(v263) == "function"
		else
			v261 = false
		end
	else
		v261 = false
	end
	local v264 = string.format
	assert(v261, v264("Please pass a handler function to %s!", "Promise:catch"))
	return p259:_andThen(debug.traceback(nil, 2), nil, p260)
end
function v_u_44.prototype.tap(p265, p_u_266) -- name: tap
	-- upvalues: (copy) v_u_44, (copy) v_u_34
	local v267
	if type(p_u_266) == "function" then
		v267 = true
	elseif type(p_u_266) == "table" then
		local v268 = getmetatable(p_u_266)
		if v268 then
			local v269 = rawget(v268, "__call")
			v267 = type(v269) == "function"
		else
			v267 = false
		end
	else
		v267 = false
	end
	local v270 = string.format
	assert(v267, v270("Please pass a handler function to %s!", "Promise:tap"))
	return p265:_andThen(debug.traceback(nil, 2), function(...)
		-- upvalues: (copy) p_u_266, (ref) v_u_44, (ref) v_u_34
		local v271 = p_u_266(...)
		if not v_u_44.is(v271) then
			return ...
		end
		local v_u_272, v_u_273 = v_u_34(...)
		return v271:andThen(function()
			-- upvalues: (copy) v_u_273, (copy) v_u_272
			local v274 = v_u_273
			local v275 = v_u_272
			return unpack(v274, 1, v275)
		end)
	end)
end
function v_u_44.prototype.andThenCall(p276, p_u_277, ...) -- name: andThenCall
	-- upvalues: (copy) v_u_34
	local v278
	if type(p_u_277) == "function" then
		v278 = true
	elseif type(p_u_277) == "table" then
		local v279 = getmetatable(p_u_277)
		if v279 then
			local v280 = rawget(v279, "__call")
			v278 = type(v280) == "function"
		else
			v278 = false
		end
	else
		v278 = false
	end
	local v281 = string.format
	assert(v278, v281("Please pass a handler function to %s!", "Promise:andThenCall"))
	local v_u_282, v_u_283 = v_u_34(...)
	return p276:_andThen(debug.traceback(nil, 2), function()
		-- upvalues: (copy) p_u_277, (copy) v_u_283, (copy) v_u_282
		local v284 = v_u_283
		local v285 = v_u_282
		return p_u_277(unpack(v284, 1, v285))
	end)
end
function v_u_44.prototype.andThenReturn(p286, ...) -- name: andThenReturn
	-- upvalues: (copy) v_u_34
	local v_u_287, v_u_288 = v_u_34(...)
	return p286:_andThen(debug.traceback(nil, 2), function()
		-- upvalues: (copy) v_u_288, (copy) v_u_287
		local v289 = v_u_288
		local v290 = v_u_287
		return unpack(v289, 1, v290)
	end)
end
function v_u_44.prototype.cancel(p291) -- name: cancel
	-- upvalues: (copy) v_u_44
	if p291._status == v_u_44.Status.Started then
		p291._status = v_u_44.Status.Cancelled
		if p291._cancellationHook then
			p291._cancellationHook()
		end
		coroutine.close(p291._thread)
		if p291._parent then
			p291._parent:_consumerCancelled(p291)
		end
		for v292 in pairs(p291._consumers) do
			v292:cancel()
		end
		p291:_finalize()
	end
end
function v_u_44.prototype._consumerCancelled(p293, p294) -- name: _consumerCancelled
	-- upvalues: (copy) v_u_44
	if p293._status == v_u_44.Status.Started then
		p293._consumers[p294] = nil
		if next(p293._consumers) == nil then
			p293:cancel()
		end
	end
end
function v_u_44.prototype._finally(p_u_295, p296, p_u_297) -- name: _finally
	-- upvalues: (copy) v_u_44
	p_u_295._unhandledRejection = false
	return v_u_44._new(p296, function(p_u_298, p_u_299, p300)
		-- upvalues: (copy) p_u_295, (copy) p_u_297, (ref) v_u_44
		local v_u_301 = nil
		p300(function()
			-- upvalues: (ref) p_u_295, (ref) v_u_301
			p_u_295:_consumerCancelled(p_u_295)
			if v_u_301 then
				v_u_301:cancel()
			end
		end)
		local v304 = p_u_297 and function(...)
			-- upvalues: (ref) p_u_297, (ref) v_u_44, (ref) v_u_301, (copy) p_u_298, (ref) p_u_295, (copy) p_u_299
			local v302 = p_u_297(...)
			if v_u_44.is(v302) then
				v_u_301 = v302
				v302:finally(function(p303)
					-- upvalues: (ref) v_u_44, (ref) p_u_298, (ref) p_u_295
					if p303 ~= v_u_44.Status.Rejected then
						p_u_298(p_u_295)
					end
				end):catch(function(...)
					-- upvalues: (ref) p_u_299
					p_u_299(...)
				end)
			else
				p_u_298(p_u_295)
			end
		end or p_u_298
		if p_u_295._status == v_u_44.Status.Started then
			local v305 = p_u_295._queuedFinally
			table.insert(v305, v304)
		else
			v304(p_u_295._status)
		end
	end)
end
function v_u_44.prototype.finally(p306, p307) -- name: finally
	local v308
	if p307 == nil or type(p307) == "function" then
		v308 = true
	elseif type(p307) == "table" then
		local v309 = getmetatable(p307)
		if v309 then
			local v310 = rawget(v309, "__call")
			v308 = type(v310) == "function"
		else
			v308 = false
		end
	else
		v308 = false
	end
	local v311 = string.format
	assert(v308, v311("Please pass a handler function to %s!", "Promise:finally"))
	return p306:_finally(debug.traceback(nil, 2), p307)
end
function v_u_44.prototype.finallyCall(p312, p_u_313, ...) -- name: finallyCall
	-- upvalues: (copy) v_u_34
	local v314
	if type(p_u_313) == "function" then
		v314 = true
	elseif type(p_u_313) == "table" then
		local v315 = getmetatable(p_u_313)
		if v315 then
			local v316 = rawget(v315, "__call")
			v314 = type(v316) == "function"
		else
			v314 = false
		end
	else
		v314 = false
	end
	local v317 = string.format
	assert(v314, v317("Please pass a handler function to %s!", "Promise:finallyCall"))
	local v_u_318, v_u_319 = v_u_34(...)
	return p312:_finally(debug.traceback(nil, 2), function()
		-- upvalues: (copy) p_u_313, (copy) v_u_319, (copy) v_u_318
		local v320 = v_u_319
		local v321 = v_u_318
		return p_u_313(unpack(v320, 1, v321))
	end)
end
function v_u_44.prototype.finallyReturn(p322, ...) -- name: finallyReturn
	-- upvalues: (copy) v_u_34
	local v_u_323, v_u_324 = v_u_34(...)
	return p322:_finally(debug.traceback(nil, 2), function()
		-- upvalues: (copy) v_u_324, (copy) v_u_323
		local v325 = v_u_324
		local v326 = v_u_323
		return unpack(v325, 1, v326)
	end)
end
function v_u_44.prototype.awaitStatus(p327) -- name: awaitStatus
	-- upvalues: (copy) v_u_44
	p327._unhandledRejection = false
	if p327._status == v_u_44.Status.Started then
		local v_u_328 = coroutine.running()
		p327:finally(function()
			-- upvalues: (copy) v_u_328
			task.spawn(v_u_328)
		end):catch(function() end)
		coroutine.yield()
	end
	if p327._status == v_u_44.Status.Resolved then
		local v329 = p327._status
		local v330 = p327._values
		local v331 = p327._valuesLength
		return v329, unpack(v330, 1, v331)
	end
	if p327._status ~= v_u_44.Status.Rejected then
		return p327._status
	end
	local v332 = p327._status
	local v333 = p327._values
	local v334 = p327._valuesLength
	return v332, unpack(v333, 1, v334)
end
local function v_u_336(p335, ...) -- name: awaitHelper
	-- upvalues: (copy) v_u_44
	return p335 == v_u_44.Status.Resolved, ...
end
function v_u_44.prototype.await(p337) -- name: await
	-- upvalues: (copy) v_u_336
	return v_u_336(p337:awaitStatus())
end
local function v_u_339(p338, ...) -- name: expectHelper
	-- upvalues: (copy) v_u_44
	if p338 ~= v_u_44.Status.Resolved then
		error(... == nil and "Expected Promise rejected with no value." or ..., 3)
	end
	return ...
end
function v_u_44.prototype.expect(p340) -- name: expect
	-- upvalues: (copy) v_u_339
	return v_u_339(p340:awaitStatus())
end
v_u_44.prototype.awaitValue = v_u_44.prototype.expect
function v_u_44.prototype._unwrap(p341) -- name: _unwrap
	-- upvalues: (copy) v_u_44
	if p341._status == v_u_44.Status.Started then
		error("Promise has not resolved or rejected.", 2)
	end
	local v342 = p341._status == v_u_44.Status.Resolved
	local v343 = p341._values
	local v344 = p341._valuesLength
	return v342, unpack(v343, 1, v344)
end
local function v353(p_u_345, ...) -- name: _resolve
	-- upvalues: (copy) v_u_44, (ref) v_u_8, (copy) v_u_34
	if p_u_345._status == v_u_44.Status.Started then
		if v_u_44.is((...)) then
			if select("#", ...) > 1 then
				local v346 = string.format("When returning a Promise from andThen, extra arguments are discarded! See:\n\n%s", p_u_345._source)
				warn(v346)
			end
			local v_u_347 = ...
			local v349 = v_u_347:andThen(function(...)
				-- upvalues: (copy) p_u_345
				p_u_345:_resolve(...)
			end, function(...)
				-- upvalues: (copy) v_u_347, (ref) v_u_8, (copy) p_u_345
				local v348 = v_u_347._values[1]
				if v_u_347._error then
					v348 = v_u_8.new({
						["error"] = nil,
						["kind"] = nil,
						["context"] = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
						["error"] = v_u_347._error,
						["kind"] = v_u_8.Kind.ExecutionError
					})
				end
				if v_u_8.isKind(v348, v_u_8.Kind.ExecutionError) then
					return p_u_345:_reject(v348:extend({
						["error"] = "This Promise was chained to a Promise that errored.",
						["trace"] = "",
						["context"] = nil,
						["context"] = string.format("The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n", p_u_345._source)
					}))
				end
				p_u_345:_reject(...)
			end)
			if v349._status == v_u_44.Status.Cancelled then
				p_u_345:cancel()
			elseif v349._status == v_u_44.Status.Started then
				p_u_345._parent = v349
				v349._consumers[p_u_345] = true
			end
		else
			p_u_345._status = v_u_44.Status.Resolved
			local v350, v351 = v_u_34(...)
			p_u_345._valuesLength = v350
			p_u_345._values = v351
			for _, v352 in ipairs(p_u_345._queuedResolve) do
				coroutine.wrap(v352)(...)
			end
			p_u_345:_finalize()
			return
		end
	else
		if v_u_44.is((...)) then
			(...):_consumerCancelled(p_u_345)
		end
		return
	end
end
v_u_44.prototype._resolve = v353
function v_u_44.prototype._reject(p_u_354, ...) -- name: _reject
	-- upvalues: (copy) v_u_44, (copy) v_u_34
	if p_u_354._status == v_u_44.Status.Started then
		p_u_354._status = v_u_44.Status.Rejected
		local v355, v356 = v_u_34(...)
		p_u_354._valuesLength = v355
		p_u_354._values = v356
		local v357 = p_u_354._queuedReject
		if next(v357) == nil then
			local v_u_358 = tostring((...))
			coroutine.wrap(function()
				-- upvalues: (ref) v_u_44, (copy) p_u_354, (copy) v_u_358
				v_u_44._timeEvent:Wait()
				if p_u_354._unhandledRejection then
					local v359 = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", v_u_358, p_u_354._source)
					for _, v360 in ipairs(v_u_44._unhandledRejectionCallbacks) do
						local v361 = task.spawn
						local v362 = p_u_354
						local v363 = p_u_354._values
						local v364 = p_u_354._valuesLength
						v361(v360, v362, unpack(v363, 1, v364))
					end
					if not v_u_44.TEST then
						warn(v359)
					end
				else
					return
				end
			end)()
		else
			for _, v365 in ipairs(p_u_354._queuedReject) do
				coroutine.wrap(v365)(...)
			end
		end
		p_u_354:_finalize()
	end
end
function v_u_44.prototype._finalize(p366) -- name: _finalize
	-- upvalues: (copy) v_u_44
	for _, v367 in ipairs(p366._queuedFinally) do
		coroutine.wrap(v367)(p366._status)
	end
	p366._queuedFinally = nil
	p366._queuedReject = nil
	p366._queuedResolve = nil
	if not v_u_44.TEST then
		p366._parent = nil
		p366._consumers = nil
	end
	task.defer(coroutine.close, p366._thread)
end
local function v372(p368, p369) -- name: now
	-- upvalues: (copy) v_u_44, (ref) v_u_8
	local v370 = debug.traceback(nil, 2)
	if p368._status == v_u_44.Status.Resolved then
		return p368:_andThen(v370, function(...)
			return ...
		end)
	end
	local v371 = v_u_44.reject
	if p369 == nil then
		p369 = v_u_8.new({
			["kind"] = nil,
			["error"] = "This Promise was not resolved in time for :now()",
			["context"] = nil,
			["kind"] = v_u_8.Kind.NotResolvedInTime,
			["context"] = ":now() was called at:\n\n" .. v370
		}) or p369
	end
	return v371(p369)
end
v_u_44.prototype.now = v372
function v_u_44.retry(p_u_373, p_u_374, ...) -- name: retry
	-- upvalues: (copy) v_u_44
	local v375
	if type(p_u_373) == "function" then
		v375 = true
	elseif type(p_u_373) == "table" then
		local v376 = getmetatable(p_u_373)
		if v376 then
			local v377 = rawget(v376, "__call")
			v375 = type(v377) == "function"
		else
			v375 = false
		end
	else
		v375 = false
	end
	assert(v375, "Parameter #1 to Promise.retry must be a function")
	local v378 = type(p_u_374) == "number"
	assert(v378, "Parameter #2 to Promise.retry must be a number")
	local v_u_379 = { ... }
	local v_u_380 = select("#", ...)
	return v_u_44.resolve(p_u_373(...)):catch(function(...)
		-- upvalues: (copy) p_u_374, (ref) v_u_44, (copy) p_u_373, (copy) v_u_379, (copy) v_u_380
		if p_u_374 <= 0 then
			return v_u_44.reject(...)
		end
		local v381 = v_u_379
		local v382 = v_u_380
		return v_u_44.retry(p_u_373, p_u_374 - 1, unpack(v381, 1, v382))
	end)
end
function v_u_44.retryWithDelay(p_u_383, p_u_384, p_u_385, ...) -- name: retryWithDelay
	-- upvalues: (copy) v_u_44
	local v386
	if type(p_u_383) == "function" then
		v386 = true
	elseif type(p_u_383) == "table" then
		local v387 = getmetatable(p_u_383)
		if v387 then
			local v388 = rawget(v387, "__call")
			v386 = type(v388) == "function"
		else
			v386 = false
		end
	else
		v386 = false
	end
	assert(v386, "Parameter #1 to Promise.retry must be a function")
	local v389 = type(p_u_384) == "number"
	assert(v389, "Parameter #2 (times) to Promise.retry must be a number")
	local v390 = type(p_u_385) == "number"
	assert(v390, "Parameter #3 (seconds) to Promise.retry must be a number")
	local v_u_391 = { ... }
	local v_u_392 = select("#", ...)
	return v_u_44.resolve(p_u_383(...)):catch(function(...)
		-- upvalues: (copy) p_u_384, (ref) v_u_44, (copy) p_u_385, (copy) p_u_383, (copy) v_u_391, (copy) v_u_392
		if p_u_384 <= 0 then
			return v_u_44.reject(...)
		end
		v_u_44.delay(p_u_385):await()
		local v393 = v_u_391
		local v394 = v_u_392
		return v_u_44.retryWithDelay(p_u_383, p_u_384 - 1, p_u_385, unpack(v393, 1, v394))
	end)
end
function v_u_44.fromEvent(p_u_395, p396) -- name: fromEvent
	-- upvalues: (copy) v_u_44
	local v_u_397 = p396 or function()
		return true
	end
	return v_u_44._new(debug.traceback(nil, 2), function(p_u_398, _, p399)
		-- upvalues: (copy) p_u_395, (ref) v_u_397
		local v_u_400 = nil
		local v_u_401 = false
		local function v402() -- name: disconnect
			-- upvalues: (ref) v_u_400
			v_u_400:Disconnect()
			v_u_400 = nil
		end
		v_u_400 = p_u_395:Connect(function(...)
			-- upvalues: (ref) v_u_397, (copy) p_u_398, (ref) v_u_400, (ref) v_u_401
			local v403 = v_u_397(...)
			if v403 == true then
				p_u_398(...)
				if v_u_400 then
					v_u_400:Disconnect()
					v_u_400 = nil
				else
					v_u_401 = true
				end
			else
				if type(v403) ~= "boolean" then
					error("Promise.fromEvent predicate should always return a boolean")
				end
				return
			end
		end)
		if v_u_401 and v_u_400 then
			return v402()
		end
		p399(v402)
	end)
end
function v_u_44.onUnhandledRejection(p_u_404) -- name: onUnhandledRejection
	-- upvalues: (copy) v_u_44
	local v405 = v_u_44._unhandledRejectionCallbacks
	table.insert(v405, p_u_404)
	return function()
		-- upvalues: (ref) v_u_44, (copy) p_u_404
		local v406 = table.find(v_u_44._unhandledRejectionCallbacks, p_u_404)
		if v406 then
			table.remove(v_u_44._unhandledRejectionCallbacks, v406)
		end
	end
end
return v_u_44