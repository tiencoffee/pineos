await ts.loadjs do
	\npm:filesize@8.0.0

App = m.comp do
	oninit: !->
		@path = \/
		@tmpPath = @path
		@hist = os.newHistory!
		@entry = void
		@entries = []

	oncreate: !->
		@goPath @path

	goPath: (path, noPushHistory) !->
		try
			path = os.resolvePath path
			@entry = await os.getEntry path
			@entries = await os.readDir @entry
			@entries.sort (a, b) ~>
				b.isDir - a.isDir or a.name.localeCompare b.name
			@path = path
			@tmpPath = path
			unless noPushHistory
				@hist.push @path
		m.redraw!

	onsubmitPath: (event) !->
		@goPath @tmpPath

	onclickBack: (event) !->
		if @hist.canUndo
			@goPath @hist.undo!, yes

	onclickForward: (event) !->
		if @hist.canRedo
			@goPath @hist.redo!, yes

	onclickParent: (event) !->
		unless @path is \/
			@goPath os.dirPath @path

	onclickRefresh: (event) !->
		@goPath @path, yes

	ondblclickEntry: (entry, event) !->
		if entry.isDir
			@goPath entry.path

	oncontextmenuEntry: (entry, event) !->
		os.openContextMenu event,
			* text: \Mở
				shown: entry.isDir
				onclick: !~>
					if entry.isDir
						@goPath entry.path

	view: ->
		m \.full.column.gap-y-3.p-3,
			m \.col-0.row.gap-x-3,
				m InputGroup,
					m Button,
						disabled: not @hist.canUndo
						icon: \arrow-left
						onclick: @onclickBack
					m Button,
						disabled: not @hist.canRedo
						icon: \arrow-right
						onclick: @onclickForward
					m Button,
						disabled: @path is \/
						icon: \arrow-up
						onclick: @onclickParent
				m InputGroup,
					class: \col
					onsubmit: @onsubmitPath
					m TextInput,
						value: @tmpPath
						oninput: (event) !~>
							@tmpPath = event.target.value
					m Button,
						icon: \arrow-rotate-right
						click: @onclickRefresh
					m Button,
						type: \submit
						icon: \arrow-turn-down-left
			m \.col,
				m Table,
					width: \100%
					bordered: \row
					interactive: yes
					header:
						m \tr,
							m \td.w-50 "Tên"
							m \td "Kích thước"
							m \td "Ngày sửa đổi"
					@entries.map (entry) ~>
						m \tr,
							key: entry.path
							ondblclick: (event) !~>
								@ondblclickEntry entry, event
							oncontextmenu: (event) !~>
								@oncontextmenuEntry entry, event
							m \td,
								m Icon,
									class: "mr-3"
									name: entry.icon
								entry.name
							m \td,
								entry.isDir and \- or filesize entry.size
							m \td,
								dayjs entry.mtime .format "DD/MM/YYYY HH:mm"
