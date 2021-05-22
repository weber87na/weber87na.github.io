---
title: sql 不用迴圈印出星星
date: 2020-10-21 01:48:02
tags:
- sql
---
&nbsp;
<!-- more -->

這個方法是看視窗函數開的一個腦洞，以往常見印星星的問題都需要依靠迴圈進行輸出，
有了視窗函數即可採用 SQL 的方式將星星印出來，感覺還挺炫炮的
```
        *
       ***
      *****
     *******
    *********
   ***********
  *************
 ***************
*****************
```
常見的 csharp 解法
``` csharp
            for (int i = 1; i <= 9; i++)
            {
                //左空白
                for(int j = 0; j < 9 - i ; j++)
                    Console.Write(" ");

                //星號本體
                for (int j = 0; j < i * 2 - 1; j++)
                    Console.Write("*");

                //右空白
                for(int j = 0; j < 9 - i ; j++)
                    Console.Write(" ");

                Console.WriteLine();
            }

```
以下為 sql 解法，若需要反向將星星排序把 order by n 改為 desc 即可
``` sql
with RECURSIVE  Tally(N , S) as (
	select 1 , '*' S
	union all
	select N + 1 , '*'
	from Tally
	where N < 9
)
select 
  MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 8 PRECEDING AND 8 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 7 PRECEDING AND 7 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 6 PRECEDING AND 6 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 5 PRECEDING AND 5 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 4 PRECEDING AND 4 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING ) N
, S
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 4 PRECEDING AND 4 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 5 PRECEDING AND 5 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 6 PRECEDING AND 6 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 7 PRECEDING AND 7 PRECEDING ) N
, MIN(S) OVER (ORDER BY N ASC ROWS BETWEEN 8 PRECEDING AND 8 PRECEDING ) N
from Tally
--order by Tally.N desc
```
