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
" InputContext
" =============================================================================
"{{{

let s:InputContext = {}
" 原始输入字符
let s:InputContext.in_chars = [ 'v', 'h', 'e', 'l', 'p', ]
" 当前光标位置
let s:InputContext.cursor_pos = 5

function s:InputContext.New() dict
	let obj = copy(self)
	call obj.Clear()
	return obj
endfunction

" 是否为输入字符
function s:InputContext.IsInputKey(keycode) dict
	if VimPinyin_Common_IsAlpha(a:keycode) | return 1 | endif
	if a:keycode == char2nr("'")| return 1 | endif
	return 0
endfunction

function s:InputContext.IsBackspaceKey(keycode) dict
	if VimPinyin_Common_IsBackspaceKey(a:keycode) | return 1 | endif
	return 0
endfunction
function s:InputContext.IsDeleteKey(keycode) dict
	if VimPinyin_Common_IsDeleteKey(a:keycode) | return 1 | endif
	return 0
endfunction
function s:InputContext.IsLeftKey(keycode) dict
	if VimPinyin_Common_IsLeftKey(a:keycode) | return 1 | endif
	return 0
endfunction
function s:InputContext.IsRightKey(keycode) dict
	if VimPinyin_Common_IsRightKey(a:keycode) | return 1 | endif
	return 0
endfunction

" 是否为空
function s:InputContext.IsEmpty() dict
	return len(self.in_chars) == 0
endfunction
" 当前字符数目
function s:InputContext.GetCharsNum() dict
	return len(self.in_chars)
endfunction
" 输入新的字符
function s:InputContext.PushChar(keycode) dict
	if !self.IsInputKey(a:keycode) | return 0 | endif
	if self.GetCharsNum() > 16 | return 0 | endif
	
	call insert(self.in_chars, nr2char(a:keycode), self.cursor_pos)
	call self.MoveCursorRight()
	
	return 1
endfunction
" 清空
function s:InputContext.Clear() dict
	let self.in_chars = []
	let self.cursor_pos = 0
	let n = self.GetCharsNum()
endfunction


" 获取光标左边输入的原始字符
function s:InputContext.GetCursorLeftInput() dict
	if self.GetCharsNum() <= 0 | return "" | endif
	if self.cursor_pos > 0
		let list = self.in_chars[0:self.cursor_pos-1]
		return join(list, "")
	else
		return ""
	endif
	
endfunction
" 获取光标右边输入的原始字符
function s:InputContext.GetCursorRightInput() dict
	if self.GetCharsNum() <= 0 | return "" | endif
	if self.cursor_pos < self.GetCharsNum()
		let list = self.in_chars[self.cursor_pos:]
		return join(list, "")
	else
		return ""
	endif
endfunction
" 获取输入的单词
function s:InputContext.GetInputWord() dict
	if self.GetCharsNum() <= 0 | return "" | endif
	let list = self.in_chars[0:]
	return join(list, "")
endfunction
" 光标位置
function s:InputContext.GetCursorPos() dict
	return self.cursor_pos
endfunction


" 左右移动光标
function s:InputContext.MoveCursorLeft() dict
	let self.cursor_pos = self.cursor_pos-1
	call self.AdjustCursorPos()
endfunction
function s:InputContext.MoveCursorRight() dict
	let self.cursor_pos = self.cursor_pos+1
	call self.AdjustCursorPos()
endfunction


" 删除字符
function s:InputContext.RemoveCursorLeftChar() dict
	if self.GetCharsNum() == 1
		call remove(self.in_chars, self.cursor_pos-1)
		let self.cursor_pos = 0
		"call self.MoveCursorLeft()
	elseif self.GetCharsNum() > 1
		if self.cursor_pos > 1
			call remove(self.in_chars, self.cursor_pos-1)
			call self.MoveCursorLeft()
		endif
	endif
	let n = self.GetCharsNum()
endfunction
function s:InputContext.RemoveCursorRightChar() dict
	if self.GetCharsNum() > 0
		if self.cursor_pos < len(self.in_chars)
			call remove(self.in_chars, self.cursor_pos)
		endif
	endif
endfunction

" 调整光标位置到合适值
function s:InputContext.AdjustCursorPos() dict
	if self.GetCharsNum() > 0
		if self.cursor_pos < 0
			let self.cursor_pos = len(self.in_chars)
		endif
		if self.cursor_pos > len(self.in_chars)
			let self.cursor_pos = 0
		endif
	else
		let self.cursor_pos = 0
	endif
endfunction


"}}}
" =============================================================================
" OutputContext
" =============================================================================
"{{{

let s:OutputContext = {}

" 输入字符串
let s:OutputContext.in_chars = ""
" 输出列表
let s:OutputContext.out_list = [ "he", "hello", ]

" 总页码
let s:OutputContext.page_num = 1
" 当前页码
let s:OutputContext.page_pos = 0
" 当前光标位置
let s:OutputContext.cursor_pos = 0
" 当前页单词
let s:OutputContext.words_list = []

