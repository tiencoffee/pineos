tid = ""

props =
	taskbarHeight: 39
	apps: []
	tasks: []
	publicMethodNames: void
	privateMethodNames: void
	tooltipPopper: void
	contextMenuPopper: void
	loaded: no
	loadedLibs:
		"dayjs@1.10.6": yes
		"dayjs@1.10.6/locale/vi.js": yes

mainMethods =
	indent: (code, lv) ->
		code.replace /^(?!$)/gm \\t * lv

	installApp: (type, src, path) !->
		switch type
		| \boot
			app = await (await fetch "#src/app.yml")text!
			app = jsyaml.safeLoad app
			app <<<
				path: path
		m.apps.push app

	runTask: (file) !->
		new Promise (resolve) !~>
			path = m.dirPath file
			app = m.apps.find (.path is path)
			if app
				pid = m.uid!
				tid = m.uuid!
				code = await m.readFile "#path/app.ls"
				code = Boot.codeI.replace /(^\t)*\(\((\w+)\)\)/gm (, tab, name) ~>
					text = eval name
					if tab
						text = m.indent text, tab.length
					text
				code = livescript.compile code
				try
					styl = await m.readFile "#path/app.styl"
				catch
					styl = ""
				styl = Boot.stylI.replace "((styl))" styl
				styl = stylus.render styl, compress: yes
				tmpl = Boot.tmplI.replace /\(\((\w+)\)\)/g (, name) ~>
					eval name
				task =
					pid: pid
					tid: tid
					app: app
					resolve: resolve
					win: void
					tmpl: tmpl
				m.tasks.push task
				m.redraw!

	onresize: (event) !->
		m.desktopWidth = innerWidth
		m.desktopHeight = innerHeight - m.taskbarHeight

	onmousedown: (event) !->
		m.closeTooltip!

	onmessage: (event) !->
		[tid, mid, kind, name, params] = event.data
		params = m.castArray params
		task = m.tasks.find (.tid is tid)
		if task
			switch kind
			| \imi
				if m.publicMethodNames.includes name
					method = m.getPublicMethods
				else if m.privateMethodNames.includes name
					method = m.getPrivateMethods
				if method
					result = await method(task)[name] ...params
					task.win.iframeEl.contentWindow.postMessage [kind, mid, result] \*

getPublicMethods = (task) ->
	readFile: (path, type = \text) ->
		type = m.upperFirst type
		fs.readFile path, type

	writeFile: (path, data) !->
		fs.writeFile path, data

	appendFile: (path, data) !->
		fs.appendFile path, data

	createDir: (path) !->
		fs.mkdir path

	close: (val) !->
		task.win.close val

getPrivateMethods = (task) ->
	openTooltip: (content, rect, opts = {}) !->
		m.closeTooltip!
		if task
			{x, y} = task.win.iframeEl.getBoundingClientRect!
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
		m.tooltipPopper = m.createPopper targetEl, tooltipEl,
			placement: opts.position

	closeTooltip: !->
		if m.tooltipPopper
			m.tooltipPopper.destroy!
			m.tooltipPopper = void
			m.mount tooltipEl

	openContextMenu: (event, ...items) ->
		items = items.flat!
		m.closeContextMenu!
		if task
			{x, y} = task.win.iframeEl.getBoundingClientRect!
		else
			x = y = 0
		new Promise (resolve) !~>
			comp =
				view: ~>
					m m.Menu,
						class: \ContextMenu
						items: items
						onitemclick: (item) !~>
							m.closeContextMenu!
							resolve item.onclick
			m.mount contextMenuEl, comp
			targetEl =
				getBoundingClientRect: ~>
					left: x + event.x
					top: y + event.y
					width: 0
					height: 0
			m.contextMenuPopper = m.createPopper targetEl, contextMenuEl,
				placement: \right-start
				flips: [\left-start]
				allowedFlips: [\right-start \left-start]
			onmousedownGlobal = (event) !~>
				unless contextMenuEl.contains event.target
					m.closeContextMenu!
					document.removeEventListener \mousedown onmousedownGlobal
					resolve!
			document.addEventListener \mousedown onmousedownGlobal

	closeContextMenu: !->
		if m.contextMenuPopper
			m.contextMenuPopper.destroy!
			m.contextMenuPopper = void
			m.mount contextMenuEl

	readClipboard: ->
		navigator.clipboard.readText!

	taskInit: ->
		publicMethodNames: m.publicMethodNames

	taskMouseDown: (button, x, y) !->
		rect = task.win.iframeEl.getBoundingClientRect!
		evt = new MouseEvent \mousedown,
			button: button
			clientX: rect.x + x
			clientY: rect.y + y
		document.dispatchEvent evt
		m.closeTooltip!

