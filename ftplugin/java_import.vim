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

autocmd BufEnter *.java call JavaEnter()
nnoremap <buffer> <leader>js :call ScanClass()<cr>
nnoremap <buffer> i :call SeekPackage()<CR>:call PlaceImport()<CR>
inoremap <buffer> i <esc>hh:call SeekPackage()<CR>:call PlaceImport()<CR>
nnoremap <buffer> o :call SeekPackage()<CR>:call AddPackage()<CR>
inoremap <buffer> o <esc>hh:call SeekPackage()<CR>:call AddPackage()<CR>
nnoremap <buffer> <C-Right> :call SwitchRightFqnames()<CR>
nnoremap <buffer> <C-Left> :call SwitchLeftFqnames()<CR>

function JavaEnter()
	if !exists("g:classdic")
		call ScanClass()
	else
		call execute("syn keyword runningClass ".join(g:keyws," "))
		call execute("hi runningClass ctermfg=81 cterm=none")
	endif
endfunction

function ScanClass()
	if !exists("b:jtype")
		call JavaStamp()
	endif
	call job_start('python3 '.s:path.'/python/scan_class.py '.b:jtype.' '.b:jpath, {'callback': 'ScanClassHandler'})
endfunction

function ScanClassHandler(channel, msg)
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
	call execute("syn keyword runningClass ".join(g:keyws," "))
	call execute("hi runningClass ctermfg=81 cterm=none")
	echo "ScanClass Done."
endfunction


function PeekWord()
	normal bve"ay
	return @a
endfunction


function SeekPackage()
	let s:fqnames = split(g:classdic[PeekWord()],":")
	call add(s:fqnames,"######")
endfunction

function PlaceImport()
	let flag = 0
	let linemax = line(".")
	normal mj
	for ii in range(1,linemax)
		let line = getline(ii)
		if line =~ '^package.*'
			let flag = ii + 1
		elseif line =~ '^import.*'
			let flag = ii
		endif
	endfor
	call append(flag,"import ".s:fqnames[0].";")
	let s:curidx = 0
	call cursor(flag+1,1)
	let s:curlinenum = flag+1
	let s:curstarts = 7
	let s:curends = 7 + strlen(s:fqnames[0])
endfunction

function AddPackage()
	let line = getline(s:curlinenum)
	let tmp1 = strpart(line,0,s:curstarts)
	let tmp2 = strpart(line,s:curends)
	call setline(s:curlinenum,tmp1.s:fqnames[0].tmp2)
	let s:curends = s:curstarts + strlen(s:fqnames[0])
endfunction

function SwitchLeftFqnames()
	if s:curidx != 0
		let s:curidx -= 1
		let line = getline(s:curlinenum)
		let tmp1 = strpart(line,0,s:curstarts)
		let tmp2 = strpart(line,s:curends)
		call setline(s:curlinenum,tmp1.s:fqnames[s:curidx].tmp2)
		let s:curends = s:curstarts + strlen(s:fqnames[s:curidx])
	endif
endfunction

function SwitchRightFqnames()
	if s:curidx + 1 < len(s:fqnames)
		let s:curidx += 1
		let line = getline(s:curlinenum)
		let tmp1 = strpart(line,0,s:curstarts)
		let tmp2 = strpart(line,s:curends)
		call setline(s:curlinenum,tmp1.s:fqnames[s:curidx].tmp2)
		let s:curends = s:curstarts + strlen(s:fqnames[s:curidx])
	endif
endfunction
