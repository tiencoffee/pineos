Popover = m.comp do
	oninit: !->
		@controlled = @attrs.controlled ? \isOpen of @attrs
		@isOpen = if @controlled => @attrs.isOpen else @attrs.defaultIsOpen
		@willUpdateIsOpen = no
		@popper = void
		@popperEl = void
		@leaveTimo = void

	onbeforeupdate: (old, first) !->
		@attrs.interactionType ?= \click
		@attrs.closeOnOutsideClick ?= yes
		@attrs.closeOnContentHover ?= no
		@attrs.hoverCloseDelay ?= 100
		if first
			@willUpdateIsOpen = yes
		else
			if !!@attrs.isOpen isnt !!old.isOpen
				@isOpen = @attrs.isOpen
				@willUpdateIsOpen = yes
		if target = @attrs.children.0
			while target?tag.isWrapper
				target .= children.0
			if target?tag
				target.attrs ?= {}
				if @isOpen
					if @attrs.interactionType in [\click \contextmenu]
						target.attrs.class ?= ""
						target.attrs.class += " active"
					if @attrs.interactionType is \contextmenu
						{onclick} = target.attrs
						target.attrs.onclick = (...args) !~>
							isOpen = not @isOpen
							unless @controlled
								@isOpen = isOpen
								@willUpdateIsOpen = yes
							@attrs.oninteraction? isOpen
							onclick? ...args
							m.redraw!
				switch @attrs.interactionType
				| \click
					{onclick} = target.attrs
					target.attrs.onclick = (...args) !~>
						isOpen = not @isOpen
						unless @controlled
							@isOpen = isOpen
							@willUpdateIsOpen = yes
						@attrs.oninteraction? isOpen
						onclick? ...args
						m.redraw!
				| \contextmenu
					{oncontextmenu} = target.attrs
					target.attrs.oncontextmenu = (...args) !~>
						isOpen = not @isOpen
						unless @controlled
							@isOpen = isOpen
							@willUpdateIsOpen = yes
						@attrs.oninteraction? isOpen
						oncontextmenu? ...args
						m.redraw!
				| \hover
					{onmouseenter, onmouseleave} = target.attrs
					target.attrs.onmouseenter = (...args) !~>
						clearTimeout @leaveTimo
						unless @controlled
							@isOpen = yes
							@willUpdateIsOpen = yes
						@attrs.oninteraction? yes
						onmouseenter? ...args
						m.redraw!
					target.attrs.onmouseleave = (...args) !~>
						@leaveTimo = setTimeout !~>
							unless @controlled
								@isOpen = no
								@willUpdateIsOpen = yes
							@attrs.oninteraction? no
							m.redraw!
						, @attrs.hoverCloseDelay
						onmouseleave? ...args
				{onremove} = @attrs
				target.attrs.onremove = !~>
					if @isOpen
						@isOpen = no
						@attrs.oninteraction? no
					@updateIsOpen!
					onremove?!

	onupdate: !->
		if @willUpdateIsOpen
			@willUpdateIsOpen = no
			@updateIsOpen!
		if @popper
			@popper.update!

	updateIsOpen: !->
		if @isOpen
			unless @popper
				parentEl = @dom.closest ".OS__popper,.Task" or portalsEl
				@popperEl = document.createElement \div
				@popperEl.className = "Popover__popper OS__popper"
				@popperEl.onmouseenter = (event) !~>
					if @attrs.interactionType is \hover
						unless @attrs.closeOnContentHover
							clearTimeout @leaveTimo
				@popperEl.onmouseleave = (event) !~>
					if @attrs.interactionType is \hover
						@leaveTimo = setTimeout !~>
							unless @controlled
								@isOpen = no
								@willUpdateIsOpen = yes
							@attrs.oninteraction? no
							m.redraw!
						, @attrs.hoverCloseDelay
				parentEl.appendChild @popperEl
				close = !~>
					unless @controlled
						@isOpen = no
						@willUpdateIsOpen = yes
					@attrs.oninteraction? no
					m.redraw!
				comp =
					view: (vnode) ~>
						m \.Popover__content,
							os.call @attrs.content, close, vnode.dom
				m.mount @popperEl, comp
				@popper = os.createPopper @dom, @popperEl,
					placement: @attrs.position
				document.addEventListener \mousedown @onmousedownGlobal
				@attrs.onopened?!
		else
			if @popper
				@popper.destroy!
				@popper = void
				m.mount @popperEl
				@popperEl.remove!
				@popperEl = void
				clearTimeout @leaveTimo
				document.removeEventListener \mousedown @onmousedownGlobal
				@attrs.onclosed?!

	onmousedownGlobal: (event) !->
		if @attrs.closeOnOutsideClick
			unless @dom.contains event.target or @popperEl.contains event.target
				unless @controlled
					@isOpen = no
					@willUpdateIsOpen = yes
				@attrs.oninteraction? no
				m.redraw!

	view: ->
		@attrs.children.0
	,,

	isWrapper: yes
