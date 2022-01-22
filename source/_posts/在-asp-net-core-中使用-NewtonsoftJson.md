---
title: 在 asp.net core 中使用 NewtonsoftJson
date: 2021-12-02 18:41:21
tags: csharp
---
&nbsp;
<!-- more -->
這個問題搞了很久 , 想要把老系統的東東轉移到 .net core 上面 , 想說沿用 `NewtonsoftJson` 變化幅度較小
可是馬上就炸裂了 , 沿用 `JsonProperty` 但是一直搞不定 , 改成 `JsonPropertyName` 又正常
### net core
```
public class Test
{
	//這行正常
	//[JsonPropertyName( "HelloWorld" )]
	[JsonProperty( PropertyName = "HelloWorld" )]
	public string WorldHello { get; set; }
}


[ApiController]
[Route( "[controller]" )]
public class TestController : Controller
{
	[HttpGet("[action]")]
	public string HelloWorld(Test test)
	{
		if (test.WorldHello != null) return test.WorldHello;

		return "HelloWorld";
	}
}
```

明明已經在 `Startup` 的 `ConfigureServices` 加入了以下這行 , 但是在 swagger ui 上面測就是有問題
```
services.AddControllers().AddNewtonsoftJson();
```
折磨了很久以後在[老外的 blog](https://dotnetcoretutorials.com/2020/01/31/using-swagger-in-net-core-3/) 看到
搞了半天原來還要安裝 `Swashbuckle.AspNetCore.Newtonsoft` 然後在最後面補上這行即可 燒了半天...
```
public void ConfigureServices( IServiceCollection services )
{
	services.AddControllers().AddNewtonsoftJson();
	services.AddSwaggerGen( c =>
	 {
		 c.SwaggerDoc( "v1", new OpenApiInfo { Title = "WebApplication2", Version = "v1" } );
	 } );
	services.AddSwaggerGenNewtonsoftSupport();
}

```

### abp
在 abp 上面設定好像會跟順序及檔案有關 , try 了很久才搞定 , [參考強國人的半殘說明](https://blog.csdn.net/dacong/article/details/106201980)
在他官方範例裡面的 `Acme.BookStore.Web` 這支檔案 `BookStoreWebModule` 的 `PreConfigureServices` 要這樣寫
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
	//https://blog.csdn.net/dacong/article/details/106201980
	context.Services.PreConfigure<IMvcBuilder>( mvcBuilder =>
	{
		mvcBuilder.AddNewtonsoftJson(
		 options => options.SerializerSettings.ContractResolver = new DefaultContractResolver() );
	} );
	context.Services.PreConfigure<AbpJsonOptions>( options =>
	{
		options.UseHybridSerializer = false;
	} );

}
```

接著安裝 `Swashbuckle.AspNetCore.Newtonsoft` 然後在 `ConfigureSwaggerServices` 加入 `services.AddSwaggerGenNewtonsoftSupport()`
不然操作 swagger ui 的時候會有問題
```
private void ConfigureSwaggerServices(IServiceCollection services)
{
	services.AddAbpSwaggerGen(
		options =>
		{
			options.SwaggerDoc("v1", new OpenApiInfo { Title = "BookStore API", Version = "v1" });
			options.DocInclusionPredicate((docName, description) => true);
			options.CustomSchemaIds(type => type.FullName);
		}
	);
	services.AddSwaggerGenNewtonsoftSupport();
}
```

最後在 `Acme.BookStore.Application` 的 `BookStoreAppService` 加入以下程式碼 , 然後 JsonProperty 應該會正常生效
```
    /* Inherit your application services from this class.
     */
    public abstract class BookStoreAppService : ApplicationService
    {
        protected BookStoreAppService()
        {
            LocalizationResource = typeof(BookStoreResource);
        }
    }

    public class Test
    {
        [JsonProperty("HelloWorld")]
        public string WorldHello { get; set; }
    }

    public class MyAppService : BookStoreAppService
    {
        [HttpPost("HelloWorld")]
        public string HelloWorld(Test test)
        {
            return test.WorldHello;
        }
    }

```

最後實在太懶了開點腦洞暴力直接加 , 我另外還有寫 [extension](https://github.com/weber87na/VSIXProjectMultiLang) , 不過時間寶貴還是跑跑龍套的階段
```
using System;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.Editing;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using Microsoft.CodeAnalysis;

namespace ConsoleApp7
{
    class Program
    {
        static void Main(string[] args)
        {
            var texts = File.ReadAllText( "Test.cs" );
            var tree = CSharpSyntaxTree.ParseText( texts );
            var root = tree.GetRoot( );
            var lines = File.ReadAllLines( "Test.cs" );
            var members = root.DescendantNodes( ).OfType<MemberDeclarationSyntax>( );
            foreach (var member in members)
            {
                var p = member as PropertyDeclarationSyntax;


                if (p != null)
                {
                    FileLinePositionSpan span = p.SyntaxTree.GetLineSpan( p.Span );
                    int lineNumber = span.StartLinePosition.Line;



                    //撈屬性名稱
                    var name = p.Identifier.Text;
                    //https://stackoverflow.com/questions/35927427/how-to-create-an-attributesyntax-with-a-parameter
                    var attrName = SyntaxFactory.ParseName( "JsonPropertyName" );
                    var arguments = SyntaxFactory.ParseAttributeArgumentList( $"(\"{p.Identifier.Text}\")" );
                    var attribute = SyntaxFactory.Attribute( attrName, arguments ); //MyAttribute("some_param")

                    var attributeList = new SeparatedSyntaxList<AttributeSyntax>( );
                    attributeList = attributeList.Add( attribute );
                    //[MyAttribute("some_param")]
                    var list = SyntaxFactory.AttributeList( attributeList );
                    var newP = p.AddAttributeLists( list );

                    Console.WriteLine( $"{lineNumber}:{newP}" );
                    Console.WriteLine( );
                    lines[lineNumber] = newP.GetText( ).ToString( );
                }
            }

            File.WriteAllLines( "TestNew.cs", lines );
        }

    }
}

```
```
