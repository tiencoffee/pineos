m.Switch = m.comp do
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
		m \.Switch,
			class: m.class do
				"disabled": @attrs.disabled
				"Switch--checked": @checked
			m \label.Switch__content,
				m \.Switch__input,
					m \.Switch__thumb
				m \input.Switch__hidden,
					type: \checkbox
					disabled: @attrs.disabled
					checked: @checked
					oninput: @oninputHidden
