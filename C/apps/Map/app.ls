App = m.comp do
	view: ->
		m \.full,
			m \iframe.__map,
				src: "https://www.openstreetmap.org/export/embed.html?bbox=105.55,21.08,106.1,21.08&layer=mapnik"
