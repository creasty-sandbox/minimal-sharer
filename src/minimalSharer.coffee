
do ($ = jQuery, window, document) ->
	services =
		twitter:
			link: 'https://twitter.com/intent/tweet?text={%title}&url={%url}&via={%twitter}'
			click: 'toolbar=0, status=0, width=650, height=360'

		facebook:
			count: 'http://graph.facebook.com/{%url}'
			link: 'http://www.facebook.com/sharer.php?u={%url}'
			filter: (data) -> data.shares
			click: 'toolbar=0, status=0, width=900, height=500'

		gplus:
			count: '?service=gplus&id={%url}'
			link: 'https://plusone.google.com/_/+1/confirm?hl={%lang}&url={%url}'
			dataType: 'text'
			click: 'toolbar=0, status=0, width=900, height=500'

			init: (btn, config) ->
				unless config.script
					btn.service.count = null
				else if '?' == @count.charAt 0
					@count = config.script + @count

		hatena:
			count: 'http://api.b.st-hatena.com/entry.count?url={%url}&callback=?'
			link: 'http://b.hatena.ne.jp/entry/{url}'
			dataType: 'text'

		pinterest:
			count: 'http://api.pinterest.com/v1/urls/count.json?url={%url}&callback=?'
			link: 'http://pinterest.com/pin/create/button/?url={%url}&media={%image}&description={%description}'
			filter: (data) -> data.count

		linkedin:
			count: 'http://www.linkedin.com/countserv/count/share?url={%url}&format=json'
			link: 'http://www.linkedin.com/sharer.php?u={%url}&t={%title}'
			filter: (data) -> data.count

		stumble:
			count: 'http://www.stumbleupon.com/services/1.01/badge.getinfo?url={%url}'
			link: 'http://www.stumbleupon.com/submit?url={%url}&title={%title}'
			filter: (data) -> data.result.views

		tumblr:
			link: 'http://www.tumblr.com/share?v=3&u={%url}&t={%title}&s='

		mail:
			link: 'mailto:?body={%title} {%url}'

		evernote:
			init: ->
				return if window.Evernote

				$('head').append '<script src="http://static.evernote.com/noteit.js" async="async"></script>'

			click: (btn, config) ->
				return unless window.Evernote

				Evernote.doClip
					providerName: config.site
					url: config.url
					title: config.title
					contentId: config.contentId ? 'main'

	sharer =
		meta: null

		init: ->
			return if @meta

			$meta = $ 'meta'
			@meta =
				url: $meta.filter('[property=og\\:url]').attr('content') ? $meta.filter('[name=canonical]').attr('content') ? window.location.href

				title: $meta.filter('[property=og\\:title]').attr('content') ? document.title

				site: $meta.filter('[property=og\\:site_name]').attr('content') ? ''

				image: $meta.filter('[property=og\\:image]').attr('content') ? ''

				lang: $('html').attr('lang') ? 'ja'

				twitter: $meta.filter('[name=twitter\\:site]').attr('content')?.replace(/^\@/, '') ? ''

		bind: (tpl, hash) ->
			tpl.replace /\{(%)?(\w+)\}/g, (_0, esacpe, key) ->
				val = hash[key] ? ''
				if esacpe then encodeURIComponent val else val

		getCount: (btn, config) ->
			$.ajax
				dataType: btn.service.dataType ? 'json'
				url: @bind btn.service.count, config
				success: (data) ->
					data = btn.service.filter data if btn.service.filter
					btn.$counter.text data || '0'
					btn.$btn.show()
				error: ->
					btn.$counter.hide()
					btn.$btn.removeClass('has-counter').show()

		click: (btn, config) ->
			btn.$link.click (e) =>
				if btn.$counter # simulate counter increment
					btn.$counter.text parseInt(btn.$counter.text(), 10) + 1

				if $.isFunction btn.service.click
					e.preventDefault()
					btn.service.click btn, config
				else if btn.service.click
					e.preventDefault()
					window.open @bind(btn.service.link, config), null, btn.service.click

		create: ($target, config) ->
			for service, label of config.buttons
				btn = service: services[service]

				continue unless btn.service && label

				btn.$btn = $("<li class=\"#{service}\"><a href=\"#\" class=\"link\">#{label}</a></li>").appendTo $target
				btn.$link = btn.$btn.children '.link'

				btn.service.init? btn, config

				if btn.service.count
					btn.$btn.hide().addClass 'has-counter'
					btn.$counter = $('<span class="counter">0</span>').appendTo btn.$btn
					@getCount btn, config

				if btn.service.link
					btn.$link.attr 'href', @bind btn.service.link, config
					btn.$link.attr 'target', (if btn.service.link.match /^https?:/i then '_blank' else '_self')

				@click btn, config

	$.fn.minimalSharer = (config) ->
		return @ unless config.buttons

		sharer.init()
		config = $.extend {}, sharer.meta, config

		@each ->
			sharer.create $(@), config

	$.minimalSharer =
		extend: (settings) ->
			$.extend services, settings

