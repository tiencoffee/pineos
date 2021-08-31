TextInput = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@value = if @controlled => @attrs.value else @attrs.defaultValue
		@isOnchange = no
		@input = void

	oncreate: !->
		@attrs.ref? @

	onbeforeupdate: (old, first) !->
		if @isOnchange
			@isOnchange = no
			if @attrs.value isnt @value
				@value = @attrs.value
		if @attrs.value isnt old.value
			@value = @attrs.value

	oninputInput: (event) !->
		if not @controlled or @attrs.onchange
			@value = event.target.value
		@attrs.oninput? event

	onchangeInput: (event) !->
		if @controlled
			@isOnchange = yes
		else
			@value = event.target.value
		@attrs.onchange? event

	oncontextmenuInput: (event) !->
		os.openContextMenu event,
			* text: "Hoàn tác"
				icon: \undo
				label: "Ctrl+Z"
				onclick: !~>
					@input.dom.focus!
					document.execCommand \undo
			* text: "Làm lại"
				icon: \redo
				label: "Ctrl+Shift+Z"
				onclick: !~>
					@input.dom.focus!
					document.execCommand \redo
			,,
			* text: "Cắt"
				icon: \scissors
				label: "Ctrl+X"
				onclick: !~>
					@input.dom.focus!
					document.execCommand \cut
			* text: "Sao chép"
				icon: \copy
				label: "Ctrl+C"
				onclick: !~>
					@input.dom.focus!
					document.execCommand \copy
			* text: "Dán"
				icon: \clipboard
				label: "Ctrl+V"
				onclick: !~>
					@input.dom.focus!
					if topWin
						text = await os.readClipboard!
					else
						text = await send \readClipboard
					document.execCommand \insertText,, text
			,,
			* text: "Chọn tất cả"
				icon: \square-dashed
				label: "Ctrl+A"
				onclick: !~>
					@input.dom.focus!
					@input.dom.select!
		@attrs.oncontextmenu? event

	view: ->
		m \.TextInput,
			class: m.class do
				"disabled": @attrs.disabled
				"TextInput--basic": @attrs.basic
				@attrs.class
			style: m.style do
				width: @attrs.width
				@attrs.style
			if @attrs.element or @attrs.icon
				if @attrs.element
					m \.TextInput__element.TextInput__leftElement,
						os.call @attrs.element
				else
					m Icon,
						class: "TextInput__icon TextInput__leftIcon"
						name: @attrs.icon
			m \input.TextInput__input,
				style: m.style do
					textAlign: @attrs.align
				type: @attrs.type
				disabled: @attrs.disabled
				min: @attrs.min
				max: @attrs.max
				step: @attrs.step
				minLength: @attrs.minLength
				maxLength: @attrs.maxLength
				pattern: @attrs.pattern
				required: @attrs.required
				readOnly: @attrs.readOnly
				value: @value
				title: ""
				oninput: @oninputInput
				onchange: @onchangeInput
				onfocus: @attrs.onfocus
				onblur: @attrs.onblur
				oncontextmenu: @oncontextmenuInput
				oncreate: (@input) !~>
			if @attrs.rightElement or @attrs.rightIcon
				if @attrs.rightElement
					m \.TextInput__element.TextInput__rightElement,
						os.call @attrs.rightElement
				else
					m Icon,
						class: "TextInput__icon TextInput__rightIcon"
						name: @attrs.rightIcon
