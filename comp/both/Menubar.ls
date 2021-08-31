Menubar = m.comp do
	onbeforeupdate: !->
		@items = @getItems @attrs.items

	getItems: (items) ->
		items = [...os.castArray items]
		for item in items
			if item?items
				item.items = @getItems item.items
		items

	view: ->
		m \nav.Menubar,
			@items.map (item) ~>
				m Popover,
					position: \bottom-start
					content: (close) ~>
						m Menu,
							basic: yes
							items: item.items
							onitemclick: close
					m Button,
						class: \Menubar__button
						basic: yes
						item.text
