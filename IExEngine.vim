
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



" =============================================================================

" 初始化
let s:bInitFlag = 0
function! s:init()
	if s:bInitFlag | return | endif
	let s:bInitFlag = 1
	
endfunction

" 查询
function! VimPinyin_IExEngine_Search(pattern)
	call s:init()
	
	return [ a:pattern ]
endfunction

" =============================================================================

