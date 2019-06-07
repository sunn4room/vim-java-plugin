if exists("b:java_compile_run")
	finish
endif
let b:java_compile_run = 1

nnoremap <buffer> <F5> :call CompileJava()<cr>
nnoremap <buffer> <F6> :call RunJava()<cr>

function RunJava()
	if !exists("b:jtype")
		call JavaStamp()
	endif
	let fullname=GetFullName()
	if b:jtype=="simple"
		exec "Cmd java ".fullname
	elseif b:jtype=="normal"
		set noautochdir
		exec "chdir ".b:jpath
		let jars=systemlist("find lib -name *.jar")
		if jars[0]=~"^find.*"
			exec "Cmd java -cp class ".fullname
		else
			exec "Cmd java -cp class:".join(jars,":")." ".fullname
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
			exec 'Mvn exec:java -Dexec.mainClass="'.fullname.'" -Dexec.cleanupDaemonThreads=false'
		else
			exec 'Mvn spring-boot:run -DmainClass="'.fullname.'"'
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
		set noautochdir
		exec "chdir ".b:jpath
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
	let curpath=expand("%:p")
	let curpath=strpart(curpath,0,strridx(curpath,"/"))
	let srcidx=strridx(curpath."/","/src/")
	echo srcidx
	if srcidx<0
		let b:jtype="simple"
		let b:jpath=curpath
	else
		let srcpath=strpart(curpath,0,srcidx)
		let b:jpath=srcpath
		if filereadable(srcpath."/pom.xml")
			let b:jtype="maven"
		else
			let b:jtype="normal"
		endif
	endif
endfunction
