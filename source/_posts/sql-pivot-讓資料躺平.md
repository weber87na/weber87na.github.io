---
title: sql pivot 讓資料躺平
date: 2024-06-18 23:26:56
tags: sql
---
&nbsp;
<!-- more -->

工作上遇到的問題, 目前有一個類似以下的 table, 他呈現一個躺平的狀態, 共有很多關卡, 每個關卡出現的 boss 名稱都不見得一樣
希望能把裡面的資料轉為正規化的一對多然後存到 db 裡面
以下懶得建 table 直接用 cte 來寫 Seq1 - SeqN 可以用 replace 函數來去除前綴

```sql
with bossSeq as (
	select 1 as id, 'cutman' Seq1 , 'snowman' Seq2 , 'gbyeman' Seq3 , 'fireman' Seq4 , 'rockman' Seq5
	union
	select 2 as id, 'snowman' Seq1 , 'cutman' Seq2 , null Seq3 , null Seq4 , null Seq5
	union
	select 3 as id, 'cutman' Seq1 , 'fireman' Seq2 , 'gbyeman' Seq3 , null Seq4 , null Seq5
	union
	select 4 as id, 'rockman' Seq1 , 'fireman' Seq2 , 'gbyeman' Seq3 , 'snowman' Seq4 , 'cutman' Seq5
	union
	select 5 as id, 'fireman' Seq1 , 'rockman' Seq2 , 'snowman' Seq3 , 'gbyeman' Seq4 , null Seq5
)
select id , boss , replace(Seq , 'seq' , '') as Seq
from bossSeq
unpivot
(
	boss for Seq in (Seq1,Seq2,Seq3,Seq4,Seq5)
) as unpivotBossSeq
order by id , seq
```

呈上, 如果希望讓本來沒躺平的資料躺平的話可以這樣寫, 這裡注意到 max(boss) 跟 max(id) 會得到完全不同結果, 要特別小心有無寫錯

```sql
with bossSeq as (
	select 1 as id, 'cutman' Seq1 , 'snowman' Seq2 , 'gbyeman' Seq3 , 'fireman' Seq4 , 'rockman' Seq5
	union
	select 2 as id, 'snowman' Seq1 , 'cutman' Seq2 , null Seq3 , null Seq4 , null Seq5
	union
	select 3 as id, 'cutman' Seq1 , 'fireman' Seq2 , 'gbyeman' Seq3 , null Seq4 , null Seq5
	union
	select 4 as id, 'rockman' Seq1 , 'fireman' Seq2 , 'gbyeman' Seq3 , 'snowman' Seq4 , 'cutman' Seq5
	union
	select 5 as id, 'fireman' Seq1 , 'rockman' Seq2 , 'snowman' Seq3 , 'gbyeman' Seq4 , null Seq5
) , unpivotBossSeq as (
	select id , boss , replace(Seq , 'seq' , '') as Seq
	from bossSeq
	unpivot
	(
		boss for Seq in (Seq1,Seq2,Seq3,Seq4,Seq5)
	) as unpivotBossSeq
)
select *
from unpivotBossSeq
pivot (
	max(boss)
	for Seq in([1],[2],[3],[4],[5])
) pivotBossSeq
```
