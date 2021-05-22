---
title: 找出大於1GB的shp
date: 2020-07-05 13:05:50
tags:
- gis
- powershell
---
&nbsp;
<!-- more -->
工作上時常需要處理地理資料 ShapeFile , 有時候會需要找出超過軟體大小限制為 1GB 的 , 可以參考以下 powershell 命令
```
$files = Get-ChildItem D:\ -Recurse | Where-Object {$_.Extension -eq ".shp"  -and $_.Length/1GB -gt 1 } |
Sort-Object -Property Length  -Descending 

foreach($f in  $files ){
 $f.FullName
}
```
