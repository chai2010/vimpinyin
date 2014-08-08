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
"{{{

" 全角数字
let s:zhDigit = [
	\'０', '１', '２', '３', '４', '５', '６', '７', '８', '９',
	\]
" 全角字母
let s:zhAlphaLower = [
	\'ａ', 'ｂ', 'ｃ', 'ｄ', 'ｅ', 'ｆ', 'ｇ',
	\'ｈ', 'ｉ', 'ｊ', 'ｋ', 'ｌ', 'ｍ', 'ｎ',
	\'ｏ', 'ｐ', 'ｑ', 'ｒ', 'ｓ', 'ｔ',
	\'ｕ', 'ｖ', 'ｗ', 'ｘ', 'ｙ', 'ｚ',
	\]
let s:zhAlphaUpper = [
	\'Ａ', 'Ｂ', 'Ｃ', 'Ｄ', 'Ｅ', 'Ｆ', 'Ｇ',
	\'Ｈ', 'Ｉ', 'Ｊ', 'Ｋ', 'Ｌ', 'Ｍ', 'Ｎ',
	\'Ｏ', 'Ｐ', 'Ｑ', 'Ｒ', 'Ｓ', 'Ｔ',
	\'Ｕ', 'Ｖ', 'Ｗ', 'Ｘ', 'Ｙ', 'Ｚ',
	\]

" 英文标点
let s:enPunctList = [
	\'`', '~',
	\'!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
	\'-', '_', '=', '+',
	\'[', '{', ']', '}', '\', '|',
	\';', ':', "'", '"',
	\',', '<', '.', '>', '/', '?',
	\' ',
	\]
" 中文标点(全角)
let s:zhPunctList = [
	\'·', '～',
	\'！', '@', '#', '￥', '%', '……', '&', '*', '（', '）',
	\'-', '——', '=', '+',
	\'【', '『', '】', '』', '、', '|',
	\'；', '：', '‘', '“',
	\'，', '《', '。', '》', '/', '？',
	\'　',
	\]


"}}}
" =============================================================================
"{{{

" 单双引号匹配
let s:cntSingleQuotation = 0
let s:cntDoubleQuotation = 0

" 处理可打印字符
" 字母/数字/标点/空格/tab
function! VimPinyin_PunctEngine_ProcessInput(keycode)
	" 数字
	if VimPinyin_Common_IsDigit(a:keycode)
		if g:VimPinyin_modeFull
			return s:zhDigit[a:keycode-char2nr('0')]
		else
			return nr2char(a:keycode)
		end
	endif
	" 字母
	if VimPinyin_Common_IsLower(a:keycode)
		if g:VimPinyin_modeFull
			return s:zhAlphaLower[a:keycode-char2nr('a')]
		else
			return nr2char(a:keycode)
		end
	endif
	if VimPinyin_Common_IsUpper(a:keycode)
		if g:VimPinyin_modeFull
			return s:zhAlphaLower[a:keycode-char2nr('A')]
		else
			return nr2char(a:keycode)
		end
	endif
	
	for i in range(len(s:enPunctList))
		if a:keycode == char2nr(s:enPunctList[i])
			if g:VimPinyin_modeFull || g:VimPinyin_modeFullPunct
				if a:keycode == char2nr("'")
					let cnt = s:cntSingleQuotation
					let s:cntSingleQuotation = s:cntSingleQuotation+1
					return (cnt%2 == 0)? '‘': '’'
				elseif a:keycode == char2nr('"')
					let cnt = s:cntDoubleQuotation
					let s:cntDoubleQuotation = s:cntDoubleQuotation+1
					return (cnt%2 == 0)? '“': '”'
				else
					return s:zhPunctList[i]
				endif
			else
				return s:enPunctList[i]
			endif
		endif
	endfor
	
	return "punct: " . a:keycode
endfunction

" 重置状态
function! VimPinyin_PunctEngine_Reset()
	let s:cntSingleQuotation = 0
	let s:cntDoubleQuotation = 0
endfunction

"}}}
" =============================================================================
"{{{1 vim: foldmethod=marker:

