---
title: webform 整合 autofac
date: 2021-12-21 05:47:45
tags: c#
---
&nbsp;
![vim](https://raw.githubusercontent.com/weber87na/flowers/master/10.jpg)
<!-- more -->

參考[官方](https://autofac.readthedocs.io/en/latest/integration/webforms.html)

### Autofac
安裝 `Autofac.Web`
```
Install-Package Autofac.Web -Version 6.0.0
```

先在 `web.config` 加上這段 , 官方寫推薦 IIS6 & IIS7 的設定都加 , 我懶得加
```
  <system.webServer>
    <!-- This section is used for IIS7 -->
    <modules>
      <add
        name="ContainerDisposal"
        type="Autofac.Integration.Web.ContainerDisposalModule, Autofac.Integration.Web"
        preCondition="managedHandler"/>
      <add
        name="PropertyInjection"
        type="Autofac.Integration.Web.Forms.PropertyInjectionModule, Autofac.Integration.Web"
        preCondition="managedHandler"/>
    </modules>
  </system.webServer>
```

建立類別 `Box`
```
public class Box
{
	public string Name { get; set; }
}
```

建立 interface `IRepo` 及 `BoxRepo`

`IRepo`
```
public interface IRepo
{
	List<Box> GetAll();
}
```

`BoxRepo`
```
    public class BoxRepo : IRepo
    {
		//理論上這邊會寫 ado.net or dapper or ef 的程式碼
        public List<Box> GetAll()
        {
            return new List<Box> {
                new Box { Name = "Car 1" } ,
                new Box { Name = "Car 2" } ,
                new Box { Name = "Car 3" } ,
            };
        }
    }

```


接著找到 `Global` 實現這個介面 `IContainerProviderAccessor`
```
public class Global : HttpApplication, IContainerProviderAccessor
{
	// Provider that holds the application container.
	static IContainerProvider _containerProvider;

	// Instance property that will be used by Autofac HttpModules
	// to resolve and inject dependencies.
	public IContainerProvider ContainerProvider
	{
		get { return _containerProvider; }
	}

	void Application_Start( object sender, EventArgs e )
	{
		// Build up your application container and register your dependencies.
		var builder = new ContainerBuilder();
		builder.RegisterType<BoxRepo>().As<IRepo>().InstancePerRequest();

		//builder.RegisterType<BoxService>().As<IBoxService>().
		//	UsingConstructor(typeof(IRepo)).InstancePerRequest();
		// ... continue registering dependencies...

		// Once you're done registering things, set the container
		// provider up with your registrations.
		_containerProvider = new ContainerProvider( builder.Build() );


		// Code that runs on application startup
		RouteConfig.RegisterRoutes( RouteTable.Routes );
		BundleConfig.RegisterBundles( BundleTable.Bundles );
	}
}
```

然後撰寫 `Page` 的程式碼 , 至此 `Repository` 就可以直接拿出資料了 , 可是實際上應該要多加個 `Service` 層比較優 , 不過老案子可能會沒這些
```
    public partial class _Default : Page
    {
        public IRepo BoxRepo { get; set; }
        //public IBoxService BoxService { get; set; }
        protected void Page_Load( object sender, EventArgs e )
        {
            var boxs = BoxRepo.GetAll();
            boxs.ForEach( x => Console.WriteLine(x.Name));
        }
    }

```

接著建立 `IBoxService`
```
    public interface IBoxService : IRepo
    {
        Box GetFirst();
    }

```

然後實現他 , 這裡用建構子注入 `IRepo`
```
    public class BoxService : IBoxService
    {
        private readonly IRepo _boxRepo;
        public BoxService( IRepo boxRepo )
        {
            _boxRepo = boxRepo;
        }
        public List<Box> GetAll()
        {
            return _boxRepo.GetAll();
        }

        public Box GetFirst()
        {
            return _boxRepo.GetAll().FirstOrDefault();
        }
    }

```

一樣回到 Global 加入 DI 設定的程式碼 , 看看要不要明確設定 `UsingConstructor` 不這樣寫應該可以

```
builder.RegisterType<BoxService>().As<IBoxService>()
	.UsingConstructor(typeof(IRepo)).InstancePerRequest();
```

接著調整 Page 就搞定了

```
    public partial class _Default : Page
    {
        //public IRepo BoxRepo { get; set; }
        public IBoxService BoxService { get; set; }
        protected void Page_Load( object sender, EventArgs e )
        {
            //var boxs = BoxRepo.GetAll();
            //boxs.ForEach( x => Console.WriteLine(x.Name));

            var boxs = BoxService.GetAll();
            var box = BoxService.GetFirst();

        }
    }

```



### 整合 NLog
### webform
安裝 `NLog`
```
Install-Package NLog -Version 4.7.13
```

接著在 `Global` 註冊 NLog
```
builder.RegisterType<Logger>().As<ILogger>().InstancePerRequest();
```

但是會炸 error , 因為他的建構子是 `protected internal`
```
Autofac.Core.Activators.Reflection.NoConstructorsFoundException: 'No accessible constructors were found for the type 'NLog.Logger'.'
```

最無腦爆力法直接繼承 Logger 然後送他一個 public 的建構子即可
```
public class MyLogger : Logger
{
	public MyLogger(){}
}
```

`Global` 註冊改這樣
```
builder.RegisterType<MyLogger>().As<ILogger>().InstancePerRequest();
```

另外如果想要在自己的物件也用屬性注入的話修改這樣 , 因為老 code 很容易有建構子地獄發生 , 所以插 Log 改用屬性注入 , 不然寫到哭
```
builder.RegisterType<BoxService>().As<IBoxService>().PropertiesAutowired().InstancePerRequest();
```


最後 Default Page 修改這樣就搞定了
```
    public partial class _Default : Page
    {
        public IBoxService BoxService { get; set; }

        public ILogger Logger { get; set; }
        protected void Page_Load( object sender, EventArgs e )
        {
            Logger.Info( "test log default page" );
            //var boxs = BoxRepo.GetAll();
            //boxs.ForEach( x => Console.WriteLine(x.Name));

            var box = BoxService.GetFirst();
            //Logger.Info(box.Name);
            var boxs = BoxService.GetAll();
        }
    }
```


不然就是參考[老外](https://stackoverflow.com/questions/43454336/nlog-with-autofac-how-to-give-logger-name)多包一個代理用的中間層
```
    public interface ILoggerService<T>
    {
        void Info(string message);

        void Debug(string message);
    }

    public class LoggerService<T> : ILoggerService<T>
    {
        public ILogger logger { get; set; }

        public LoggerService()
        {
            logger = LogManager.GetLogger(typeof(T).FullName);
        }

        public void Debug(string message)
        {
            logger.Debug(message);
        }

        public void Info(string message)
        {
            logger.Info(message);
        }
    }

```

最後註冊進去就搞定了
```
builder.RegisterGeneric(typeof(LoggerService<>)).As(typeof(ILoggerService<>)).InstancePerRequest();
```

#### webapi
想要在 `Global` 的 `Application_Error` 讓 Log 有作用 , 生命週期要選 `InstancePerLifetimeScope` 才生效
```
builder.RegisterType<MyLogger>().As<ILogger>().InstancePerLifetimeScope();
```

測試 Application_Error
```
protected void Application_Error(object sender, EventArgs e)
{
	var rawUrl = Request.RawUrl;
	var ex = Server.GetLastError();

	var logger = _containerProvider.ApplicationContainer.Resolve<ILogger>();
	logger.Error(ex);


	Debug.WriteLine("RawUrl: {0}", rawUrl);
	Debug.WriteLine("Ex: {0}", ex.Message);
	Debug.WriteLine("StackTrace: {0}", ex.StackTrace);

}
```

可是 web api 不會直接走 `Application_Error` , 要加上 filter , 但因為跟 autofac 進行整合 , 所以要加上 `IAutofacExceptionFilter` [參考官網](https://autofac.readthedocs.io/en/latest/integration/webapi.html#register-the-filter-provider)
```
public class LoggingActionFilter : IAutofacExceptionFilter
{
	readonly ILogger _logger;

	public LoggingActionFilter(ILogger logger)
	{
		_logger = logger;
	}

	public Task OnExceptionAsync(HttpActionExecutedContext actionExecutedContext, CancellationToken cancellationToken)
	{
		_logger.Error(actionExecutedContext.Exception);
		return Task.FromResult(0);
	}
}
```

接著設定 DI 屬性注入
```
builder.Register(c => new LoggingActionFilter(c.Resolve<ILogger>()))
	.AsWebApiExceptionFilterForAllControllers()
	.InstancePerRequest();

```

注意還要有設定這段才會正確生效
```
var config = GlobalConfiguration.Configuration;
builder.RegisterWebApiFilterProvider(config);
```


如果不想用 Global 的方式的話 , 其實也可以直接繼承 `ExceptionFilterAttribute` 然後 `override OnException`
特別注意到 namespace `System.Web.Http.Filters`
```
public class LogExceptionFilterAttribute : ExceptionFilterAttribute
{
	public ILogger Logger { get; set; }

	public override void OnException(HttpActionExecutedContext context)
	{
		Logger.Error(context.Exception);
	}
}
```

注意一樣要設定 `builder.RegisterWebApiFilterProvider(config);` , 接著掛載 `Attribute` 到 `Controller` 上即可
```
[LogExceptionFilter]
public class HaController : ApiController
{
	[HttpGet]
	[Route("ha")]
	public string Ha()
	{
		throw new Exception("Ha");
		return "HA";
	}
}
```

#### 改用 Microsoft.Extensions.Logging
首先安裝 `NLog.Config` `NLog.Extensions.Logging` `NLog.Web`
[參考大神](https://dotblogs.com.tw/yc421206/2020/10/28/standard_log_api_Microsoft_Extensions_Logging_for_nlog) 及 [NLog官方](https://github.com/nlog/NLog/wiki/File-target)
舊版 web api 忘了怎麼寫可以參考[老外](https://www.c-sharpcorner.com/article/exception-handling-in-asp-net-mvc-web-api/) or [這篇](https://dotblogs.com.tw/yc421206/2013/11/07/127253)

注意引用命名空間 `using Microsoft.Extensions.Logging;`

接著設定 Autofac 整合 , 修改 `Application_Start`
```
protected void Application_Start()
{
	AreaRegistration.RegisterAllAreas();
	GlobalConfiguration.Configure(WebApiConfig.Register);
	FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
	RouteConfig.RegisterRoutes(RouteTable.Routes);
	BundleConfig.RegisterBundles(BundleTable.Bundles);

	//把 NLog 的 Provider 新增進去
	var loggerFactory = new LoggerFactory();
	loggerFactory.AddProvider(new NLogLoggerProvider());

	var builder = new ContainerBuilder();

	//這行是必須的
	builder.RegisterInstance(loggerFactory).As<ILoggerFactory>().SingleInstance();
	//用泛型註冊
	builder.RegisterGeneric(typeof(Logger<>)).As(typeof(ILogger<>));


	builder.RegisterType<TestAttribute>().PropertiesAutowired();
	builder.RegisterType<LogExceptionFilterAttribute>().PropertiesAutowired();


	builder.Register(c => new LoggingActionFilter(c.Resolve<ILogger<LoggingActionFilter>>()))
		.AsWebApiExceptionFilterForAllControllers()
		.InstancePerRequest();

	builder.RegisterApiControllers(Assembly.GetExecutingAssembly());
	var config = GlobalConfiguration.Configuration;
	builder.RegisterWebApiFilterProvider(config);


	var container = builder.Build();
	config.DependencyResolver = new AutofacWebApiDependencyResolver(container);

	//清除 web api xml
	GlobalConfiguration.Configuration.Formatters.XmlFormatter.SupportedMediaTypes.Clear();

}

```

接著把要用 Log 的類別改成這樣即可
```
public class LoggingActionFilter : IAutofacExceptionFilter
{
	readonly ILogger<LoggingActionFilter> _logger;

	public LoggingActionFilter(ILogger<LoggingActionFilter> logger)
	{
		_logger = logger;
	}

	public Task OnExceptionAsync(HttpActionExecutedContext actionExecutedContext, CancellationToken cancellationToken)
	{
		_logger.LogError(actionExecutedContext.Exception.Message.ToString());
		return Task.FromResult(0);
	}
}

```

然後 Controller 大概改這樣 , action 裡面的實作就自行調整
```
[RoutePrefix("api/ha")]
public class HaController : ApiController
{
	readonly ILogger<HaController> _logger;
	public HaController(ILogger<HaController> logger)
	{
		_logger = logger;
	}

	[HttpGet]
	[Route("ha")]
	public IHttpActionResult Ha()
	{
		_logger.LogError("測試 controller & action");

		try
		{
			throw new Exception("test");
			List<string> list = new List<string>();
			list.Add("haha");
			return Ok(list);
		}
		catch (Exception ex)
		{
			_logger.LogError(ex.ToString());
			return StatusCode(HttpStatusCode.InternalServerError);
		}
	}
}

```


後來遇到一個雷用 Json 當 Layout 時出現中文亂碼 , 加上 `escapeUnicode="false"` 還有設定 `encoding="utf-8"`
```
<?xml version="1.0" encoding="utf-8" ?>
<nlog xmlns="http://www.nlog-project.org/schemas/NLog.xsd"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.nlog-project.org/schemas/NLog.xsd NLog.xsd"
      autoReload="true"
      throwExceptions="false"
      internalLogLevel="Off" internalLogFile="c:\temp\nlog-internal.log">

	<extensions>
		<add assembly="NLog.Web"/>
	</extensions>


	<!-- optional, add some variables
  https://github.com/nlog/NLog/wiki/Configuration-file#variables
  -->
	<variable name="myvar" value="myvalue"/>

	<!--
  See https://github.com/nlog/nlog/wiki/Configuration-file
  for information on customizing logging rules and outputs.
   -->
	<targets>

		<!--
    add your targets here
    See https://github.com/nlog/NLog/wiki/Targets for possible targets.
    See https://github.com/nlog/NLog/wiki/Layout-Renderers for the possible layout renderers.
    -->

		<!--
    Write events to a file with the date in the filename.
    <target xsi:type="File" name="f" fileName="${basedir}/logs/${shortdate}.log"
            layout="${longdate} ${uppercase:${level}} ${message}" />
    -->
		<target name="file" xsi:type="File"
			layout="${longdate} ${logger} ${message}${exception:format=ToString}"
			fileName="${basedir}/logs/${shortdate}.log"
			encoding="utf-8" />

		<target name="jsonfile" xsi:type="File" fileName="${basedir}/logs/${shortdate}.json" encoding="utf-8">
			<layout xsi:type="JsonLayout">
				<attribute name="time" layout="${date:format=O}" />
				<attribute name="message" layout="${message}" escapeUnicode="false"/>
				<attribute name="logger" layout="${logger}"/>
				<attribute name="level" layout="${level}"/>

				<attribute name="${aspnet-appbasepath}" layout="${aspnet-appbasepath}"/>
				<attribute name="${aspnet-application}" layout="${aspnet-application}"/>
				<attribute name="${aspnet-item}" layout="${aspnet-item}"/>
				<attribute name="${aspnet-mvc-action}" layout="${aspnet-mvc-action}"/>
				<attribute name="${aspnet-mvc-controller}" layout="${aspnet-mvc-controller}"/>
				<attribute name="${aspnet-request}" layout="${aspnet-request}"/>
				<attribute name="${aspnet-request-cookie}" layout="${aspnet-request-cookie}"/>
				<attribute name="${aspnet-request-form}" layout="${aspnet-request-form}"/>
				<attribute name="${aspnet-request-headers}" layout="${aspnet-request-headers}"/>
				<attribute name="${aspnet-request-host}" layout="${aspnet-request-host}"/>
				<attribute name="${aspnet-request-ip}" layout="${aspnet-request-ip}"/>
				<attribute name="${aspnet-request-method}" layout="${aspnet-request-method}"/>
				<attribute name="${aspnet-request-posted-body}" layout="${aspnet-request-posted-body}"/>
				<attribute name="${aspnet-request-querystring}" layout="${aspnet-request-querystring}"/>
				<attribute name="${aspnet-request-referrer}" layout="${aspnet-request-referrer}"/>
				<attribute name="${aspnet-request-routeparameters}" layout="${aspnet-request-routeparameters}"/>
				<attribute name="${aspnet-request-url}" layout="${aspnet-request-url}"/>
				<attribute name="${aspnet-request-useragent}" layout="${aspnet-request-useragent}"/>
				<attribute name="${aspnet-response-statuscode}" layout="${aspnet-response-statuscode}"/>
				<attribute name="${aspnet-session}" layout="${aspnet-session}"/>
				<attribute name="${aspnet-sessionid}" layout="${aspnet-sessionid}"/>
				<attribute name="${aspnet-traceidentifier}" layout="${aspnet-traceidentifier}"/>
				<attribute name="${aspnet-user-authtype}" layout="${aspnet-user-authtype}"/>
				<attribute name="${aspnet-user-identity}" layout="${aspnet-user-identity}"/>
				<attribute name="${aspnet-user-isauthenticated}" layout="${aspnet-user-isauthenticated}"/>
				<attribute name="${aspnet-webrootpath}" layout="${aspnet-webrootpath}"/>
				<attribute name="${iis-site-name}" layout="${iis-site-name}"/>
			</layout>
		</target>

	</targets>

	<rules>
		<!-- add your logging rules here -->

		<!--
    Write all events with minimal level of Debug (So Debug, Info, Warn, Error and Fatal, but not Trace)  to "f"
    <logger name="*" minlevel="Debug" writeTo="f" />
    -->
		<logger name="*" minlevel="Debug" writeTo="file" />
		<logger name="*" minlevel="Debug" writeTo="jsonfile" />
	</rules>
</nlog>

```


為了讓 Error 統一輸出自己想要的格式[參考這篇](https://stackoverflow.com/questions/47778018/exceptionhandler-being-called-but-not-returning-json)
```
public class GlobalExceptionHandler : ExceptionHandler
{
	//要順便 Log 的話加上去
	//public ILogger<GlobalExceptionHandler> Logger { get; set; }
	public override void Handle(ExceptionHandlerContext context)
	{
		//Logger.LogError(context.Exception.ToString());

		var info = new ErrorInformation
		{
			Message = "伺服器內部發生錯誤" ,
			ErrorDate = DateTime.UtcNow
		};
		var result = context.Request.CreateResponse( HttpStatusCode.InternalServerError, info,
					System.Net.Http.Formatting.JsonMediaTypeFormatter.DefaultMediaType);
		context.Result = new ResponseMessageResult(result);
	}
}

```

看看要不要順便也把 Log 插裡面 , 要的話需要用 di container 去拿
```
builder.RegisterType<GlobalExceptionHandler>().PropertiesAutowired();
config.Services.Replace(typeof(IExceptionHandler), container.Resolve<GlobalExceptionHandler>());
```

如果不用 DI 拿的話 config 記得要多加上這樣
```
config.Services.Replace(typeof(IExceptionHandler), new GlobalExceptionHandler());
```

### 其他地雷
如果有遇到噴這個 error 就檢查看看型別是否設定有錯誤
```
None of the constructors found with 'Autofac.Core.Activators.Reflection.DefaultConstructorFinder' on type 'WebApplication3.BoxService' can be invoked with the available services and parameters:
Cannot resolve parameter 'WebApplication3.BoxRepo boxRepo' of constructor 'Void .ctor(WebApplication3.BoxRepo)'.
```

建構子有問題
```
Cannot choose between multiple constructors with equal length 2 on type 'WebApplication3.BoxService'. Select the constructor explicitly, with the UsingConstructor() configuration method, when the component is registered.
```

這兩個順序會讓 autofac 搞不懂要找誰 , 老 code 特別容易發生這種問題
```
public BoxService( IRepo boxRepo, ILogger logger )
{
	_boxRepo = boxRepo;
	_logger = logger;
}

public BoxService( ILogger logger ,IRepo boxRepo )
{
	_boxRepo = boxRepo;
	_logger = logger;
}

```

使用 `UsingConstructor` 告訴他建構子用哪個即可搞定
```
builder.RegisterType<BoxService>().As<IBoxService>()
	.UsingConstructor(typeof(IRepo) , typeof(ILogger))
	.PropertiesAutowired().InstancePerRequest();
```



### SignalR

官方文件好像沒更新 , 應該是要安裝 `Autofac.SignalR2` 以及 `Autofac.Owin`
```
Install-Package Autofac.SignalR2 -Version 6.0.0
```

這裡特別要注意到 , 如果整合 asp.net webform 的話 , DI 的設定是直接寫在 `Global` 裡面 , 而 SignalR 則是寫在 `Startup` 類別裡
```
public class Startup
{
	public void Configuration( IAppBuilder app )
	{
		var builder = new ContainerBuilder();

		builder.RegisterHubs( Assembly.GetExecutingAssembly() );

		//註冊繼承自 NLog 把建構子改為 public 的自訂類別
		builder.RegisterType<MyLogger>().As<ILogger>();

		//註冊 repository
		builder.RegisterType<BoxRepo>().As<IRepo>();

		//設定 services
		builder.RegisterType<BoxService>().As<IBoxService>()
			.UsingConstructor( typeof( IRepo ), typeof( ILogger ) );
			//.InstancePerLifetimeScope();

		var container = builder.Build();
		var resolver = new AutofacDependencyResolver( container );

		// Any connection or hub wire up and configuration should go here
		app.UseAutofacMiddleware(container);

		app.Map( "/signalr", map =>
		{
			map.UseCors( CorsOptions.AllowAll );
			var config = new HubConfiguration { Resolver = resolver };
			map.RunSignalR(config);
		} );

	}
}

```

接著注入物件到 `hub` 內
```
public class TestHub : Hub
{
	private readonly ILifetimeScope _hubLifetimeScope;
	private readonly ILogger _logger;
	private readonly IBoxService _boxService;

	//可以這樣寫
	//public TestHub( ILifetimeScope lifetimeScope )
	//{
	//    // Create a lifetime scope for the hub.
	//    _hubLifetimeScope = lifetimeScope.BeginLifetimeScope();

	//    // Resolve dependencies from the hub lifetime scope.
	//    _logger = _hubLifetimeScope.Resolve<ILogger>();

	//    _boxService = _hubLifetimeScope.Resolve<IBoxService>();
	//}

	//這樣寫也可以
	public TestHub(IBoxService boxService , ILogger logger)
	{
		_boxService = boxService;
		_logger = logger;
	}


	//給 client 呼叫 server 上的方法
	public void LaSai( string message )
	{
		_logger.Info( "test log" );
		var result = _boxService.GetAll();
		//server 丟一些 result 回去給 client
		Clients.All.hello( result );
	}
}

```

最後是前端呼叫 `laSai` 這個方法時 , 因為在 server 內有這句 `Clients.All.hello( result );` 所以前端會把得到的 json 物件印在畫面上
```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title></title>
    <script src="Scripts/jquery-3.4.1.js"></script>
    <script src="Scripts/jquery.signalR-2.2.2.js"></script>
    <script src="/signalr/hubs"></script>

	<!--使用靜態生出來的-->
    <!--<script src="Scripts/server.js"></script>-->
</head>
<body>
    <script>

		//如果是其他站台要用的話要加上這句
		//$.connection.hub.url = 'http://localhost:23007/signalr';
        var chat = $.connection.testHub;

        $.connection.hub.start().done(function () {
            $(document).on('click' , '#btn', function () {
                chat.server.laSai('la di sai');
            })
        })

        chat.client.hello = function (resp) {
            console.log(resp);
            resp.forEach(x => {
                $('#display').append(`<p>${x.Name}</p>`);
            });
        }
    </script>
    <div id="display"></div>
    <button id="btn">go</button>
</body>
</html>

```

### SignalR 後續
常常有個疑惑 , 不曉得怎樣定時去撈 DB 然後用 signalr 傳給前端 , 於是看到了[這篇文章](http://henriquat.re/server-integration/signalr/integrateWithSignalRHubs.html)
主要就是實現了 `IRegisteredObject` 介面 , 然後就可以在 server 裡面定時去執行某些任務
所以特別注意到 `HostingEnvironment.RegisterObject` 當插入這個以後 server side (IIS) 就會固定每隔 N 秒執行撈 sql 的動作

另外有個雷 , 因為我有用 `autofac` 導致執行的時候雖然會觸發 timer 內的事件 , 結果 signalr server side 裡面的 function 卻不 work
所以要參考[這篇](https://stackoverflow.com/questions/21126624/signalr-autofac-owin-why-doesnt-globalhost-connectionmanager-gethubcontext)去調整設定 , 不然是吃不到 DI 的

`Startup` 內的 `Configuration` 方法
```
var builder = new ContainerBuilder();

//註冊 signalr 的 hub
builder.RegisterHubs(Assembly.GetExecutingAssembly());

//把 NLog 的 Provider 新增進去
var loggerFactory = new LoggerFactory();
loggerFactory.AddProvider(new NLogLoggerProvider());

//註冊 AutoMapper
builder.RegisterAutoMapper(Assembly.GetExecutingAssembly());
builder.RegisterType(typeof(Mapper)).AsSelf();

//這行是必須的
builder.RegisterInstance(loggerFactory).As<ILoggerFactory>().SingleInstance();

//用泛型註冊
builder.RegisterGeneric(typeof(Logger<>)).As(typeof(ILogger<>));


//DI 的相關屬性設定
//註冊 connectionFactory
builder.RegisterType<ConnectionFactory>()
	.As<IConnectionFactory>()
	.AsSelf();

//註冊 repository
builder.RegisterType<YourRepository>()
	.As<IYourRepository>()
	.As<IRepository<YourClass>>()
	.AsSelf();

var container = builder.Build();
var resolver = new AutofacDependencyResolver(container);

//todo 注意這個地方很雷 , 如果沒有替換 DependencyResolver 會無法正常 trigger 10 秒更新軌跡的動作
//https://stackoverflow.com/questions/21126624/signalr-autofac-owin-why-doesnt-globalhost-connectionmanager-gethubcontext
GlobalHost.DependencyResolver = resolver;

var yourService = resolver.Resolve<YourService>();

// Any connection or hub wire up and configuration should go here
app.UseAutofacMiddleware(container);

//設定 signalr
app.Map("/signalr", map =>
{
   map.UseCors(CorsOptions.AllowAll);

   //這裡直接插 config 會失效
   //var config = new HubConfiguration { Resolver = resolver };

   //要選用這個方法
   //map.MapHubs(config);

   //如果直接用這句的話不曉得為啥會不給過 , 可能是 autofac 跟 signalr 整合的 bug
   //map.RunSignalR(config);

   //同上面的問題 GlobalHost.DependencyResolver , 上面三句在此處其實都不起作用  , 直接呼叫 RunSignalR 即可
   map.RunSignalR();
});

//註冊背景物件 , 這個會去定時每隔 10 秒呼叫一次 hub
//撈 sql 把資料給送給前端使用
HostingEnvironment.RegisterObject(new BackgroundServerTimer(yourService));

```




### web api
#### autofac
`Autofac.WebApi2`

```
Install-Package Autofac.WebApi2 -Version 6.1.0
```

一樣在 `Global` 設定 , 這次不小心踩個雷 , 把 `builder.RegisterApiControllers( Assembly.GetExecutingAssembly() ).InstancePerRequest();` 寫在 `var container = builder.Build();` 之後
特別注意這個順序很重要 , 寫錯了就起不來 , 讓你 debug 到想死 , 可憐 ~
```
void Application_Start( object sender, EventArgs e )
{
	//設定 DI
	var builder = new ContainerBuilder();

	//DI 的相關屬性設定
	builder.RegisterType<MyLogger>().As<ILogger>().InstancePerRequest();
	builder.RegisterType<BoxRepo>().As<IRepo>().InstancePerRequest();
	builder.RegisterType<BoxService>().As<IBoxService>()
		.UsingConstructor( typeof( IRepo ), typeof( ILogger ) )
		.PropertiesAutowired().InstancePerRequest();

	//設定 web api controller 註冊 DI
	builder.RegisterApiControllers( Assembly.GetExecutingAssembly() ).InstancePerRequest();
	
	//建立 DI container 特別注意順序很重要 , build 完以後才寫上面的屬性註冊會失效
	var container = builder.Build();
	
	//註冊給 asp.net webform 使用
	_containerProvider = new ContainerProvider( container );
	
	//設定 web api 的 di
	var config = GlobalConfiguration.Configuration;
	config.DependencyResolver = new AutofacWebApiDependencyResolver( container );

	//預設的 application startup 設定流程
	GlobalConfiguration.Configure( WebApiConfig.Register );
	RouteConfig.RegisterRoutes( RouteTable.Routes );
	BundleConfig.RegisterBundles( BundleTable.Bundles );

	//清空 xml formatter
	GlobalConfiguration.Configuration.Formatters.XmlFormatter.SupportedMediaTypes.Clear();
}

```

#### WebApiProxy
在 nuget 搜尋  `WebApiProxy` 並且安裝
找到 `WebApiConfig` 加上這句 `config.RegisterProxyRoutes( );`
[參考自這篇](https://dotblogs.com.tw/yc421206/2018/09/28/webapi_generate_proxy_class_code)
```
        private static void AddRoutes(HttpConfiguration config)
        {
            //https://dotblogs.com.tw/yc421206/2018/09/28/webapi_generate_proxy_class_code
            //WebApiProxy
            config.RegisterProxyRoutes( );

            //這串要在 MapHttpRoute 前面
            config.MapHttpAttributeRoutes( );

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }

```

他會幫你自動產生 proxy 像這樣 `http://localhost:23007/api/proxies`
接著前端 code 會長這樣 , 注意需要有 `jQuery`
```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title></title>
    <script src="Scripts/jquery-3.4.1.js"></script>

    <!--自動產生的 javascript api proxies-->
    <script src="/api/proxies"></script>

</head>
<body>
    <script>
        //測試 proxy 產出的 javascript api
        $.proxies.gps.get('test2').done(function (resp) {
            console.log(resp);
        });

        var test1 = {
            "id": 'test1',
            "x": 12,
            "y": 24,
        };
        $.proxies.gps.add(test1).done(function (resp) {
            console.log(resp);
        });

    </script>
</body>
</html>
```

#### Swashbuckle
在 nuget 搜尋 `Swashbuckle` 並且安裝
`Build` => `Output path` => `bin\` => 打勾 `XML document file` => `bin\WebApplicationWebFormWithWebApi.xml`
找到 `SwaggerConfig.cs` 底下的 `c.IncludeXmlComments` 這串 , 修改為這樣
[參考1](https://marcus116.blogspot.com/2019/01/how-to-add-api-document-using-swagger-in-webapi.html) [參考2](https://docs.microsoft.com/zh-tw/aspnet/core/tutorials/getting-started-with-swashbuckle?view=aspnetcore-6.0&tabs=visual-studio) [參考3](https://dotblogs.com.tw/shadowkk/2019/09/03/092620)

```
var files = Directory.GetFiles(
	AppDomain.CurrentDomain.BaseDirectory, $"WebApplicationWebFormWithWebApi*.xml",
	SearchOption.AllDirectories
);
foreach (var name in files) c.IncludeXmlComments( name );

```

### 生出 typescript 用的 前端 api
這個是因為用純 js 太通靈 , 後來才發現的 typescript 方法 , 需要先有 swagger 的 api 才可以動!
安裝 , 注意要切到你專案的 root 底下 , 可以參考這個官方[說明](https://www.npmjs.com/package/swagger-typescript-api)
```
npm i swagger-typescript-api
```

建立資料夾讓他長得像是下面這樣
```
├───Scripts
│   └───TypeScripts
│       ├───dist
│       └───src
```

接著在 TypeScripts/src 底下新增 `tsconfig.json` , 這個選項 `compileOnSave` 可以讓存檔時生出 `js` 檔案
```
{
  "compilerOptions": {
    "noImplicitAny": false,
    "noEmitOnError": true,
    "removeComments": false,
    "sourceMap": true,
    "target": "ES2020",
    "outDir": "./dist",
    "rootDir": "./src",
    "module": "ES2020"
  },
  "exclude": [
    "node_modules",
    "wwwroot"
  ],
  "compileOnSave": true
}
```


最後啟動你的 api 網站 , 讓他能抓得到 swagger 產生的 json , 並且執行以下命令
```
npx swagger-typescript-api -p http://localhost:50348/swagger/docs/v1 -o ./YourProject/Scripts/TypeScripts/src -n myApi.ts
```

接著 cd 到 `TypeScripts` 目錄 , 執行 `tsc` 這個命令讓 `js` 可以生出來 , 注意一定要在 `TypeScripts` 這個資料夾才正常
```
tsc
```

在 `Solution Exploer` 上面點 `Show All Files` 可以看到生出 `myApi.ts`

```
tsc myApi.ts
```


萬一跳這個 error 執行這串即可 `npm install -g typescript`
```
tsc : 無法辨識 'tsc' 詞彙是否為 Cmdlet、函數、指令檔或可執行程式的名稱。請檢查名稱拼字是否正確，如果包含路徑的話，請確認路徑是否正確，然後再試一次。
```

在 `src` 加入這個檔案 `test.ts`
```
import { Api } from "./myApi.js";

const root = new Api({
    baseUrl: "http://localhost:50348"
});


var test = root.api.valuesGet();

root.api.valuesGet().then(x => console.log(x.data));

```

最後新增個網頁來測 `test.html` , 正常的話在 console 上面會印出 api 撈出的數值 , 這樣可以用強行別減輕不少開發壓力
```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <script src="Scripts/TypeScripts/src/test.js" type="module"></script>
</body>
</html>
```


### 整合 AutoMaper
首先安裝 `AutoMapper` 及 `AutoMapper.Contrib.Autofac.DependencyInjection`
可以參考他的[官網](https://github.com/alsami/AutoMapper.Contrib.Autofac.DependencyInjection)

修正 `Global` 如下就可以正常註冊了 , 他的 github 上面 example 好像沒更新
他是用這句 `containerBuilder.AddAutoMapper(typeof(Program).Assembly);` 實際使用時看他標示已經棄用

```
    public class Global : HttpApplication, IContainerProviderAccessor
    {
        static IContainerProvider _containerProvider;
        public IContainerProvider ContainerProvider
        {
            get { return _containerProvider; }
        }
        void Application_Start( object sender, EventArgs e )
        {
            var builder = new ContainerBuilder();

            //註冊 AutoMapper
            builder.RegisterAutoMapper( Assembly.GetExecutingAssembly() );
			//我測 webform 沒加這句的話也會噴 null
			builder.RegisterType(typeof(Mapper)).AsSelf();

            builder.RegisterType<MyLogger>().As<ILogger>().InstancePerRequest();
            builder.RegisterApiControllers( Assembly.GetExecutingAssembly() ).InstancePerRequest();
            var container = builder.Build();
            _containerProvider = new ContainerProvider( container );
            var config = GlobalConfiguration.Configuration;
            config.DependencyResolver = new AutofacWebApiDependencyResolver( container );

            //從 Autofac 裡面拿出 AutoMapper 的 config
            var mapperConfiguration = container.Resolve<MapperConfiguration>();

            //這句用來驗證 AutoMapper 的 Profile 是否正確
            mapperConfiguration.AssertConfigurationIsValid(  );

            // Code that runs on application startup
            GlobalConfiguration.Configure( WebApiConfig.Register );
            RouteConfig.RegisterRoutes( RouteTable.Routes );
            BundleConfig.RegisterBundles( BundleTable.Bundles );
        }
    }
```


建立 `Customer`
```
public class Customer
{
	public Guid Id { get; }
	public string Name { get; }

	public Customer( Guid id, string name )
	{
		Id = id;
		Name = name;
	}
}
```

建立 `CustomerDto`
```
public class CustomerDto
{
	public Guid Id { get; }
	public string Name { get; }

	public string FullName { get; set; }

	public CustomerDto( Guid id, string name )
	{
		Id = id;
		Name = name;
	}
}
```


建立 `CustomerProfile`
這裡是重點 , 最好在專案建立資料夾 `Profiles` 進行分類 , 不然會有一堆 mapping
注意他的規則是擺在後面的 Type 為 return 的物件 , 所以此處為設定 `CustomerDto` 為 return 的結果
如果屬性相同的話可以不用一個一個設定 , 他會自己去 mapping
最後可以考慮加上 `ReverseMap();` 這樣可以  two way mapping
```
public class CustomerProfile : Profile
{
	public CustomerProfile()
	{
		//注意他的規則是擺在後面的 Type 為 return 的物件
		//從 Customer 的 Name +Id Mapping 至 DTO 的 FullName
		CreateMap<Customer, CustomerDto>()
			.ForMember( x => x.FullName, y => y.MapFrom( z => z.Id + z.Name ) )
			.ReverseMap();
	}
}
```


最後弄個 api controller 測試看看 , 要手動注入 `IMapper` 就搞定了
```
[RoutePrefix("api/values")]
public class ValuesController : ApiController
{
	private readonly IComponentContext _componentContext;
	private readonly IMapper _mapper;
	public ValuesController( IComponentContext componentContext, IMapper mapper )
	{
		_componentContext = componentContext;
		_mapper = mapper;
	}

	[HttpGet]
	[Route("test")]
	public string Get()
	{
		Debug.WriteLine("Hello World");
		var x = _componentContext.Resolve<ILogger>(new TypedParameter(typeof(string) , "test test test test"));
		x.Info( "Ha Ha" );

		return "test";
	}

	[HttpGet]
	[Route("CustomerToDto")]
	public CustomerDto CustomerToDto()
	{
		var customer = new Customer( Guid.NewGuid(), "HaHa" );
		var result = _mapper.Map<Customer, CustomerDto>(customer);
		return result;

	}

	[HttpGet]
	[Route("DtoToCustomer")]
	public Customer DtoToCustomer()
	{
		var customerDto = new CustomerDto( Guid.NewGuid(), "HaHa" );
		var result = _mapper.Map<CustomerDto, Customer>(customerDto);
		return result;
	}
}

```


最後是 signalr 整合 automapper , 跟前面一樣大同小異在 `Startup`
加入關鍵這三行即可
`builder.RegisterAutoMapper( Assembly.GetExecutingAssembly() );`
`var mapperConfiguration = container.Resolve<MapperConfiguration>();`
`mapperConfiguration.AssertConfigurationIsValid();`

```
public class Startup
{
	public void Configuration( IAppBuilder app )
	{
		var builder = new ContainerBuilder();

		builder.RegisterAutoMapper( Assembly.GetExecutingAssembly() );

		builder.RegisterHubs( Assembly.GetExecutingAssembly() );
		builder.RegisterType<MyLogger>().As<ILogger>();

		builder.RegisterType<BoxRepo>().As<IRepo>();

		builder.RegisterType<BoxService>().As<IBoxService>()
			.UsingConstructor( typeof( IRepo ), typeof( ILogger ) );
			//.InstancePerLifetimeScope();

		var container = builder.Build();
		var resolver = new AutofacDependencyResolver( container );

		//從 Autofac 裡面拿出 AutoMapper 的 config
		var mapperConfiguration = container.Resolve<MapperConfiguration>();

		//這句用來驗證 AutoMapper 的 Profile 是否正確
		mapperConfiguration.AssertConfigurationIsValid();


		// Any connection or hub wire up and configuration should go here
		app.UseAutofacMiddleware(container);

		app.Map( "/signalr", map =>
		{
			map.UseCors( CorsOptions.AllowAll );
			var config = new HubConfiguration { Resolver = resolver };
			map.RunSignalR(config);
		} );

	}
}
```

接著建立 `CustomerHub`
```
public class CustomerHub : Hub
{
	private readonly IMapper _mapper;

	public CustomerHub( IMapper mapper )
	{
		_mapper = mapper;
	}

	public CustomerDto CustomerToDto()
	{
		var customer = new Customer( Guid.NewGuid(), "HaHa" );
		var result = _mapper.Map<Customer, CustomerDto>( customer );
		Clients.All.getCustomerDto( result );
		return result;

	}

	public Customer DtoToCustomer()
	{
		var customerDto = new CustomerDto( Guid.NewGuid(), "HaHa" );
		var result = _mapper.Map<CustomerDto, Customer>( customerDto );
		Clients.All.getCustomer( result );
		return result;
	}
}
```

最後調整前端 code

```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title></title>
    <script src="Scripts/jquery-3.4.1.js"></script>
    <script src="Scripts/jquery.signalR-2.2.2.js"></script>
    <script src="/signalr/hubs"></script>

	<!--使用靜態生出來的-->
    <!--<script src="Scripts/server.js"></script>-->
</head>
<body>
    <script>
        var chat = $.connection.customerHub;
        $.connection.hub.start().done(function () {
            $(document).on('click' , '#btn', function () {
                chat.server.customerToDto();
            })
        })
        chat.client.getCustomerDto = function (resp) {
            console.log(resp);
            $('#display').append(`<p>${resp.Id} , ${resp.Name}</p>`);
        }
    </script>
    <div id="display"></div>
    <button id="btn">go</button>
</body>
</html>

```
