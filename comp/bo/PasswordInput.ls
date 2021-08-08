m.PasswordInput = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@isHidePassword = yes
		@inputEl

	oncontextmenu: (event) !->
		m.openContextMenu event,
			* text: @isHidePassword and "Hiện mật khẩu" or "Ẩn mật khẩu"
				icon: @isHidePassword and \eye or \eye-slash
				onclick: !~>
					@inputEl.focus!
					not= @isHidePassword
			,,
			* text: "Hoàn tác"
				icon: \undo
				label: "Ctrl+Z"
				onclick: !~>
					@inputEl.focus!
					document.execCommand \undo
			* text: "Làm lại"
				icon: \redo
				label: "Ctrl+Shift+Z"
				onclick: !~>
					@inputEl.focus!
					document.execCommand \redo
			,,
			* text: "Cắt"
				icon: \cut
				label: "Ctrl+X"
				disabled: @isHidePassword
				onclick: !~>
					@inputEl.focus!
					document.execCommand \cut
			* text: "Sao chép"
				icon: \copy
				label: "Ctrl+C"
				disabled: @isHidePassword
				onclick: !~>
					@inputEl.focus!
					document.execCommand \copy
			* text: "Dán"
				icon: \clipboard
				label: "Ctrl+V"
				onclick: !~>
					@inputEl.focus!
					if tid
						text = await send \readClipboard
					else
						text = await m.readClipboard!
					document.execCommand \insertText,, text
		@attrs.oncontextmenu? event

	view: ->
		m m.TextInput,
			class: m.class do
				"PasswordInput--isHidePassword": @isHidePassword
				"PasswordInput"
				@attrs.class
			controlled: @controlled
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
			inputRef: (@inputEl) !~>
			element: @attrs.element
			rightElement:
				m m.Tooltip,
					content: @isHidePassword and "Hiện mật khẩu" or "Ẩn mật khẩu"
					m m.Button,
						style:
							marginRight: 2
						basic: yes
						small: yes
						icon: @isHidePassword and \eye or \eye-slash
						onclick: !~>
							@inputEl.focus!
							not= @isHidePassword
