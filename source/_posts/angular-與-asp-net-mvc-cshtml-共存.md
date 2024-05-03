---
title: angular 與 asp.net mvc cshtml 共存
date: 2024-04-18 22:33:24
tags: angular
---
很古椎的業務跳惹 實在寫不太下去 哀
<p class="codepen" data-height="500" data-default-tab="result" data-slug-hash="vYMxMjo" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/vYMxMjo">
  YalaryByeBye</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

<iframe width="853" height="480" src="https://www.youtube.com/embed/a8sVOAqi0fQ" title="One More Time" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>


<!-- more -->

今天被問到說要怎麼升 angularjs 到 angular ...  老實說沒啥心情想管 , wtf 硬著頭皮寫這篇
目前只研究到讓他活在 cshtml 裡面 , 不過這種方式感覺不是很優 , 整個超亂 XD
可以參考[這篇](https://ej2.syncfusion.com/angular/documentation/getting-started/aspnet-mvc)

先開個 asp.net core mvc 專案 , 接著在專案底下開個 angular 專案
```
ng new ClientApp
```

找到 `angular.json` 調整設定 `outputPath` 為 `../Scripts/ClientApp`
```
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "../Scripts/ClientApp",
```

設定完後編譯他就會在專案底下的 `Script\ClientApp` 產生出 angular 網站的東西
```
ng build --watch
```


安裝 `WebOptimizer` 並在 `Program` 底下設定這樣
```
builder.Services.AddWebOptimizer(pipeline =>
{
    pipeline.AddJavaScriptBundle("/js/clientapp",
        "Scripts/ClientApp/runtime.*",
        "Scripts/ClientApp/polyfills.*",
        "Scripts/ClientApp/main.*"
        )
    .UseContentRoot();

    pipeline.AddCssBundle("/css/clientapp",
        "Scripts/ClientApp/styles.*")
    .UseContentRoot();

});
```

記得要設定 `UseWebOptimizer` 在 `UseStaticFiles` 才會生效
```
app.UseWebOptimizer();
app.UseStaticFiles();

```

設定 `MapFallbackToController` 路徑 , 這樣 angular 的 route 才能動

```
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}"
    );

app.MapFallbackToController("Index", "Home");

```


最後設定 `_Layout`

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - WebApplication1</title>
    <base href="/" />
@*     <link rel="stylesheet" href="~/lib/bootstrap/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="~/css/site.css" asp-append-version="true" />
    <link rel="stylesheet" href="~/WebApplication1.styles.css" asp-append-version="true" />
 *@
    <link rel="stylesheet" href="~/css/clientapp" />
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white border-bottom box-shadow mb-3">
            <div class="container-fluid">
                <a class="navbar-brand" asp-area="" asp-controller="Home" asp-action="Index">WebApplication1</a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target=".navbar-collapse" aria-controls="navbarSupportedContent"
                        aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="navbar-collapse collapse d-sm-inline-flex justify-content-between">
                    <ul class="navbar-nav flex-grow-1">
                        <li class="nav-item">
                            <a class="nav-link text-dark" asp-area="" asp-controller="Home" asp-action="Index">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-dark" asp-area="" asp-controller="Home" asp-action="Privacy">Privacy</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>
    <div class="container">
        <main role="main" class="pb-3">
            @RenderBody()
        </main>
    </div>


@*     <script src="~/lib/jquery/dist/jquery.min.js"></script>
    <script src="~/lib/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="~/js/site.js" asp-append-version="true"></script>
 *@
    <script src="~/js/clientapp"></script>
    @await RenderSectionAsync("Scripts", required: false)
</body>
</html>

```


在 angular 專案上則是讓 `app.component.html` 只留下 `<router-outlet></router-outlet>` 即可

`app-routing.module.ts` 則需要設定 routing
```
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HelloWorldComponent } from './HelloWorld/HelloWorld.component';

const routes: Routes = [
  {
    path: 'HelloWorld',
    component: HelloWorldComponent,
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}

```

然後新開的頁面也是需要一個 `Index.cshtml` 當作入口
```
public class HelloWorldController : Controller {
	public IActionResult Index(){
		return View();
	}
}
```

接著 `cshtml` 大概會長下面這樣
```
@{
    ViewBag.Title = "HelloWorld";
    Layout = "_LayoutAngular";
}

@Html.Partial("_PartialBreadCrumb")


<app-root></app-root>
<app-hello-world></app-hello-world>

```

