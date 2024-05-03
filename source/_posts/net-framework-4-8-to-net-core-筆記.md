---
title: .net framework 4.8 to .net core 筆記
date: 2023-12-28 20:01:34
tags: c#
---
&nbsp;
<!-- more -->

這是我工作上升級舊版 `web api` `排程程式` 及 `底層類別` 遇到的相關解法 , 以 cookbook 的方式記錄下

## ef core

### ef core The entity type 'IdentityUserLogin<string>' requires a primary key to be defined

可以參考[這裡](https://stackoverflow.com/questions/40703615/the-entity-type-identityuserloginstring-requires-a-primary-key-to-be-defined)

因為有使用到 `IdentityDbContext<MyUser>` 所以在 `OnModelCreating` 先呼叫

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
  base.OnModelCreating(modelBuilder);
}
```

### ef core DbContext Include Roles

這個問題疑似要自己定義 Roles 沒定義這樣寫的話會噴紅字

```csharp
db.Users.Include(x => x.Roles);
```

可以參考[這篇](https://stackoverflow.com/questions/47767267/ef-core-2-how-to-include-roles-navigation-property-on-identityuser)

解法如下 , 這裡注意到使用 `IdentityUser`

需要安裝套件 `Microsoft.AspNetCore.Identity.EntityFrameworkCore`

```csharp
public class MyUser : IdentityUser{
    //要自己手動加入
    /// <summary>
    /// Navigation property for the roles this user belongs to.
    /// </summary>
    public virtual ICollection<IdentityUserRole<string>> Roles { get; } = new List<IdentityUserRole<string>>();
}
```

### ef core new DbContext

如果在以前的類別裡面有直接 `new DbContext` 這樣會噴 Erorr

```csharp
using (var db = new YourrDbContext())
```

不想要注入的話可以參考以下這個方法

```csharp
var optionsBuilder = new DbContextOptionsBuilder<YourrDbContext>();
optionsBuilder.UseSqlServer(GetConnectionString());
using (var db = new YourrDbContext(optionsBuilder.Options))

```

`GetConnectionString` 函數實作如下

```csharp
public string GetConnectionString()
{
    var builder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
    var configuration = builder.Build();
    var result = configuration.GetConnectionString("YourrDbContext");
    return result;
}

```


### ef core 沒有 SqlQuery 的解法

我升級的版本是用 .net 6 我找到這個[套件](https://github.com/PaulARoy/EntityFrameworkCore.RawSQLExtensions) `EntityFrameworkCore.RawSQLExtensions`
有了他以後基本上都無痛解決

### ef core string null 噴的錯誤

在 ef core 裡面預設的 string 會變成 not null 想要沿用以前的行為的話要在 `.csproj` 把 `<Nullable>` 註解起來

```
<!--<Nullable>enable</Nullable>-->
```

### ef core HasOptional WithMany

.net framework

```csharp
HasOptional( t => t.myUser ).WithMany();
```

.net core

```csharp
modelBuilder.Entity<ExtInfo>(entity =>
{
    entity.HasOne(x => x.myUser).WithMany();
});

```

### ef core WillCascadeOnDelete

https://stackoverflow.com/questions/55233677/what-is-the-equivalent-of-willcascadeondeletefalse-in-ef-core

在 ef core 沒這個函數了改用 OnDelete(DeleteBehavior.SetNull)

### ef core HasRequired WithMany

.net framework

```chsarp
HasRequired(t => t.ExtInfo)
.WithMany()
.HasForeignKey(t => t.ExtId);
```

.net core

```csharp
entity.HasOne(x => x.ExtInfo)
    .WithMany()
    .HasForeignKey(x => x.ExtId)
```



### ef core 多 Key 的問題

has multiple properties with the [Key] attribute. Composite primary keys can only be set using 'HasKey' in 'OnModelCreating'

https://stackoverflow.com/questions/74342264/the-entity-type-has-multiple-properties-with-the-key-attribute-composite-prim

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<MyModel>()
          .HasKey(m => new { m.column1 , m.column2 });
}
```

