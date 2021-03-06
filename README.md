Vim拼音输入法
============

**注意：该输入法还在开发阶段，还不能满足平时使用需求！**

主要功能
-------

- v模式: 输入英文单词, 如输入: vhelp
- u模式: 四角号码输入单字, 输入: u1080 . (这个要用字母选字)
- 拼音: 普通输入(这个没有加词库), 只能识别: nihao; 如果有Python3, 支持baidu云输入引擎
- 中文标点输入

功能键有
-------

- 空格上字
- 回车输入原始字符
- ';' 候选键
- 删除键(del/backspace)
- 翻页键
- 方向键(上下左右)
- esc取消当前输入

输入法切换键
----------

- <C-\> 中英文切换
- <C-^> 中文输入法参数配置

TODO部分
-------

- i模式, 兼容lua和vim脚本
- 匹配引擎的优化(快速/准确)
- 拼音能支持自定义词语和自动更新词频(包括输入之前词库不存在的新词语)

安装
----

将附件解压到 `$VIM/vimfiles/plugin`

补充
----

- 显示参考的ywvim，使用的是lmap映射,
- Python云输入参考的是VimIM
- 词库目前主要参考的VimIM

效果图
-----

![](https://raw.githubusercontent.com/chai2010/vimpinyin/master/doc/1.png)
![](https://raw.githubusercontent.com/chai2010/vimpinyin/master/doc/2.png)
![](https://raw.githubusercontent.com/chai2010/vimpinyin/master/doc/3.png)
![](https://raw.githubusercontent.com/chai2010/vimpinyin/master/doc/4.png)

