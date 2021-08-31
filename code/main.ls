TID = ""
topWin = window

os <<<
	isMain: yes
	admin: yes
	apps: []
	tasks: []
	task: void
	desktopWidth: void
	desktopHeight: void
	taskbarHeight: 39
	time: dayjs!
	battery: void
	batteryLevel: 0
	batteryCharging: no
	nightLight: no
	publicMethodNames: void
	privateMethodNames: void
	tooltipPopper: void
	contextMenuPopper: void
	callbacks: {}
	loaded: no
	loadedLibs:
		"dayjs@1.10.6": yes
		"dayjs@1.10.6/locale/vi.js": yes
		"dayjs@1.10.6/plugin/localeData.js": yes
		"dayjs@1.10.6/plugin/customParseFormat.js": yes

	indent: (code, lv = 1) ->
		code.replace /^(?!$)/gm \\t * lv

	getBatteryIcon: ->
		if @battery
			if @batteryLevel is 0 => \battery-empty
			else if @batteryLevel <= 0.2 => \battery-low
			else if @batteryLevel <= 0.4 => \battery-quarter
			else if @batteryLevel <= 0.6 => \battery-half
			else if @batteryLevel <= 0.8 => \battery-three-quarters
			else \battery-full
		else \battery-exclamation

	toggleNightLight: (val) !->
		val = if val? => !!val else not @nightLight
		@nightLight = val
		m.redraw!

	installApp: (type, src, path) !->
		switch type
		| \boot
			app = await @fetch "#src/app.yml"
			app = jsyaml.safeLoad app
			app <<<
				path: path
		@apps.push app

	runTask: (file, env = {}) ->
		path = @dirPath file
		app = @apps.find (.path is path)
		if app
			env = {} <<< app <<< env <<<
				name: app.name
				path: app.path
			new Promise (resolve) !~>
				pid = @uid!
				tid = @uuid!
				js = await @readFile "#path/app.ls"
				js = Boot.code.replace /(^\t*)?\(\((\w+)\)\)/gm (, tab, name) ~>
					text = eval name
					text = @indent text, tab.length if tab
					text
				js = livescript.compile js
				try
					css = await @readFile "#path/app.styl"
				catch
					css = ""
				css = Boot.styl.replace /(^\t*)?\(\((\w+)\)\)/gm (, tab, name) ~>
					text = eval name
					text = @indent text, tab.length if tab
					text
				css = stylus.render css, compress: yes
				html = Boot.html.replace /\(\((\w+)\)\)/g (, name) ~>
					eval name
				task =
					isTask: yes
					pid: pid
					tid: tid
					app: app
					env: env
					admin: env.admin
					resolve: resolve
					win: void
					button: void
					postMessage: void
					html: html
				task <<< @getPublicMethods task
				task <<< @getPrivateMethods task
				@tasks.push task
				m.redraw!

	send: (task, name, ...params) ->
		if task.postMessage
			new Promise (resolve, reject) !~>
				mid = @uuid!
				@callbacks[mid] =
					resolve: resolve
					reject: reject
				task.postMessage [TID, mid, \mim name, params] \*

	getEntryIcon: (data) ->
		if data.isDir
			\folder|d9822b
		else if data.name is \app.yml
			try
				yml = await @readFile data.path
				yml = jsyaml.safeLoad yml
				yml.icon or \fad:window
			catch
				\bug
		else
			ext = @extPath data.path
			switch ext
			| \txt => \file-lines
			| \png \jpg \jpeg \webp \gif => \file-image
			| \mp4 \3gp => \file-video
			| \mp3 \wav \ogg => \file-audio
			| \pdf => \file-pdf
			| \pug \ls \styl \stylus \htm \htm \css \js => \file-code
			| \zip \rar => \file-zipper
			else \file

	statEntry: (entry) ->
		if entry.path
			entry
		else
			stat = await fs.stat entry
			data =
				name: stat.name
				path: stat.fullPath
				size: stat.size
				mtime: stat.modificationTime
				isDir: stat.isDirectory
				isFile: stat.isFile
			data.icon = await @getEntryIcon data
			if entry.children
				promises = []
				for entry2 in entry.children
					promises.push @statEntry entry2
				data.children = await Promise.all promises
			data

	entryPath: (path) ->
		path.path or path

	getPublicMethods: (ts) ->
		readFile: (path, type = \text) ->
			path = @entryPath path
			type = @upperFirst type
			fs.readFile path, type

		writeFile: (path, data) ->
			path = @entryPath path
			file = await fs.writeFile path, data
			await @statEntry file

		appendFile: (path, data) ->
			path = @entryPath path
			file = await fs.appendFile path, data
			await @statEntry file

		removeFile: (path) ->
			path = @entryPath path
			res = await fs.unlink path
			res is void

		createDir: (path) ->
			dir = await fs.mkdir path
			await @statEntry dir

		readDir: (path, isDeep) ->
			path = @entryPath path
			entries = await fs.readdir path, deep: isDeep
			promises = []
			for entry in entries
				promises.push @statEntry entry
			await Promise.all promises

		removeDir: (path) ->
			path = @entryPath path
			res = await fs.rmdir path
			res is void

		getEntry: (path) ->
			path = @entryPath path
			entry = await fs.getEntry path
			await @statEntry entry

		existsEntry: (path) ->
			path = @entryPath path
			await fs.exists path

		copyEntry: (path, newPath, isCreate) ->
			path = @entryPath path
			newPath = @entryPath newPath
			entry = await fs.copy path, newPath, create: isCreate
			await @statEntry entry

		moveEntry: (path, newPath, isCreate) ->
			path = @entryPath path
			newPath = @entryPath newPath
			entry = await fs.rename path, newPath, create: isCreate
			await @statEntry entry

		close: (val) !->
			ts.win.close val

	getPrivateMethods: (ts) ->
		openTooltip: (content, rect, opts = {}) !->
			@closeTooltip!
			if ts.isTask
				{x, y} = ts.win.iframeEl.getBoundingClientRect!
			else
				x = y = 0
			comp =
				view: ~> content
			m.mount tooltipEl, comp
			targetEl =
				getBoundingClientRect: ~>
					left: x + rect.x
					top: y + rect.y
					width: rect.width
					height: rect.height
			@tooltipPopper = @createPopper targetEl, tooltipEl,
				placement: opts.position

		closeTooltip: !->
			if @tooltipPopper
				@tooltipPopper.destroy!
				@tooltipPopper = void
				m.mount tooltipEl

		openContextMenu: (event, ...items) ->
			@closeContextMenu!
			if items.length
				items = items.flat!
				if ts.isTask
					{x, y} = ts.win.iframeEl.getBoundingClientRect!
				else
					x = y = 0
				new Promise (resolve) !~>
					comp =
						view: ~>
							m Menu,
								class: \ContextMenu
								items: items
								onitemclick: (item) !~>
									@closeContextMenu!
									resolve item.onclick
					m.mount contextMenuEl, comp
					targetEl =
						getBoundingClientRect: ~>
							left: x + event.x
							top: y + event.y
							width: 0
							height: 0
					@contextMenuPopper = @createPopper targetEl, contextMenuEl,
						placement: \bottom-start
						flips: [\top-start]
					onmousedownGlobal = (event) !~>
						unless contextMenuEl.contains event.target
							@closeContextMenu!
							document.removeEventListener \mousedown onmousedownGlobal
							resolve!
					document.addEventListener \mousedown onmousedownGlobal

		closeContextMenu: !->
			if @contextMenuPopper
				@contextMenuPopper.destroy!
				@contextMenuPopper = void
				m.mount contextMenuEl

		readClipboard: ->
			navigator.clipboard.readText!

		taskInit: ->
			unless ts.postMessage
				{contentWindow} = ts.win.iframeEl
				ts.tid = @uuid!
				ts.postMessage = contentWindow.postMessage.bind contentWindow
				tid: ts.tid
				publicMethodNames: @publicMethodNames

		taskMouseDown: (button, x, y) !->
			ts.win.focus!
			rect = ts.win.iframeEl.getBoundingClientRect!
			evt = new MouseEvent \mousedown,
				button: button
				clientX: rect.x + x
				clientY: rect.y + y
			document.dispatchEvent evt
			@closeTooltip!

	onlevelchangeBattery: !->
		@batteryLevel = @battery.level
		m.redraw!

	onchargingchangeBattery: !->
		@batteryCharging = @battery.charging
		m.redraw!

	onresize: !->
		@desktopWidth = innerWidth
		@desktopHeight = innerHeight - @taskbarHeight

	onmousedown: (event) !->
		@closeTooltip!
		if event.isTrusted
			for task in @tasks
				@send task, \$_mainMouseDown event.button, 0 0

	onmessage: (event) !->
		[tid, mid, kind, name, params, result, isErr] = event.data
		task = @tasks.find (.tid is tid)
		if task
			params = @castArray params
			switch kind
			| \imi
				if @methodNames.includes name
					try
						result = await task[name]apply @, params
						isErr = no
					catch result
						isErr = yes
					task.win.iframeEl.contentWindow.postMessage [TID, mid, kind,,, result, isErr] \*
			| \mim
				callback = @callbacks[mid]
				callback[isErr and \reject or \resolve] result
				delete @callbacks[mid]

	onclickTaskbarTask: (task, event) !->
		if task is @task
			task.win.minimize!
		else
			task.win.focus!

	oninit: !->
		methods = @getPublicMethods @
		@ <<< methods
		@publicMethodNames = Object.keys methods
		methods = @getPrivateMethods @
		@ <<< methods
		@privateMethodNames = Object.keys methods
		@methodNames = @publicMethodNames ++ @privateMethodNames
		@bind @
		os := window.os = @

	oncreate: !->
		addEventListener \resize @onresize
		@onresize!
		document.addEventListener \mousedown @onmousedown
		await fs.init do
			type: Window.TEMPORARY
			size: 1024 * 1024 * 256
		@battery = await navigator.getBattery!
		@battery.addEventListener \levelchange @onlevelchangeBattery
		@battery.addEventListener \chargingchange @onchargingchangeBattery
		@onlevelchangeBattery!
		@onchargingchangeBattery!
		for path in Boot.paths\C
			dist = \/ + path
			if @extPath dist
				data = await @fetch path, \arrayBuffer
				await @writeFile dist, data
			else
				await @createDir dist
		for path in Boot.paths\C/apps
			dist = \/ + path
			await @installApp \boot path, dist
		addEventListener \message @onmessage
		@loaded = yes
		@runTask \/C/apps/FileManager/app.yml,
			desktop: yes
		@runTask \/C/apps/FileManager/app.yml
		m.redraw!

	view: ->
		m \.App,
			m \.App__tasks,
				@tasks.map (task) ~>
					m Task,
						key: task.pid
						task: task
			m \.App__taskbar,
				style: m.style do
					height: @taskbarHeight
				m Popover,
					position: \top-start
					content: (close) ~>
						m \.column.p-3,
							m \h3 "PineOS"
					m Button,
						basic: yes
						icon: \home
				m \.App__taskbarTasks,
					@tasks.map (task) ~>
						if task.win
							m Popover,
								key: task.pid
								interactionType: \contextmenu
								content: (close) ~>
									m Menu,
										basic: yes
										width: 178
										items:
											* header: task.win.title
											* text: "Giữa màn hình"
												icon: \align-center
												onclick: !~>
													task.win.x = Math.floor (@desktopWidth - task.win.width) / 2
													task.win.y = Math.floor (@desktopHeight - task.win.height) / 2
													task.win.focus!
											* text: "Đóng"
												icon: \xmark
												color: \red
												onclick: !~>
													task.win.close!
										onitemclick: close
								m Button,
									active: task is @task
									width: 180
									icon: task.win.icon
									onclick: (event) !~>
										@onclickTaskbarTask task, event
									oninit: (task.button) !~>
									task.win.title
						else
							m Button,
								key: task.pid
								oninit: (task.button) !~>
				m \.App__taskbarTray,
					m Button,
						basic: yes
						icon: \volume
					m Tooltip,
						position: \top
						content: ~>
							"Pin: #{Math.round @batteryLevel * 100}%, #{@batteryCharging and \đang or \không} sạc"
						m Button,
							basic: yes
							icon: @getBatteryIcon!
					m Button,
						basic: yes
						icon: \wifi
					m Popover,
						position: \top
						content: ~>
							m DateTime,
								basic: yes
						m Tooltip,
							position: \top
							content: ~>
								@time.format "dddd, DD MMMM, YYYY"
							m Button,
								basic: yes
								@time.format "dd, DD/MM/YYYY, HH:mm"
					m Popover,
						position: \top
						content: (close) ~>
							m \.column.p-3,
								m \.col
								m \.col-0,
									m Table,
										class: "text-center"
										bordered: yes
										fixed: yes
										width: 300
										interactive: \col
										m \tr,
											m \td.p-3,
												m Icon,
													name: \wifi
												m \.mt-1,
													"Mạng"
											m \td.p-3,
												m Icon,
													name: \arrows-repeat
												m \.mt-1,
													"PeerJS"
											m \td.p-3,
												m Icon,
													name: \location-dot
												m \.mt-1,
													"Định vị"
										m \tr,
											m \td.p-3,
												m Icon,
													name: \brightness
												m \.mt-1,
													"Độ sáng"
											m \td.p-3,
												m Icon,
													name: \presentation-screen
												m \.mt-1,
													"Chiếu"
											m \td.p-3,
												m Icon,
													name: \circle-half-stroke
												m \.mt-1,
													"Chế độ tối"
										m \tr,
											m \td.p-3,
												m Icon,
													name: \moon
												m \.mt-1,
													"Tập trung"
											m \td.p-3,
												class: m.class do
													"bg-blue text-white": @nightLight
												onclick: (event) !~>
													@toggleNightLight!
												m Icon,
													name: \eye
												m \.mt-1,
													"Làm dịu mắt"
											m \td.p-3,
												m Icon,
													name: \gear
												m \.mt-1,
													"Cài đặt"
						m Button,
							basic: yes
							icon: \message-middle
			if @nightLight
				m \.App__nightLight

m.mount appEl, os
