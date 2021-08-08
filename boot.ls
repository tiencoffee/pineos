get = (url, type = \text) ->
	(await fetch url)[type]!

indent = (code, lv) ->
	code.replace /^(?!$)/gm \\t * lv

Boot = window.Boot = {}
Boot.paths = await get \paths.json \json

stylM = ""
stylI = ""
text = await get \styl/bo.styl
stylM += text
stylI += text
text = await get \styl/ma.styl
stylM .= replace "((text))" text
text = await get \styl/if.styl
stylI .= replace "((text))" text

Boot.stylI = stylI
stylM = stylus.render stylM, compress: yes
stylEl.textContent = stylM

codeM = ""
codeI = ""
text = await get \code/bo.ls
codeM += text
codeI += text
for path in Boot.paths\comp/bo
	text = await get path
	codeM += text
	codeI += text
for path in Boot.paths\comp/ma
	text = await get path
	codeM += text
text = await get \code/ma.ls
codeM += text
text = await get \code/if.ls
codeI += text

Boot.codeI = codeI
livescript.run codeM

text = await get \tmpl.html
Boot.tmplI = text
