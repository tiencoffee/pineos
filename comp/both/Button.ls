Button = m.comp do
	onbeforeupdate: !->
		@attrs.type ?= \button

	view: ->
		m \button.Button,
			class: m.class do
				"active": @attrs.active
				"disabled": @attrs.disabled
				"Button--basic": @attrs.basic
				"Button--small": @attrs.small
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
			onmouseup: @attrs.onmouseup
			onmouseenter: @attrs.onmouseenter
			onmouseleave: @attrs.onmouseleave
			onpointerdown: @attrs.onpointerdown
			onpointerup: @attrs.onpointerup
			onlostpointercapture: @attrs.onlostpointercapture
			oncontextmenu: @attrs.oncontextmenu
			if @attrs.icon
				m Icon,
					class: "Button__icon Button__leftIcon"
					name: @attrs.icon
			if @attrs.children.length
				m \.Button__text,
					@attrs.children
			if @attrs.rightIcon
				m Icon,
					class: "Button__icon Button__rightIcon"
					name: @attrs.rightIcon
