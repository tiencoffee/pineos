m.InputGroup = m.comp do
	view: ->
		m \.InputGroup,
			class: m.class do
				@attrs.class
			style: m.style do
				width: @attrs.width
				@attrs.style
			@attrs.children