### ef core 手殘把關聯鍵設定為物件

cannot be used as a property on entity type because it is configured as a navigation

會出現這個應該是手殘打錯

https://stackoverflow.com/questions/58659431/propertyname-cannot-be-used-as-a-property-on-entity-type-typename-because-it

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<User>(user =>
    {
        user
        .HasOne(x => x.Gender)
        .WithMany(x => x.Users)
        .HasForeignKey(x => x.GenderId);
    }

    user.HasIndex(x => x.Gender);
}
```

這裡這個老外打錯成 `user.HasIndex(x => x.Gender)` 正解應該是 `user.HasIndex(x => x.GenderId)`

### ef core view 上面 Key 的問題

在舊版會這樣寫

```csharp
[Table("YOURVIEW")]
public class YOURVIEW
{
    [Key]
    [Column( Order = 0 )]
    public string YOURID { get; set; }
}

```

新版要把 `Key` 移除然後加上 `Keyless`

```csharp
[Table("YOURVIEW")]
[Keyless]
public class YOURVIEW
{
    //todo 他應該是 view 在 ef core 不用寫 Key 也會動
    // [Key]
    // [Column( Order = 0 )]
    public string YOURID { get; set; }
}
```

### ef core AutoInclude

如果之前的程式查詢下去會出現關聯屬性的話 , 但是你的沒出現則表示沒設定 `AutoInclude`

```csharp
public class PointLog {
    public int? Point1Id { get; set; }

    public Point Point1 { get; set; }
}

public class Point{
    [Key, DatabaseGenerated(DatabaseGeneratedOption.None)]
    public int Id { get; set; }
}
```

```csharp
modelBuilder.Entity<PointLog>().HasOne(x => x.Point1).WithMany().HasForeignKey(r => r.Point1Id);
modelBuilder.Entity<PointLog>().Navigation(x => x.Point1).AutoInclude();
```

### ef core HasDatabaseGeneratedOption(DatabaseGeneratedOption.Identity)

在 .net framework 會寫這樣

```csharp
Property( t => t.Id ).HasDatabaseGeneratedOption( DatabaseGeneratedOption.Identity )
```

ef core

https://stackoverflow.com/questions/36155429/auto-increment-on-partial-primary-key-with-entity-framework-core

```csharp
modelBuilder.Entity<Foo>()
            .Property(f => f.Id)
            .ValueGeneratedOnAdd();
```

### ef core Lazy loading

如果想要用 lazy loading 必須要自己手動啟用

https://learn.microsoft.com/en-us/ef/core/querying/related-data/lazy

需要先安裝這個套件 `Microsoft.EntityFrameworkCore.Proxies`

另外導覽屬性都要設定 `virtual` 不然也會噴 error ~

另外要注意如果由 .net framework 升級的會有多處這種地方也要記得跟著修正 `var db = new YourDbContext()`



```csharp
    builder.Services.AddDbContext<YourDbContext>(options =>
        options.UseLazyLoadingProxies().UseSqlServer(builder.Configuration.GetConnectionString("YourDbContext"))
    );
```

數量太多的話可以在建構子裡面 DbContext 設定 , 參考[官網](https://learn.microsoft.com/zh-tw/ef/core/querying/related-data/lazy)
```
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    => optionsBuilder
        .UseLazyLoadingProxies()
        .UseSqlServer(myConnectionString);
```


### ef core Lazy loading is not supported for detached entities or entities that are loaded with 'AsNoTracking'

如果 `啟用了 Lazy loading` 好像跟 entity framework 寫法略有不同 , 以下這句在 entity framework 是正常的 , 可是 ef core 就需要去掉 `AsNoTracking`

錯誤

```csharp
var test = _db.YourTable
    .Where(x => x.id == id)
    .AsNoTracking()
    .FirstOrDefault();
```

正常

```csharp
var test = _db.YourTable
    .Where(x => x.id == id)
    .FirstOrDefault();
