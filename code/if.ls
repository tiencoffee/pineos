tid = \((tid))
callbacks = {}

send = (name, ...params) ->
	new Promise (resolve, reject) !~>
		mid = m.uuid!
		top.postMessage [tid, mid, \imi name, params] \*
		callbacks[mid] =
			resolve: resolve
			reject: reject

addEventListener \message (event) !~>
	[kind, mid, result] = event.data
	switch kind
	| \imi
		callback = callbacks[mid]
		callback.resolve result
		delete callbacks[mid]

await do !->
	codeEl.remove!
	data = await send \taskInit
	for let name in data.publicMethodNames
		unless name is \taskInit
			m[name] = (...args) ~>
				send name, ...args

	props =
		loadedLibs:
			"dayjs@1.10.6": yes
			"dayjs@1.10.6/locale/vi.js": yes
			"dayjs@1.10.6/plugin/localeData.js": yes
			"dayjs@1.10.6/plugin/customParseFormat.js": yes

	ifrmMethods =
		openContextMenu: (event, ...items) !->
			items = items.flat!
			onclicks = {}
			handle = (items) ~>
				for item in items
					if item
						if item.onclick
							uuid = m.uuid!
							onclicks[uuid] = item.onclick
							item.onclick = uuid
						if item.items
							handle item.items
			handle items
			uuid = await send \openContextMenu,
				x: event.x
				y: event.y
				items
			if uuid
				onclicks[uuid]!

	m <<< props
	m <<< ifrmMethods

	document.addEventListener \mousedown (event) !~>
		send \taskMouseDown event.button, event.x, event.y

await do (tid, callbacks, send) !~>
	((code))

m.mount appEl, m.App
