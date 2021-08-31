require! {
	"fs-extra": fs
	\glob-concat
}
process.chdir __dirname

Paths =
	"comp/both": globConcat.sync \comp/both/*
	"comp/main": globConcat.sync \comp/main/*
	"C/apps": globConcat.sync \C/apps/*
	"C": globConcat.sync \C/apps/**

fs.writeJsonSync \paths.json Paths, spaces: \\t
