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

function! s:BaiduSearch_py2(pattern)
:sil!python3 << EOF
import vim, urllib2
try:
	py = vim.eval("a:pattern")
	url = "http://olime.baidu.com/py?rn=0&pn=20&py=%s"
	urlopen = urllib2.urlopen(url % py, None, 20)
	response = urlopen.read()
	res = unicode(response, 'gbk').encode('utf-8')
	vim.command("return %s" % res)
	urlopen.close()
except vim.error:
	print("vim error: %s" % vim.error)
EOF
endfunction

function! s:BaiduSearch_py3(pattern)
:sil!python3 << EOF
import vim, urllib.request
try:
	py = vim.eval("a:pattern")
	url = "http://olime.baidu.com/py?rn=0&pn=20&py=%s"
	urlopen = urllib.request.urlopen(url % py)
	response = urlopen.read()
	res = response.decode('gbk')
	vim.command("return %s" % res)
	urlopen.close()
except vim.error:
	print("vim error: %s" % vim.error)
EOF
endfunction

function! s:BaiduSearch(pattern)
	if has("python3")
		return s:BaiduSearch_py3(a:pattern)
	endif
	if has("python")
		return s:BaiduSearch_py2(a:pattern)
	endif
	return [ a:pattern ]
endfunction

" =============================================================================

let s:_baiduFile = expand("<sfile>:p:h") . "/data/tmp/baidu.txt"

" 词库缓冲
let s:baidu_py_db = {}
let s:baidu_py_db_cnt = 0

function! s:LoadCloudDB()
	if !filereadable(s:_baiduFile) | return 0 | endif
	
	for line in readfile(s:_baiduFile, '', 50)
		let list = split(line)
		if len(list) < 2 | continue | endif
		
		let key = remove(list, 0)
		if has_key(s:baidu_py_db, key)
			let s:baidu_py_db[key] += list
		else
			let s:baidu_py_db[key] = list
		endif
	endfor
	return 1
endfunction
function! s:SaveCloudDB()
	let list = []
	for key in keys(s:baidu_py_db)
		let line = key . " " . join(s:baidu_py_db[key])
		call insert(list, line)
	endfor
	if len(list) > 0
		call writefile(list, s:_baiduFile)
	endif
endfunction
function! s:InsertCloudDB(pattern, list)
	let s:baidu_py_db[a:pattern] = a:list
	let s:baidu_py_db_cnt = s:baidu_py_db_cnt + 1
	
	if s:baidu_py_db_cnt > 5
		let s:baidu_py_db_cnt = 0
		" 保存到文件
		call s:SaveCloudDB()
	endif
endfunction

" =============================================================================

" 初始化
let s:bInitFlag = 0
function! s:init()
	if s:bInitFlag | return | endif
	let s:bInitFlag = 1
	
	call s:LoadCloudDB()
endfunction

" 查询
function! VimPinyin_CloudEngine_Search(pattern)
	call s:init()
	
	let pattern = a:pattern
	if !VimPinyin_Common_IsStringType(a:pattern)
		return [ a:pattern ]
	endif
	
	" 先搜索缓冲
	if has_key(s:baidu_py_db, pattern)
		return s:baidu_py_db[pattern]
	endif
	
	let output = s:BaiduSearch(a:pattern)
	if !VimPinyin_Common_IsListType(output)
		return [ a:pattern ]
	endif
	if empty(output)
		return [ a:pattern  ]
	endif
	
	let output_list = get(output,0)
	if !VimPinyin_Common_IsListType(output_list)
		return [ a:pattern ]
	endif
	
	let matched_list = []
	for item_list in output_list
		let chinese = get(item_list,0)
		if chinese =~ '\w'
			continue
		endif
		let english = strpart(a:pattern, get(item_list,1))
		let yin_yang = chinese . english
		call add(matched_list, chinese)
	endfor
	
	" 缓冲
	call s:InsertCloudDB(pattern, matched_list)
	return matched_list
endfunction

" =============================================================================

