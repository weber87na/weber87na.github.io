---
title: 快速轉換png為ico
date: 2020-07-05 12:56:31
tags:
- powershell
- imagemagick
---
&nbsp;
<!-- more -->
某次任務中有個軟體的圖檔只能吃 .ico 格式 , 於是使用 powershell + imagemagick 快速轉換整個資料夾的 png 為 ico
```powershell
$files = Get-ChildItem D:\png\  | Where-Object {$_.Extension -eq ".png"  } 

foreach($f in  $files ){
   #'magick.exe convert ' + $f.FullName + ' -resize 16x16 -transparent white -colors 256 ' +   $f.FullName.Replace(".png",".ico")
   magick.exe convert -background transparent $f.FullName -define icon:auto-resize=16 $f.FullName.Replace(".png",".ico")
}
```
