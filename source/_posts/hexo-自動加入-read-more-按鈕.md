---
title: hexo 自動加入 read more 按鈕
date: 2020-08-21 00:42:34
tags:
- hexo
- bash
---
&nbsp;
<!-- more -->
文章開始變多，但是先前的文章卻都沒有加入 read more 按鈕
所以寫了個 bash 將先前的按鈕補出來，主要原理是在 markdown 的第二個 --- 後面加上以下程式碼，像是以下片段
不過這樣有個缺點就是前面會多一段空白區段，老實說效果不是特好只能將就著用
```
---
title: yourtitle
date: 2020-08-21 00:42:34
tags:
- hexo
- bash
---
&nbsp;
<!-- more -->
```

以下是 bash 防止意外我只寫成 echo 要執行的話需要自己補
主要原理是使用 regex 將第二個 --- dash 找到並且換成想要的結果
注意 dollar sign $ 跟 & 需要 escape
``` bash
#!/bin/bash
FILES=$(ls *.md)
for f in $FILES
do
	echo "sed ':a;N;\$!ba; s/---/---\n\&nbsp;\n<!-- more -->/2' $f > $f-changed.txt && mv $f-changed.txt $f"
done
```

參考老外資料
1. [https://unix.stackexchange.com/questions/403271/sed-replace-only-the-second-match-word](https://unix.stackexchange.com/questions/403271/sed-replace-only-the-second-match-word)
2. [https://unix.stackexchange.com/questions/259885/save-file-after-using-sed-command/259887](https://unix.stackexchange.com/questions/259885/save-file-after-using-sed-command/259887)
