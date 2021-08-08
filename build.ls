require! {
	"fs-extra": fs
	\glob-concat
	\live-server
}
process.chdir __dirname

Paths =
	"comp/bo": globConcat.sync \comp/bo/*
	"comp/ma": globConcat.sync \comp/ma/*
	"C/apps": globConcat.sync \C/apps/*
	"C": globConcat.sync \C/apps/**

fs.writeJsonSync \paths.json Paths, spaces: \\t

liveServer.start do
	host: \localhost
	port: 8080
	logLevel: 0
	open: no
