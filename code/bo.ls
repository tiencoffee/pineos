dayjs.locale \vi
dayjs.extend dayjs_plugin_localeData
dayjs.extend dayjs_plugin_customParseFormat

m <<<
	uidVal: 0

	cssUnitless:
		animationIterationCount: yes
		aspectRatio: yes
		borderImageOutset: yes
		borderImageSlice: yes
		borderImageWidth: yes
		boxFlex: yes
		boxFlexGroup: yes
		boxOrdinalGroup: yes
		columnCount: yes
		columns: yes
		flex: yes
		flexGrow: yes
		flexPositive: yes
		flexShrink: yes
		flexNegative: yes
		flexOrder: yes
		gridArea: yes
		gridRow: yes
		gridRowEnd: yes
		gridRowSpan: yes
		gridRowStart: yes
		gridColumn: yes
		gridColumnEnd: yes
		gridColumnSpan: yes
		gridColumnStart: yes
		fontWeight: yes
		lineClamp: yes
		lineHeight: yes
		opacity: yes
		order: yes
		orphans: yes
		tabSize: yes
		widows: yes
		zIndex: yes
		zoom: yes
		fillOpacity: yes
		floodOpacity: yes
		stopOpacity: yes
		strokeDasharray: yes
		strokeDashoffset: yes
		strokeMiterlimit: yes
		strokeOpacity: yes
		strokeWidth: yes

	upperFirst: (text) ->
		text.0.toUpperCase! + text.substring 1

	castArray: (val) ->
		if Array.isArray val => val
		else if val? => [val]
		else []

	safeCall: (fn, ...args) ->
		if typeof fn is \function => fn ...args
		else fn

	uid: ->
		++m.uidVal

	uuid: ->
		\_ + Math.random! + Date.now! - \.

	fetch: (url, type) ->
		(await fetch url)[type]!

	loadjs: (...libs) !->
		promises = []
		for lib in libs
			unless m.loadedLibs[lib]
				[type, path] = lib.split \:
				if type is \gh
					"https://cdn.jsdelivr.net/gh/#path"
				else if type is \http or type is \https or type.startsWith \//
					lib
				else
					"https://cdn.jsdelivr.net/npm/#path"
				m.loadedLibs[lib] = yes
				promise = m.fetch url
				promises.push promise
		code = await Promise.all promises
		code .= join \\n
		window.eval code

	loadcss: (...libs) !->
		promises = []
		for lib in libs
			unless m.loadedLibs[lib]
				[type, path] = lib.split \:
				if type is \gh
					"https://cdn.jsdelivr.net/gh/#path"
				else if type is \http or type is \https or type.startsWith \//
					lib
				else
					"https://cdn.jsdelivr.net/npm/#path"
				m.loadedLibs[lib] = yes
				promise = m.fetch url
				promises.push promise
		styl = await Promise.all promises
		styl = styl.join(\\n) + \\n
		libStylEl.textContent += styl

	splitPath: (path) ->
		res = []
		if path.0 is \/
			abs = \/
			path .= substring 1
		else
			abs = ""
		nodes = path.split /\/+/
		for node in nodes
			if node and node isnt \.
				if node is \..
					res.pop!
				else
					res.push node
		[res, abs]

	normPath: (path) ->
		[nodes, abs] = m.splitPath path
		abs + nodes.join \/

	dirPath: (path) ->
		[nodes, abs] = m.splitPath path
		abs + (nodes.slice 0 -1 .join \/)

	filePath: (path) ->
		[nodes] = m.splitPath path
		nodes[* - 1]

	extPath: (path) ->
		filename = m.filePath path
		filename.split \. .1 or ""

	class: (...names) ->
		res = []
		for name in names
			if Array.isArray name
				res.push @class ...name
			else if name instanceof Object
				for k of name
					res.push k if name[k]
			else if name?
				res.push name
		if res.length
			res.join " "

	style: (...rules) ->
		res = {}
		for rule in rules
			if Array.isArray rule
				Object.assign res, @style ...rule
			else if rule instanceof Object
				for k, val of rule
					val += \px if not @cssUnitless[k] and +val
					res[k] = val
		res

	bind: (target, thisArg = target) !->
		for k, val of target
			if typeof val is \function
				target[k] = val.bind thisArg

	comp: (comp, ...stts) ->
		comp <<<
			$_oninit: comp.oninit
			$_oncreate: comp.oncreate
			$_onbeforeupdate: comp.onbeforeupdate
			$_onupdate: comp.onupdate
			$_oldAttrs: void
			oninit: (vnode) !->
				m.bind @
				@attrs = vnode.attrs or {}
				@attrs.children = m.castArray @attrs.children ? vnode.children
				@$_oldAttrs = @attrs
				@$_oninit?!
				@$_onbeforeupdate? @$_oldAttrs, yes
			oncreate: (vnode) !->
				@dom = vnode.dom
				@$_oncreate?!
				@$_onupdate? @$_oldAttrs, yes
			onbeforeupdate: (vnode) ->
				@attrs = vnode.attrs or {}
				@attrs.children = m.castArray @attrs.children ? vnode.children
				@$_onbeforeupdate? @$_oldAttrs
			onupdate: (vnode) !->
				@dom = vnode.dom
				@$_onupdate? @$_oldAttrs
				@$_oldAttrs = @attrs
		for stt in stts
			comp <<< stt if stt
		comp

	createPopper: (refEl, popperEl, opts = {}) ->
		Popper.createPopper refEl, popperEl,
			placement: opts.placement or \auto
			modifiers:
				* name: \offset
					options:
						offset: opts.offsets
				* name: \preventOverflow
					options:
						padding: opts.padding
				* name: \flip
					options:
						fallbackPlacements: opts.flips
						allowedAutoPlacements: opts.allowedFlips

document.addEventListener \contextmenu (event) !~>
	event.preventDefault!
