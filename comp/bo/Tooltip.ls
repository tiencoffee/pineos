m.Tooltip = m.comp do
	onbeforeupdate: !->
		if target = @attrs.children.0
			while target?tag.isWrapper
				target .= children.0
			if target?tag
				{onmouseenter, onmouseleave} = target{}attrs
				target.attrs.onmouseenter = (...args) !~>
					content = m.safeCall @attrs.content
					content += ""
					rect = @dom.getBoundingClientRect!
					if tid
						send \openTooltip content, rect,
							position: @attrs.position
					else
						m.openTooltip content, rect,
							position: @attrs.position
					onmouseenter? ...args
				target.attrs.onmouseleave = (...args) !~>
					if tid
						send \closeTooltip
					else
						m.closeTooltip!
					onmouseleave? ...args

	view: ->
		@attrs.children.0
	,,

	isWrapper: yes
