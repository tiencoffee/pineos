m.Popover = m.comp do
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
				{onclick, onmouseenter, onmouseleave, onremove} = target{}attrs
				if @isOpen
					if @attrs.interactionType is \click
						target.attrs.class ?= ""
						target.attrs.class += " active"
				target.attrs.onclick = (...args) !~>
					if @attrs.interactionType is \click
						isOpen = not @isOpen
						unless @controlled
							@isOpen = isOpen
							@willUpdateIsOpen = yes
						@attrs.oninteraction? isOpen
						m.redraw!
					onclick? ...args
				target.attrs.onmouseenter = (...args) !~>
					if @attrs.interactionType is \hover
						clearTimeout @leaveTimo
						unless @controlled
							@isOpen = yes
							@willUpdateIsOpen = yes
						@attrs.oninteraction? yes
						m.redraw!
					onmouseenter? ...args
				target.attrs.onmouseleave = (...args) !~>
					if @attrs.interactionType is \hover
						@leaveTimo = setTimeout !~>
							unless @controlled
								@isOpen = no
								@willUpdateIsOpen = yes
							@attrs.oninteraction? no
							m.redraw!
						, @attrs.hoverCloseDelay
					onmouseleave? ...args
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
				@popperEl = document.createElement \div
				parentEl = @dom.closest ".Popover__popper,.Task" or portalsEl
				@popperEl.className = \Popover__popper
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
							m.safeCall @attrs.content, close, vnode.dom
				m.mount @popperEl, comp
				@popper = m.createPopper @dom, @popperEl,
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
