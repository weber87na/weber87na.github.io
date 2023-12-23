---
title: Entity Framework Oracle 筆記
date: 2022-01-07 20:36:05
tags:
---
&nbsp;
![vim](https://raw.githubusercontent.com/weber87na/flowers/master/08.jpg)
<!-- more -->

工作以來一直沒機會用 Oracle , 都用窮人用的 postgresql , Oracle 頂多只用過 ado.net 去連 , 最近在 ef 上遇到一堆雷 , 順便筆記一下

### 安裝及 config 設定
首先安裝套件 `Oracle.ManagedDataAccess` `Oracle.ManagedDataAccess.EntityFramework`
然後在 `web.config` 加入這串 , 比較特別的是我拿到的權限是用 `SID` 一般常見會是 `SERVICE_NAME`
在 connectionString 的 `Data Source` 部分寫上你要連的 `alias` 即可
```
<connectionStrings>
	<add name="OracleDbContext" providerName="Oracle.ManagedDataAccess.Client" connectionString="User Id=LADISAI;Password=LADISAI;Data Source=oracle" />
</connectionStrings>

<oracle.manageddataaccess.client>
	<version number="*">
		<dataSources>
			<dataSource alias="oracle" descriptor="(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.123.45.67)(PORT=1521))(CONNECT_DATA=(SID=LADISAI))) " />
		</dataSources>
	</version>
</oracle.manageddataaccess.client>

```

### ado.net
接著寫看看 ado.net 的測試 function , 沒特別遇到什麼問題
``` c#
private static void Read()
{
	var str = System.Configuration.ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;
	using (var conn = new OracleConnection(str))
	using (var cmd = conn.CreateCommand())
	{
		conn.Open();
		cmd.CommandText = @"SELECT * from YOURVIEW";
		var reader = cmd.ExecuteReader();
		while (reader.Read())
		{
			var gg = reader["GG"];
			Console.WriteLine(gg);
		}
	}
}
```

### Dapper
``` c#
private static void DapperQuery()
{
	string sql = "SELECT * FROM YOURVIEW WHERE ROWNUM <= 1";

	var str = System.Configuration.ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;
	using (var connection = new OracleConnection(str))
	{
		var result = connection.Query(sql).FirstOrDefault();
		Console.WriteLine(result);
	}
}

```

### ef code first
接著用 ef code first 測試看看
此處有兩個關鍵 , 首先要在建構子設定 `Database.SetInitializer<OracleDbContext>(null);` 不然會噴 ORA-01031: 權限不足
接著在 `OnModelCreating` 設定 `HasDefaultSchema("")` 不然會噴 ORA-01918: 使用者 'dbo' 不存在
``` c#
public class OracleDbContext : DbContext
{
	public OracleDbContext() : base("name=OracleDbContext")
	{
		//要設定這樣 不然會噴 ORA-01031: 權限不足
		Database.SetInitializer<OracleDbContext>(null);
	}

	public DbSet<YOURVIEW> YOURVIEW { get; set; }

	protected override void OnModelCreating(DbModelBuilder modelBuilder)
	{
		//這裡要設定空字串 ORA-01918: 使用者 'dbo' 不存在
		modelBuilder.HasDefaultSchema("");

		//設定 view 的 config
		modelBuilder.Configurations.Add(new YOURVIEWConfiguration());
	}
}

```

因為我只有 view 的權限 , 這裡要多設定 `EntityTypeConfiguration` 並且指定 key 跟 view 的名稱 , 整個就搞定了
``` c#
[Table("YOURVIEW")]
public class YOURVIEW
{
	public string GG { get; set; }
}

public class YOURVIEWConfiguration : EntityTypeConfiguration<YOURVIEW>
{
	public YOURVIEWConfiguration()
	{
		this.HasKey(t => t.GG);
		this.ToTable("YOURVIEW");
	}
}

```

接著測試看看 , 這部分是關鍵
``` c#
private static void EF()
{
	YOURDbContext db = new YOURDbContext();
	//這裡可以印出來 sql 觀察問題點
	db.Database.Log = s => System.Diagnostics.Debug.WriteLine(s);

	//跑這段正常運作
	var test = db.YOURVIEW.SqlQuery("SELECT * FROM YOURVIEW");
	var all = test.ToList();
	var one = all.First();
	Console.WriteLine(one.GG);

	//如果沒有設定 HasDefaultSchema 為空字串 , 會噴 ORA-01918
	//另外一開始以為指定我的 schema 為 LADISAI 以後會噴 ORA-00942
	var list = db.YOURVIEW.Take(100).ToList();
	Print(list);

}

//印出這個物件的欄位及數值
private static void Print<T>(List<T> list)
{
	foreach (var item in list)
	{
		Type t = item.GetType();
		PropertyInfo[] pi = t.GetProperties();
		foreach (PropertyInfo p in pi)
		{
			var val = p.GetValue(item) ?? "(null)";
			Console.WriteLine($"{p.Name}:{val}");
		}
		Console.Write(new string('*', 100));
		Console.WriteLine();
	}
}


```

當你手動指定自己的 sql 語法 `db.YOURVIEW.SqlQuery("SELECT * FROM YOURVIEW")` 就算 `DbContext` 的 `HasDefaultSchema` 沒設定也可以正常跑
``` sql
SELECT * FROM YOURVIEW
```

當你直接呼叫 `db.YOURVIEW.Take(10).ToList()` 可以看到他生出的語法噴 ORA-00942 , 他產的 sql 會長下面這樣
所以到此問題迎刃而解 , 只要把來喇低賽的 schema 用 `modelBuilder.HasDefaultSchema("")` 移除掉事情就解決了
``` sql
SELECT
"c"."GG" AS "GG"
FROM "LADISAI"."YOURVIEW" "c"
WHERE (ROWNUM <= (10) )
```


### where in 的效能問題處理
如果要在 ef 用 sql 的 in 最直覺就是寫這樣 , 可是這樣 oracle 會產一堆亂七八糟的 code
資料筆數少的話效能還好 , 一多的話直接送你升天
``` c#
var nos = GetNos();
var result = db.Prod.AsNoTracking()
.Where( x => nos.Contains( x.Id ) )
.ToArray();
```

這裡是精隨所在! 需要使用 `Union All` 搭配 `where in` 來完成這個動作
要串 `Union All` 的原因是 oracle 用 `where in` 只允許 `1000` 筆 , 超過會噴 `ORA-01795` , 效能可以參考 [這篇](https://stackoverflow.com/questions/8107439/why-is-contains-slow-most-efficient-way-to-get-multiple-entities-by-primary-ke)
接著要讓資料分頁 , 每頁 1000 筆 , 如果小於等於 1000 筆則要用另外一個 function
``` c#
private static string GetProdSqlGreaterThan1000( IEnumerable<string> nos )
{
	//計算有幾頁
	var page = nos.Count() / 1000;

	//取得餘數
	var countMod = nos.Count() % 1000;

	//加上餘數那頁
	if( countMod > 0 )
		page += 1;

	//因為使用 in 的話 oracle 噴 ORA-01795 只允許 1000 筆 , 所以用 union all 避開這個問題
	List<string> sqls = new List<string>();
	for( int i = 0 ; i < page ; i++ )
	{
		//處理餘數
		string strPage = "";
		if( i == page )
			strPage = string.Join( ", ", nos.Skip( i * 1000 ).Take( countMod ).Select( x => $"'{x}'" ) );
		else
			strPage = string.Join( ", ", nos.Skip( i * 1000 ).Take( 1000 ).Select( x => $"'{x}'" ) );

		var sql = string.Format(
			@"
SELECT ID AS Id ,
	PRODNAME AS ProdName
FROM Prod WHERE Id IN ({0})",
			strPage );
		//Debug.WriteLine( sql );
		sqls.Add( sql );
	}

	//把 sql 語法進行 union all 處理
	string finalSql = "";
	int count = 0;
	foreach( var sql in sqls )
	{
		//最後一筆時不需要 union all
		if( sqls.Count - 1 == count )
			finalSql += sql;
		else
			finalSql += sql + " union all";

		count++;
	}

	return finalSql;
}

```

沒分頁的 function
``` c#
private static string GetProdSqlLessThan1000( IEnumerable<string> nos )
{
		var start = 0;
		var end = nos.Count();
		var strPage = string.Join( ", ", nos.Skip( start ).Take( end ).Select( x => $"'{x}'" ) );
		var sql = string.Format(
			@"
SELECT ID AS Id ,
	PRODNAME AS ProdName
FROM Prod WHERE Id IN ({0})",
			strPage );
	//Debug.WriteLine( sql );
	return sql;
}
```


判斷資料比數看要用哪個 function
``` c#
private static string GetProdUnionAllSql( IEnumerable<string> nos )
{
	//小於等於 1000 就不用分頁
	if( nos.Count() <= 1000 ) return GetProdSqlLessThan1000( nos );

	//大於 1000 使用
	return GetProdSqlGreaterThan1000( nos );
}
```

最後這樣寫即可
```
var sql = GetProdUnionAllSql( nos );
var result = db.Prod.SqlQuery( sql ).AsNoTracking().ToArray();
```


### Schema
今天遇到特別的處理法 , 平常都只讀取資料 , 今天需要寫入 , 因為資料表 schema 有分測試及正式 , 只希望開放一張可以寫
研究發發現可以這樣設定 Schema 在 attribute 上面 , 輕鬆切換
``` c#
#if DEBUG
    [Table( "Product" , Schema = "TEST")]
#endif
    public class Product{
	
	}
```


### 其他
另外要看是啥資料型態可以這樣下 , [參考](https://stackoverflow.com/questions/22962114/get-data-type-of-field-in-select-statement-in-oracle)
Data Type Mapping 參考(https://docs.microsoft.com/zh-tw/dotnet/framework/data/adonet/oracle-data-type-mappings)
```
SELECT  table_name, column_name, data_type, data_length  , nullable
FROM all_tab_columns
WHERE table_name = 'YOURVIEW'
```

後來發現他有工具可以自己反轉出類別 , 不過還沒支援 vs2022 [ODT for Visual Studio 2019](https://www.oracle.com/database/technologies/net-downloads.html)
安裝好後點選專案 => `Add` => `New Item` => `Data` => `ADO.NET Entity Data Model` => `起個好名` => `Add` =>
`Code First From Database` => `New Connection` => `Oracle Database` => `ODP.NET, Managed Driver` => `Continue` => `Connection Type` => `Advanced` => `Data source name` => `User name` => `Password`
這樣就搞定了 , 真的超複雜 , 後來發現 ef6 好像沒辦法直接生出來要退回 ef5 [參考這篇](https://entityframework.net/knowledge-base/50911394/visual-studio-entity-data-wizard--crashes-when-trying-to-connect-to-oracle)
最後忽略一點 , 好像沒辦法直接從 view 去自動產生類別

`Data source name` 範例
```
(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.123.45.67)(PORT=1521))(CONNECT_DATA=(SID=LADISAI)))
```

後來參考這個[老外](https://stackoverflow.com/questions/34336722/with-odp-net-create-c-sharp-class-struct-from-column-info-of-an-oracle-dbs-tab)
自己改寫一個撈 view 用的
``` sql
WITH cte AS (
SELECT  table_name, column_name, data_type, data_length  , nullable ,
		--這裡在 mapping c# 資料型別
         case utc.data_type
            when 'DATE' then 'DateTime'
            when 'VARCHAR2' then 'string'
            when 'CLOB' then 'string'
            when 'NUMBER' then
              case when utc.data_scale=0 then
                case
                  when utc.data_precision = 19 then 'long'
                  when utc.data_precision = 9 then 'int'
                  when utc.data_precision = 4 then 'int'
                  when utc.data_precision = 1 then 'Boolean'
                  else 'int'|| utc.data_precision  end
              else 'decimal' end
            when 'CHAR' then
              case when utc.data_length = 1 then 'char'
              else 'string' end
            else '' end as clr_data_type

FROM all_tab_columns utc

)
SELECT 'public ' || clr_data_type ||
    --判斷是否為 null 型別
    case when clr_data_type = 'string' then ''
    else
        case when nullable = 'Y' then '?'
        else '' end
    end
    || ' ' || COLUMN_NAME || ' { get;set; }' as prop
FROM cte
WHERE table_name = 'YOURVIEW'
```

最後發現可以直接用 Oracle SQL Developer 連線 MSSQL , 不過斷手斷腳嚴重 , [參考這篇](https://bioticssupport.natureserve.org/support/solutions/articles/216887-connecting-oracle-sql-developer-to-sql-server-database)


### .Net Core
在 .net core 的 ef 使用要注意下自己的版本 , 如果沒那麼快升到最新的 6 , 要留意一下 , 這裡用 5.x 最後一版
```
Install-Package Oracle.ManagedDataAccess.Core -Version 3.21.50
Install-Package Oracle.EntityFrameworkCore -Version 5.21.5
```

設定 Configuration , 這裡在 core 改成 `IEntityTypeConfiguration`
``` c#
public class YOURVIEWConfiguration : IEntityTypeConfiguration<YOURVIEW>
{
	public void Configure(EntityTypeBuilder<YOURVIEW> builder)
	{
		builder.HasKey(t => t.GG);
		builder.ToTable("YOURVIEW");
	}
}

```

設定 DbContext , 這裡有個暴雷點 , 要看自己的 Oracle 版本是多少去設定 `UseOracleSQLCompatibility` 這個參數值
我的環境好死不死是 10g , [官網](https://docs.microsoft.com/en-us/ef/core/providers/?tabs=dotnet-core-cli)寫最低好像支援到 11g ... 滿尷尬的 , 不過我測起來還是能跑 , 可以看看官方(https://docs.oracle.com/en/database/oracle/oracle-data-access-components/19.3.2/odpnt/EFCoreAPI.html#GUID-D237259B-0A8A-42D1-A142-1685AAC4178C) 跟[這篇](https://stackoverflow.com/questions/66398282/entity-framework-core-5-doesnt-support-oracle-10g)還有[這篇](https://stackoverflow.com/questions/56341445/entity-framework-core-take1-single-first-not-working-with-oracle-pr/56343155#56343155)
另外 `HasDefaultSchema` 沒辦法讓你設定空字串 , 會噴 `System.ArgumentException: 'The string argument 'schema' cannot be empty.'` , 我註解掉就能動了
最後想要 Log 的話可以直接用 `optionsBuilder.LogTo(Console.WriteLine)` 即可
``` c#
public class OracleDbContext : DbContext
{
	protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
	{
		//Log
		optionsBuilder.LogTo(Console.WriteLine);
		var str = @"User Id=LADISAI;Password=LADISAI;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.123.45.67)(PORT=1521))(CONNECT_DATA=(SID=LADISAI)))";
		//這裡要指定版本用 11
		optionsBuilder.UseOracle(str , opt => opt.UseOracleSQLCompatibility("11") );

	}

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		//這句在 .net framework 上要寫
		//modelBuilder.HasDefaultSchema("");
		modelBuilder.ApplyConfiguration(new YOURVIEWConfiguration());

	}

	public virtual DbSet<YOURVIEW> YOURVIEW { get; set; }

}

```

最後測連看看
``` c#
private static void EF()
{
	OracleDbContext db = new OracleDbContext();

	//這句要選擇 Oracle 版本 opt.UseOracleSQLCompatibility("11") , 不然會噴錯
	var test1 = db.YOURVIEW.Take(100).ToList();
	Print(test1);

	var test2 = db.YOURVIEW.ToList();
	Print(test2);
}

```

### sqlcl 筆記
可以在這裡[下載](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/)

今天被 sqlcl 愚弄了一波 , 一直連不上去 , 後來發現環境是用 `sid` 去連 , 不是 `service name` , 所以要寫下面這樣 , 真的折磨人
"username/password@(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=123.45.67.89)(PORT=1521))(CONNECT_DATA=(SID=yoursid)))"

設定日期 format
``` sql
alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';
```

[轉出 json ](https://database.guide/how-to-export-oracle-query-results-to-a-json-file-when-using-sqlcl/)
``` sql
SET SQLFORMAT json;
SPOOL test.json;
SELECT * FROM test;
SPOOL off;
SET SQLFORMAT ansiconsole;
```

結論 , 就算身為 terminal 的愛好者 , Oracle 的工具還是稍微更難用點 , 相比之下這個 [dbcli](https://github.com/dbcli) 用起來更加友善多了
