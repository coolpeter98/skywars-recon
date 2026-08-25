local callbacks = require(script.Parent.callbacks)

local DataStoreService = game:GetService("DataStoreService")

local GetAsync = DataStoreService:GetDataStore("_").GetAsync
local SetAsync = DataStoreService:GetDataStore("_").SetAsync
local UpdateAsync = DataStoreService:GetDataStore("_").UpdateAsync
local RemoveAsync = DataStoreService:GetDataStore("_").RemoveAsync

local GetOpts = Instance.new("DataStoreGetOptions")
GetOpts.UseCache = false

local function getdatastore(name: string): DataStore
	return DataStoreService:GetDataStore(name)
end

local function getasync(datastore: DataStore, key: string): (boolean, any)
	local success, result = pcall(GetAsync, datastore, key, GetOpts)
	if success then
		return true, result
	end

	callbacks.apierror({
		msg = result,
		op = "GetAsync",
		datastore = datastore,
		key = key,
		retry = true,
	})

	local success, result = pcall(GetAsync, datastore, key, GetOpts)
	if success then
		return true, result
	end

	callbacks.apierror({
		msg = result,
		op = "GetAsync",
		datastore = datastore,
		key = key,
		retry = false,
	})

	return false
end

local function setasync(datastore: DataStore, key: string, value: any): boolean
	local success, result = pcall(SetAsync, datastore, key, value)
	if success then
		return true
	end

	callbacks.apierror({
		msg = result,
		op = "SetAsync",
		datastore = datastore,
		key = key,
		retry = true,
	})

	local success, result = pcall(SetAsync, datastore, key, value)
	if success then
		return true
	end

	callbacks.apierror({
		msg = result,
		op = "SetAsync",
		datastore = datastore,
		key = key,
		retry = false,
	})

	return false
end

local function updateasync(datastore: DataStore, key: string, transform: (any, DataStoreKeyInfo) -> any): (boolean, any, DataStoreKeyInfo)
	local success, result, info = pcall(UpdateAsync, datastore, key, transform)
	if success then
		return true, result, info
	end

	callbacks.apierror({
		msg = result,
		op = "UpdateAsync",
		datastore = datastore,
		key = key,
		retry = true,
	})

	local success, result, info = pcall(UpdateAsync, datastore, key, transform)
	if success then
		return true, result, info
	end

	callbacks.apierror({
		msg = result,
		op = "UpdateAsync",
		datastore = datastore,
		key = key,
		retry = false,
	})

	return false
end

local function removeasync(datastore: DataStore, key: string): boolean
	local success, result = pcall(RemoveAsync, datastore, key)
	if success then
		return true
	end

	callbacks.apierror({
		msg = result,
		op = "RemoveAsync",
		datastore = datastore,
		key = key,
		retry = true,
	})

	local success, result = pcall(RemoveAsync, datastore, key)
	if success then
		return true
	end

	callbacks.apierror({
		msg = result,
		op = "RemoveAsync",
		datastore = datastore,
		key = key,
		retry = false,
	})

	return false
end

return table.freeze({
	getdatastore = getdatastore,
	getasync = getasync,
	setasync = setasync,
	updateasync = updateasync,
	removeasync = removeasync,
})
