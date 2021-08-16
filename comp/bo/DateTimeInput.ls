m.DateTimeInput = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@isOnchange = no
		@parseFormats =
			"YYYY-MM-DDTHH:mm:ss.S"
			"YYYY-MM-DDTHH:mm:ss"
			"YYYY-MM-DDTHH:mm"
			"YYYY-MM-DD"
			"D/M/YYYY H:m:s.S"
			"D/M/YYYY H:m:s"
			"D/M/YYYY H:m"
			"D/M/YYYY"
		@updateTimePrecision!
		@day = dayjs (if @controlled => @attrs.value else @attrs.defaultValue), @parseFormats
		@value = @getValue @day
		@outputValue = @getOutputValue @day
		@popper = void
		@popperEl = void
		@dateTime = void

	onbeforeupdate: (old) !->
		if (@isOnchange and @attrs.value isnt @value) or (not @isOnchange and @attrs.value isnt old.value)
			@isOnchange = no
			@day = dayjs @attrs.value, @parseFormats
			@value = @getValue @day
			@outputValue = @getOutputValue @day
		if @attrs.timePrecision isnt old.timePrecision
			@updateTimePrecision!

	getValue: (day) ->
		day.format @displayFormat

	getOutputValue: (day) ->
		day.format @outputFormat

	updateTimePrecision: !->
		switch @attrs.timePrecision
		| \minute
			@outputFormat = \YYYY-MM-DDTHH:mm
			@displayFormat = "DD/MM/YYYY HH:mm"
		| \second
			@outputFormat = \YYYY-MM-DDTHH:mm:ss
			@displayFormat = "DD/MM/YYYY HH:mm:ss"
		| \millisecond
			@outputFormat = \YYYY-MM-DDTHH:mm:ss.SSS
			@displayFormat = "DD/MM/YYYY HH:mm:ss.SSS"
		else
			@outputFormat = \YYYY-MM-DD
			@displayFormat = "DD/MM/YYYY"

	togglePopper: (isOpen) !->
		if isOpen
			unless @popper
				@popperEl = document.createElement \div
				@popperEl.className = \DateTimeInput__popper
				comp =
					view: ~>
						m m.DateTime,
							timePrecision: @attrs.timePrecision
							fixedWeekCount: yes
							value: @outputValue
							ref: (@dateTime) !~>
							onvalue: (value) !~>
								@handleOnchange value
							onclickday: !~>
								@togglePopper no
				m.mount @popperEl, comp
				@popper = m.createPopper @dom, @popperEl,
					placement: \bottom
					allowedFlips: [\bottom \top]
				portalsEl.appendChild @popperEl
				document.addEventListener \mousedown @onmousedownGlobal
				m.redraw!
		else
			if @popper
				@popper.destroy!
				@popper = void
				m.mount @popperEl
				@popperEl.remove!
				@popperEl = void
				@dateTime = void
				document.removeEventListener \mousedown @onmousedownGlobal
				m.redraw!

	handleOnchange: (value) !->
		day = dayjs value, @parseFormats
		value = @getValue day
		outputValue = @getOutputValue day
		if @controlled
			@isOnchange = yes
		else
			@day = day
			@value = value
			@outputValue = outputValue
		@attrs.onvalue? outputValue

	oninput: (event) !->
		day = dayjs event.target.value, @parseFormats
		@outputValue = @getOutputValue day
		@attrs.oninput? event.target.value

	onchange: (event) !->
		@handleOnchange event.target.value

	onfocus: (event) !->
		unless @day.isValid!
			@value = ""
		@togglePopper yes

	onmousedownGlobal: (event) !->
		{target} = event
		unless @dom.contains target
		or @popperEl.contains target
		or @dateTime.monthSelect.popperEl?contains target
		or @dateTime.yearSelect.popperEl?contains target
			@togglePopper no

	onremove: !->
		@togglePopper no

	view: ->
		m m.TextInput,
			class:
				"DateTimeInput"
				@attrs.class
			value: @value
			oninput: @oninput
			onchange: @onchange
			onfocus: @onfocus
