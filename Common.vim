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
" 变量类型
" =============================================================================
" {{{

function! VimPinyin_Common_IsIntType(var)
	return type(a:var) == type(0)
endfunction
function! VimPinyin_Common_IsFloatType(var)
	return type(a:var) == type(0.0)
endfunction
function! VimPinyin_Common_IsStringType(var)
	return type(a:var) == type("")
endfunction
function! VimPinyin_Common_IsListType(var)
	return type(a:var) == type([])
endfunction
function! VimPinyin_Common_IsDictType(var)
	return type(a:var) == type({})
endfunction
function! VimPinyin_Common_IsFuncType(var)
	return type(a:var) == type(function("tr"))
endfunction

"}}}
" =============================================================================
" 普通字符类型
" =============================================================================
"{{{

function! VimPinyin_Common_IsSpace(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == char2nr(' ')
endfunction
function! VimPinyin_Common_IsDigit(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode >= char2nr('0') && a:keycode <= char2nr('9')
endfunction
function! VimPinyin_Common_IsLower(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode >= char2nr('a') && a:keycode <= char2nr('z')
endfunction
function! VimPinyin_Common_IsUpper(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode >= char2nr('A') && a:keycode <= char2nr('Z')
endfunction
function! VimPinyin_Common_IsAlpha(keycode)
	if VimPinyin_Common_IsLower(a:keycode)
		return 1
	endif
	if VimPinyin_Common_IsUpper(a:keycode)
		return 1
	endif
	return 0
endfunction
function! VimPinyin_Common_IsPunct(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	" [! - /] -> [ 32 -  47]
	" [: - @] -> [ 58 -  64]
	" [\[- `] -> [ 91 -  96]
	" [{ - ~] -> [123 - 126]
	if a:keycode >= char2nr('!') && a:keycode <= char2nr('/')
		return 1
	endif
	if a:keycode >= char2nr(':') && a:keycode <= char2nr('@')
		return 1
	endif
	if a:keycode >= char2nr('[') && a:keycode <= char2nr('`')
		return 1
	endif
	if a:keycode >= char2nr('{') && a:keycode <= char2nr('~')
		return 1
	endif
	return 0
endfunction
function! VimPinyin_Common_IsGraph(keycode)
	if VimPinyin_Common_IsDigit(a:keycode)
		return 1
	endif
	if VimPinyin_Common_IsAlpha(a:keycode)
		return 1
	endif
	if VimPinyin_Common_IsPunct(a:keycode)
		return 1
	endif
	return 0
endfunction
function! VimPinyin_Common_IsPrint(keycode)
	if VimPinyin_Common_IsGraph(a:keycode)
		return 1
	endif
	if VimPinyin_Common_IsSpace(a:keycode)
		return 1
	endif
	return 0
endfunction

"}}}
" =============================================================================
" 控制字符类型
" =============================================================================
"{{{

" <C-\>
function! VimPinyin_Common_IsSwitchKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == 28
endfunction
" <C-^>
function! VimPinyin_Common_IsSettingKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == 30
endfunction
function! VimPinyin_Common_IsEscKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == 27
endfunction

" ???
function! VimPinyin_Common_IsEnterKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == 13
endfunction
function! VimPinyin_Common_IsCandidateKey(keycode)
	return a:keycode == char2nr(';')
endfunction

function! VimPinyin_Common_IsBackspaceKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<BS>")
endfunction
function! VimPinyin_Common_IsDeleteKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<Del>")
endfunction

function! VimPinyin_Common_IsPageUpKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<PageUp>")
endfunction
function! VimPinyin_Common_IsPageDownKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<PageDown>")
endfunction

function! VimPinyin_Common_IsLeftKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<Left>")
endfunction
function! VimPinyin_Common_IsRightKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<Right>")
endfunction
function! VimPinyin_Common_IsUpKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<Up>")
endfunction
function! VimPinyin_Common_IsDownKey(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode)
		return 0
	endif
	return a:keycode == expand("\<Down>")
endfunction

" =============================================================================

" 鼠标键
" [v:mouse_win, v:mouse_lnum, v:mouse_col]
function! VimPinyin_Common_IsLeftMouse(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode) | return 0 | endif
	return a:keycode == "\<LeftMouse>" && v:mouse_win > 0
endfunction
function! VimPinyin_Common_IsRightMouse(keycode)
	if !VimPinyin_Common_IsStringType(a:keycode) | return 0 | endif
	return a:keycode == "\<RightMouse>" && v:mouse_win > 0
endfunction

" =============================================================================

function! VimPinyin_Common_IsUnknowKey(keycode)
	if VimPinyin_Common_IsPrint(a:keycode)
		return 0
	endif
	
	if VimPinyin_Common_IsEnterKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsBackspaceKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsDeleteKey(a:keycode)
		return 0
	endif


	if VimPinyin_Common_IsPageUpKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsPageDownKey(a:keycode)
		return 0
	endif
	
	if VimPinyin_Common_IsLeftKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsRightKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsUpKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsDownKey(a:keycode)
		return 0
	endif
	
	if VimPinyin_Common_IsEscKey(a:keycode)
		return 0
	endif

	return 1
endfunction

"}}}
" =============================================================================
" 字符对应输入模式
" =============================================================================
"{{{

function! VimPinyin_Common_IsPinyinModeKey(keycode)
	if !VimPinyin_Common_IsAlpha(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsIExModeKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsU4CModeKey(a:keycode)
		return 0
	endif
	if VimPinyin_Common_IsVEnModeKey(a:keycode)
		return 0
	endif
	return 1
endfunction
function! VimPinyin_Common_IsIExModeKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == char2nr('i')
endfunction
function! VimPinyin_Common_IsU4CModeKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == char2nr('u')
endfunction
function! VimPinyin_Common_IsVEnModeKey(keycode)
	if !VimPinyin_Common_IsIntType(a:keycode)
		return 0
	endif
	return a:keycode == char2nr('v')
endfunction

"}}}
" =============================================================================
" 显示相关
" =============================================================================
"{{{

" 清空命令行
function! VimPinyin_Common_ClearCommandBar()
	echo ''
    if mode() !~ '[in]'
		let cmdtype = getcmdtype()
        if cmdtype != '@'
            let prepre = cmdtype . getcmdline() . "\n"
			execute 'echo | echon "' . prepre . '"'
        endif
    endif
endfunction

" 返回空字符串
function! VimPinyin_Common_ReturnNone()
	redrawstatus!
	return ""
endfunction

"}}}
" =============================================================================
"{{{1 vim: foldmethod=marker:

