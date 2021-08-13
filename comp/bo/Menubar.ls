m.Menubar = m.comp do
	onbeforeupdate: !->
		@items = @getItems @attrs.items

	getItems: (items) ->
		items = [...m.castArray items]
		for item in items
			if item?items
				item.items = @getItems item.items
		items

	view: ->
		m \.Menubar,
			@items.map (item) ~>
				m m.Popover,
					position: \bottom-start
					content: (close) ~>
						m m.Menu,
							basic: yes
							items: item.items
							onitemclick: close
					m m.Button,
						class: \Menubar__button
						basic: yes
						item.text