```

這裡還有個重點 , 萬一你之前 `entity framework 6` navigation property 沒有加上 virtual 的話實際上 api 丟出來是取不到東西的像是下面這樣

沒加 `virtual`

```csharp
[ForeignKey( "DeptId" )]
public DEPT Dept { get; set; }

```

沒加 `virtual` api 結果

```json
    "Dept": null,
    "Id": "123456",
```

加了 `virtual`

```csharp
[ForeignKey( "DeptId" )]
public virtual DEPT Dept { get; set; }
```

加了 `virtual` api 結果

```json
    "Dept": {
      "Id": "123456",
      "DeptCode" : "AAA"
    },
    "oId": "123456",
```

### ef core Precision
No store type was specified for the decimal property 'YourColumn' on entity type 'YourClass' This will cause values to be silently truncated if they do not fit in the default precision and scale. Explicitly specify the SQL server column type that can accommodate all the values in 'OnModelCreating' using 'HasColumnType', specify precision and scale using 'HasPrecision', or configure a value converter using 'HasConversion'

這個問題是沒有明確定義資料型別的大小 , 例如 sql server 是 decimal(10,4) 可以用這樣定義

```csharp
class YourClass{
    [Precision(10, 4)]
    public decimal YourColumn {get;set;}
}
```

或是在 `OnModelCreating` 這樣定

```csharp
modelBuilder.Entity<YourClass>(entity =>
{
    entity.Property(x => x.YourColumn).HasPrecision(10, 4);

}
```

### ef core Keyless
The entity type 'YourCol' has the [Keyless] attribute, but the [Key] attribute was specified on property 'YourView'; the two are incompatible, consider removing one. Note that the entity will have no key unless you configure one in 'OnModelCreating'

這個問題應該是你已經在類別設定 `Keyless` 那個欄位上的 `Key` 卻忘了移除

```csharp
[Keyless]
class YourView{

    [Key]
    public int YourCol {get;set;}

}
```

### ef core BackingField
Lazy-loaded navigations must have backing fields. Either name the backing field so that it is discovered by convention or configure the backing field to use

這個問題是因為在 .net core 上面要標註 `BackingField` 不然會噴 error 以前好像沒這東西

```csharp
private string name;

[BackingField(nameof(name))]
public virtual string Name
{
    get { return name; }
    set { name = value; }
}

```


### ef core string.Compare 的坑

本來有有串在 ef 6 這樣寫給過 , 它裡面用了 `string.Compare` 在 ef core 就炸了

The LINQ expression 'DbSet<XXX>()
.Where(b => 
string.Compare(\r\n strA: **code_0, \r\n strB: b.Start, \r\n ignoreCase: True) >= 0 && 
string.Compare(\r\n strA: **code_0, \r\n strB: b.End, \r\n ignoreCase: True) <= 0)' 
could not be translated. 

Additional information: Translation of method 'string.Compare' failed. 
If this method can be mapped to your custom function, see https://go.microsoft.com/fwlink/?linkid=2132413 for more information.
Translation of method 'string.Compare' failed.
If this method can be mapped to your custom function, see https://go.microsoft.com/fwlink/?linkid=2132413 for more information.
Either rewrite the query in a form that can be translated, or switch to client evaluation explicitly by inserting a call to 'AsEnumerable', 'AsAsyncEnumerable', 'ToList', or 'ToListAsync'.
See https://go.microsoft.com/fwlink/?linkid=2101038 for more information.

```csharp
var result = db.XXX
.Where( x => string.Compare( code, x.Start, true ) >= 0 && string.Compare( code, x.End, true ) <= 0 )
.AsNoTracking()
.FirstOrDefault();
```

舊版打出來的 sql 如下 , 要印出方法可以參考[這裡](https://stackoverflow.com/questions/1412863/how-do-i-view-the-sql-generated-by-the-entity-framework)

```csharp
var sql = ((System.Data.Objects.ObjectQuery)query).ToTraceString();
```

```sql
SELECT
[Extent1].[id] AS [id],
[Extent1].[Code] AS [Code],
[Extent1].[Start] AS [Start],
[Extent1].[End] AS [End]
FROM [dbo].[XXX] AS [Extent1]
WHERE (@p__linq__0 >= [Extent1].[Start]) AND (@p__linq__1 <= [Extent1].[End])
```

後來測半天 , 改用以下查詢

```csharp
var result = db.XXX
.Where(x => code.CompareTo(x.Start) >= 0)
.Where(x => code.CompareTo(x.End) <= 0)
.AsNoTracking()
.FirstOrDefault();

```

打出來的 sql 如下

```sql
SELECT [b].[id], [b].[Code], [b].[Start], [b].[End]
FROM [XXX] AS [b]
WHERE (@__code_0 >= [b].[StartSeq]) AND (@__code_0 <= [b].[EndSeq])
```


### ef core 'System.Single' to type 'System.Double'.'

這個問題是你設定的 entity 資料型別與 db 的不相符合

例如測試機寫成 real , 正式機用 decimal 然後你的 entity 設定資料型別用 decimal

```csharp
entity.Property(x => x.Power).HasPrecision(14, 5);
```

要比對正式與測試的 table 可以先 create as script

然後用這個[線上工具](https://www.diffchecker.com/text-compare/) 看看印出來的相異之處


### ef core CTE
這個還滿雷的跟以前寫發差異有點多 , 要先定義 CTE 的類別在 DbContext , 並且類別的欄位一定要用到 , 不然也會噴錯
還有如果偷懶有兩個 column 名稱一樣的話 , 也是會炸 , 要特別注意
```
public virtual DbSet<YOURCTEVIEW> YOURCTEVIEW { get; set; }

```

接著在 `OnModelCreating` 定義這個設定
```
modelBuilder.Entity<YOURCTEVIEW>().HasNoKey().ToView(null);
```

最後使用的時候要這樣寫
```
db.Set<YOURCTEVIEW>().FromSqlRaw(sql).ToList();
```

### ef core HasPrecision 快速修正
warn: Microsoft.EntityFrameworkCore.Model.Validation[30000]
      No store type was specified for the decimal property 'COLUMNNAME' on entity type 'TABLENAME'. 
	  This will cause values to be silently truncated if they do not fit in the default precision and scale. 
	  Explicitly specify the SQL server column type that can accommodate all the values in 'OnModelCreating' using 'HasColumnType', 
	  specify precision and scale using 'HasPrecision', 
	  or configure a value converter using 'HasConversion'.
	  
如果噴一堆這種類似的錯誤他會跳警告 , 可以在 sql server 上面下這串 , 自己產 code 然後加在 DbContext 裡面
```
select COLUMN_NAME , NUMERIC_PRECISION , NUMERIC_SCALE , 
'entity.Property(e=>e.' + COLUMN_NAME + ').HasPrecision('+ convert(varchar, NUMERIC_PRECISION) + ', '+ convert(varchar,NUMERIC_SCALE) + ');'
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='TABLENAME'
and DATA_TYPE = 'decimal'
```

最後在 OnModelCreating 加上去
```
modelBuilder.Entity<TABLENAME>(entity =>
{
	entity.Property(e => e.COLUMNNAME).HasPrecision(8, 1);
});
```

### ef core CommandTimeout
https://stackoverflow.com/questions/39058422/how-to-set-command-timeout-in-asp-net-core-entity-framework-core

舊版
```
db.Database.CommandTimeout = 300;
```

.net core
```
var optionsBuilder = new DbContextOptionsBuilder<YourDbContext>();
optionsBuilder.UseOracle(GetDbConnectionString() , opt => opt.CommandTimeout(60));


services.AddDbContext<YourDbContext>(options => options.UseOracle(
    this.Configuration.GetConnectionString("YourConnectionString"),
    sqlServerOptions => sqlServerOptions.CommandTimeout(60))
);
```


### ef core Connection.State
舊版
```
if (db.Database.Connection.State != ConnectionState.Open)
	db.Database.Connection.Open();

```

.net core
```
if (db.Database.GetDbConnection().State != ConnectionState.Open)
	db.Database.GetDbConnection().Open();

```


### ef core Cannot convert implicitly a type 'System.Linq.IQueryable' into 'Microsoft.EntityFrameworkCore.Query.IIncludableQueryable'
參考這篇
https://iditect.com/faq/csharp/cannot-convert-implicitly-a-type-39systemlinqiqueryable39-into-39microsoftentityframeworkcorequeryiincludablequeryable39.html

```
// This will throw a compile-time error
var query = context.MyEntity.Include(e => e.RelatedEntity);

// This will work correctly
var query = context.MyEntity.Include(e => e.RelatedEntity).AsQueryable();
```


## Autofac

### Autofac 注入 DbContext

基本上最好是用注入的

```csharp
builder.Register(x =>
{
    var optionsBuilder = new DbContextOptionsBuilder<YourDbContext>();
    optionsBuilder.UseSqlServer(configuration.GetConnectionString("YourDbContext"));
    return new YourDbContext(optionsBuilder.Options);
})
.InstancePerLifetimeScope()
.Named("db", typeof(YourDbContext));

```

### Autofac 注入多參數建構子

```csharp
builder.RegisterType<OOService>()
    .As<IOOService>()
    .UsingConstructor(
        typeof(YourDbContext),
        typeof(GGDbContext)
    )
    .WithParameters(new List<ResolvedParameter>() {
        new ResolvedParameter(
            (pi, ctx) => pi.ParameterType == typeof(YourDbContext),
            (pi, ctx) => ctx.ResolveNamed<YourDbContext>("db")),

        new ResolvedParameter(
            (pi, ctx) => pi.ParameterType == typeof(GGDbContext),
            (pi, ctx) => ctx.ResolveNamed<GGDbContext>("gg"))
    })
    .Named("ooService", typeof(IOOService));

```

### Autofac 注入物件

```csharp
//這裡好像不加 As 使用具名會壞掉
builder.RegisterType<OOService>()
.As<OOService>()
.Named("ooService",typeof(OOService));

```

## 其他類

### ApiController 修正
.net core 改用 `IActionResult` 取代 `IHttpActionResult`

### Newtonsoft

舊版 `.net framework` 應該都用 `Newtonsoft`
`.net core` 預設會用 `System.Text.Json` 來處理 json
所以最好安裝以下這兩個套件
`Microsoft.AspNetCore.Mvc.NewtonsoftJson`
`Swashbuckle.AspNetCore.Newtonsoft`

```csharp
    builder.Services.AddControllers().AddNewtonsoftJson(opt =>
    {
        opt.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
        opt.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
    });

    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo
        {
            Version = "v1",
            Title = "ToDo API",
            Description = "An ASP.NET Core Web API for managing ToDo items",
            TermsOfService = new Uri("https://example.com/terms"),
            Contact = new OpenApiContact
            {
                Name = "Example Contact",
                Url = new Uri("https://example.com/contact")
            },
            License = new OpenApiLicense
            {
                Name = "Example License",
                Url = new Uri("https://example.com/license")
            }
        });

        // using System.Reflection;
        var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
        options.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, xmlFilename));
    });
    builder.Services.AddSwaggerGenNewtonsoftSupport();

