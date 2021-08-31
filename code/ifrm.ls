codeEl.remove!

TID = \((tid))
callbacks = {}
listeners = {}
ts = os
try topWin = window.top

send = (name, ...params) ->
	new Promise (resolve, reject) !~>
		mid = ts.uuid!
		callbacks[mid] =
			resolve: resolve
			reject: reject
		window.top.postMessage [TID, mid, \imi name, params] \*

addEventListener \message (event) !~>
	[tid, mid, kind, name, params, result, isErr] = event.data
	switch kind
	| \imi
		callback = callbacks[mid]
		callback[isErr and \reject or \resolve] result
		delete callbacks[mid]
	| \mim
		if listener = listeners[name]
			try
				result = await listener ...params
				isErr = no
			catch result
				isErr = yes
			window.top.postMessage [TID, mid, kind,,, result, isErr] \*

await do !->
	ts <<<
		loadedLibs:
			"dayjs@1.10.6": yes
			"dayjs@1.10.6/locale/vi.js": yes
			"dayjs@1.10.6/plugin/localeData.js": yes
			"dayjs@1.10.6/plugin/customParseFormat.js": yes

		listen: (methods) !~>
			for name, method of methods
				unless name.startsWith \$_
					listeners[name] = method

		openContextMenu: (event, ...items) !->
			items = items.flat!
			onclicks = {}
			handle = (items) ~>
				for item in items
					if item
						if item.onclick
							uuid = @uuid!
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

	listeners <<<
		$_mainMouseDown: (button, x, y) !~>
			evt = new MouseEvent \mousedown,
				button: button
				clientX: x
				clientY: y
			document.dispatchEvent evt

	data = await send \taskInit
	TID := data.tid
	for let name in data.publicMethodNames
		ts[name] = (...args) ~>
			send name, ...args

	if topWin
		task = topWin.os.tasks.find (.tid is TID)
		os := {}
		for name in topWin.os.methodNames
			os[name] = task[name]
		os := new Proxy os,
			get: (target, prop) ~>
				if prop of target
					target[prop]
				else
					topWin.os[prop]
			set: (target, prop, val) ~>
				if prop of target
					target[prop] = val
				else
					topWin.os[prop] = val
				yes
			deleteProperty: (target, prop) ~>
				if prop of target
					delete target[prop]
				else
					delete topWin.os[prop]
				yes
		ts.task = task
		ts := new Proxy ts,
			get: (target, prop) ~>
				if prop of target
					target[prop]
				else
					target.task[prop]
			set: (target, prop, val) ~>
				if prop of target
					target[prop] = val
				else
					target.task[prop] = val
				yes
			deleteProperty: (target, prop) ~>
				if prop of target
					delete target[prop]
				else
					delete target.task[prop]
				yes

	document.addEventListener \mousedown (event) !~>
		if event.isTrusted
			send \taskMouseDown event.button, event.x, event.y

App = await do (TID, callbacks, listeners, send) ~>
	((js))

m.mount appEl, App