" 每页候选字最大数目
let s:OutputContext.pageSize = 5
" 屏幕宽度
let s:OutputContext.outputBarWidth = 80

" 构造函数
function s:OutputContext.New() dict
	let obj = copy(self)
	call obj.Clear()
	return obj
endfunction


" 是否为选择键
function s:OutputContext.IsSelectKey(keycode) dict
	if VimPinyin_Common_IsEnterKey(a:keycode) | return 1 | endif
	if VimPinyin_Common_IsSpace(a:keycode) | return 1 | endif
	if VimPinyin_Common_IsDigit(a:keycode)
		let idx = a:keycode - char2nr('1')
		if idx >= 0 && idx < len(self.words_list)
			return 1
		endif
	endif
	if a:keycode == char2nr(';')
		let idx = self.cursor_pos + 1
		if idx >= 0 && idx < len(self.words_list)
			return 1
		endif
	endif

	return 0
endfunction
function s:OutputContext.IsUpKey(keycode) dict
	if VimPinyin_Common_IsUpKey(a:keycode) | return 1 | endif
	return 0
endfunction
function s:OutputContext.IsDownKey(keycode) dict
	if VimPinyin_Common_IsDownKey(a:keycode) | return 1 | endif
	return 0
endfunction
function s:OutputContext.IsPageUpKey(keycode) dict
	if VimPinyin_Common_IsPageUpKey(a:keycode) | return 1 | endif
	return 0
endfunction
function s:OutputContext.IsPageDownKey(keycode) dict
	if VimPinyin_Common_IsPageDownKey(a:keycode) | return 1 | endif
	return 0
endfunction

" 设置结果
function s:OutputContext.SetList(in_chars, out_list) dict
	if !VimPinyin_Common_IsStringType(a:in_chars) | return 0 | endif
	if !VimPinyin_Common_IsListType(a:out_list) | return 0 | endif
	
	let self.in_chars = a:in_chars
	let self.out_list = a:out_list
	
	let self.page_num = floor((len(a:out_list)+self.pageSize-1)/self.pageSize)
	let self.page_pos = 0
	let self.cursor_pos = 0
	let self.words_list = []
	
	for i in range(len(a:out_list))
		call add(self.words_list, a:out_list[i])
		if len(self.words_list) >= self.pageSize | break | endif
	endfor
	return 1
endfunction
function s:OutputContext.SelectByKey(keycode) dict
	if VimPinyin_Common_IsEnterKey(a:keycode)
		return self.in_chars
	endif
	if VimPinyin_Common_IsSpace(a:keycode)
		return self.words_list[self.cursor_pos]
	endif
	if VimPinyin_Common_IsDigit(a:keycode)
		let idx = a:keycode - char2nr('1')
		if idx >= 0 && idx < len(self.words_list)
			return self.words_list[idx]
		endif
	endif
	if a:keycode == char2nr(';')
		let idx = self.cursor_pos + 1
		if idx >= 0 && idx < len(self.words_list)
			return self.words_list[idx]
		endif
	endif
	return ""
endfunction
function s:OutputContext.Clear() dict
	let self.in_chars = ""
	let self.out_list = []
	
	let self.page_num = 1
	let self.page_pos = 0
	let self.cursor_pos = 0
	let self.words_list = []

	let self.outputBarWidth = g:VimPinyin_vimColumns
endfunction

" 选择操作
function s:OutputContext.GetWordList() dict
	return self.words_list
endfunction
function s:OutputContext.GetCursorPos() dict
	return self.cursor_pos
endfunction

function s:OutputContext.MovePageUp() dict
	let pos = self.page_pos-1
	if pos < 0 | let pos = 0 | endif
	
	if pos != self.page_pos
		let self.page_pos = pos
		let self.cursor_pos = 0
		let self.words_list = []
		
		let iStart = self.page_pos * self.pageSize
		let iEnd = iStart + self.pageSize
		let self.words_list = self.out_list[iStart : iEnd]
	endif
endfunction
function s:OutputContext.MovePageDown() dict
	let pos = self.page_pos+1
	if pos >= self.page_num | let pos = self.page_num-1 | endif
	
	if pos != self.page_pos
		let self.page_pos = pos
		let self.cursor_pos = 0
		let self.words_list = []
		
		let iStart = self.page_pos * self.pageSize
		let iEnd = iStart + self.pageSize
		let self.words_list = self.out_list[iStart : iEnd]
	endif
endfunction

function s:OutputContext.MoveCursorUp() dict
	let self.cursor_pos = self.cursor_pos-1
	if self.cursor_pos < 0
		let self.cursor_pos = len(self.words_list)-1
	endif
endfunction
function s:OutputContext.MoveCursorDown() dict
	let self.cursor_pos = self.cursor_pos+1
	if self.cursor_pos >= len(self.words_list)
		let self.cursor_pos = 0
	endif
endfunction


"}}}
" =============================================================================
"{{{

