---
title: asp.net core 自訂 configuration provider 讀取 web.config
date: 2024-05-26 17:45:29
tags: c#
---
&nbsp;
<!-- more -->

上課的作業, 順手筆記下, 主要是參考這個 [sqlite](https://github.com/dotnet-labs/CustomConfigurationProviderDemo/blob/master/Demo/Infrastructure/MyConfigurationProvider.cs) 的寫法

```csharp
<Query Kind="Program">
  <Namespace>Microsoft.AspNetCore.Builder</Namespace>
  <Namespace>Microsoft.AspNetCore.Http</Namespace>
  <Namespace>Microsoft.AspNetCore.HttpOverrides</Namespace>
  <Namespace>Microsoft.AspNetCore.Mvc</Namespace>
  <Namespace>Microsoft.Extensions.Configuration</Namespace>
  <Namespace>Microsoft.Extensions.DependencyInjection</Namespace>
  <Namespace>Microsoft.Extensions.Hosting</Namespace>
  <Namespace>Microsoft.Extensions.Options</Namespace>
  <Namespace>System.Net</Namespace>
  <Namespace>System.Net.Http</Namespace>
  <Namespace>System.Threading.Tasks</Namespace>
  <IncludeAspNet>true</IncludeAspNet>
</Query>

void Main()
{
	// 設定環境變數
	Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development");
	var builder = WebApplication.CreateBuilder();

	var configuration = builder.Configuration;

	//清空其他 Configuration 設定
	configuration.Sources.Clear();
	
	//寫入 web.config
            var webconfig =
""""""
<?xml version="1.0" encoding="utf-8"?>
<configuration>
	<appSettings>
		<add key="RemoteAppApiKey" value="35E65A5D-BFD2-4124-2CA4-X81F8E9Z5465" />
		<add key="Port" value="1234" />
	</appSettings>
	<connectionStrings>
	</connectionStrings>
</configuration>
"""""";
	File.WriteAllText("web.config", webconfig);


	//加入我的 WebConfiguration
	configuration
		.AddWebConfigAppSettings("web.config")
		.Build();

	//注入 web.config appSettings
	builder.Services.Configure<AppSettings>(configuration);

	//builder.Services.AddControllers();
	builder.Services.AddControllers().AddApplicationPart(this.GetType().Assembly);
	builder.Services.AddEndpointsApiExplorer();

	var apiKey = configuration["RemoteAppApiKey"];
	var port = configuration["Port"];
	Console.WriteLine(apiKey);
	Console.WriteLine(port);
	
	var app = builder.Build();	
	app.UseHttpsRedirection();
	app.UseAuthorization();
	app.MapControllers();
	app.Run();
}

public class AppSettings
{
    public string RemoteAppApiKey { get; set; }
    public int Port { get; set; }
}

public class WebConfigAppSettingsConfigurationSource : IConfigurationSource
{
    private readonly string fileName;
    public WebConfigAppSettingsConfigurationSource(string fileName)
    {
        this.fileName = fileName;
    }

    public IConfigurationProvider Build(IConfigurationBuilder builder)
    {
        return new WebConfigAppSettingsConfigurationProvider(this.fileName);
    }
}

public class WebConfigAppSettingsConfigurationProvider : ConfigurationProvider
{
    private readonly string fileName;
    public WebConfigAppSettingsConfigurationProvider(string fileName)
    {
        this.fileName = fileName;
    }
    public override void Load()
    {
        try
        {
            var doc = new XmlDocument();
            doc.Load(this.fileName);
            XmlNode appSettingsNode = doc.SelectSingleNode("/configuration/appSettings");

            if (appSettingsNode == null) throw new ArgumentException("無效的 appSettings 區塊");

            XmlNodeList addNodes = appSettingsNode.SelectNodes("add");

            if (addNodes == null) throw new ArgumentException("appSettings 找不到 add 相關節點");

            foreach (XmlNode addNode in addNodes)
            {
                string key = addNode.Attributes["key"].Value;
                string value = addNode.Attributes["value"].Value;

                //設定讀取 <add key="xxx" value="xxx" />
                Set(key, value);
            }
        }
        catch (Exception)
        {
            throw;
        }
    }
}

public static class WebConfigAppSettingsExtensions
{
    public static IConfigurationBuilder AddWebConfigAppSettings(
        this IConfigurationBuilder configuration,
        string fileName
        )
    {
        configuration.Add(new WebConfigAppSettingsConfigurationSource(fileName));
        return configuration;
    }
}

    [ApiController]
    [Route("api/[controller]")]
    public class TestController : ControllerBase
    {
        private readonly IConfiguration configuration;
        public TestController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        [HttpGet]
        public IActionResult GetApiKey()
        {
            var apiKey = configuration["RemoteAppApiKey"];
            Console.WriteLine(apiKey);
            return Ok(apiKey);
        }
    }
	
    [Route("api/[controller]")]
    [ApiController]
    public class SettingsController : ControllerBase
    {
        private readonly AppSettings _appSettings;

        public SettingsController(IOptions<AppSettings> appSettings)
        {
            _appSettings = appSettings.Value;
        }

        [HttpGet]
        public IActionResult GetSettings()
        {
            return Ok(_appSettings);
        }
    }
```
