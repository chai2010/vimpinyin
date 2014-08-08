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

" 始终显示状态栏(否则拼音会显示不正常)
set laststatus=2

" 脚本文件对应目录
let g:VimPinyin_root = expand("<sfile>:p:h")

" =============================================================================
" 配置信息
" =============================================================================
"{{{

function! VimPinyin_InitConfig()
	"--------------------------------------------------------------
	" 基本选项

	" 0 = 英文/1 = 中文
	if !exists('g:VimPinyin_modeChinese') 
		let g:VimPinyin_modeChinese = 0
	endif

	" 0 = 全拼/1 = 双拼
	if !exists('g:VimPinyin_modePinyinFull') 
		let g:VimPinyin_modePinyinFull = 0
	endif

	" 0 = 无  /1 = 用z/c/s代表zh/ch/sh
	if !exists('g:VimPinyin_modePinyinZCS') 
		let g:VimPinyin_modePinyinZCS = 0
	endif

	" 0 = 半角/1 = 全角
	if !exists('g:VimPinyin_modeFull') 
		let g:VimPinyin_modeFull = 0
	endif

	" 0 = 英文标点/1 = 中文标点
	if !exists('g:VimPinyin_modeFullPunct') 
		let g:VimPinyin_modeFullPunct = 0
	endif

	" 0 = 简体/1 = 繁体
	if !exists('g:VimPinyin_modeSimp') 
		let g:VimPinyin_modeSimp = 1
	endif

	" 每页最多候选字数, [3-9]个
	if !exists('g:VimPinyin_pageSize') 
		let g:VimPinyin_pageSize = 5
	endif


	"--------------------------------------------------------------
	" 英文助手

	" 开启自动建议
	" 0 = 关闭
	" 1 = 开启
	if !exists('g:VimPinyin_enSuggestEnabled') 
		let g:VimPinyin_enSuggestEnabled = 0
	endif

	" 第几个字母开始建议, 取值[3,9]
	if !exists('g:VimPinyin_enSuggestChars') 
		let g:VimPinyin_enSuggestChars = 3
	endif


	"--------------------------------------------------------------
	" 按键

	" 中英文切换
	" 0 = 关闭
	" 1 = shift切换
	if !exists('g:VimPinyin_zhEnSelectKey') 
		let g:VimPinyin_zhEnSelectKey = 0
	endif

	" 繁体/简体转换
	" 0 = 关闭
	" 1 = 切换?
	if !exists('g:VimPinyin_simpTradSelectKey') 
		let g:VimPinyin_simpTradSelectKey = 0
	endif

	" 翻页键
	" 0 = 关闭
	" 1 = -=翻页
	" 2 = ,.翻页
	" 3 = -=/,.翻页
	if !exists('g:VimPinyin_pageUpDownKeys') 
		let g:VimPinyin_pageUpDownKeys = 1
	endif

	" 二三候选键
	" 0 = 关闭
	" 1 = ;'二三候选
	if !exists('g:VimPinyin_candidateKeys') 
		let g:VimPinyin_candidateKeys = 0
	endif


	"--------------------------------------------------------------
	" 字典

	" 自动记录自造词并记录词频
	" 0 = 关闭
	" 1 = 开启
	if !exists('g:VimPinyin_saveUnknowWords') 
		let g:VimPinyin_saveUnknowWords = 0
	endif

	" 使用自定义词语
	" 0 = 关闭
	" 1 = 开启
	if !exists('g:VimPinyin_userDefinedWordsEnabled') 
		let g:VimPinyin_userDefinedWordsEnabled = 0
	endif


	"--------------------------------------------------------------
	" 扩展

	" 启用扩展模式
	" 0 = 关闭
	" 1 = 开启
	if !exists('g:VimPinyin_extEnabled') 
		let g:VimPinyin_extEnabled = 1
	endif

	" 扩展列表
	if !exists('g:VimPinyin_extList') 
		let g:VimPinyin_extList = ["base.lua","im4corner.lua",]
	endif


	"--------------------------------------------------------------
	" 自动同步(暂不支持)

	" 密码(加密密码/登录口令)
	" Dropbox(被墙)


	"--------------------------------------------------------------
	" 内部使用

	" 屏幕列数(最大80列)
	let g:VimPinyin_vimColumns = &columns
	if g:VimPinyin_vimColumns > 80
		let g:VimPinyin_vimColumns = 80
	endif

	"--------------------------------------------------------------
endfunction

"}}}
" =============================================================================
" 从文件加载配置
" =============================================================================
"{{{

" 临时文件名(保存配置状态)
let s:_configFile = g:VimPinyin_root . "/data/tmp/VimPinyin.conf"

" 加载
function! VimPinyin_LoadConfig()
	if !filereadable(s:_configFile) | return 0 | endif
	
	for line in readfile(s:_configFile, '', 50)
		let list = split(line)
		if len(list) != 2 | continue | endif
		
		if list[0] == "modeFull"
			let g:VimPinyin_modeFull = (list[1] == "true")? 1: 0
		elseif  list[0] == "modeSimp"
			let g:VimPinyin_modeSimp = (list[1] == "true")? 1: 0
		elseif  list[0] == "modeFullPunct"
			let g:VimPinyin_modeFullPunct = (list[1] == "true")? 1: 0
		endif
	endfor
	return 1
