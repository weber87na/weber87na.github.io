---
title: CTE妙用 產生出css網格系統
date: 2020-08-10 14:42:28
tags:
- css
- sql
---
&nbsp;
<!-- more -->
看書時某個章節講述手寫類似 bootstrap 的 css 網格系統
主要原理是 100% / 12 * N
12 可以是你需要的 column 數量
特別要注意重點
1.就是要加上百分比 % 符號
2.calc 計算中間要有空白否則會失效
因為太懶了腦洞大開可以直接用 sql 的 cte 進行程式碼產出
使用 cte 搭配 union all 產生 1-12 的數字

``` sql
WITH col (C) as(
	select C = 1
	union all
	select C + 1
	from col
	where C < 12
)
select 
	'.column-' + CAST( C as nvarchar) + ' { width: calc( 100% / 12 * ' + CAST( C as nvarchar) + '); }' as 'css-calc-column' ,
	'.column-' + CAST( C as nvarchar) + ' { width: ' + CAST ( C / 12.0 * 100 as nvarchar) + '%;}' as 'css-column'
from col
```

最終結果如下
寫法1動態計算
``` css
.column-1 { width: calc( 100% / 12 * 1); }
.column-2 { width: calc( 100% / 12 * 2); }
.column-3 { width: calc( 100% / 12 * 3); }
.column-4 { width: calc( 100% / 12 * 4); }
.column-5 { width: calc( 100% / 12 * 5); }
.column-6 { width: calc( 100% / 12 * 6); }
.column-7 { width: calc( 100% / 12 * 7); }
.column-8 { width: calc( 100% / 12 * 8); }
.column-9 { width: calc( 100% / 12 * 9); }
.column-10 { width: calc( 100% / 12 * 10); }
.column-11 { width: calc( 100% / 12 * 11); }
.column-12 { width: calc( 100% / 12 * 12); }
```

寫法2靜態計算
``` css
.column-1 { width: 8.333300%;}
.column-2 { width: 16.666600%;}
.column-3 { width: 25.000000%;}
.column-4 { width: 33.333300%;}
.column-5 { width: 41.666600%;}
.column-6 { width: 50.000000%;}
.column-7 { width: 58.333300%;}
.column-8 { width: 66.666600%;}
.column-9 { width: 75.000000%;}
.column-10 { width: 83.333300%;}
.column-11 { width: 91.666600%;}
.column-12 { width: 100.000000%;}
```
