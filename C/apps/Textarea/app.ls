m.App = m.comp do
	view: ->
		m \.p-3,
			m m.Tooltip,
				content: "Không có gì :)"
				m \span,
					"Sao dị?"
			m m.TextInput