endfunction

" 保存
function! VimPinyin_SaveConfig()
	let list = [
		\"modeFull       " . (g:VimPinyin_modeFull? "true": "false"),
		\"modeSimp       " . (g:VimPinyin_modeSimp? "true": "false"),
		\"modeFullPunct  " . (g:VimPinyin_modeFullPunct? "true": "false"),
		\]
	call writefile(list, s:_configFile)
endfunction

"}}}
" =============================================================================
" 初始化输入法
" =============================================================================
"{{{

" 输入法开关
noremap! <silent> <C-\> <C-R>=VimPinyin_ToggleIME()<CR><C-^>
noremap! <silent> <C-^> <C-R>=VimPinyin_Settings()<CR>

" 初始化
let s:bInitFlag = 0
function! s:init()
	if s:bInitFlag | return | endif
	let s:bInitFlag = 1
	
	" 初始化配置
	call VimPinyin_InitConfig()

	" 从文件加载配置
	if !VimPinyin_LoadConfig()
		call VimPinyin_SaveConfig()
	endif
endfunction

" 切换开关
function! VimPinyin_ToggleIME()
	call s:init()
	
	" 初始化键盘映射
	call VimPinyin_MapAllKeys()

	call VimPinyin_Reset()

	redraw!
	redrawstatus!
	return ""
endfunction

" 配置选项
function! VimPinyin_Settings()
	call s:init()
	
	call VimPinyin_Reset()
	call VimPinyin_ConfigEditer_ProcessInput()
	redrawstatus!
	return ""
endfunction

" lmap映射表达式
function! VimPinyin_KeyFilter(key)
	call s:init()
	
	let keycode = char2nr(a:key)
	let rv = ""
	
	if VimPinyin_Common_IsPinyinModeKey(keycode)
		let rv = VimPinyin_PyEditer_ProcessInput(keycode)
	elseif VimPinyin_Common_IsIExModeKey(keycode)
		let rv = VimPinyin_IExEditer_ProcessInput(keycode)
	elseif VimPinyin_Common_IsU4CModeKey(keycode)
		let rv = VimPinyin_U4CEditer_ProcessInput(keycode)
	elseif VimPinyin_Common_IsVEnModeKey(keycode)
		let rv = VimPinyin_VEnEditer_ProcessInput(keycode)
	elseif VimPinyin_Common_IsPrint(keycode)
		let rv = VimPinyin_PunctEngine_ProcessInput(keycode)
	end
	
	redrawstatus!
	return rv
endfunction

" 状态重置
function! VimPinyin_Reset()
	call s:init()
	
	call VimPinyin_PyEditer_Reset()
	call VimPinyin_PunctEngine_Reset()
	
	call VimPinyin_IExEditer_Reset()
	call VimPinyin_U4CEditer_Reset()
	call VimPinyin_VEnEditer_Reset()
endfunction

" 映射键盘
function! VimPinyin_MapAllKeys()
	call s:init()

	" 空格
	lnoremap <buffer> <expr> <Space> VimPinyin_KeyFilter(" ")
	" [0-9]
	for key in sort(split("0123456789", '\zs'))
		execute 'lnoremap <buffer> <expr> ' . key . '  VimPinyin_KeyFilter("' . key . '")'
	endfor
	" [a-z]
	for key in sort(split("abcdefghijklmnopqrstuvwxyz", '\zs'))
		execute 'lnoremap <buffer> <expr> ' . key . '  VimPinyin_KeyFilter("' . key . '")'
	endfor
	" 标点
	let punctList = [ '`', '~', 
		\'!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
		\'-', '_', '=', '+',
		\'[', '{', ']', '}', '\', '|',
		\';', ':', "'", '"',
		\',', '<', '.', '>', '/', '?',
		\]
	for key in punctList
		if key == "'"
			lnoremap <buffer> <expr>  '  VimPinyin_KeyFilter("'")
		elseif key == '"'
			lnoremap <buffer> <expr>  "  VimPinyin_KeyFilter('"')
		elseif key == '\'
			lnoremap <buffer> <expr>  \  VimPinyin_KeyFilter('\')
		elseif key == '|'
			lnoremap <buffer> <expr> \|  VimPinyin_KeyFilter("\|")
		else
			execute 'lnoremap <buffer> <expr> ' . key . '  VimPinyin_KeyFilter("' . key . '")'
		endif
	endfor
	
endfunction


" =============================================================================
" =============================================================================

function! VimPinyin_OnVimResized()
	"iaaa<Esc>
	redrawstatus!
	echo "VimPinyin_OnVimResized"
endfunction
function! VimPinyin_OnCursorMovedI()
	echo "VimPinyin_OnCursorMovedI"
	redrawstatus!
endfunction
function! VimPinyin_OnCursorMoved()
	echo "VimPinyin_OnCursorMoved"
	redrawstatus!
endfunction

" 检测相关事件
function! VimPinyin_MonitorVimEvents()
	"au VimResized   *  call VimPinyin_OnVimResized()
	"au CursorMovedI *  call VimPinyin_OnCursorMovedI()
	"au CursorMoved  *  call VimPinyin_OnCursorMoved()
endfunction

call VimPinyin_MonitorVimEvents()


"}}}
" =============================================================================
" END
" =============================================================================
"{{{1 vim: foldmethod=marker:


