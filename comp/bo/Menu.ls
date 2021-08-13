m.Menu = m.comp do
	oninit: !->
		@item = void
		@popper = void
		@timo = void
		@isRoot = not @attrs.root
		@root = @attrs.root or @

	onbeforeupdate: !->
		@items = @getItems @attrs.items

	getItems: (items) ->
		items = [...m.castArray items]
		for item in items
			if item?items
				item.items = @getItems item.items
		items

	updateItems: !->
		@items = [...m.castArray @attrs.items]
		handle = (items) !~>
		for item in @items
			if item?
				item.items and= m.castArray item.items

	onmouseenterItem: (item, event) !->
		unless item is @item
			@close!
			@item = item
			if item.items
				@timo = setTimeout !~>
					comp =
						view: ~>
							m m.Menu,
								class: \Menu__submenu
								root: @root
								items: item.items
					el = @dom.lastChild
					m.mount el, comp
					@popper = m.createPopper event.target, el,
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
			tabIndex: 0
			@items.map (item) ~>
				if item
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
						m m.Icon,
							class: \Menu__itemIcon
							name: item.icon
						m \.Menu__itemText,
							item.text
						if item.items
							m \.Menu__itemLabel,
								m m.Icon,
									name: \chevron-right
						else if item.label
							m \.Menu__itemLabel,
								item.label
				else
					m \.Menu__divider
			m \.Menu__popper
