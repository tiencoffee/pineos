m.Task = m.comp do
	oninit: !->
		{task} = @attrs
		{app} = task
		@title = app.title or app.name or app.path
		@icon = app.icon or \fad:window
		@sandbox =
			\allow-downloads
			\allow-pointer-lock
			\allow-popups
			\allow-presentation
			\allow-scripts
		if task.system
			@sandbox.push \allow-same-origin
		@sandbox *= " "
		@width = app.width or 700
		@height = app.height or 500
		@x = app.x ? Math.floor (m.desktopWidth - @width) / 2
		@y = app.y ? Math.floor (m.desktopHeight - @height) / 2
		@tranX = 0
		@tranY = 0
		@moving = no

	oncreate: !->
		{task} = @attrs
		iframeEl = @dom.querySelector \iframe
		@iframeEl = iframeEl
		@iframeEl.srcdoc = task.tmpl
		@dialogEl = @dom.querySelector \.__dialog
		delete task.tmpl
		task.win = @
		m.redraw!

	close: (val) !->
		{task} = @attrs
		index = m.tasks.indexOf task
		m.tasks.splice index, 1
		task.resolve val
		m.redraw!

	onpointerdownTitle: (event) !->
		event.target.setPointerCapture event.pointerId
		@moving = yes

	onpointermoveTitle: (event) !->
		event.redraw = no
		if @moving
			@tranX += event.movementX
			@tranY += event.movementY
			@dialogEl.style.translate = "#{@tranX}px #{@tranY}px"

	onpointerupTitle: (event) !->
		if @moving
			@x += @tranX
			@y += @tranY
			@tranX = 0
			@tranY = 0
			@moving = no
			@dialogEl.style.translate = ""

	onclickClose: (event) !->
		@close!

	view: ->
		m \.Task,
			m \.Task__dialog.__dialog,
				style: m.style do
					left: @x
					top: @y
					width: @width
					height: @height
				m \.Task__header,
					m m.Button,
						class: \Task__icon
						basic: yes
						small: yes
						icon: @icon
					m \.Task__title,
						onpointerdown: @onpointerdownTitle
						onpointermove: @onpointermoveTitle
						onpointerup: @onpointerupTitle
						@title
					m \.Task__buttons,
						m m.Button,
							class: \Task__button
							basic: yes
							small: yes
							icon: \far:minus
						m m.Button,
							class: \Task__button
							basic: yes
							small: yes
							icon: \far:plus
						m m.Button,
							class: \Task__button
							basic: yes
							small: yes
							color: \red
							icon: \far:times
							onclick: @onclickClose
				m \.Task__body,
					m \iframe.Task__iframe,
						sandbox: @sandbox
