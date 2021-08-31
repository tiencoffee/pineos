Radio = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \checked of @attrs
		@checked = Boolean if @controlled => @attrs.checked else @attrs.defaultChecked

	onbeforeupdate: (old, first) !->
		if !!@attrs.checked isnt !!old.checked
			@checked = !!@attrs.checked

	oninputHidden: (event) !->
		unless @controlled
			@checked = event.target.checked
		@attrs.oninput? event

	view: ->
		m \label.Radio,
			class: m.class do
				"disabled": @attrs.disabled
				"Radio--checked": @checked
			m \label.Radio__content,
				m \.Radio__input,
					if @checked
						m \.Radio__check
				if @attrs.label
					m \.Radio__label,
						@attrs.label
				m \input.Radio__hidden,
					type: \radio
					disabled: @attrs.disabled
					checked: @attrs.checked
					oninput: @oninputHidden
