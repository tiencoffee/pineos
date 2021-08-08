m.DateTime = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \value of @attrs
		@today = dayjs!
		@day = dayjs if @controlled => @attrs.value else @attrs.defaultValue
		@updateDay!
		@updateFormat!

	onbeforeupdate: (old) !->
		if @attrs.value isnt old.value
			@day = dayjs @attrs.value
			@updateDay!
		if @attrs.timePrecision isnt old.timePrecision
			@updateFormat!

	updateDay: !->
		@days = []
		day = @day.date 1 .day 0
		n = 0
		while n < 28 or day.month! is @day.month! or day.day!
			@days.push day
			day .= add 1 \d
			n++

	updateFormat: !->
		@format = switch @attrs.timePrecision
			| \minute => \YYYY-MM-DDTHH:mm
			| \second => \YYYY-MM-DDTHH:mm:ss
			| \millisecond => \YYYY-MM-DDTHH:mm:ss.SSS
			else \YYYY-MM-DD

	onclickPrev: (event) !->
		day = @day.subtract 1 \M
		unless @controlled
			@day = day
			@updateDay!
		value = day.format @format
		@attrs.onvalue? value

	onclickNext: (event) !->
		day = @day.add 1 \M
		unless @controlled
			@day = day
			@updateDay!
		value = day.format @format
		@attrs.onvalue? value

	onitemselectMonth: (item, index) !->
		day = @day.month index
		unless @controlled
			@day = day
			@updateDay!
		value = day.format @format
		@attrs.onvalue? value

	onitemselectYear: (item) !->
		day = @day.year item.value
		unless @controlled
			@day = day
			@updateDay!
		value = day.format @format
		@attrs.onvalue? value

	onclickDay: (day) !->
		unless @controlled
			@day = day
			@updateDay!
		value = day.format @format
		@attrs.onvalue? value

	onchangeHour: (event) !->
		hour = Math.floor event.target.value
		if 0 <= hour <= 23
			day = @day.hour hour
			unless @controlled
				@day = day
				@updateDay!
			value = day.format @format
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
					onitemselect: @onitemselectMonth
				m m.Select,
					class: \DateTime__year
					basic: yes
					width: 85
					value: @day.year!
					items: [@day.year! - 20 to @day.year! + 20]
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
							"DateTime__day--today": day.isSame @today, \d
							"DateTime__day--selected": day.isSame @day, \d
						onclick: (event) !~>
							@onclickDay day
						day.date!
			if @attrs.timePrecision
				m \.DateTime__times,
					m m.InputGroup,
						m m.TextInput,
							class: \DateTime__hour
							type: \number
							basic: yes
							width: 40
							min: 0
							max: 23
							required: yes
							value: @day.hour!
							onchange: @onchangeHour
