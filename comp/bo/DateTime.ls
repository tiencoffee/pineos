m.DateTime = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@today = dayjs!
		@setDay if @controlled => @attrs.value else @attrs.defaultValue
		@updateTimePrecision!
		@monthSelect = void
		@yearSelect = void

	oncreate: !->
		@attrs.ref? @

	onbeforeupdate: (old) !->
		@attrs.highlightToday ?= yes
		if @attrs.value isnt old.value
			@setDay @attrs.value
		if !!@attrs.fixedWeekCount isnt !!old.fixedWeekCount
			@updateDays!
		if @attrs.timePrecision isnt old.timePrecision
			@updateTimePrecision!

	setDay: (day) !->
		day = dayjs day unless day instanceof dayjs
		if day.isValid!
			@day = day
		else
			@day ?= dayjs!
		@updateDays!
		year = @day.year!
		minYear = year - 20
		minYear = 1000 if minYear < 1000
		maxYear = year + 20
		maxYear = 9999 if maxYear > 9999
		@yearItems = [minYear to maxYear]

	updateDays: !->
		{fixedWeekCount} = @attrs
		@days = []
		day = @day.date 1 .day 0
		month = @day.month!
		n = 0
		while (fixedWeekCount and n < 42)
		or (not fixedWeekCount and (n < 28 or day.month! is month or day.day!))
			@days.push day
			day .= add 1 \d
			n++

	updateTimePrecision: !->
		@outputFormat = switch @attrs.timePrecision
			| \minute => \YYYY-MM-DDTHH:mm
			| \second => \YYYY-MM-DDTHH:mm:ss
			| \millisecond => \YYYY-MM-DDTHH:mm:ss.SSS
			else \YYYY-MM-DD

	onclickPrev: (event) !->
		day = @day.subtract 1 \M
		value = day.format @outputFormat
		unless @controlled
			@setDay day
		@attrs.onvalue? value

	onclickNext: (event) !->
		day = @day.add 1 \M
		value = day.format @outputFormat
		unless @controlled
			@setDay day
		@attrs.onvalue? value

	onitemselectMonth: (item, index) !->
		day = @day.month index
		value = day.format @outputFormat
		unless @controlled
			@setDay day
		@attrs.onvalue? value

	onitemselectYear: (item) !->
		day = @day.year item.value
		value = day.format @outputFormat
		unless @controlled
			@setDay day
		@attrs.onvalue? value

	onclickDay: (day) !->
		value = day.format @outputFormat
		unless @controlled
			@setDay day
		@attrs.onvalue? value
		@attrs.onclickday? day.clone!

	onchangeTime: (type, event) !->
		val = Math.floor event.target.value
		if event.target.min <= val <= event.target.max
			day = @day[type] val
			value = day.format @outputFormat
			unless @controlled
				@setDay day
			@attrs.onvalue? value

	view: ->
		m \.DateTime,
			m \.DateTime__header,
				m m.Button,
					class: \DateTime__prev
					basic: yes
					icon: \chevron-left
					onclick: @onclickPrev
				m m.Select,
					class: \DateTime__month
					basic: yes
					width: 115
					value: @day.month!
					items: [0 to 11]map ~>
						text: "Tháng #{it + 1}"
						value: it
					ref: (@monthSelect) !~>
					onitemselect: @onitemselectMonth
				m m.Select,
					class: \DateTime__year
					basic: yes
					width: 85
					value: @day.year!
					items: @yearItems
					ref: (@yearSelect) !~>
					onitemselect: @onitemselectYear
				m m.Button,
					class: \DateTime__next
					basic: yes
					icon: \chevron-right
					onclick: @onclickNext
			m \.DateTime__weekdays,
				m \.DateTime__weekday \CN
				m \.DateTime__weekday \T2
				m \.DateTime__weekday \T3
				m \.DateTime__weekday \T4
				m \.DateTime__weekday \T5
				m \.DateTime__weekday \T6
				m \.DateTime__weekday \T7
			m \.DateTime__days,
				@days.map (day) ~>
					m \.DateTime__day,
						class: m.class do
							"DateTime__day--isInMonth": day.month! is @day.month!
							"DateTime__day--today": @attrs.highlightToday and day.isSame @today, \d
							"DateTime__day--selected": day.isSame @day, \d
						onclick: (event) !~>
							@onclickDay day
						day.date!
			if @attrs.timePrecision
				m \.DateTime__times,
					m m.TextInput,
						type: \number
						basic: yes
						width: 40
						align: \center
						min: 0
						max: 23
						required: yes
						value: @day.hour!
						onchange: (event) !~>
							@onchangeTime \hour event
					m \.DateTime__separator \:
					m m.TextInput,
						type: \number
						basic: yes
						width: 40
						align: \center
						min: 0
						max: 59
						required: yes
						value: @day.minute!
						onchange: (event) !~>
							@onchangeTime \minute event
					if @attrs.timePrecision isnt \minute
						m.fragment do
							m \.DateTime__separator \:
							m m.TextInput,
								type: \number
								basic: yes
								width: 40
								align: \center
								min: 0
								max: 59
								required: yes
								value: @day.second!
								onchange: (event) !~>
									@onchangeTime \second event
					if @attrs.timePrecision is \millisecond
						m.fragment do
							m \.DateTime__separator \.
							m m.TextInput,
								type: \number
								basic: yes
								width: 50
								align: \center
								min: 0
								max: 999
								required: yes
								value: @day.millisecond!
								onchange: (event) !~>
									@onchangeTime \millisecond event
