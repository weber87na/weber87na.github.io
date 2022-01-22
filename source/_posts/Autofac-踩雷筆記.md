---
title: Autofac 踩雷筆記
date: 2021-12-18 03:59:42
tags: .net core
---
&nbsp;
<!-- more -->

最近專案因為用 autofac , 又踩一堆雷 , 套件換來換去心累 , 只好筆記一下 , 我是用 `net 5` 進行實作 , [參考這個大陸人](https://vickchen.win/2020/202002182318/)

### .net core
這邊直接開個預設 web api 範本來起手

先安裝 `Autofac` 跟 `Autofac.Extensions.DependencyInjection` , 接著調整 `Program` 多插上這句 `UseServiceProviderFactory(new AutofacServiceProviderFactory())`
```
public class Program
{
	public static void Main( string[] args )
	{
		CreateHostBuilder( args ).Build().Run();
	}

	public static IHostBuilder CreateHostBuilder( string[] args ) =>
		Host.CreateDefaultBuilder( args )
			.UseServiceProviderFactory(new AutofacServiceProviderFactory())
			.ConfigureWebHostDefaults( webBuilder =>
			 {
				 webBuilder.UseStartup<Startup>();
			 } );
}

```

接著手動在 `Startup` 加入方法 `ConfigureContainer` 然後寫 autofac 的設定在裡面 , 我是遇到 `Cannot choose between multiple constructors with equal length 1 on type` 這個雷 , 所以設定去找自己想要的建構子
在 `ConfigureServices` 先調整這句 `services.AddControllers()` => `services.AddControllers().AddControllersAsServices()`
接著加入這句 `services.AddAutofac( ConfigureContainer )` 即可 , 另外也可以繼承自 autofac 的 `Module` override Load 方法寫設定在裡面也可以

`Startup`
```
public class Startup
{
	public Startup( IConfiguration configuration )
	{
		Configuration = configuration;
	}

	public IConfiguration Configuration { get; }

	// This method gets called by the runtime. Use this method to add services to the container.
	public void  ConfigureServices( IServiceCollection services )
	{

		services.AddControllers().AddControllersAsServices();
		services.AddSwaggerGen( c =>
		 {
			 c.SwaggerDoc( "v1", new OpenApiInfo { Title = "WebApplicationAutofac", Version = "v1" } );
		 } );

		services.AddAutofac( ConfigureContainer );
	}

	public void ConfigureContainer( ContainerBuilder builder )
	{
		//方法 1 直接寫裡面即可
		builder.RegisterType<WeatherForecastController>().PropertiesAutowired();
		builder.RegisterType<TestDI>()
			.AsSelf()
			.UsingConstructor(typeof(string))
			.WithParameter( new TypedParameter( typeof( string ), "s" ) )
			.WithParameter( new TypedParameter( typeof( int ), 123 ) )
			.PropertiesAutowired();

		//方法 2
		//builder.RegisterModule<ConfigureAutofac>();
	}

	// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
	public void Configure( IApplicationBuilder app, IWebHostEnvironment env )
	{
		if (env.IsDevelopment())
		{
			app.UseDeveloperExceptionPage();
			app.UseSwagger();
			app.UseSwaggerUI( c => c.SwaggerEndpoint( "/swagger/v1/swagger.json", "WebApplicationAutofac v1" ) );
		}

		app.UseRouting();

		app.UseAuthorization();

		app.UseEndpoints( endpoints =>
		 {
			 endpoints.MapControllers();
		 } );
	}
}

```

`ConfigureAutofac`
```
public class ConfigureAutofac : Module
{
	protected override void Load( ContainerBuilder builder )
	{
		builder.RegisterType<WeatherForecastController>().PropertiesAutowired();
		builder.RegisterType<TestDI>()
			.AsSelf()
			.UsingConstructor(typeof(string))
			.WithParameter( new TypedParameter( typeof( string ), "s" ) )
			.WithParameter( new TypedParameter( typeof( int ), 123 ) )
			.PropertiesAutowired();
	}
}
```

`TestDI`
```
public class TestDI    {
	public ILogger<TestDI> MyProperty { get; set; }
	public TestDI( string s )
	{
		Console.WriteLine( s );
	}

	public TestDI( int i )
	{
		Console.WriteLine( i );
	}

	public void Test()
	{
		MyProperty.LogInformation( "test" );
		Console.WriteLine("test");
	}
}

```


### abp
abp 內建就直接整合 autofac
因為炸了這個 error `Cannot choose between multiple constructors with equal length 1 on type` 不得不手動設定 , 不然預設就可以直接無腦用 DI
以官方的範例為例只要加在 `Acme.BookStore.Web` 這個專案底下的 `BookStoreWebModule` 這個類別的 `PreConfigureServices` 方法即可
後來發現直接放在 `ConfigureServices` 也是可以動

```
public override void PreConfigureServices(ServiceConfigurationContext context)
{
	context.Services.PreConfigure<AbpMvcDataAnnotationsLocalizationOptions>(options =>
	{
		options.AddAssemblyResource(
			typeof(BookStoreResource),
			typeof(BookStoreDomainModule).Assembly,
			typeof(BookStoreDomainSharedModule).Assembly,
			typeof(BookStoreApplicationModule).Assembly,
			typeof(BookStoreApplicationContractsModule).Assembly,
			typeof(BookStoreWebModule).Assembly
		);

	});

	context.Services.PreConfigure<IMvcBuilder>( mvcBuilder =>
	{
		mvcBuilder.AddNewtonsoftJson(
		 options => options.SerializerSettings.ContractResolver = new DefaultContractResolver() );
	} );
	context.Services.PreConfigure<AbpJsonOptions>( options =>
	{
		options.UseHybridSerializer = false;
	} );

	//設定手動 DI
	var builder = context.Services.GetContainerBuilder();

	//abp 的話這句預設就會幫你注入
	//builder.RegisterType<MyAppService>().PropertiesAutowired();

	//手動設定選擇建構子
	builder.RegisterType<TestDI>()
		.AsSelf()
		.UsingConstructor( typeof( string ) )
		.WithParameter( new TypedParameter( typeof( string ), "s" ) )
		//.WithParameter( new TypedParameter( typeof( int ), 123 ) )
		.PropertiesAutowired();
}

```

`TestDI`
```
    public class TestDI    {
        public ILogger<TestDI> MyProperty { get; set; }
        public TestDI( string s )
        {
            Console.WriteLine( s );
        }

        public TestDI( int i )
        {
            Console.WriteLine( i );
        }

        public void Test()
        {
            MyProperty.LogInformation( "test" );
            Console.WriteLine("test");
        }
    }


```

`MyAppService`
```
public class MyAppService : BookStoreAppService
{
	//private readonly TestService service;
	//public MyAppService( TestService service )
	//{
	//    this.service = service;
	//}

	protected TestService MyTestService => lazy.Value;
	private readonly Lazy<TestService> lazy = null;
	public MyAppService()
	{

		lazy = new Lazy<TestService>( () => new TestService(   ) );

	}

	public TestDI Haha { get; set; }

	[HttpGet("Ha")]
	public void Ha()
	{
		Haha.Test();
		Haha.Test();
	}
}

```


最後萬一炸 Could not find ContainerBuilder. Be sure that you have called UseAutofac method before!
可以參考[這篇](https://github.com/abpframework/abp/issues/391)
把 `Program` 的 `UseAutofac()` 順序調整一下即可
`Program`
```
internal static IHostBuilder CreateHostBuilder(string[] args) =>
	Host.CreateDefaultBuilder(args)
		//調整過的位置
		.UseAutofac()
		.ConfigureAppConfiguration(build =>
		{
			build.AddJsonFile("appsettings.secrets.json", optional: true);
		})
		.ConfigureWebHostDefaults(webBuilder =>
		{
			webBuilder.UseStartup<Startup>();
		})
		//原本位置
		//.UseAutofac()
		.UseSerilog();
```

### lazy 地雷
今天遇到的雷筆記一下 , 因為舊系統用了一堆 lazy , 三不五時就炸 null , 只好想辦法乖乖把 lazy 先暫時換掉
```
public class TestLazyService: ITransientDependency
{
	protected LaSaiService LazyService => lazyService.Value;
	private readonly Lazy<LaSaiService> lazyService = null;

	public TestLazyService()
	{
		lazyService = new Lazy<LaSaiService>( () => new LaSaiService() );
	}

	public void Test()
	{
		LazyService.Test();
	}

}

public class LaSaiService: ITransientDependency
{
	public ILogger<LineService> Logger { get; set; }

	public LaSaiService()
	{
		//注意這句使用 property injection 時一開始在建構子裡面會是 null
		if(Logger is null)
			Console.WriteLine("Logger is null");
	}

	public void Test()
	{
		//這句也是關鍵 , 使用 lazy 去 new 出來 LaSaiService 的話 , 這邊會是 null
		Logger.LogInformation( "TEST" );
	}

}
```

在 `ConfigureServices` 插入這個測試看看
```
private void TestDI()
{
	ContainerBuilder builder = new ContainerBuilder();

	builder.RegisterType<LaSaiService>()
		.PropertiesAutowired();
	//TestLazyService

	builder.RegisterType<TestLazyService>()
		.PropertiesAutowired();
}

```
後來又遇到 [circular-dependencies](https://autofac.readthedocs.io/en/latest/advanced/circular-dependencies.html) 可以這樣解看看

### 快速寫 Autofac 屬性注入
實務上遇到一個煩人的問題 , 因為舊系統搬到 .net core 一堆物件需要使用 DI
如果用建構子注入的話會造成太多建構子相依 , 導致系統難以修改 , 所以改用 property injection 找到 `ConfigureServices`
接著加入這段 , 可想而知一堆要加進去手動寫的話會想哭
```
//todo: property injection
ContainerBuilder builder = new ContainerBuilder();
builder.RegisterType<A>().PropertiesAutowired();
builder.RegisterType<B>().PropertiesAutowired();
builder.RegisterType<C>().PropertiesAutowired();
builder.RegisterType<D>().PropertiesAutowired();
builder.RegisterType<E>().PropertiesAutowired();
builder.RegisterType<F>().PropertiesAutowired();

```

所以參考[這篇](https://shellgeek.com/powershell-get-filename-without-extension/)直接依靠 powershell 快速收工
```
ls | ForEach-Object -Process { "builder.RegisterType<" + [System.IO.Path]::GetFileNameWithoutExtension($_) + ">().PropertiesAutowired();" }
```
[abp 用法參考強國人](https://www.cnblogs.com/lenmom/p/9081658.html)
