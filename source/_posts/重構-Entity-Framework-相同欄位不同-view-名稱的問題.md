---
title: 重構 Entity Framework 相同欄位不同 view 名稱的問題
date: 2023-03-17 19:30:11
tags: 
- csharp
- ef
---
&nbsp;
<!-- more -->

同事遇到的問題 , 順手解看看 , 有兩張 view , 分別對應中文及英文 , 欄位名稱都一模一樣 , 查詢條件也永遠都一樣 , 用以下 code 模擬
內心 OS : 好在只有中英文 , 不然哪天加個非洲語跟印度話之類的 , 整個 code 又膨脹 N 多倍 , 不就又更智障 XXXD
另外他們的 view 存放日期是用 varchar OOXX 因為已經綁死 , 所以不能改

### 測試資料
``` sql
create or alter view [dbo].[twcte] as
with cte(Id , UserName , OrderDate) as (
	select 1 as Id ,  N'測試' + cast( 1 as nvarchar ) as UserName , '2022/01/0' + cast( 1 as varchar ) as OrderDate
	union all
	select 1 + Id  , N'測試' + cast( 1 + Id as nvarchar ) , '2022/01/0' + cast( 1 + Id as varchar ) as OrderDate
	from cte
	where Id < 9
)
select Id , UserName , OrderDate
from cte as [twcte]

create or alter view [dbo].[encte] as
with cte(Id , UserName , OrderDate) as (
	select 1 as Id ,  'Test' + cast( 1 as varchar ) as UserName , '2022/01/0' + cast( 1 as varchar ) as OrderDate
	union all
	select 1 + Id  , 'Test' + cast( 1 + Id as varchar ) , '2022/01/0' + cast( 1 + Id as varchar ) as OrderDate
	from cte
	where Id < 9
)
select Id , UserName , OrderDate
from cte as encte

```

查詢結果如下
```
twcte
1	測試1	2022/01/01
2	測試2	2022/01/02
3	測試3	2022/01/03
4	測試4	2022/01/04
5	測試5	2022/01/05
6	測試6	2022/01/06
7	測試7	2022/01/07
8	測試8	2022/01/08
9	測試9	2022/01/09

encte
1	Test1	2022/01/01
2	Test2	2022/01/02
3	Test3	2022/01/03
4	Test4	2022/01/04
5	Test5	2022/01/05
6	Test6	2022/01/06
7	Test7	2022/01/07
8	Test8	2022/01/08
9	Test9	2022/01/09

如果有非洲就加上去吧!
```

### 內建的笨方法

因為目前有兩國語言 , 所以每個 Repository 要寫很多重複的 code , 每次改動需要兩個 function 裡面的程式碼都要修改大概 200 - 300 行 , 類似以下這樣
``` csharp
private List<EN> GetEN(){
var query = repository.GetAll();
	//很多同樣的邏輯條件
	return query.Where(x => x.Code == 1)
			.Where(x => x.OrderDate == "XXX")
			.Where(x => x.Category == "OOO");
}

private List<TW> GetTW(){
var query = repository.GetAll();
	//很多同樣的邏輯條件
	return query.Where(x => x.Code == 1)
			.Where(x => x.OrderDate == "XXX")
			.Where(x => x.Category == "OOO");
}
```

研究下發現可以繼承同個父類別解決此問題 , model 大概長這樣

``` csharp
public class ParentView
{
	public int Id { get; set; }
	public string UserName { get; set; }
	public string OrderDate { get; set; }
}


[Table("encte")]
public class EnCte : ParentView
{
}

[Table("twcte")]
public class TwCte : ParentView
{
}

public class CteDBContext : DbContext
{
	public CteDBContext(string connectionString) : base(connectionString)
	{
		Database.SetInitializer<CteDBContext>(null);
	}
	public DbSet<EnCte> EnCtes { get; set; }
	public DbSet<TwCte> TwCtes { get; set; }
}

```


接著分別建立可以產 Repository 的物件 , 還有可以將查詢收攏的物件 , 這裡最關鍵就是要設定 `where T : ParentView` 去約束
然後藉由 `QueryIdEqOne` 去把本來很傻的呼叫收攏成一個函數即可 另外這裡還有個重點 , 一般來說沒辦法在 ef 裡面去轉換 string 為 datetime , 會噴 error , 研究了一陣子發現可以用 `SqlFunctions.DateAdd` 然後讓天數加 0 天就可以達成 string to datetime

