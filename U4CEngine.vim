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
let s:mbfile = expand("<sfile>:p:h") . "/data/vimim.4corner.txt"

" 四角号码表
let s:im4c_table = []
" 通配符用的查找表
let s:im4c_table_ext = {}
" 汉字拼音表
let s:pinyin_table = {}

" 加载
function! VimPinyin_U4CEngine_LoadData(filename)
	if !filereadable(a:filename) | return 0 | endif
	
	for i in range(9999+1)
		call add(s:im4c_table, [])
	endfor
	
	for line in readfile(a:filename, '', 50000)
		let list = split(line)
		if len(list) < 2 | continue | endif
		if strlen(list[0]) == 4
			let key = remove(list, 0)
			let chs = split(key, '\zs')
			let id = str2nr(key)
			let s:im4c_table[id] += list
			
			let ext_keys = [
				\ "?"   . chs[1] . chs[2] . chs[3],
				\chs[0] .  "?"   . chs[2] . chs[3],
				\chs[0] . chs[1] .  "?"   . chs[3],
				\chs[0] . chs[1] . chs[2] .  "?"  ,
				\ "?"   .  "?"   . chs[2] . chs[3],
				\ "?"   . chs[1] .  "?"   . chs[3],
				\ "?"   . chs[1] . chs[2] .  "?"  ,
				\chs[0] .  "?"   .  "?"   . chs[3],
				\chs[0] .  "?"   . chs[2] .  "?"  ,
				\chs[0] . chs[1] .  "?"   .  "?"  ,
				\]
			for ext_k in ext_keys
				if has_key(s:im4c_table_ext, ext_k)
					let s:im4c_table_ext[ext_k] += list
				else
					let s:im4c_table_ext[ext_k] = list
				endif
			endfor
		endif
	endfor
	return 1
endfunction

" =============================================================================

" return [id, key, show_info]
function! s:readArgs(args)
	let id = -1
	let key = ""
	let show_info = 0
	
	if !VimPinyin_Common_IsStringType(a:args)
		return [ id, key, show_info ]
	endif
	
	let chs = split(a:args, '\zs')
	if len(chs) < 2 || len(chs) > 5
		return [ id, key, show_info ]
	endif
	
	let is_num = 1
	let temp_key = ""
	for i in range(4)
		if i >= len(chs) | break | endif
		if !VimPinyin_Common_IsDigit(char2nr(chs[i]))
			if chs[i] != '?' 
				return [ id, key, show_info ] 
			endif
			let is_num = 0
		endif
		let temp_key = temp_key . chs[i]
	endfor
	if len(chs) < 4
		let is_num = 0
		while 1
			if strlen(temp_key) >= 4 
				break
			endif
			let temp_key = temp_key . "?"
		endwhile
	endif
	let key = temp_key
	
	if len(chs) == 5
		if chs[4] != '?' 
			return [ id, key, show_info ] 
		endif
		let show_info = 1
	endif
	
	if is_num
		let id = str2nr(temp_key)
	endif
	return [ id, key, show_info ]
endfunction

" =============================================================================

" 初始化
let s:bInitFlag = 0
function! s:init()
	if !s:bInitFlag
		let s:bInitFlag = 1
		
		if VimPinyin_U4CEngine_LoadData(s:mbfile)
			return
		else
			" error
		endif
	endif
endfunction

" 查询
function! VimPinyin_U4CEngine_Search(pattern)
	call s:init()
	
	let [ id, key, show_info ] = s:readArgs(a:pattern)
	"return [ id, key, show_info, a:pattern ]
	
	if id >= 0
		return s:im4c_table[id]
	else
		if has_key(s:im4c_table_ext, key)
			return s:im4c_table_ext[key]
		endif
	endif
	
	return [a:pattern ]
endfunction

" =============================================================================

