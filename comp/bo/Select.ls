m.Select = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@value = if @controlled => @attrs.value else @attrs.defaultValue
		@item = void
		@popper = void
		@popperEl = void
		@indeterminate = no
		@updateItems!

	oncreate: !->
		@attrs.ref? @

	onbeforeupdate: (old, first) !->
		if @attrs.value isnt old.value
			@value = @attrs.value
			@updateItems!

	updateItems: !->
		@hasIcons = no
		@items = m.castArray @attrs.items
			.map (item) ~>
				if item?
					if item.icon
						@hasIcons = yes
					if item instanceof Object
						icon: item.icon
						text: (item.text ? item.value) + ""
						value: item.value
					else
						text: item + ""
						value: item
			.filter (item) ~>
				not item? or item.value?
		item = @items.find ~>
			it and it.value? and it.value is @value
		if item
			@item = item
			@indeterminate = no
		else
			@item or= @items.0
			@indeterminate = yes

	togglePopper: (isOpen) !->
		if isOpen
			unless @popper
				@updateItems!
				@hoverItem = @item
				@popperEl = document.createElement \div
				@popperEl.className = m.class do
					@attrs.portalClass
					"Select__popper"
				comp =
					view: ~>
						m \.Select__items,
							@items.map (item, index) ~>
								if item
									m \.Select__item,
										class: m.class do
											"hover": @hoverItem and @hoverItem.value is item.value
										onmouseenter: (event) !~>
											@hoverItem = item
										onclick: (event) !~>
											@onclickItem item, index, event
										if @hasIcons
											m m.Icon,
												class: \Select__itemIcon
												name: item.icon
										m \.Select__itemText,
											item.text
								else
									m \.Select__divider
				m.mount @popperEl, comp
				@popper = m.createPopper @dom, @popperEl,
					placement: \bottom
					allowedFlips: [\bottom \top]
				@popperEl.style <<< m.style do
					width: @dom.offsetWidth
					height: Math.floor innerHeight / 2 - @dom.offsetHeight * 2
				portalsEl.appendChild @popperEl
				document.addEventListener \mousedown @onmousedownGlobal
				if @item
					if itemEl = @popperEl.querySelector \.hover
						itemEl.scrollIntoView do
							block: \center
				m.redraw!
		else
			if @popper
				@hoverItem = void
				@popper.destroy!
				@popper = void
				m.mount @popperEl
				@popperEl.remove!
				@popperEl = void
				document.removeEventListener \mousedown @onmousedownGlobal
				m.redraw!

	onclick: (event) !->
		@togglePopper not @popper

	onclickItem: (item, index, event) !->
		value = @value
		unless @controlled
			@value = item.value
			@updateItems!
		if @indeterminate or value isnt item.value
			@attrs.onvalue? item.value
			@attrs.onitemselect? item, index
		@togglePopper no

	onmousedownGlobal: (event) !->
		unless @dom.contains event.target or @popperEl.contains event.target
			@togglePopper no

	onremove: !->
		@togglePopper no

	view: ->
		m \.Select,
			class: m.class do
				"active": @popper
				"disabled": @attrs.disabled
				"Select--basic": @attrs.basic
				@attrs.class
			style: m.style do
				width: @attrs.width
			onclick: @onclick
			if @item
				if @hasIcons
					m m.Icon,
						class: \Select__icon
						name: @item.icon
			m \.Select__text,
				@item?text
			m m.Icon,
				class: \Select__arrow
				name: \sort
