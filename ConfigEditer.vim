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

" 显示配置
function! VimPinyin_ConfigEditer_ShowConfigBar(title, out_list, hi_list)

	" 清空命令行
	call VimPinyin_Common_ClearCommandBar()

	" [title] 
	execute 'echohl Title | echon "[' . a:title . '] "'
	
	" [title] [1.简体] 2.繁体 3.全角 4.[半角] 5.中标 6.[英标]
	for i in range(len(a:out_list))
		if a:hi_list[i]
			execute 'echohl LineNr | echon "' . (i+1) . '."'
			execute 'echohl None | echon "["'
			execute 'echohl Label | echon "' . a:out_list[i] . '"'
			execute 'echohl None | echon "] "'
		else
			execute 'echohl LineNr | echon "' . (i+1) . '."'
			execute 'echohl None | echon "' . a:out_list[i] . ' "'
		endif
	endfor
endfunction

" 配置参数
function! VimPinyin_ConfigEditer_ProcessInput()

	let title = "设置"
	let out_list = [ "简体", "繁体", "全角", "半角", "中标", "英标" ]
	let hi_list  = [
		\g:VimPinyin_modeSimp, ! g:VimPinyin_modeSimp,
		\g:VimPinyin_modeFull, ! g:VimPinyin_modeFull,
		\g:VimPinyin_modeFullPunct, ! g:VimPinyin_modeFullPunct,
		\]
	let hi_list_old  = [
		\g:VimPinyin_modeSimp, ! g:VimPinyin_modeSimp,
		\g:VimPinyin_modeFull, ! g:VimPinyin_modeFull,
		\g:VimPinyin_modeFullPunct, ! g:VimPinyin_modeFullPunct,
		\]
		
	" 选择参数
	while 1
		call VimPinyin_ConfigEditer_ShowConfigBar(title, out_list, hi_list)
		
        let keycode = getchar()
		if !VimPinyin_Common_IsDigit(keycode)
			break
		endif
		
		if keycode == char2nr('1')
			let g:VimPinyin_modeSimp = 1
			let hi_list[0] = 1
			let hi_list[1] = 0
		elseif keycode == char2nr('2')
			let g:VimPinyin_modeSimp = 0
			let hi_list[1] = 1
			let hi_list[0] = 0
		elseif keycode == char2nr('3')
			let g:VimPinyin_modeFull = 1
			let hi_list[2] = 1
			let hi_list[3] = 0
		elseif keycode == char2nr('4')
			let g:VimPinyin_modeFull = 0
			let hi_list[3] = 1
			let hi_list[2] = 0
		elseif keycode == char2nr('5')
			let g:VimPinyin_modeFullPunct = 1
			let hi_list[4] = 1
			let hi_list[5] = 0
		elseif keycode == char2nr('6')
			let g:VimPinyin_modeFullPunct = 0
			let hi_list[5] = 1
			let hi_list[4] = 0
		endif
	endwhile
	
	" 验证参数是否变化
	for i in range(len(hi_list))
		if hi_list[i] != hi_list_old[i]
			call VimPinyin_SaveConfig()
			return
		endif
	endfor
endfunction

" =============================================================================


