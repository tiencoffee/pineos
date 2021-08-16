m.NumberInput = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@timoSpin = void
		@intvSpin = void
		@input = void

	step: (val) !->
		@input.input.dom.focus!
		@input.input.dom.stepUp val
		evt = new InputEvent \input
		@input.input.dom.dispatchEvent evt
		evt = new InputEvent \change
		@input.input.dom.dispatchEvent evt

	onpointerdownSpin: (val, event) !->
		event.target.setPointerCapture event.pointerId
		@step val
		@timoSpin = setTimeout !~>
			@step val
			@intvSpin = setInterval !~>
				@step val
			, 100
		, 300

	onlostpointercaptureSpin: (event) !->
		clearTimeout @timoSpin
		clearInterval @intvSpin

	oncontextmenu: (event) !->
		m.openContextMenu event,
			* text: "Tăng lên"
				icon: \chevron-up
				label: "ArrowUp"
				onclick: !~>
					@step 1
			* text: "Giảm xuống"
				icon: \chevron-down
				label: "ArrowDown"
				onclick: !~>
					@step -1
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
				onclick: !~>
					@input.input.dom.focus!
					document.execCommand \cut
			* text: "Sao chép"
				icon: \copy
				label: "Ctrl+C"
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
			,,
			* text: "Chọn tất cả"
				label: "Ctrl+A"
				onclick: !~>
					@input.dom.focus!
					@input.dom.select!
		@attrs.oncontextmenu? event

	onremove: !->
		clearTimeout @timoSpin
		clearInterval @intvSpin

	view: ->
		m m.TextInput,
			class:
				"NumberInput"
			controlled: @controlled
			type: \number
			basic: @attrs.basic
			disabled: @attrs.disabled
			min: @attrs.min
			max: @attrs.max
			step: @attrs.step
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
			rightElement:
				m \.NumberInput__spins,
					m m.Button,
						class: "NumberInput__spin NumberInput__spinUp"
						basic: yes
						icon: \chevron-up
						onpointerdown: (event) !~>
							@onpointerdownSpin 1 event
						onlostpointercapture: @onlostpointercaptureSpin
					m m.Button,
						class: "NumberInput__spin NumberInput__spinDown"
						basic: yes
						icon: \chevron-down
						onpointerdown: (event) !~>
							@onpointerdownSpin -1 event
						onlostpointercapture: @onlostpointercaptureSpin
