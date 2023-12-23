---
title: sql except 筆記
date: 2022-10-11 18:44:42
tags: sql
---
![sql](https://raw.githubusercontent.com/weber87na/flowers/master/sql.png)
<!-- more -->

工作上測試東西遇到的問題 , 太久沒用 except 忘了特性 , 本來以為用下去就可以直接得到 `E` , `F` 結果不行 XD
另外 oracle 沒 `except` 則要用 `minus`

A - B 取不到結果
```
;with A as (
	select 'A' Id union all
	select 'B' union all
	select 'C' union all
	select 'D'
) , B as (
	select 'A' Id union all
	select 'B' union all
	select 'C' union all
	select 'D' union all
	select 'E' union all
	select 'F'
)
select Id
from A
except
select Id
from B


Id
----

(0 rows affected)
```


所以這時候要用 B - A 才可以取得資料
```
;with A as (
	select 'A' Id union all
	select 'B' union all
	select 'C' union all
	select 'D'
) , B as (
	select 'A' Id union all
	select 'B' union all
	select 'C' union all
	select 'D' union all
	select 'E' union all
	select 'F'
)
select Id
from B
except
select Id
from A


Id
----
E
F

(2 rows affected)
```


知道特性後就可以來修正 ef 上面遇到的問題 , 情境大概是這樣 , 要從 `Oracle` 原始資料運用排程把資料倒進去 `sql server` 裡

```
//這裡拿兩個特殊觸發欄位進行相減
var oracleData =
	oracleDb.Doc.AsNoTracking()
	.Select( x => new ExceptViewModel
	{
		Id = x.Id,
		Item1 = x.Item1,
		ModifyDatetime = x.ModifyDatetime,
		SysUpdateDatetime = x.SysUpdateDatetime,
	} ).ToList();

var msData = msDb.Doc.AsNoTracking()
	.Select( x => new ExceptViewModel
	{
		Id = x.Id,
		Item1 = x.Item1,
		ModifyDatetime = x.ModifyDatetime,
		SysUpdateDatetime = x.SysUpdateDatetime,
	} ).ToList();


//取出全部 sql server 裡面存放的 oracle 同步資料
var msFullData = msData.Doc.ToList();

//Oracle 減去 sql server 資料
var modifyOracleData = oracleData.Except( msData, new ExceptIEqualityComparer() ).ToArray();

//做些其他處理
```

在 linq 裡面用 `Except` 的話需要自訂比較方法 , 所以要繼承 `IEqualityComparer` 去比較 , 我這裡設定所有欄位當節點
另外一點特別注意 `GetHashCode` 只寫需要比較的欄位就好 , 多寫或是少寫都會錯誤

```
public class ExceptIEqualityComparer : IEqualityComparer<ExceptDocViewModel>
{
	public bool Equals( ExceptDocViewModel x, ExceptDocViewModel y )
	{
		return ( x.Id == y.Id &&
			x.Item1 == y.Item1 &&
			x.ModifyDatetime == y.ModifyDatetime &&
			x.SysUpdateDatetime == y.SysUpdateDatetime );
	}
	public int GetHashCode( ExceptDocViewModel obj )
	{
		return (obj.Id,
			obj.Item1,
			obj.ModifyDatetime,
			obj.SysUpdateDatetime
			).GetHashCode();
	}
}

```

後續又遇到效能問題 , 本來是在 ef 跑 loop , 去 insert or update or delete 結果因為資料量有 7 萬筆 , 速度超慢要跑個 20 - 30 分鐘
同步資料主要有三個動作 , 先刪除 sql server 內的多餘資料 , 接著 insert oracle 新增的資料 , 最後 update oracle 與 sql server 差異部分

找出需要從 sql server 刪除的資料
```
var deleteData = ms.Except( oracle, new ExceptIdEqualityComparer () )
```

找出 oracle 新增的資料 , 等等新增到 sql server , 這裡的 Comparer 只需要比對 Id 即可
```
var insertData = oracle.Except( ms, new ExceptIdEqualityComparer () )
```

找出需要更新的資料 , 注意這裡的 Comparer 不一樣 , 需要比對數值
```
var modifyOracleData = oracleData.Except( msData, new ExceptIEqualityComparer() ).ToArray();
```


比對 ID 用 , 找出需要 insert & delete 的資料
```
    public class ExceptIdEqualityComparer : IEqualityComparer<ExceptDocViewModel>
    {
        public bool Equals( ExceptDocViewModel x, ExceptDocViewModel y )
        {
            return (
                x.Id == y.Id
                );
        }
        public int GetHashCode( ExceptDocViewModel obj )
        {
            return (
                obj.Id
                ).GetHashCode();
        }
    }

```

建立 datatable 等等寫入 temp table
```
private static DataTable CreateDataTable( ExceptDocViewModel[] list )
{
	//欄位名稱不一樣所以多個多載
	//PlmDcItemElecDoc
	var datatable = new DataTable();
	datatable.Columns.Add( "Id", typeof( string ) );
	datatable.Columns.Add( "Item1", typeof( string ) );
	datatable.Columns.Add( "ModifyDatetime", typeof( DateTime ) );
	datatable.Columns.Add( "SysUpdateDatetime", typeof( DateTime ) );
	foreach( var item in list )
		datatable.Rows.Add(
				item.Id,
				item.Item1 ,
				item.ModifyDatetime ,
				item.SysUpdateDatetime 
			);
	return datatable;

}

```

塞入資料到 sql server 內 , 最關鍵就是先用 select into 建立空的臨時表 , 接著把 datatable 資料塞到臨時表
最後要新增的話就直接從臨時表新增至主表 , 更新的話則用 join 去更新資料 , 大概 20 秒內就可以解決原本要 20 - 30 分鐘的作業時間
```
                //mapping data to datatable
                var datatable = CreateDataTable( needInsertData );

                var conn = db.Database.Connection;
                conn.Open();
                var transaction = conn.BeginTransaction();
                var cmd = conn.CreateCommand();

                //這邊要設定交易不然會噴下面這個 error
                //當指定給命令的連接為擱置的本機交易時，ExecuteNonQuery 需要連接以交易。命令的 Transaction 屬性尚未初始化。
                cmd.Transaction = transaction;

                //用 select into 建立暫時資料表
                cmd.CommandText =
@"
select Item1 , ModifyDatetime , SysUpdateDatetime
into #DocForInsert
from Doc
where 1 != 1;
";
                var effect = cmd.ExecuteNonQuery();
                using( var bulkCopy = new SqlBulkCopy(
                    (SqlConnection) conn,
                    SqlBulkCopyOptions.Default,
                    (SqlTransaction) transaction ) )
                {
                    //丟到 temp table
                    bulkCopy.DestinationTableName = "#DocForInsert";
                    bulkCopy.WriteToServer( datatable );
                }

                //把 temp 資料表的內容丟入
                cmd = conn.CreateCommand();

                //這邊要設定交易不然會噴下面這個 error
                //當指定給命令的連接為擱置的本機交易時，ExecuteNonQuery 需要連接以交易。命令的 Transaction 屬性尚未初始化。
                cmd.Transaction = transaction;

                //把暫存的資料丟進去真正的資料表內
                cmd.CommandText =
@"
insert into Doc(Item1 , ModifyDatetime , SysUpdateDatetime)
select Item1 , ModifyDatetime , SysUpdateDatetime
from #DocForInsert
";
                effect = cmd.ExecuteNonQuery();

                transaction.Commit();
                Debug.WriteLine( $"新增筆數: {effect}" );

```

如果要更新的話 sql 語法大改長這樣
```
update Doc
set Doc.Item1 = #DocForInsert.Item1 ,
Doc.ModifyDatetime = #DocForInsert.ModifyDatetime ,
Doc.SysUpdateDatetime = #DocForInsert.SysUpdateDatetime
from Doc join #DocForInsert
on Doc.DocId = #DocForInsert.DocId
```

最後如果是用 Oracle 可以參考 [這篇文章](https://www.c-sharpcorner.com/article/two-ways-to-insert-bulk-data-into-oracle-database-using-c-sharp/)

```
private static void BulkInsertToOracle(ErpDbContext erpDb, DataTable datatable)
{
    var conn = erpDb.Database.Connection;
    erpDb.Database.Connection.Open();
    using( var bulkCopy = new OracleBulkCopy(
	(OracleConnection) conn,
	OracleBulkCopyOptions.Default
	) )
    {
	bulkCopy.DestinationTableName = "yourtable";
	bulkCopy.WriteToServer( datatable );
    }
}
```

後來又發現其實可以用 merge into , 以前好像在書上看過 , 可是沒實戰沒那個感覺 , 用這招三秒就全部的事都做完了 .. 真是淫蕩
```
MERGE Doc AS T
USING #DocSource AS S
ON T.DocId = S.DocId
WHEN MATCHED THEN
	UPDATE SET  T.Item1 = S.Item1
		  , T.ModifyDatetime = S.ModifyDatetime
		  , T.SysUpdateDatetime = S.SysUpdateDatetime
WHEN NOT MATCHED BY TARGET 
	THEN INSERT (Item1 , ModifyDatetime , SysUpdateDatetime) 
	VALUES (S.Item1 , S.ModifyDatetime , S.SysUpdateDatetime)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
```

另外還可以這樣用
```
INSERT INTO DocTest(S.Item1 , S.ModifyDatetime , S.SysUpdateDatetime)
SELECT Item1 , ModifyDatetime , SysUpdateDatetime
FROM (
	MERGE Doc AS T
	USING #DocSource AS S
	ON T.DocId = S.DocId
	WHEN MATCHED THEN
		UPDATE SET  T.Item1 = S.Item1
			  , T.ModifyDatetime = S.ModifyDatetime
			  , T.SysUpdateDatetime = S.SysUpdateDatetime
	WHEN NOT MATCHED BY TARGET 
		THEN INSERT (Item1 , ModifyDatetime , SysUpdateDatetime) 
		VALUES (S.Item1 , S.ModifyDatetime , S.SysUpdateDatetime)
	WHEN NOT MATCHED BY SOURCE THEN DELETE
	OUTPUT $action , Inserted.Item1 , Inserted.ModifyDatetime , SysUpdateDatetime.DocId
) AS Changes (Action , Item1 , ModifyDatetime , DocId)
WHERE Action = 'INSERT'
```

最後就是如果兩個資料集相同的話 , 其實 `merge into` 還是會 `update` , 本來腦補以為不會更新 , 結果觀念有點錯
如果要加工的話 insert update delete 結果的話可以這樣寫

可以參考 [這篇](https://www.sqlservercentral.com/articles/the-output-clause-for-the-merge-statements) 或是 [這篇](https://stackoverflow.com/questions/17165870/multiple-output-clauses-in-merge-insert-delete-sql-commands) [官方](https://learn.microsoft.com/zh-tw/sql/t-sql/queries/output-clause-transact-sql?view=sql-server-ver16)

```
DECLARE @DocTest TABLE
(
   MergeAction varchar(50),
   Item1 varchar(30) not null,
   ModifyDatetime datetime null,
   SysUpdateDatetime datetime not null
);

MERGE Doc AS T
USING #DocSource AS S
ON T.DocId = S.DocId
WHEN MATCHED THEN
	UPDATE SET  T.Item1 = S.Item1
		  , T.ModifyDatetime = S.ModifyDatetime
		  , T.SysUpdateDatetime = S.SysUpdateDatetime
WHEN NOT MATCHED BY TARGET 
	THEN INSERT (Item1 , ModifyDatetime , SysUpdateDatetime) 
	VALUES (S.Item1 , S.ModifyDatetime , S.SysUpdateDatetime)
WHEN NOT MATCHED BY SOURCE THEN DELETE
OUTPUT $action as MergeAction,
    CASE $action
		WHEN 'DELETE' THEN deleted.Item1 
		ELSE inserted.Item1 END AS Item1,
    CASE $action
		WHEN 'DELETE' THEN deleted.ModifyDatetime 
		ELSE inserted.ModifyDatetime END AS ModifyDatetime,
    CASE $action
		WHEN 'DELETE' THEN deleted.SysUpdateDatetime 
		ELSE inserted.DocId END AS SysUpdateDatetime
    INTO @DocTest;

SELECT *
FROM @DocTest;
```
