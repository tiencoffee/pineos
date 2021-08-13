m.PasswordInput = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@isHidePassword = yes
		@input = void

	oncreate: !->
		@attrs.ref? @

	onclickToggleHidePassword: (event) !->
		@input.input.dom.focus!
		not= @isHidePassword

	oncontextmenu: (event) !->
		m.openContextMenu event,
			* text: @isHidePassword and "Hiện mật khẩu" or "Ẩn mật khẩu"
				icon: @isHidePassword and \eye or \eye-slash
				onclick: !~>
					@input.input.dom.focus!
					not= @isHidePassword
			,,
			* text: "Hoàn tác"
				icon: \undo
				label: "Ctrl+Z"
				onclick: !~>
					@input.input.dom.focus!
					document.execCommand \undo
			* text: "Làm lại"
				icon: \redo
				label: "Ctrl+Shift+Z"
				onclick: !~>
					@input.input.dom.focus!
					document.execCommand \redo
			,,
			* text: "Cắt"
				icon: \cut
				label: "Ctrl+X"
				disabled: @isHidePassword
				onclick: !~>
					@input.input.dom.focus!
					document.execCommand \cut
			* text: "Sao chép"
				icon: \copy
				label: "Ctrl+C"
				disabled: @isHidePassword
				onclick: !~>
					@input.input.dom.focus!
					document.execCommand \copy
			* text: "Dán"
				icon: \clipboard
				label: "Ctrl+V"
				onclick: !~>
					@input.input.dom.focus!
					if tid
						text = await send \readClipboard
					else
						text = await m.readClipboard!
					document.execCommand \insertText,, text
		@attrs.oncontextmenu? event

	view: ->
		m m.TextInput,
			class:
				"PasswordInput--isHidePassword": @isHidePassword
				"PasswordInput"
				@attrs.class
			controlled: @controlled
			basic: @attrs.basic
			disabled: @attrs.disabled
			min: @attrs.min
			max: @attrs.max
			step: @attrs.step
			minLength: @attrs.minLength
			maxLength: @attrs.maxLength
			pattern: @attrs.pattern
			required: @attrs.required
			readOnly: @attrs.readOnly
			defaultValue: @attrs.defaultValue
			value: @attrs.value
			icon: @attrs.icon
			rightIcon: @attrs.rightIcon
			oninput: @attrs.oninput
			oncontextmenu: @oncontextmenu
			ref: (@input) !~>
			element: @attrs.element
			rightElement:
				m m.Tooltip,
					content: @isHidePassword and "Hiện mật khẩu" or "Ẩn mật khẩu"
					m m.Button,
						basic: yes
						small: yes
						icon: @isHidePassword and \eye or \eye-slash
						onclick: @onclickToggleHidePassword
