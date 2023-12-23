---
title: 在 .net framework 版本的 web api controller 加入 summary 說明
date: 2023-02-09 19:53:58
tags: csharp
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 希望在 controller 上面加說明 , 現在大多 example 都是 .net core 的
如果是 .net core 請參考[這裡](https://stackoverflow.com/questions/50511071/how-to-define-controller-descriptions-in-asp-net-core-swagger-swashbuckle-aspne)
搜尋了半天發現這個強國人有[類似的](https://www.twblogs.net/a/5ee843256040a668d92fd100) 但也是 .net core , 所以自己改下沒想到真能動 XD

首先找到你的 `SwaggerConfig` 找到這串複製 , 修改類別名稱 `CustomizeChineseApiDescriptionExtensions`
```
//c.DocumentFilter<ApplyDocumentVendorExtensions>
c.DocumentFilter<CustomizeChineseApiDescriptionExtensions>
```

接著加入類別 , 假設你有個 `LaDiSaiApiController` , 在你的 `List<Tag>` 加入需要的 controller 即可
```
public class CustomizeChineseApiDescriptionExtensions : IDocumentFilter
{
	public void Apply(SwaggerDocument swaggerDoc, SchemaRegistry schemaRegistry, IApiExplorer apiExplorer)
	{
		swaggerDoc.tags = new List<Tag>
		{
			new Tag
			{
				//不要加 Controller 取前面的名稱即可
				name = "LaDiSaiApi",
				//中文說明
				description = "喇低賽"
			}
		};

		//自動加入
		//swaggerDoc.tags = XmlSummaryReader.GetTags();
	}
}
```

後來覺得手動太麻煩 , 於是寫個陽春版
```
public static class XmlSummaryReader
{
	public static List<Tag> GetTags()
	{
		var result = Assembly.GetExecutingAssembly()
					.GetTypes()
					.Where( type => typeof( ApiController ).IsAssignableFrom( type ) )
					.SelectMany( type => type.GetMethods( BindingFlags.Instance | BindingFlags.DeclaredOnly | BindingFlags.Public ) )
					.Where( m => !m.GetCustomAttributes( typeof( System.Runtime.CompilerServices.CompilerGeneratedAttribute ), true ).Any() )
					.GroupBy( x => x.DeclaringType.FullName )
					.Select( x => new Tag
					{
						name = XmlSummaryReader.RemoveLastController( Type.GetType( x.Key ).Name ),
						description = XmlSummaryReader.GetSummary( Type.GetType( x.Key ) ),
					} )
					.ToList();

		return result;
	}


	public static string GetSummary( Type type )
	{
		//XDocument xmlDoc = XDocument.Load( type.Assembly.Location + ".xml" );
		XDocument xmlDoc = XDocument.Load( HostingEnvironment.MapPath( @"~/bin/YOURXML.xml" ) );
		XElement typeNode = xmlDoc.Descendants( "member" )
			.FirstOrDefault( x => x.Attribute( "name" ).Value == "T:" + type.FullName );
		if( typeNode != null )
		{
			XElement summaryNode = typeNode.Element( "summary" );
			if( summaryNode != null )
			{
				return summaryNode.Value.Trim();
			}
		}

		return string.Empty;
	}

	public static string RemoveLastController( string input )
	{
		Regex pattern = new Regex( @"Controller$" );
		if( pattern.IsMatch( input ) )
		{
			return pattern.Replace( input, "" );
		}
		else
		{
			return input;
		}
	}
}
```