如果是在 .net core 可以參考這篇[說明](https://dasith.me/2022/01/23/ef-core-datetime-conversion-rabbit-hole/)
總之也是要自訂類似的 `function` 不然就要用 DateTimeOffset 去騙 ef core
``` csharp
public class QueryHelper
{
	public static IQueryable<T> Query<T>(IRepository<T> repository) where T : ParentView
	{
	    DateTime beginDate = DateTime.Parse("2022-01-05");
	    DateTime endDate = DateTime.Parse("2022-01-08");

	    var query = repository.GetAll();
	    //很多同樣的邏輯條件
	    return query.Where(x => x.Id > 1)
			.Where(x =>
			    SqlFunctions.DateAdd("day", 0, x.OrderDate) >= beginDate &&
			    SqlFunctions.DateAdd("day", 0, x.OrderDate) < endDate
			);
	}
}




public interface IRepository<T>
{
	IQueryable<T> GetAll();
}

public class LangRepository<T> : IRepository<T> where T : ParentView
{
	private CteDBContext db;
	public LangRepository(CteDBContext db)
	{
		this.db = db;
	}
	public IQueryable<T> GetAll()
	{
		var type = typeof(T);
		if (type == typeof(EnCte))
		{
			var query = db.EnCtes.Cast<T>().AsQueryable();
			return query;
		}
		if (type == typeof(TwCte))
		{
			var query = db.TwCtes.Cast<T>().AsQueryable();
			return query;
		}

		throw new Exception("Type not found");

	}
}
```


最後可以測看看結果如何
```
    internal class Program
    {
        static void Main(string[] args)
        {
            try
            {
                using (var db = new CteDBContext("DefaultConnection"))
                {
                    db.Database.Log = e => Console.WriteLine(e);
                    var twRepository = new LangRepository<TwCte>(db);
                    var tws = QueryHelper.Query(twRepository).ToList();
                    foreach (var tw in tws)
                    {
                        Console.WriteLine(tw.UserName);
                        Console.WriteLine(tw.Id);
                        Console.WriteLine(tw.OrderDate);
                    }

                    var enRepository = new LangRepository<EnCte>(db);
                    var ens = QueryHelper.Query(enRepository).ToList();

                    foreach (var en in ens)
                    {
                        Console.WriteLine(en.UserName);
                        Console.WriteLine(en.Id);
                        Console.WriteLine(en.OrderDate);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }

            Console.ReadLine();
        }
    }

```

產出 sql 如下
```
Opened connection at 2023/3/19 上午 12:45:55 +08:00

SELECT
    [Extent1].[Id] AS [Id],
    [Extent1].[UserName] AS [UserName],
    [Extent1].[OrderDate] AS [OrderDate]
    FROM [dbo].[twcte] AS [Extent1]
    WHERE ([Extent1].[Id] > 1) AND ((DATEADD(day, cast(0 as float(53)), [Extent1].[OrderDate])) >= @p__linq__0) AND ((DATEADD(day, cast(0 as float(53)), [Extent1].[OrderDate])) < @p__linq__1)


-- p__linq__0: '2022/1/5 上午 12:00:00' (Type = DateTime2, IsNullable = false)

-- p__linq__1: '2022/1/8 上午 12:00:00' (Type = DateTime2, IsNullable = false)

-- Executing at 2023/3/19 上午 12:45:56 +08:00

-- Completed in 7 ms with result: SqlDataReader
```



connectionString

```
  <connectionStrings>
    <add name="DefaultConnection" connectionString="Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=test;Integrated Security=True"
    providerName="System.Data.SqlClient" />
  </connectionStrings>
```


後來發現另外一個方法不過也是很迂迴 , 如果有字串處理需求可能可以考慮用看看 , 需要先[安裝這個大神的 lib](https://weblogs.asp.net/Dixin/EntityFramework.Functions) 接著讓 year , month , day 三個函數實作出來
```
    public static class BuiltInFunctions
    {
        [Function(FunctionType.BuiltInFunction, "Month")]
        public static int Month(this string value) => Function.CallNotSupported<int>();

        [Function(FunctionType.BuiltInFunction, "Year")]
        public static int Year(this string value) => Function.CallNotSupported<int>();

        [Function(FunctionType.BuiltInFunction, "Day")]
        public static int Day(this string value) => Function.CallNotSupported<int>();
    }

```

DbContext 的部分也要進行設定才能 work
```
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Conventions.Add(new FunctionConvention(typeof(BuiltInFunctions)));
            base.OnModelCreating(modelBuilder);
        }
```

最後搭配 DbFunctions 裡面的 CreateDateTime 一樣可以做出類似效果 , 不過產的 sql 很噁心就是
```
        public static IQueryable<T> Query<T>(IRepository<T> repository) where T : ParentView
        {
            DateTime beginDate = DateTime.Parse("2022-01-05");
            DateTime endDate = DateTime.Parse("2022-01-08");

            var query = repository.GetAll();
            //很多同樣的邏輯條件
            //return query
            //.Where(x =>
            //    SqlFunctions.DateAdd("day", 0, x.OrderDate) >= beginDate &&
            //    SqlFunctions.DateAdd("day", 0, x.OrderDate) < endDate
            //);

            return query
            .Where(x =>
            DbFunctions.CreateDateTime(
                BuiltInFunctions.Year(x.OrderDate),
                BuiltInFunctions.Month(x.OrderDate),
                BuiltInFunctions.Day(x.OrderDate),
                0, 0, 0 )
                 >= beginDate &&
            DbFunctions.CreateDateTime(
                BuiltInFunctions.Year(x.OrderDate),
                BuiltInFunctions.Month(x.OrderDate),
                BuiltInFunctions.Day(x.OrderDate),
                0, 0, 0 )
                 < endDate
            );

        }
    }

```

產出的 sql
```
SELECT
    [Extent1].[Id] AS [Id],
    [Extent1].[UserName] AS [UserName],
    [Extent1].[OrderDate] AS [OrderDate]
    FROM [dbo].[twcte] AS [Extent1]
    WHERE ((convert (datetime2,right('000' + convert(varchar(255), Year([Extent1].[OrderDate])), 4) + '-' + convert(varchar(255), Month([Extent1].[OrderDate])) + '-' + convert(varchar(255), Day([Extent1].[OrderDate])) + ' ' + convert(varchar(255), 0) + ':' + convert(varchar(255), 0) + ':' + str(cast(0 as float(53)), 10, 7), 121)) >= @p__linq__0) AND ((convert (datetime2,right('000' + convert(varchar(255), Year([Extent1].[OrderDate])), 4) + '-' + convert(varchar(255), Month([Extent1].[OrderDate])) + '-' + convert(varchar(255), Day([Extent1].[OrderDate])) + ' ' + convert(varchar(255), 0) + ':' + convert(varchar(255), 0) + ':' + str(cast(0 as float(53)), 10, 7), 121)) < @p__linq__1)


-- p__linq__0: '2022/1/5 上午 12:00:00' (Type = DateTime2, IsNullable = false)

-- p__linq__1: '2022/1/8 上午 12:00:00' (Type = DateTime2, IsNullable = false)
```

### 自訂轉換 string to datetime 解法
最後覺得治標不治本 , 花了不少時間找到真正的解法 , 我把他改為可以轉 datetime [參考自此](https://stackoverflow.com/questions/29503962/are-model-defined-functions-still-supported-in-ef6)
```
    public class StringToDatetimeFunctionConvertions : IConceptualModelConvention<EdmModel>
    {
        public void Apply(EdmModel item, DbModel model)
        {
            var functionParseDate = new EdmFunctionPayload()
            {
                CommandText = $"CAST(str AS {PrimitiveType.GetEdmPrimitiveType(PrimitiveTypeKind.DateTime)})",
                Parameters = new[] {
                    FunctionParameter.Create("str", PrimitiveType.GetEdmPrimitiveType(PrimitiveTypeKind.String), ParameterMode.In),
                },

                ReturnParameters = new[] {
                    FunctionParameter.Create("ReturnValue", PrimitiveType.GetEdmPrimitiveType(PrimitiveTypeKind.DateTime), ParameterMode.ReturnValue),
                },
                IsComposable = true
            };

            var function = EdmFunction.Create("CastStringToDatetime", model.ConceptualModel.EntityTypes.First().NamespaceName, DataSpace.CSpace, functionParseDate, null);
            model.ConceptualModel.AddItem(function);
        }
    }
```

然後在 DbContext 加入以下程式碼 DbFunction 的第一個參數要用你的 namespace
```
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Conventions.Add(new StringToDatetimeFunctionConvertions());
            base.OnModelCreating(modelBuilder);
        }
		
        [DbFunction("ConsoleApp1", "CastStringToDatetime")]
        public static DateTime CastStringToDatetime(string value)
        {
            throw new NotImplementedException();
        }
		

```


最後修改使用自訂的轉換

```
    public class QueryHelper
    {
        public static IQueryable<T> Query<T>(IRepository<T> repository) where T : ParentView
        {
            DateTime beginDate = DateTime.Parse("2022-01-05");
            DateTime endDate = DateTime.Parse("2022-01-08");

            var query = repository.GetAll();
            //很多同樣的邏輯條件

            return query.Where(x => 
                CteDBContext.CastStringToDatetime(x.OrderDate) >= beginDate && 
                CteDBContext.CastStringToDatetime(x.OrderDate) < endDate
            );

        }
    }

```

產生的 sql
```

SELECT
    [Extent1].[Id] AS [Id],
    [Extent1].[UserName] AS [UserName],
    [Extent1].[OrderDate] AS [OrderDate]
    FROM [dbo].[twcte] AS [Extent1]
    WHERE ( CAST( [Extent1].[OrderDate] AS datetime2) >= @p__linq__0) AND ( CAST( [Extent1].[OrderDate] AS datetime2) < @p__linq__1)
```
