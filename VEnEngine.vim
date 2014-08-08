" =============================================================================
"
" VimPinyin —— Vim 拼音输入法
"
" 作者: ChaiShushan<chaishushan@gmail.com>
" 版权: BSD
" 
" =============================================================================

" UTF8无BOM编码
scriptencoding utf-8

" =============================================================================

" 码表文件
let s:mbfile = expand("<sfile>:p:h") . "/data/en.top850.txt"

" 码表
let s:words_table = {}
let s:words_flag = {}


" 加载
function! VimPinyin_VEnEngine_LoadData(filename)
	if !filereadable(a:filename) | return 0 | endif
	
	for line in readfile(a:filename, '', 50000)
		if !VimPinyin_Common_IsLower(char2nr(line))
			continue
		endif
		let list = split(line)
		if len(list) >= 0
			let wd = list[0]
			let s:words_flag[wd] = 1
			
			let chs = split(wd, '\zs')
			
			if len(chs) >= 1
				let key = chs[0]
				if has_key(s:words_table, key)
					let s:words_table[key] += list
				else
					let s:words_table[key] = list
				endif
			endif
			if len(chs) >= 2
				let key = chs[0] . chs[1]
				if has_key(s:words_table, key)
					let s:words_table[key] += list
				else
					let s:words_table[key] = list
				endif
			endif
			if len(chs) >= 3
				let key = chs[0] . chs[1] . chs[2]
				if has_key(s:words_table, key)
					let s:words_table[key] += list
				else
					let s:words_table[key] = list
				endif
			endif
		endif
	endfor
	return 1
endfunction

" =============================================================================

" 初始化
let s:bInitFlag = 0
function! s:init()
	if s:bInitFlag | return | endif
	let s:bInitFlag = 1
	
	if VimPinyin_VEnEngine_LoadData(s:mbfile)
		"
	else
		" error
	endif
endfunction

" 查询
function! VimPinyin_VEnEngine_Search(pattern)
	call s:init()
	
	if !empty(s:words_table)
		let rv = [ a:pattern ]
		if VimPinyin_Common_IsStringType(a:pattern)
			let chs = split(a:pattern, '\zs')
			let key = "_"
			if len(chs) >= 3
				let key = chs[0] . chs[1] . chs[2]
			elseif len(chs) >= 2
				let key = chs[0] . chs[1]
			elseif len(chs) >= 1
				let key = chs[0]
			endif
			if has_key(s:words_table, key)
				let rv += s:words_table[key]
			endif
		endif
		return rv
	endif
	
	return [ a:pattern ]
endfunction

" =============================================================================

