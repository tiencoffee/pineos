Task = m.comp do
	oninit: !->
		{task} = @attrs
		{env, app} = task
		task.win = @
		@moving = void
		@resizing = void
		@canRestore = no
		@minimizeAnim = void
		@minimized = no
		@maximized = no
		@desktop = env.desktop ? app.desktop ? no
		@icon = env.icon or app.icon or \fad:window
		@title = env.title or app.name or app.path
		@width = os.clamp env.width || app.width || 700 200 os.desktopWidth
		@height = os.clamp env.height || app.height || 500 100 os.desktopHeight
		@x = os.clamp (env.x ? app.x ? Math.floor (os.desktopWidth - @width) / 2), 0 os.desktopWidth - @width
		@y = os.clamp (env.y ? app.y ? Math.floor (os.desktopHeight - @height) / 2), 0 os.desktopHeight - @height
		@z = os.uid! + 2
		@minimizable = env.minimizable ? app.minimizable ? yes
		@maximizable = env.maximizable ? app.maximizable ? yes
		@resizable = env.resizable ? app.resizable ? yes
		@movable = env.movable ? app.movable ? yes
		if val = env.minimized ? app.minimized ? no
			@minimize val
		if val = env.maximized ? app.maximized ? no
			@maximize val
		if @focusable = env.focusable ? app.focusable ? yes
			@focus!
		@acceptFirstMouse = env.acceptFirstMouse ? app.acceptFirstMouse ? yes
		@skipHeader = env.skipHeader ? app.skipHeader ? no
		@skipTaskbar = env.skipTaskbar ? app.skipTaskbar ? no
		if @desktop
			@width = os.desktopWidth
			@height = os.desktopHeight
			@x = 0
			@y = 0
			@z = 1
			@minimizable = no
			@maximizable = no
			@resizable = no
			@movable = no
			@focusable = no
			@skipHeader = yes
			@skipTaskbar = yes
		@sandbox = """
			allow-downloads
			allow-forms
			allow-pointer-lock
			allow-popups
			allow-presentation
			allow-scripts
		"""
		if env.admin
			@sandbox += " allow-same-origin"
		@buttonItems =
			* text: "Thu nhỏ"
				icon: \minus
				onclick: @onclickMinimize
			* text: "Phóng to"
				icon: \plus
				onclick: @onclickMaximize
			* text: "Đóng"
				icon: \xmark
				color: \red
				onclick: @onclickClose

	oncreate: !->
		{task} = @attrs
		{env} = task
		iframeEl = @dom.querySelector \iframe
		@iframeEl = iframeEl
		@iframeEl.srcdoc = task.html
		@dialogEl = @dom.querySelector \.Task__dialog
		delete task.html

	minimize: (val, force) !->
		val = if val? => !!val else not @minimized
		if force or @minimizable
			if val isnt @minimized
				@minimized = val
				if val
					@blur!
					if button = @attrs.task.button
						rect = button.dom.getBoundingClientRect!
						@minimizeAnim = @dialogEl.animate do
							* left: rect.x + \px
								top: rect.y + \px
								width: rect.width + \px
								height: rect.height + \px
								visibility: \hidden
							* duration: 400
								easing: "cubic-bezier(.25,1,.5,1)"
								fill: \forwards
					else
						@minimizeAnim = @dialogEl.animate do
							* visibility: \hidden
							* duration: 0
								fill: \forwards
				else
					@focus!
					@minimizeAnim.reverse!
					@minimizeAnim = void
					keyframes =
						if @maximized
							left: 0
							top: 0
							width: \100%
							height: \100%
						else
							left: @x + \px
							top: @y + \px
							width: @width + \px
							height: @height + \px
					@dialogEl.animate do
						* keyframes
						* duration: 400
							easing: "cubic-bezier(.25,1,.5,1)"
				m.redraw!

	maximize: (val, force) !->
		val = if val? => !!val else not @maximized
		if force or @maximizable
			if val isnt @maximized
				@maximized = val
				if val
					@canRestore = yes
				m.redraw!

	close: (val) !->
		{task} = @attrs
		if task.resolve
			index = os.tasks.indexOf task
			os.tasks.splice index, 1
			task.resolve val
			delete task.resolve
			@blur!
		@dom.classList.add \Task--closing
		m.redraw!

	focus: !->
		{task} = @attrs
		if @focusable and os.task isnt task
			if @minimized
				@minimize no
			else
				os.task = task
				@z = os.uid!
			m.redraw!

	blur: ->
		focused = os.task is @attrs.task
		os.task = void
		focusTask = void
		maxZ = 0
		for task2 in os.tasks
			if task2.env.focusable and task2.win and not task2.win.minimized and task2.win.z > maxZ
				maxZ = task2.win.z
				focusTask = task2
		if focusTask
			focusTask.win?focus!
		if focused
			@dom.style.zIndex = os.uid!
		m.redraw!

	onmousedown: (event) !->
		@focus!

	onclickTitle: (event) !->
		if event.detail % 2 is 0
			@maximize!

	onpointerdownTitle: (event) !->
		if @movable
			if event.button is 0
				event.target.setPointerCapture event.pointerId
				@moving = x: 0 y: 0

	onpointermoveTitle: (event) !->
		event.redraw = no
		if @moving
			if @maximized
				@x = Math.floor os.clamp event.x - @width / 2, 0, os.desktopWidth - @width
				@y = 0
				@maximize no
			@moving.x += event.movementX
			@moving.y += event.movementY
			@dialogEl.style.translate = "#{@moving.x}px #{@moving.y}px"

	onlostpointercaptureTitle: (event) !->
		if @moving
			@dialogEl.style.translate = ""
			if event.x <= 0
				@x = 0
				@y = 0
				@width = Math.floor os.desktopWidth / 2
				@height = os.desktopHeight
			else if event.x >= os.desktopWidth - 1
				width = Math.floor os.desktopWidth / 2
				@x = os.desktopWidth - width
				@y = 0
				@width = width
				@height = os.desktopHeight
			else
				@x = os.clamp @x + @moving.x, 0, os.desktopWidth - @width
				@y = os.clamp @y + @moving.y, 0, os.desktopHeight - @height
				if event.y <= 0
					@maximize yes
			@moving = void

	oncontextmenuTitle: (event) !->
		os.openContextMenu event, @buttonItems

	onpointerdownResizes: (event) !->
		if event.button is 0
			event.target.setPointerCapture event.pointerId
			{x, y} = event.target.dataset
			@resizing =
				dirX: +x
				dirY: +y
				moveX: 0
				moveY: 0
				x: @x
				y: @y
				width: @width
				height: @height

	onpointermoveResizes: (event) !->
		event.redraw = no
		if @resizing
			@resizing.moveX += event.movementX
			@resizing.moveY += event.movementY
			if @resizing.dirX is 1
				left = os.desktopWidth - @x
				@width = os.clamp @resizing.width + @resizing.moveX, 200 left
			else if @resizing.dirX is -1
				right = @x + @width
				@x = os.clamp @resizing.x + @resizing.moveX, 0 right - 200
				@width = os.clamp @resizing.width - @resizing.moveX, 200 right
			if @resizing.dirY is 1
				top = os.desktopHeight - @y
				@height = os.clamp @resizing.height + @resizing.moveY, 100 top
			else if @resizing.dirY is -1
				bottom = @y + @height
				@y = os.clamp @resizing.y + @resizing.moveY, 0 bottom - 100
				@height = os.clamp @resizing.height - @resizing.moveY, 100 bottom
			m.redraw.sync!

	onlostpointercaptureResizes: (event) !->
		if @resizing
			@resizing = void

	onclickMinimize: (event) !->
		@minimize!

	onclickMaximize: (event) !->
		@maximize!

	onclickClose: (event) !->
		@close!

	onbeforeremove: ->
		new Promise (resolve) !~>
			@dialogEl.animate do
				* scale: 0.9
					opacity: 0
				* duration: 400
					easing: "cubic-bezier(.25,1,.5,1)"
			.onfinish = resolve

	view: ->
		m \.Task,
			class: m.class do
				"Task--minimized": @minimized
				"Task--maximized": @maximized
				"Task--restored": not @maximized and @canRestore
				"Task--focused": os.task is @attrs.task
				"Task--desktop": @desktop
				"Task--moving": @moving
				"Task--resizing": @resizing
			style: m.style do
				zIndex: @z
			onmousedown: @onmousedown
			m \.Task__dialog,
				style: m.style do
					left: @x
					top: @y
					width: @width
					height: @height
				unless @skipHeader
					m \.Task__header,
						m Popover,
							position: \bottom-start
							content: (close) ~>
								m Menu,
									basic: yes
									items: @buttonItems
									onitemclick: close
							m Button,
								class: \Task__icon
								basic: yes
								small: yes
								icon: @icon
						m \.Task__title,
							onclick: @onclickTitle
							onpointerdown: @onpointerdownTitle
							onpointermove: @onpointermoveTitle
							onlostpointercapture: @onlostpointercaptureTitle
							oncontextmenu: @oncontextmenuTitle
							m \.Task__titleText,
								@title
						m \.Task__buttons,
							m Button,
								class: \Task__button
								basic: yes
								small: yes
								icon: \minus
								onclick: @onclickMinimize
							m Button,
								class: \Task__button
								basic: yes
								small: yes
								icon: \plus
								onclick: @onclickMaximize
							m Button,
								class: \Task__button
								basic: yes
								small: yes
								color: \red
								icon: \xmark
								onclick: @onclickClose
				m \.Task__body,
					m \iframe.Task__iframe,
						sandbox: @sandbox
					if not @acceptFirstMouse and os.task isnt @attrs.task
						m \.Task__notAcceptFirstMouse
				if @resizable and not @maximized
					m \.Task__resizes,
						onpointerdown: @onpointerdownResizes
						onpointermove: @onpointermoveResizes
						onlostpointercapture: @onlostpointercaptureResizes
						m \.Task__resize,
							"data-x": -1
						m \.Task__resize,
							"data-x": 1
						m \.Task__resize,
							"data-y": -1
						m \.Task__resize,
							"data-y": 1
						m \.Task__resize,
							"data-x": -1
							"data-y": -1
						m \.Task__resize,
							"data-x": 1
							"data-y": -1
						m \.Task__resize,
							"data-x": -1
							"data-y": 1
						m \.Task__resize,
							"data-x": 1
							"data-y": 1
