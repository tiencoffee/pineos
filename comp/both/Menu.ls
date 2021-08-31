Menu = m.comp do
	oninit: !->
		@item = void
		@popper = void
		@timo = void
		@isRoot = not @attrs.root
		@root = @attrs.root or @

	onbeforeupdate: !->
		@items = @getItems @attrs.items

	getItems: (items) ->
		res = []
		items = os.castArray items
		for item in items
			if item?
				if \shown not of item or os.call item.shown
					if item.header?
						data =
							header: os.call item.header
					else
						data =
							icon: os.call item.icon
							text: os.call item.text
							label: os.call item.label
							color: os.call item.color
							disabled: os.call item.disabled
							onclick: item.onclick
						if item.items
							data.items = @getItems item.items
					res.push data
			else
				res.push void
		res

	onmouseenterItem: (item, event) !->
		unless item is @item
			@close!
			@item = item
			if item.items
				@timo = setTimeout !~>
					comp =
						view: ~>
							m Menu,
								class: \Menu__submenu
								root: @root
								items: item.items
					el = @dom.lastChild
					m.mount el, comp
					@popper = os.createPopper event.target, el,
						placement: \right-start
						offsets: [-5 -4]
						flips: [\left-start]
						allowedFlips: [\right-start \left-start]
					if @isRoot
						document.addEventListener \mousedown @onmousedownGlobal
					@timo = 0
					m.redraw!
				, 250

	onmouseleaveItem: (item, event) !->
		if @timo or (@item and not @item.items)
			@close!

	onclickItem: (item, event) !->
		unless item.items
			item.onclick? event
			@root.attrs.onitemclick? item
			@root.close item

	onmousedownGlobal: (event) !->
		unless @dom.contains event.target
			@close!
			m.redraw!

	close: (item) !->
		@item = void
		if @timo
			@timo = clearTimeout @timo
		if @popper
			@popper.destroy!
			@popper = void
			m.mount @dom.lastChild
		if @isRoot
			document.removeEventListener \mousedown @onmousedownGlobal

	onremove: !->
		@close!

	view: ->
		m \.Menu,
			class: m.class do
				"Menu--basic": @attrs.basic
				@attrs.class
			style: m.style do
				width: @attrs.width
				@attrs.style
			tabIndex: 0
			@items.map (item) ~>
				if not item
					m \.Menu__divider
				else if item.header?
					m \.Menu__header,
						item.header
				else
					m \.Menu__item,
						class: m.class do
							"disabled": item.disabled
							"Menu__item--#{item.color}": item.color
							"Menu__item--submenuShown": item is @item
							"Menu__item--hasItems": item.items
						onmouseenter: (event) !~>
							@onmouseenterItem item, event
						onmouseleave: (event) !~>
							@onmouseleaveItem item, event
						onclick: (event) !~>
							@onclickItem item, event
						m Icon,
							class: \Menu__itemIcon
							name: item.icon
						m \.Menu__itemText,
							item.text
						if item.items
							m \.Menu__itemLabel,
								m Icon,
									name: \chevron-right
						else if item.label
							m \.Menu__itemLabel,
								item.label
			m \.Menu__popper
