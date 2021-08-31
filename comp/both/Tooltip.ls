Tooltip = m.comp do
	onbeforeupdate: !->
		if target = @attrs.children.0
			while target?tag.isWrapper
				target .= children.0
			if target?tag
				{onmouseenter, onmouseleave} = target{}attrs
				target.attrs.onmouseenter = (...args) !~>
					content = os.call @attrs.content
					content += ""
					rect = @dom.getBoundingClientRect!
					if topWin
						os.openTooltip content, rect,
							position: @attrs.position
					else
						send \openTooltip content, rect,
							position: @attrs.position
					onmouseenter? ...args
				target.attrs.onmouseleave = (...args) !~>
					if topWin
						os.closeTooltip!
					else
						send \closeTooltip
					onmouseleave? ...args

	view: ->
		@attrs.children.0
	,,

	isWrapper: yes