```

此外好像 `.csproj` 還要加上這個設定才會正常產文件

```xml
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
```

### UserManager CreateIdentityAsync 移除的解法

在 .net framework 使用到了 `CreateIdentityAsync` 這個函數但是 .net core 已經移除了

```csharp
//他這裡 return ClaimsIdentity
var claimsIdentity = await mgr.CreateIdentityAsync(this, DefaultAuthenticationTypes.ApplicationCookie);
```

我目前的解法是改用如下方式 , 不過尚未驗證
可參考
https://stackoverflow.com/questions/40304516/the-name-defaultauthenticationtypes-does-not-exist-in-the-current-context
https://github.com/aspnet/AspNetIdentity/blob/main/src/Microsoft.AspNet.Identity.Core/DefaultAuthenticationTypes.cs

這句 `DefaultAuthenticationTypes.ApplicationCookie` 就是個常數 `ApplicationCookie`

```csharp
var claimsIdentity = new ClaimsIdentity(await mgr.GetClaimsAsync(this), "ApplicationCookie");
```

### AspNetUser 資料表的問題

如果要在 .net core 使用 `IdentityUser` 的話會噴以下錯誤 , 這是因為新的資料表有這些欄位 , 升級時應該要注意下這個部分

https://stackoverflow.com/questions/50343512/migrate-existing-microsoft-aspnet-identity-db-ef-6-to-microsoft-aspnetcore-ide

https://www.youtube.com/watch?v=CByZc2CDDqE

```
Microsoft.Data.SqlClient.SqlException (0x80131904): 無效的資料行名稱 'ConcurrencyStamp'。
無效的資料行名稱 'LockoutEnd'。
無效的資料行名稱 'NormalizedEmail'。
無效的資料行名稱 'NormalizedUserName
```

### Application_Start 的解法
var app = builder.Build();

//https://learn.microsoft.com/zh-tw/aspnet/core/migration/50-to-60-samples?view=aspnetcore-8.0
IHostApplicationLifetime lifetime = app.Lifetime;

//Application_Start
lifetime.ApplicationStarted.Register(() =>
{
	//你需要執行的內容
});

### MapPath 的解法

假設有用到 `MapPath` 取得 `App_Data` 資料夾的話 , 可以用以下方法解決
```
//var targetPath = $"{HostingEnvironment.MapPath("~/App_Data")}/photos";
var targetPath = Path.Combine(Directory.GetCurrentDirectory(), "App_Data/photos");
```

### ActionFilter OnActionExecuted 的坑

在舊版的 mvc 裡面自訂 ActionFilter 通常會複寫 `OnActionExecuting` 及 `OnActionExecuted`
可以用 `HttpActionContext` 的 `ActionArguments` 去塞一些狀態 , 如執行時間 , 拿 client ip 作比對等等 , 大概長以下這樣

```
public override void OnActionExecuting( HttpActionContext actionContext ){
	actionContext.ActionArguments["ip"] = ip;
}

