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

let s:_olimeFile = expand("<sfile>:p:h") . "/data/tmp/olime.txt"

" 初始化
let s:bInitFlag = 0
function! s:init()
	if s:bInitFlag | return | endif
	let s:bInitFlag = 1
	
endfunction

" 查询
" http://olime.baidu.com/py?rn=0&pn=10&py=ni
function! VimPinyin_PyEngine_Search(pattern)
	call s:init()
	
	if has('ptrhon') || has('python3')
		return VimPinyin_CloudEngine_Search(a:pattern)
	endif

	if !VimPinyin_Common_IsStringType(a:pattern) || strlen(a:pattern) == 0
		return [ a:pattern ]
	endif
	let wget_option = ' -qO "' . s:_olimeFile . '" --timeout 1 -t 3 '
	let url = 'http://olime.baidu.com/py?rn=0&pn=10&py='
	"call system('wget'  . wget_option . '"' . url . a:pattern . '"')

	if a:pattern == 'n'
		return [
			\"你", "那", "能", "呢", "年",
			\"尼", "拟", "泥", "妮", "腻",
			\"逆",
			\]
	elseif a:pattern == 'ni'
		return [
			\"你", "尼", "拟", "妮", "泥",
			\"腻", "逆", "昵",
			\]
	elseif a:pattern == 'nih'
		return [
			\"你好", "你会", "你还", "拟好", "拟合",
			\"你和", "嫟好", "你很", "霓虹", "呢好",
			\"倪华", "逆火", "泥河",
			\]
	elseif a:pattern == 'niha'
		return [
			\"尼", "拟", "泥", "妮", "腻",
			\"逆",
			\]
	elseif a:pattern == 'nihao'
		return [
			\"你好", "嫟好", "呢好", "拟好", "你",
			\"尼",
			\]
	else
		return [
			\a:pattern,
			\]
	endif
endfunction

" =============================================================================

