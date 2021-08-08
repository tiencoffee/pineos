m.Icon = m.comp do
	view: ->
		name = (@attrs.name ? "") + ""
		[kind, val] = match name
			| /\/\// => [\img name]
			| /^\d+$/ => [\img "https://flaticon.com/svg/static/icons/svg/#{name.slice 0 -3}/#name.svg"]
			| /^fa[srldb]?:/ => name.split \:
			| /./ => [\fas name]
			else [\blank]
		switch kind
		| \img
			m \img.Icon.Icon--img,
				class: m.class do
					@attrs.class
				src: val
				height: @size
				onload: m.redraw
		| \blank
			m \.Icon.Icon--blank,
				class: m.class do
					@attrs.class
				style: m.style do
					width: @size
					height: @size
		else
			m \i.Icon.Icon--fa,
				class: m.class do
					"#kind fa-#val"
					@attrs.class
				style: m.style do
					fontSize: @size
