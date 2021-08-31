Tabs = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \tabId of @attrs
		@tabId = if @controlled => @attrs.tabId else @attrs.defaultTabId
		@willUpdateTabId = yes
		@updateTabs!

	oncreate: !->
		@indicatorEl = @dom.querySelector \.Tabs__indicator

	onbeforeupdate: (old, first) !->
		@attrs.animate = Boolean @attrs.animate ? yes
		if @attrs.tabId isnt old.tabId
			@tabId = @attrs.tabId
			@willUpdateTabId = yes
			@updateTabs!

	onupdate: (old, first) !->
		if @willUpdateTabId
			@willUpdateTabId = no
			tabEl = @dom.querySelector \.Tabs__tab.active
			x = tabEl.offsetLeft
			y = tabEl.offsetHeight - 3
			width = tabEl.offsetWidth
			@indicatorEl.style.width = width + \px
			@indicatorEl.style.transform = "translate(#{x}px,#{y}px)"
		if first or @attrs.animate isnt old.animate
			@indicatorEl.offsetWidth
			@updateAnimate!

	updateTabs: !->
		@tabs = os.castArray @attrs.tabs
		@tab = @tabs.find (.id is @tabId) or @tabs.0

	updateAnimate: !->
		if @attrs.animate
			@indicatorEl.style.transition = "width .1s,transform .1s"
		else
			@indicatorEl.style.transition = ""

	onclickTab: (tab, event) !->
		unless @controlled
			@tabId = tab.id
			@willUpdateTabId = yes
			@updateTabs!
		@attrs.ontabidchange? tab.id

	view: ->
		m \.Tabs,
			m \.Tabs__tabs,
				@tabs.map (tab) ~>
					m \.Tabs__tab,
						class: m.class do
							"active": @tabId is tab.id
						onclick: (event) !~>
							@onclickTab tab, event
						tab.title
				m \.Tabs__indicator
			m \.Tabs__panel,
				os.call @tab.panel