function! VimPinyin_PyEditer_MakeQuery(inCtx, outCtx)
	let chars = a:inCtx.GetInputWord()
	let list = VimPinyin_PyEngine_Search(chars)
	if VimPinyin_Common_IsStringType(chars) && strlen(chars) > 0
		call a:outCtx.SetList(chars, list)
	else
		call a:outCtx.SetList("", [])
	endif
endfunction

" 显示输入栏
function! VimPinyin_PyEditer_ShowEnInputBar(inCtx, outCtx)

	let in_text = a:inCtx.GetCursorLeftInput()
	let in_chars = a:inCtx.GetCursorRightInput()
	let out_list = a:outCtx.GetWordList()
	let cursor_pos = a:outCtx.GetCursorPos()

	call VimPinyin_Common_ClearCommandBar()
	
	"------------------------------------------------------
	" [英文] vhe|l >> 1.[hel] 2.help 3.held 4.helpful 5.hello
	
	execute 'echohl Title | echon "["'
	execute 'echohl Title | echon "拼音"'
	execute 'echohl Title | echon "] "'
	
	" debug
	"let in_cursor_pos = a:inCtx.GetCursorPos()
	"execute 'echohl None | echon "' . in_cursor_pos . ' "'
	"let num = a:inCtx.GetCharsNum()
	"execute 'echohl None | echon "-' . num . ' "'
	
	if strlen(in_text) > 0
		execute 'echohl None | echon "' . in_text . '"'
	endif
	execute 'echohl LineNr | echon "|"'
	if strlen(in_chars) > 0 
		execute 'echohl None | echon "' . in_chars . '"'
	endif
	
	execute 'echohl MoreMsg | echon " >> "'
	
	for i in range(len(out_list))
		" 超出最大宽度
		if getcmdpos() >= (g:VimPinyin_vimColumns-20)
			execute 'echohl None | echon " ..."'
			break
		endif
	
		if i == cursor_pos
			execute 'echohl LineNr | echon "' . (i+1) . '."'
			execute 'echohl None | echon "["'
			execute 'echohl Label | echon "' . out_list[i] . '"'
			execute 'echohl None | echon "] "'
		else
			execute 'echohl LineNr | echon "' . (i+1) . '."'
			execute 'echohl None | echon "' . out_list[i] . ' "'
		endif
	endfor
	echohl None
	return 1
endfunction


"}}}
" =============================================================================
"{{{

" 处理输入
function! VimPinyin_PyEditer_ProcessInput(keycode_)
	let keycode = a:keycode_
	let inCtx  = s:InputContext.New()
	let outCtx = s:OutputContext.New()
	
	while 1
	
		"--------------------------------------------------
		" 处理退出控制键
		
		if VimPinyin_Common_IsEscKey(keycode)
			return VimPinyin_Common_ReturnNone()
		endif
		if VimPinyin_Common_IsUnknowKey(keycode)
			return VimPinyin_Common_ReturnNone()
		endif
		
		"--------------------------------------------------
		" 处理输入相关
		
		let bInputChanged = 0
		
		" 输入
		if inCtx.IsInputKey(keycode)
			call inCtx.PushChar(keycode)
			let bInputChanged = 1
			
		elseif inCtx.IsBackspaceKey(keycode)
			call inCtx.RemoveCursorLeftChar()
			let bInputChanged = 1
		elseif inCtx.IsDeleteKey(keycode)
			call inCtx.RemoveCursorRightChar()
			let bInputChanged = 1
			
		elseif inCtx.IsLeftKey(keycode)
			call inCtx.MoveCursorLeft()
		elseif inCtx.IsRightKey(keycode)
			call inCtx.MoveCursorRight()
		endif
		
		" 根据输入更新输出
		if  bInputChanged
			if inCtx.IsEmpty()
				return VimPinyin_Common_ReturnNone()
			endif
			let v = VimPinyin_PyEditer_MakeQuery(inCtx, outCtx)
		endif
		
		"--------------------------------------------------
		" 处理结果查看键
		
		" 切换后选字
		if outCtx.IsUpKey(keycode)
			call outCtx.MoveCursorUp()
		elseif outCtx.IsDownKey(keycode)
			call outCtx.MoveCursorDown()
		
		" 翻页
		elseif outCtx.IsPageUpKey(keycode)
			call outCtx.MovePageUp()
		elseif outCtx.IsPageDownKey(keycode)
			call outCtx.MovePageDown()
		endif
		
		"--------------------------------------------------
		" 处理结果输出键
		
		if outCtx.IsSelectKey(keycode)
			return outCtx.SelectByKey(keycode)
		endif
		
		"--------------------------------------------------
		
		" 显示输入面板
		call VimPinyin_PyEditer_ShowEnInputBar(inCtx, outCtx)
		" 获取新的字符
		let keycode = getchar()
		
		"--------------------------------------------------
	endwhile
endfunction

" 清空状态
function! VimPinyin_PyEditer_Reset()
endfunction


"}}}
" =============================================================================
"{{{1 vim: foldmethod=marker:


