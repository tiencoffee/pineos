App = m.comp do
	view: ->
		m \.p-3,
			m Tooltip,
				content: "Không có gì :)"
				m \span,
					"Sao dị?"
			m Select,
				items:
					"Mưa đêm ngoại ô"
					"Hai mùa mưa"
					"Trăng tàn trên hè phố"
					"Ngày đó xa rồi"
			m DateTimeInput
