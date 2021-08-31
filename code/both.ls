dayjs.locale \vi
dayjs.extend dayjs_plugin_localeData
dayjs.extend dayjs_plugin_customParseFormat

m <<<
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
					val += \px if not m.cssUnitless[k] and +val
					res[k] = val
		res

	comp: (comp, ...stts) ->
		comp <<<
			$_oninit: comp.oninit
			$_oncreate: comp.oncreate
			$_onbeforeupdate: comp.onbeforeupdate
			$_onupdate: comp.onupdate
			$_oldAttrs: void
			oninit: (vnode) !->
				for k, val of @
					@[k] = val.bind @ if typeof val is \function
				@attrs = vnode.attrs or {}
				@attrs.children ?= vnode.children ? []
				@attrs.children = [@attrs.children] unless Array.isArray @attrs.children
				@$_oldAttrs = @attrs
				@$_oninit?!
				@$_onbeforeupdate? @$_oldAttrs, yes
			oncreate: (vnode) !->
				@dom = vnode.dom
				@$_oncreate?!
				@$_onupdate? @$_oldAttrs, yes
			onbeforeupdate: (vnode) ->
				@attrs = vnode.attrs or {}
				@attrs.children ?= vnode.children ? []
				@attrs.children = [@attrs.children] unless Array.isArray @attrs.children
				@$_onbeforeupdate? @$_oldAttrs
			onupdate: (vnode) !->
				@dom = vnode.dom
				@$_onupdate? @$_oldAttrs
				@$_oldAttrs = @attrs
		for stt in stts
			comp <<< stt if stt
		comp

os =
	uidVal: 0

	upperFirst: (text) ->
		text.0.toUpperCase! + text.substring 1

	rand: (min, max) ->
		if &length < 2
			min = 0
			max = if &length => min else 1
		Math.floor min + Math.random! * (max + 1 - min)

	clamp: (val, min, max) ->
		if &length is 2
			max = min
			min = 0
		if val < min => min
		else if val > max => max
		else val

	castArray: (val) ->
		if Array.isArray val => val
		else if val? => [val]
		else []

	call: (fn, ...args) ->
		if typeof fn is \function => fn ...args
		else fn

	uid: ->
		++@uidVal

	uuid: ->
		\_ + Math.random! + Date.now! - \.

	bind: (target) !->
		for k, val of target
			target[k] = val.bind target if typeof val is \function

	fetch: (url, type = \text) ->
		(await fetch url)[type]!

	loadjs: (...libs) !->
		promises = []
		for lib in libs
			unless @loadedLibs[lib]
				[type, path] = lib.split \:
				url = switch type
					| \npm => "https://cdn.jsdelivr.net/npm/#path"
					| \gh => "https://cdn.jsdelivr.net/gh/#path"
					| \https \http => lib
				@loadedLibs[lib] = yes
				promises.push @fetch url
		js = await Promise.all promises
		js .= join \\n
		window.eval js

	loadcss: (...libs) !->
		promises = []
		for lib in libs
			unless @loadedLibs[lib]
				[type, path] = lib.split \:
				url = switch type
					| \npm => "https://cdn.jsdelivr.net/npm/#path"
					| \gh => "https://cdn.jsdelivr.net/gh/#path"
					| \https \http => lib
				@loadedLibs[lib] = yes
				promises.push @fetch url
		css = await Promise.all promises
		css = css.join(\\n) + \\n
		cssLibEl.textContent += css

	newHistory: (items, pushAt = 0, max = 100, duplicate) ->
		hist =
			items: @castArray items
			index: 0
			canUndo: no
			canRedo: no
			push: (item) !~>
				unless duplicate
					index = if hist.index < pushAt => pushAt else hist.index
					return if item is hist.items[index]
				if hist.index > pushAt
					hist.items .= slice hist.index
					hist.index = 0
				hist.items.splice pushAt, 0 item
				if hist.items.length > max
					hist.items.pop!
				hist.canRedo = no
				hist.canUndo = hist.items.length > 1
			undo: ~>
				if hist.canUndo
					hist.index++
					hist.canRedo = yes
					hist.canUndo = hist.index + 1 < hist.items.length
					hist.items[hist.index]
			redo: ~>
				if hist.canRedo
					hist.index--
					hist.canUndo = yes
					hist.canRedo = hist.index - 1 >= 0
					hist.items[hist.index]
			current: ~>
				hist.items[hist.index]
			prev: ~>
				hist.items[hist.index + 1]
			next: ~>
				hist.items[hist.index - 1]
		hist

	splitPath: (path, keepTwoDot) ->
		res = []
		if path.0 is \/
			abs = \/
			path .= substring 1
		else
			abs = ""
		nodes = path.split /\/+/
		for node in nodes
			if node and node isnt \.
				if node is \.. and not keepTwoDot
					res.pop!
				else
					res.push node
		[res, abs]

	dirPath: (path) ->
		[nodes, abs] = @splitPath path
		abs + (nodes.slice 0 -1 .join \/)

	filePath: (path) ->
		[nodes] = @splitPath path
		nodes.at -1

	extPath: (path) ->
		filename = @filePath path
		filename.split \. .1 or ""

	normPath: (path) ->
		[nodes, abs] = @splitPath path
		abs + nodes.join \/

	resolvePath: (...paths) ->
		res = ""
		for path in paths
			[nodes, abs] = @splitPath path, yes
			res = "" if abs
			res += \/ + nodes.join \/
		[nodes] = @splitPath res
		\/ + nodes.join \/

	createPopper: (refEl, popperEl, opts = {}) ->
		Popper.createPopper refEl, popperEl,
			placement: opts.placement or \auto
			modifiers:
				* name: \offset
					options:
						offset: opts.offsets
				* name: \preventOverflow
					options:
						padding: opts.padding ? 4
				* name: \flip
					options:
						fallbackPlacements: opts.flips
						allowedAutoPlacements: opts.allowedFlips

document.addEventListener \contextmenu (event) !~>
	event.preventDefault!
