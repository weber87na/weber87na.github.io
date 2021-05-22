---
title: ef core warm up 筆記
date: 2021-04-20 19:26:32
tags: asp.net core
---
&nbsp;
<!-- more -->

### 幫 ef core warm up 暖身
因為以前用 dapper 比重比較高 , 好像沒注意到這個問題
ef 在第一次 request 的時候速度總是慢吞吞 , 剛好有點時間調整效能就順便解看看
主要解法大致上就是在啟動系統時先讓 ef 的 context 建立起來 , 舊版的話 code first 因為沒有 edmx 檔案 , 所以要加些奇怪的 code
[參考自老外](https://stackoverflow.com/questions/30423838/entity-framework-very-slow-to-load-for-first-time-after-every-compilation)
```
public void Configure( IApplicationBuilder app,
	IWebHostEnvironment env ,
	ApiDbContext dbContext){

	if (env.IsDevelopment())
	{
		app.UseDeveloperExceptionPage();
	}

	Task.Run( () => { _ = dbContext.Model; } );

	}
```

### 舊版 ef warm up 暖身
在 `Global.asax` 的 `Application_Start` 加入暖身程式碼
```
//參考自以下
//https://www.cnblogs.com/enternal/p/4764741.html
//https://www.cnblogs.com/dudu/p/entity-framework-warm-up.html
using (var dbContext = new YourDbContext())
{
	var objectContext = ((IObjectContextAdapter)dbContext).ObjectContext;
	var mappingCollection =
		(StorageMappingItemCollection)objectContext.MetadataWorkspace.GetItemCollection( DataSpace.CSSpace );
	mappingCollection.GenerateViews( new List<EdmSchemaError>() );
}
```


### ef core 使用 connection pool 連線
反正都在調校了 , 印象中用 pool 會提升效能 , 就順便設定看看筆記一下 , 結果馬上炸 error , 還好解法不難
```
The DbContext of type 'ApiDbContext' cannot be pooled because it does not have a
public constructor accepting a single parameter of type DbContextOptions or
has more than one constructor.'
```
設定 pool 部分
```
services.AddDbContextPool<ApiDbContext>(
	(serviceProvider , options )=> {
		options.UseLoggerFactory( LoggerFactory.Create( builder => builder.AddConsole() ) )
			.UseSqlServer( Configuration.GetConnectionString("Default"));
	} );
```

把 `ApiDbContext` 建構子註解起來即可
```
//public ApiDbContext()
//{
//}

public ApiDbContext( DbContextOptions<ApiDbContext> options )
	: base( options )
{
}

```

成功後會看到下列訊息
```
info: Microsoft.EntityFrameworkCore.Infrastructure[10403]
Entity Framework Core 5.0.5 initialized 'ApiDbContext' using provider 'Microsoft.EntityFrameworkCore.SqlServer' with options: MaxPoolSize=128
```
