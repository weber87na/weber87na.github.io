---
title: redoc 筆記
date: 2023-10-19 21:00:55
tags:
- swagger
- c#
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 由於廠商沒辦法連入內網看到我們的 swagger api 文件
之前都是用些很沒效率的方法處理 , 碰巧又遇到 api 要修改的問題 , 這把就把這個搞定

### 舊版
首先找到這個地方安裝 [redoc-cli](https://www.npmjs.com/package/redoc-cli)
```
npm install -g redoc-cli
redoc-cli bundle -o index.html openapi.json
```

他還可以自訂額外屬性 , 像是最重要的 `logo` , 用法就是自己補 `x-logo` 在你的 `openapi.json` 裡面即可
詳細可以看他[文件說明](https://github.com/Redocly/redoc)

``` json
{
  "info": {
    "version": "1.0.0",
    "title": "Swagger Petstore",
    "x-logo": {
      "url": "https://redocly.github.io/redoc/petstore-logo.png",
      "backgroundColor": "#FFFFFF",
      "altText": "Petstore logo"
    }
  }
}
```


### 新版
目前已改用新版 , 不過要編他的東西前要先看下有沒有 `Supported in Redoc CE` , 不然也是白忙一場
```
npm i -g @redocly/cli@latest
redocly build-docs v1.json --output=index.html
```

想要加入 `logo` 可以看這裡的[說明](https://redocly.com/docs/redoc/redoc-vendor-extensions/#x-logo) , 好像跟舊版差不多
新版還可以插入 `markdown` 這個挺酷 , [說明看此](https://redocly.com/docs/api-reference-docs/guides/embedded-markdown/)

``` json
{
  "info": {
    "version": "1.0.0",
    "title": "Swagger Petstore",
	"description": { "$ref" : "test.md" },
    "x-logo": {
      "url": "https://redocly.github.io/redoc/petstore-logo.png",
      "backgroundColor": "#FFFFFF",
      "altText": "Petstore logo"
    }
  }
}
```

`test.md`
``` js
// hahaha test
console.log('test')
```

### 在舊版 .net 加入 x-logo
因為是維護 .net 4.x 的 api 如果想要直接在 swagger 增加 `x-logo` 屬性可以這樣用
先找到 `SwaggerConfig.cs`
```
GlobalConfiguration.Configuration
.EnableSwagger(c =>
	{
		c.SingleApiVersion("v1", "ladisai-api");
		c.DocumentFilter<SwaggerAddXLogo>();
		//其他 code ...
	}
```

然後實作 `IDocumentFilter` 即可 , 這裡就拿 `google` 當範例
```
public class SwaggerAddXLogo : IDocumentFilter
{
	public void Apply(SwaggerDocument swaggerDoc, SchemaRegistry schemaRegistry, IApiExplorer apiExplorer)
	{
		//加上額外的屬性讓建立離線 swagger 文件的工具 redocly build-docs 可以吃到 logo
		Dictionary<string, string> xlogo = new Dictionary<string, string>();
		xlogo.Add("url", "https://www.google.co.uk/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png");
		xlogo.Add("backgroundColor", "#FFFFFF");
		xlogo.Add("altText", "google");
		swaggerDoc.info.vendorExtensions.Add("x-logo", xlogo);
	}
}
```

### join
另外他還有個超酷的功能 `join` , 如果有多個不同 api 就可以一口氣轉為一份文件 , 也是挺不錯用 , 不過要注意只支援 `OpenAPI 3.x`
可以到 [這裡](https://editor.swagger.io/) 去轉換自己的版本

```
redocly join pet-swagger.json secret-swagger.json -o join.json
redocly build-docs join.json --output=join.html
```

### .net 6 加入 x-logo
如果是寫 .net 6 的話可以這樣設定

發現圖片也可以吃 `base64` , 需要的話可以到這個 [網站](https://www.base64-image.de/) 去轉
```
builder.Services.AddSwaggerGen(x =>
{
    var xlogoProp = new OpenApiObject();
    xlogoProp.Add("url", new OpenApiString("https://www.google.co.uk/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"));
    xlogoProp.Add("backgroundColor", new OpenApiString("#FFFFFF"));
    xlogoProp.Add("altText", new OpenApiString("google"));
    x.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Version = "v1",
        Title = "SecretApi",
        Extensions = new Dictionary<string, IOpenApiExtension>()
        {
            { "x-logo" , xlogoProp }
        }
    }); ;
});
```

