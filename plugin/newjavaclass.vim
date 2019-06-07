if exists("g:newjavaclass")
	finish
endif
let g:newjavaclass = 1

command -nargs=1 NewClass call NewClass(<f-args>)

function NewClass(fullname)
py3 << EOF
import os
curpath=os.getcwd()
idx=(curpath+"/").rfind("/java/")
if idx >= 0:
	path=curpath[:idx+5]
else:
	idx=(curpath+"/").rfind("/src/")
	if idx >= 0:
		path=curpath[:idx+4]
	else:
		path=curpath
fullname=vim.eval("a:fullname")
if fullname[0]==".":
	if path!=curpath:
		fullname=curpath[len(path)+1:].replace("/",".")+fullname
	else:
		fullname=fullname[1:]
filestr=path+"/"+fullname.replace(".","/")+".java"

if not os.path.exists(filestr):
	filepath=filestr[:filestr.rfind("/")]
	if not os.path.exists(filepath):
		os.makedirs(filepath)
	sepidx = fullname.rfind(".")
	if sepidx == -1:
		f = open(filestr,"w",encoding="utf-8")
		f.write("\npublic class "+fullname+" {\n\t\n}")
		f.close()
	else:
		f = open(filestr,"w",encoding="utf-8")
		f.write("package "+fullname[:sepidx]+";\n\n\npublic class "+fullname[sepidx+1:]+" {\n\t\n}")
		f.close()
EOF
endfunction
