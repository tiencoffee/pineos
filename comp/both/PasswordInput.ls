PasswordInput = m.comp do
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
		os.openContextMenu event,
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
				icon: \scissors
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
		m TextInput,
			class:
				"PasswordInput--isHidePassword": @isHidePassword
				"PasswordInput"
				@attrs.class
			controlled: @controlled
			basic: @attrs.basic
			disabled: @attrs.disabled
			minLength: @attrs.minLength
			maxLength: @attrs.maxLength
			pattern: @attrs.pattern
			required: @attrs.required
			readOnly: @attrs.readOnly
			defaultValue: @attrs.defaultValue
			value: @attrs.value
			icon: @attrs.icon
			rightIcon: @attrs.rightIcon
			ref: (@input) !~>
			oninput: @attrs.oninput
			onchange: @attrs.onchange
			oncontextmenu: @oncontextmenu
			element: @attrs.element
			rightElement:
				m Tooltip,
					content: @isHidePassword and "Hiện mật khẩu" or "Ẩn mật khẩu"
					m Button,
						style:
							marginRight: 2
						basic: yes
						small: yes
						icon: @isHidePassword and \eye or \eye-slash
						onclick: @onclickToggleHidePassword
