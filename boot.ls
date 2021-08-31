getText = (url) ->
	(await fetch url)text!

getJSON = (url) ->
	(await fetch url)json!

indent = (code, lv) ->
	code.replace /^(?!$)/gm \\t * lv

Boot = window.Boot =
	paths: await getJSON \paths.json \json

[both, main, ifrm] = await Promise.all [
	getText \styl/both.styl
	getText \styl/main.styl
	getText \styl/ifrm.styl
]

main = both.replace "((css))" main
ifrm = both.replace "((css))" ifrm

Boot.styl = ifrm
main = stylus.render main, compress: yes
cssEl.textContent = main

[both, main, ifrm, compBoth, compMain] = await Promise.all [
	getText \code/both.ls
	getText \code/main.ls
	getText \code/ifrm.ls
	Promise.all Boot.paths"comp/both"map getText
	Promise.all Boot.paths"comp/main"map getText
]

compBoth *= ""
compMain *= ""
main = both + compBoth + compMain + main
ifrm = both + compBoth + compMain + ifrm

Boot.code = ifrm
livescript.run main

ifrm = await getText \ifrm.html
Boot.html = ifrm
