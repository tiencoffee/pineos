m.Table = m.comp do
	view: ->
		m \.Table,
			class: m.class do
				"Table--bordered": @attrs.bordered
				"Table--striped": @attrs.striped
				"Table--interactive": @attrs.interactive
				"Table--hasHeader": @attrs.header
			style: m.style do
				width: @attrs.width
				height: @attrs.height
				@attrs.style
			m \.Table__content,
				m.safeCall @attrs.header
				@attrs.children
