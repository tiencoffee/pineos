InputGroup = m.comp do
	view: ->
		m \form.InputGroup,
			class: m.class do
				@attrs.class
			style: m.style do
				width: @attrs.width
				@attrs.style
			onsubmit: (event) !~>
				event.preventDefault!
				@attrs.onsubmit? event
			@attrs.children
