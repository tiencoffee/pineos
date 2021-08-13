m.Button = m.comp do
	onbeforeupdate: !->
		@attrs.type = \button
		@attrs.rounded ?= yes

	view: ->
		m \button.Button,
			class: m.class do
				"active": @attrs.active
				"disabled": @attrs.disabled
				"Button--basic": @attrs.basic
				"Button--small": @attrs.small
				"Button--rounded": @attrs.rounded
				"Button--onlyIcon": (@attrs.icon xor @attrs.rightIcon) and not @attrs.children.length
				"Button--#{@attrs.color}": @attrs.color
				@attrs.class
			style: m.style do
				width: @attrs.width
				textAlign: @attrs.align
				@attrs.style
			type: @attrs.type
			disabled: @attrs.disabled
			onclick: @attrs.onclick
			onmousedown: @attrs.onmousedown
			onmouseenter: @attrs.onmouseenter
			onmouseleave: @attrs.onmouseleave
			if @attrs.icon
				m m.Icon,
					class: "Button__icon Button__leftIcon"
					name: @attrs.icon
			if @attrs.children.length
				m \.Button__text,
					@attrs.children
			if @attrs.rightIcon
				m m.Icon,
					class: "Button__icon Button__rightIcon"
					name: @attrs.rightIcon
