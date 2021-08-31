Table = m.comp do
	view: ->
		m \.Table,
			class: m.class do
				"Table--borderedRow": @attrs.bordered in [yes \row]
				"Table--borderedColumn": @attrs.bordered in [yes \column]
				"Table--striped": @attrs.striped
				"Table--fixed": @attrs.fixed
				"Table--interactiveRow": @attrs.interactive in [yes \row]
				"Table--interactiveCol": @attrs.interactive is \col
				"Table--hasHeader": @attrs.header
				@attrs.class
			style: m.style do
				width: @attrs.width
				height: @attrs.height
				@attrs.style
			m \.Table__content,
				os.call @attrs.header
				@attrs.children
