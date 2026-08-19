-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

local v_u_1 = require(script.Parent.Promise)
local v_u_2 = game:GetService("RunService")
local v_u_11 = {
	["Promise"] = v_u_1,
	["getModule"] = function(p3, p4, p5) -- name: getModule
		-- upvalues: (copy) v_u_2
		local v6
		if p5 == nil then
			v6 = "@rbxts"
		else
			v6 = p4
			p4 = p5
		end
		if v_u_2:IsRunning() and v_u_2:IsClient() then
			local v7 = v_u_2:IsStudio()
			if v7 then
				v7 = p3:FindFirstAncestorWhichIsA("Plugin") ~= nil
			end
			if not (v7 or game:IsLoaded()) then
				game.Loaded:Wait()
			end
		end
		while true do
			local v8 = p3:FindFirstChild("node_modules")
			if v8 then
				local v9 = v8:FindFirstChild(v6)
				local v10 = v9 and v9:FindFirstChild(p4)
				if v10 then
					return v10
				end
			end
			p3 = p3.Parent
			if p3 == nil then
				error("roblox-ts: " .. "Could not find module: " .. p4, 2)
				return
			end
		end
	end
}
local v_u_12 = {}
local v_u_13 = {}
function v_u_11.import(p14, p15, ...) -- name: import
	-- upvalues: (copy) v_u_12, (copy) v_u_13, (copy) v_u_11
	for v16 = 1, select("#", ...) do
		p15 = p15:WaitForChild((select(v16, ...)))
	end
	if p15.ClassName ~= "ModuleScript" then
		error("roblox-ts: " .. "Failed to import! Expected ModuleScript, got " .. p15.ClassName, 2)
	end
	v_u_12[p14] = p15
	local v17 = p15
	local v18 = 0
	while p15 do
		v18 = v18 + 1
		p15 = v_u_12[p15]
		if p15 == v17 then
			local v19 = p15.Name
			for _ = 1, v18 do
				p15 = v_u_12[p15]
				v19 = v19 .. "  \226\135\146 " .. p15.Name
			end
			error("roblox-ts: " .. "Failed to import! Detected a circular dependency chain: " .. v19, 2)
		end
	end
	if not v_u_13[v17] then
		if _G[v17] then
			error("roblox-ts: " .. "Invalid module access! Do you have multiple TS runtimes trying to import this? " .. v17:GetFullName(), 2)
		end
		_G[v17] = v_u_11
		v_u_13[v17] = true
	end
	local v20 = require(v17)
	if v_u_12[p14] == v17 then
		v_u_12[p14] = nil
	end
	return v20
end
function v_u_11.instanceof(p21, p22) -- name: instanceof
	if type(p22) == "table" then
		local v23 = p22.instanceof
		if type(v23) == "function" then
			return p22.instanceof(p21)
		end
	end
	if type(p21) == "table" then
		local v24 = getmetatable(p21)
		while v24 ~= nil do
			if v24 == p22 then
				return true
			end
			local v25 = getmetatable(v24)
			if v25 then
				v24 = v25.__index
			else
				v24 = nil
			end
		end
	end
	return false
end
function v_u_11.async(p_u_26) -- name: async
	-- upvalues: (copy) v_u_1
	return function(...)
		-- upvalues: (ref) v_u_1, (copy) p_u_26
		local v_u_27 = select("#", ...)
		local v_u_28 = { ... }
		return v_u_1.new(function(p_u_29, p_u_30)
			-- upvalues: (ref) p_u_26, (copy) v_u_28, (copy) v_u_27
			coroutine.wrap(function()
				-- upvalues: (ref) p_u_26, (ref) v_u_28, (ref) v_u_27, (copy) p_u_29, (copy) p_u_30
				local v31 = v_u_28
				local v32 = v_u_27
				local v33, v34 = pcall(p_u_26, unpack(v31, 1, v32))
				if v33 then
					p_u_29(v34)
				else
					p_u_30(v34)
				end
			end)()
		end)
	end
end
function v_u_11.await(p35) -- name: await
	-- upvalues: (copy) v_u_1
	if v_u_1.is(p35) then
		local v36, v37 = p35:awaitStatus()
		if v36 == v_u_1.Status.Resolved then
			return v37
		elseif v36 == v_u_1.Status.Rejected then
			error(v37, 2)
		else
			error("The awaited Promise was cancelled", 2)
		end
	else
		return p35
	end
end
function v_u_11.bit_lrsh(p38, p39) -- name: bit_lrsh
	local v40 = bit32.arshift(p38, p39)
	if bit32.btest(v40, 2147483648) then
		return v40 - 4294967296
	else
		return v40
	end
end
v_u_11.TRY_RETURN = 1
v_u_11.TRY_BREAK = 2
v_u_11.TRY_CONTINUE = 3
function v_u_11.try(p41, p42, p43) -- name: try
	-- upvalues: (copy) v_u_11
	local v44, v45, v46 = pcall(p41)
	local v47
	if v44 then
		v47 = nil
	else
		v47 = v45
		v45 = nil
	end
	local v48 = nil
	local v49, v50, v51, v52
	if v44 or not p42 then
		v49 = v48
		v50 = v46
		v51 = v45
		v52 = true
	else
		v52, v49, v50 = pcall(p42, v47)
		if v52 then
			v51 = v49
			v49 = v48
		else
			v51 = nil
		end
		if not v51 then
			v50 = v46
			v51 = v45
		end
	end
	local v53, v54
	if p43 then
		v53, v54 = p43()
		if not v53 then
			v54 = v50
			v53 = v51
		end
	else
		v54 = v50
		v53 = v51
	end
	if v53 ~= v_u_11.TRY_RETURN and (v53 ~= v_u_11.TRY_BREAK and v53 ~= v_u_11.TRY_CONTINUE) then
		if not v52 then
			error(v49, 2)
		end
		if not (v44 or p42) then
			error(v47, 2)
		end
	end
	return v53, v54
end
function v_u_11.generator(p55) -- name: generator
	local v_u_56 = coroutine.create(p55)
	return {
		["next"] = function(...) -- name: next
			-- upvalues: (copy) v_u_56
			if coroutine.status(v_u_56) == "dead" then
				return {
					["done"] = true
				}
			end
			local v57, v58 = coroutine.resume(v_u_56, ...)
			if v57 == false then
				error(v58, 2)
			end
			return {
				["value"] = v58,
				["done"] = coroutine.status(v_u_56) == "dead"
			}
		end
	}
end
return v_u_11