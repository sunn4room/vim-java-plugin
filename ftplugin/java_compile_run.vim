if exists("b:java_function")
	finish
endif
let b:java_function = 1

nnoremap <buffer> <F5> :call CompileJava()<cr>
nnoremap <buffer> <F6> :call RunJava()<cr>

function RunJava()
	if !exists("b:jtype")
		call JavaStamp()
	endif
	if b:jtype=="simple"
		exec "Cmd java ".GetFullName()
	elseif b:jtype=="normal"
		let curpath=getcwd()
		let mainpath=strpart(curpath,0,strridx(curpath."/","/src/"))
		set noautochdir
		exec "chdir ".mainpath
		let jars=systemlist("find lib -name *.jar")
		if jars[0]=~"^find.*"
			exec "Cmd java -cp class ".GetFullName()
		else
			exec "Cmd java -cp class:".join(jars,":")." ".GetFullName()
		endif
		exec "chdir ".curpath
		set autochdir
	elseif b:jtype=="maven"
		let run="exec"
		for ii in range(1,line("$"))
			let line=getline(ii)
			if line=~'^@SpringBootApplication.*'
				let run="boot"
				break
			elseif line=~'^public.*' || line=~'^class.*'
				break
			endif
		endfor
		if run=="exec"
			exec 'Mvn exec:java -Dexec.mainClass="'.GetFullName().'" -Dexec.cleanupDaemonThreads=false'
		else
			exec 'Mvn spring-boot:run -DmainClass="'.GetFullName().'"'
		endif
	endif
endfunction

function GetFullName()
	for ii in range(1,line("$"))
		let line=getline(ii)
		if line=~'^package.*'
			return strpart(line,8,strlen(line)-9).".".expand("%<")
		elseif line=~'^public.*' || line=~'^class.*'
			break
		endif
	endfor
	return expand("%<")
endfunction

function CompileJava()
	if !exists("b:jtype")
		call JavaStamp()
	endif
	if b:jtype=="simple"
		exec "Cmd javac %"
	elseif b:jtype=="normal"
		let curpath=getcwd()
		let mainpath=strpart(curpath,0,strridx(curpath."/","/src/"))
		set noautochdir
		exec "chdir ".mainpath
		if isdirectory(mainpath+"/class")
			call system("rm -rf class")
		endif
		let javas=systemlist("find src -name *.java")
		let jars=systemlist("find lib -name *.jar")
		if jars[0]=~"^find.*"
			exec "Cmd javac -d class ".join(javas," ")
		else
			exec "Cmd javac -d class -cp ".join(jars,":")." ".join(javas," ")
		endif
		exec "chdir ".curpath
		set autochdir
	elseif b:jtype=="maven"
		exec "Mvn clean compile"
	endif
endfunction

function JavaStamp()
	let curpath=getcwd()
	let srcidx=strridx(curpath."/","/src/")
	if srcidx<0
		let b:jtype="simple"
	else
		let srcpath=strpart(curpath,0,srcidx)
		if filereadable(srcpath."/pom.xml")
			let b:jtype="maven"
		else
			let b:jtype="normal"
		endif
	endif
endfunction

