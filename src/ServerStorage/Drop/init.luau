local callbacks = require(script.callbacks)
local schema = require(script.schema)
local store = require(script.store)

export type Schema<T> = schema.Schema<T>
export type Store<T> = store.Store<T>

return table.freeze({
	callbacks = callbacks,

	schema = schema.create,
	migrate = schema.migrate,

	store = store.create,
	startsession = store.startsession,
	waitforsession = store.waitforsession,
	issessionactive = store.issessionactive,
	stopsessionasync = store.stopsessionasync,
	view = store.view,
	update = store.update,
	observe = store.observe,
	viewasync = store.viewasync,
	updateasync = store.updateasync,
	txasync = store.txasync,
})