m <<< props
m <<< mainMethods
m.getPublicMethods = getPublicMethods
methods = getPublicMethods!
m <<< methods
m.publicMethodNames = Object.keys methods
m.getPrivateMethods = getPrivateMethods
methods = getPrivateMethods!
m <<< methods
m.privateMethodNames = Object.keys methods

m.App = m.comp do
	oninit: !->
		@val = "Xe đạp lách cách"
		@boolVal = yes
		@isOpen1 = no
		@isOpen2 = yes
		@colors = <[red yellow green blue]>
		@dateTimeVal = "2021/10/20T15:52:04"
		@tabId = \about
		@menuItems =
			* text: "Chọn"
				color: \blue
				icon: \check-circle
			,,
			* text: "Mở"
			* text: "Mở bằng"
				icon: \fad:tablet-alt
				items:
					* text: "Google Play"
						icon: 732208
					* text: "Xbox"
						icon: 732260
					* text: "Gmail"
						icon: 888853
					* text: "Slack"
						icon: 732245
					,,
					* text: "Chọn ứng dụng khác..."
			,,
			* text: "Văn bản"
				items:
					* text: "Căn chỉnh"
						items:
							* text: "Trái"
								icon: \align-left
							* text: "Giữa"
								icon: \align-center
							* text: "Phải"
								icon: \align-right
					* text: "Làm đậm"
						icon: \bold
			* text: "Gửi"
				color: \green
				icon: \share
				items:
					* text: "Gửi qua Bluetooth"
						color: \yellow
			* text: "Mưa rơi bên thềm, thấp thoáng bóng ai ngoài kia, anh ngỡ như là em đã quay về"
				icon: \quote-right
				label: "Ctrl+D"
			,,
			* text: "Xóa"
				color: \red
				icon: \fad:trash-alt
				label: "Delete"
			* text: "Tạo mã QR cho trang này"
				icon: \qrcode
				label: "Ctrl+Shift+Q"
		@selectItems =
			* text: "Torkoal"
				icon: \https://www.serebii.net/pokedex-swsh/icon/324.png
				value: "torkoal"
			* text: "Cá ngừ đại dương"
				value: "cá ngừ"
			,,
			* text: "Số PI"
				value: 3.14159
			* 2021
			* no
			,,
			* text: "Halong bay"
				icon: 2510402
				value: \halong-bay
			* text: "Chỉ có text"
			* text: "Nhà tôi ở cuối chân đồi, có giàn thiên lý có người tôi thương"
				icon: \fad:mountain
				value: [1 5 6]
			* text: "Việt Nam"
				icon: 321252
				value: \vn
			* value: \chi-gia-tri
			,,
			* icon: \gift
				value: \gift
			* text: "Bóng tennis"
				icon: 802289
				value: 802289
		@selectVal = \vn
		@pkmItems =
			* text: "Silicobra"
				icon: \https://www.serebii.net/pokedex-swsh/icon/843.png
			* text: "Wooloo"
				icon: \https://www.serebii.net/pokedex-swsh/icon/831.png
			* text: "Lurantis"
				icon: \https://www.serebii.net/pokedex-swsh/icon/754.png
			* text: "Espurr"
				icon: \https://www.serebii.net/pokedex-swsh/icon/677.png
			* text: "Hakamo-o"
				icon: \https://www.serebii.net/pokedex-swsh/icon/783.png
		@tableItems =
			* icon: \https://www.serebii.net/pokedex-swsh/icon/264.png
				name: "Linoone"
				type: "Normal"
			* icon: \https://www.serebii.net/pokedex-swsh/icon/742.png
				name: "Cutiefly"
				type: "Bug / Fairy"
			* icon: \https://www.serebii.net/pokedex-swsh/icon/746-s.png
				name: "Washiwashi (School Form)"
				type: "Water"
			* icon: \https://www.serebii.net/pokedex-swsh/icon/797.png
				name: "Celesteela"
				type: "Steel / Flying"
			* icon: \https://www.serebii.net/pokedex-swsh/icon/823.png
				name: "Corviknight"
				type: "Flying / Steel"
			* icon: \https://www.serebii.net/pokedex-swsh/icon/845.png
				name: "Cramorant"
				type: "Flying / Water"
			* icon: \https://www.serebii.net/pokedex-swsh/icon/895.png
				name: "Regidrago"
				type: "Dragon"

	oncreate: !->
		addEventListener \resize m.onresize
		m.onresize!
		addEventListener \mousedown m.onmousedown
		await fs.init do
			type: Window.TEMPORARY
			size: 1024 * 1024 * 256
		for path in Boot.paths\C
			if m.extPath path
				data = await (await fetch path)arrayBuffer!
				await m.writeFile path, data
			else
				await m.createDir path
		for path in Boot.paths\C/apps
			await m.installApp \boot path, path
		addEventListener \message m.onmessage
		m.loaded = yes
		# m.runTask \C/apps/Map/app.yml
		m.redraw!

	# view: ->
	# 	m \.App,
	# 		m \.App__tasks,
	# 			m.tasks.map (task) ~>
	# 				m m.Task,
	# 					task: task
	# 			Date.now!
	# 		m \.Taskbar,
	# 			style: m.style do
	# 				height: m.taskbarHeight
	# 			m.tasks.map (task) ~>
	# 				if task.win
	# 					m m.Button,
	# 						width: 180
	# 						icon: task.win.icon
	# 						task.win.title

	view: ->
		m \.App,
			m \.h-100.p-4.scroll,
				m \p Date.now!
				m m.Button,
					"Default"
				@colors.map (color) ~>
					m m.Button,
						color: color
						color
				m m.Button,
					basic: yes
					"Default"
				@colors.map (color) ~>
					m m.Button,
						basic: yes
						color: color
						color
				m m.Checkbox
				m m.Checkbox,
					checked: @boolVal
					label: "Nhà"
				m m.Radio
				m m.Radio,
					checked: @boolVal
					label: "Tôi"
					oninput: (event) !~>
						@boolVal = event.target.checked
				m m.Switch
				m m.Switch,
					checked: @boolVal
					oninput: (event) !~>
						@boolVal = event.target.checked
				m m.Icon,
					name: \fad:sim-card
				m m.DateTime,
					timePrecision: \millisecond
					value: @dateTimeVal
					onvalue: (@dateTimeVal) !~>
				m \span @dateTimeVal + ""
				m m.Button,
					onclick: !~>
						@dateTimeVal = new Date!toJSON!
					"Đặt ngày h.tại"
				m m.Tabs,
					tabId: @tabId
					ontabidchange: (tabId) !~>
						@tabId = tabId
					tabs:
						* id: \home
							title: "Trang chủ"
							panel: ~>
								m \.p-3,
									m \p "Gió vẫn hát thành lời, mặc kệ mây mây bay về trời..."
									m m.Button,
										onclick: !~>
											@tabId = \about
										"About"
						* id: \setting
							title: "Cài đặt"
							panel: ~>
								m m.Table,
									striped: @boolVal
									width: \100%
									@tableItems.map (item) ~>
										m \tr,
											m \td,
												m \img,
													src: item.icon
											m \td item.name
											m \td item.type
						* id: \about
							title: "Giới thiệu"
							panel: ~>
								m \.p-3,
									m \h3 "Một góc nhìn về thời gian"
									m \p "Chúng ta đang sống trong thế kỷ 21 với sự tiến bộ vượt bậc của tri thức cũng như khoa học kỹ thuật. Có khi nào các bạn tự hỏi rằng trái đất chúng ta đang sống được hình thành như thế nào không? Các loài sinh vật đầu tiên trên trái đất gồm có loài nào? Có khác gì so với với sinh vật ngày nay không?"
									m \p "Thông qua quá trình tiến hóa, các sinh vật nhận được và truyền lại các đặc tính từ thế hệ này sang thế hệ khác, trải qua 1 thời gian dài để biến đổi, thích ứng với điều kiện sống hiện tại để có thể sinh tồn."
				m m.TextInput,
					icon: \compact-disc
					value: @val
					oninput: (event) !~>
						@val = event.target.value
				m m.TextInput,
					icon: \copy
					value: @val
					onchange: (event) !~>
						@val = event.target.value
				m m.TextInput,
					disabled: yes
					icon: \motorcycle
					value: @val
				m \p @val
				m m.PasswordInput,
					defaultValue: "12345678aA@"
				m m.Table,
					bordered: yes
					striped: yes
					interactive: yes
					width: \100%
					height: 200
					header:
						m \tr,
							m \th "Icon"
							m \th "Tên"
							m \th "Hệ"
					@tableItems.map (item) ~>
						m \tr,
							m \td,
								m \img,
									src: item.icon
							m \td item.name
							m \td item.type
				m \code "<html>"
				m \kbd "Ctrl+B"
				m \blockquote "Chẳng thà mình không nói để người ta tưởng mình ngu, còn hơn mở miệng ra để người ta không còn nghi ngờ gì nữa."
				m \h1 "Hoa sứ nhà nàng"
				m \h2 "Hoa sứ nhà nàng"
				m \h3 "Hoa sứ nhà nàng"
				m \h4 "Hoa sứ nhà nàng"
				m \h5 "Hoa sứ nhà nàng"
				m \h6 "Hoa sứ nhà nàng"
				m \ul,
					m \li "Cà phê"
					m \li "Trà",
						m \ul,
							m \li "Trà sữa"
							m \li "Trà bí đao"
					m \li "Sữa chua"
				m m.Select,
					items: @selectItems
				m m.Select,
					items: @selectItems
					value: @selectVal
				m m.Select,
					items: @selectItems
					onvalue: (@selectVal) !~>
				m m.Select,
					items: @selectItems
					value: @selectVal
					onvalue: (@selectVal) !~>
				m m.TextInput,
					value: @selectVal
					oninput: (event) !~>
						@selectVal = event.target.value
				m \span @selectVal + ""
				m m.Popover,
					isOpen: @isOpen1
					oninteraction: (isOpen) !~>
						@isOpen1 = isOpen
					content: (close1) ~>
						m \div,
							style: padding: \12px
							m \div "isOpen1: #@isOpen1"
							m \small Date.now!
							m m.Popover,
								isOpen: @isOpen2
								oninteraction: (isOpen) !~>
									@isOpen2 = isOpen
								content: (close2) ~>
									m \div,
										style: padding: \12px
										m \div "isOpen2: #@isOpen2"
										m \small Date.now!
										m m.Button,
											onclick: close1
											"Đóng popover 1"
										m m.Button,
											onclick: close2
											"Đóng popover 2"
								m m.Button,
									basic: yes
									color: \yellow
									"Popover thứ 2"
					m m.Tooltip,
						position: \top
						content: "hihi"
						m m.Button,
							"Popover"
				m \p "isOpen1: #@isOpen1 / isOpen2: #@isOpen2"
				m m.Menu,
					basic: yes
					items: @menuItems

m.mount appEl, m.App
