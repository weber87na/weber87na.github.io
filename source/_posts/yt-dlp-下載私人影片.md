---
title: yt-dlp 下載私人影片
date: 2024-05-13 17:36:32
tags:
---

&nbsp;
<!-- more -->


被朋友問到要怎麼下載 youtube 私人影片, 印象中以前好像用其他的 lib 做過, 後來好像掛了? 防止自己又忘了順手記錄下
首先到 yt-dlp 官網下載 yt-dlp.exe
接著無腦執行以下命令, 不曉得為啥用 chrome 反而發生錯誤以下錯誤

```
ERROR: Could not copy Chrome cookie database. See  https://github.com/yt-dlp/yt-dlp/issues/7271  for more info
```

直接改 firefox 就能下了, 先這樣吧

```
yt-dlp --cookies-from-browser firefox "https://www.youtube.com/watch?v=xxxxx"
```

### 地雷

不曉得從哪個版本開始, 又變得沒辦法無腦下載, 筆記下解法

先安裝 ffmpeg

指令要這樣寫, 他就會自動 merge 影片跟檔案, 否則會噴這句 `WARNING: You have requested merging of multiple formats but ffmpeg is not installed. The formats won't be merged` 分成兩個檔

```
yt-dlp -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]' --cookies-from-browser firefox "https://www.youtube.com/watch?v=xxx"
```


