---
title: sql 圈圈叉叉
date: 2022-02-23 18:27:05
tags: sql
---

&nbsp;
![sql](https://raw.githubusercontent.com/weber87na/flowers/master/sql.png)
<!-- more -->

突然遇到一個問題 , string 內有多少個重複字元 , 印象中以前有在書上看過 `len(@ans) - len(replace(@ans, 'X', ''))` 可以用這樣的方法算出來
為了要用類似的情況就搞個 OOXX 來玩看看 ~ 記得以前書上是寫晶圓板的樣子 , 久沒寫暫時也想不出其他好法子 , 就先這樣吧

sql server
```
declare @ans as varchar(9) = 'ONNXNNXNO'

select @ans ,
case
	 --防錯
	 when len(@ans) < 9 then 'Error'
	 when len(@ans) = 9 and substring(@ans , 1 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 2 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 3 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 4 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 5 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 6 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 7 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 8 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when len(@ans) = 9 and substring(@ans , 9 , 1) not in ('O' , 'X' , 'N') then 'Error'

	 --防止 OX 輸入錯誤
	 when len(@ans) = 9 and len(@ans) - len(replace(@ans, 'X', '')) > 3 then 'Error'
	 when len(@ans) = 9 and len(@ans) - len(replace(@ans, 'O', '')) > 3 then 'Error'

	 --橫條
	 when substring(@ans , 1 , 3) in ('OOO') then 'O win'
	 when substring(@ans , 1 , 3) in ('XXX') then 'X win'
	 when substring(@ans , 4 , 6) in ('OOO') then 'O win'
	 when substring(@ans , 4 , 6) in ('XXX') then 'X win'
	 when substring(@ans , 7 , 9) in ('OOO') then 'O win'
	 when substring(@ans , 7 , 9) in ('XXX') then 'X win'

	 --直條
	 when substring(@ans , 1 , 1) = 'O' and substring(@ans , 4 , 1) = 'O' and substring(@ans , 7 , 1) = 'O' then 'O win'
	 when substring(@ans , 2 , 1) = 'O' and substring(@ans , 5 , 1) = 'O' and substring(@ans , 8 , 1) = 'O' then 'O win'
	 when substring(@ans , 3 , 1) = 'O' and substring(@ans , 6 , 1) = 'O' and substring(@ans , 9 , 1) = 'O' then 'O win'

	 when substring(@ans , 1 , 1) = 'X' and substring(@ans , 4 , 1) = 'X' and substring(@ans , 7 , 1) = 'X' then 'X win'
	 when substring(@ans , 2 , 1) = 'X' and substring(@ans , 5 , 1) = 'X' and substring(@ans , 8 , 1) = 'X' then 'X win'
	 when substring(@ans , 3 , 1) = 'X' and substring(@ans , 6 , 1) = 'X' and substring(@ans , 9 , 1) = 'X' then 'X win'

	 --斜線
	 when substring(@ans , 1 , 1) = 'O' and substring(@ans , 5 , 1) = 'O' and substring(@ans , 9 , 1) = 'O' then 'O win'
	 when substring(@ans , 1 , 1) = 'X' and substring(@ans , 5 , 1) = 'X' and substring(@ans , 9 , 1) = 'X' then 'X win'

	 else 'Continue'
end result
```

Oracle 因為函數略有不同 , 稍微變換一下即可
```
declare ans as varchar(9) = 'ONNXNNXNO'

select ans ,
case
	 --防錯
	 when LENGTH(ans) < 9 then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 1 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 2 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 3 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 4 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 5 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 6 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 7 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 8 , 1) not in ('O' , 'X' , 'N') then 'Error'
	 when LENGTH(ans) = 9 and substr(ans , 9 , 1) not in ('O' , 'X' , 'N') then 'Error'

	 --防止 OX 輸入錯誤
	 when LENGTH(ans) = 9 and LENGTH(ans) - LENGTH(replace(ans, 'X', '')) > 3 then 'Error'
	 when LENGTH(ans) = 9 and LENGTH(ans) - LENGTH(replace(ans, 'O', '')) > 3 then 'Error'

	 --橫條
	 when substr(ans , 1 , 3) in ('OOO') then 'O win'
	 when substr(ans , 1 , 3) in ('XXX') then 'X win'
	 when substr(ans , 4 , 6) in ('OOO') then 'O win'
	 when substr(ans , 4 , 6) in ('XXX') then 'X win'
	 when substr(ans , 7 , 9) in ('OOO') then 'O win'
	 when substr(ans , 7 , 9) in ('XXX') then 'X win'

	 --直條
	 when substr(ans , 1 , 1) = 'O' and substr(ans , 4 , 1) = 'O' and substr(ans , 7 , 1) = 'O' then 'O win'
	 when substr(ans , 2 , 1) = 'O' and substr(ans , 5 , 1) = 'O' and substr(ans , 8 , 1) = 'O' then 'O win'
	 when substr(ans , 3 , 1) = 'O' and substr(ans , 6 , 1) = 'O' and substr(ans , 9 , 1) = 'O' then 'O win'

	 when substr(ans , 1 , 1) = 'X' and substr(ans , 4 , 1) = 'X' and substr(ans , 7 , 1) = 'X' then 'X win'
	 when substr(ans , 2 , 1) = 'X' and substr(ans , 5 , 1) = 'X' and substr(ans , 8 , 1) = 'X' then 'X win'
	 when substr(ans , 3 , 1) = 'X' and substr(ans , 6 , 1) = 'X' and substr(ans , 9 , 1) = 'X' then 'X win'

	 --斜線
	 when substr(ans , 1 , 1) = 'O' and substr(ans , 5 , 1) = 'O' and substr(ans , 9 , 1) = 'O' then 'O win'
	 when substr(ans , 1 , 1) = 'X' and substr(ans , 5 , 1) = 'X' and substr(ans , 9 , 1) = 'X' then 'X win'

	 else 'Continue'
end result
```