public override void OnActionExecuted( HttpActionExecutedContext filterContext ){
	var ip = filterContext.ActionContext.ActionArguments["ip"];
}
```

可是在 . net core 裡面是拿不到 OnActionExecuted 裡面的東東 , 所以要改寫這樣
```
public override void OnActionExecuting(ActionExecutingContext context){

	var ip = context.HttpContext.Features.Get<IHttpConnectionFeature>()?.RemoteIpAddress.ToString();
	context.HttpContext.Items["ip"] = ip;
}

public override void OnActionExecuted(ActionExecutedContext context){
	var ip = (T)context.HttpContext.Items["ip"];
}
```

### 多語系

多語系如果沿用舊版的 Resource 可以這樣寫 , 他會在你 Request 裡面去用對應的語系處理 , 幾乎無痛升級
一開始看到要在 controller 加上一堆 `IStringLocalizer` 差點嚇死 , 好險後來找到這個方法
```    
	builder.Services.AddLocalization();
    builder.Services.Configure<RequestLocalizationOptions>(
        options =>
        {
            //取得目前語系
            var currentCulture = CultureInfo.CurrentCulture;
            Console.WriteLine(currentCulture);
            var supportedCultures = new List<CultureInfo>
            {
                new CultureInfo("zh-TW"),
                new CultureInfo("en"),
                new CultureInfo("zh-CN"),
            };

            //設定目前語系
            options.DefaultRequestCulture = new RequestCulture(currentCulture);
            //options.DefaultRequestCulture = new RequestCulture(culture: "en-US", uiCulture: "en-US");

            options.SupportedCultures = supportedCultures;
            options.SupportedUICultures = supportedCultures;
        });
		
		
    //多語系
    app.UseRequestLocalization();
```

### IHttpActionResult
基本上看到 IHttpActionResult 只要改成 IActionResult 即可