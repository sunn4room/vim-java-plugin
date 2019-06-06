if exists("b:java_import")
	finish
endif
let b:java_import = 1

let s:path="find"
for cur in split(&rtp,",")
	if cur=~".*vim-java-plugin$"
		let s:path=cur
		break
	endif
endfor


function! JavaEnter()
	if !exists("g:classdic")
		call ScanClass()
	else
		call RunningClass()
	endif
endfunction

function! RunningClass()
	call execute("syn keyword runningClass ".join(g:keyws," "))
	call execute("hi runningClass ctermfg=81 cterm=none")
endfunction

func! ScanClass()
	if !exists("b:jtype")
		call JavaStamp()
	endif
	call job_start(['/bin/bash', '-c', 'python3 '.s:path.'/python/scan_class.py '.b:jtype], {'callback': 'ScanClassHandler'})
endfunc

func! ScanClassHandler(channel, msg)
	exec "let g:classdic=".a:msg
	let g:keyws=keys(g:classdic)
	call filter(g:keyws, 'v:val != "Contains"')
	call filter(g:keyws, 'v:val != "Oneline"')
	call filter(g:keyws, 'v:val != "Fold"')
	call filter(g:keyws, 'v:val != "Display"')
	call filter(g:keyws, 'v:val != "Extend"')
	call filter(g:keyws, 'v:val != "Concealends"')
	call filter(g:keyws, 'v:val != "Conceal"')
	call filter(g:keyws, 'v:val != "Cchar"')
	call filter(g:keyws, 'v:val != "Contained"')
	call filter(g:keyws, 'v:val != "Containedin"')
	call filter(g:keyws, 'v:val != "Nextgroup"')
	call filter(g:keyws, 'v:val != "Transparent"')
	call filter(g:keyws, 'v:val != "Skipwhite"')
	call filter(g:keyws, 'v:val != "Skipnl"')
	call filter(g:keyws, 'v:val != "Skipempty"')
	call RunningClass()
	echo "ScanClass has been completed"
endfunc

nnoremap <buffer> <F10> :echo GetFolder()<cr>
