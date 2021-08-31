Checkbox = m.comp do
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
		m \.Checkbox,
			class: m.class do
				"disabled": @attrs.disabled
				"Checkbox--checked": @checked
			m \label.Checkbox__content,
				m \.Checkbox__input,
					if @checked
						m \i.fas.fa-check.Checkbox__check
				if @attrs.label
					m \.Checkbox__label,
						@attrs.label
				m \input.Checkbox__hidden,
					type: \checkbox
					disabled: @attrs.disabled
					checked: @checked
					oninput: @oninputHidden
