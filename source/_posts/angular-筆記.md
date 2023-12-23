---
title: angular 筆記
date: 2022-10-11 18:26:18
tags: angular
---
&nbsp;
![angular](https://angular.tw/assets/images/logos/angular/angular.svg)
<!-- more -->

差不多一年前短暫搞過 Angular , 後來又忙其他事 , 現在又被抓回來搞 , 已經完全忘光 XD 甚至連 css 要怎麼寫都不太記得了 , 更何況 Angular QQ , 有種越寫越兩光的 fu ~

### vscode
注意現在最新版為 `version 1.78` 會造成 `typescript language service` 發生不明錯誤

我降回 1.75 就沒事了 https://code.visualstudio.com/updates/v1_75
記得選 `Downloads: Windows: User`

另外他好像會自動更新 , 記得要在 `settings.json` 設定
```
    "update.mode": "manual",
    "update.enableWindowsBackgroundUpdates": false
```

如果你已經中標解除安裝前可以用以下命令去列出 extension 清單 , 並且安裝完後可以還原
``` powershell
code --list-extensions > extensions.list
cat extensions.list |% { code --install-extension $_}
```

記得先備份底下的 `keybindings.json` `settings.json`
```
%APPDATA%/Code/User
```

### Angular Cli 

#### 安裝
[看這篇](https://angular.tw/guide/setup-local#install-the-angular-cli)

裝好 nodejs 要重啟 terminal
```
gsudo choco install nodejs
node --version
npm install --global @angular/cli
```

我先安裝 angular cli , 然後馬上噴 error , 折磨了一翻發現我的 nodejs 版本為 16.10.x 現在最新版為 16.17.01 (https://nodejs.org/en/)
```
npm install -g @angular/cli
```
其他可以看[保哥這份說明](https://gist.github.com/doggy8088/15e434b43992cf25a78700438743774a)

#### 加入 eslint

```
ng add @angular-eslint/schematics
```

#### ng 參數
萬事起頭難 , 還好 angular 的 help 還算友善
`ng new --help`
```
      --help                Shows a help message for this command in the console.                                                                                                  [boolean]
      --interactive         Enable interactive input prompts.                                                                                                      [boolean] [default: true]
      --dry-run             Run through and reports activity without writing out results.                                                                         [boolean] [default: false]
      --defaults            Disable interactive input prompts for options with a default.                                                                         [boolean] [default: false]
      --force               Force overwriting of existing files.                                                                                                  [boolean] [default: false]
  -c, --collection          A collection of schematics to use in generating the initial application.                                                                                [string]
      --commit              Initial git repository commit information.                                                                                             [boolean] [default: true]
      --create-application  Create a new initial application project in the 'src' folder of the new workspace. When false, creates an empty workspace with no initial application. You can
                            then use the generate application command so that all applications are created in the projects folder.                                 [boolean] [default: true]
      --directory           The directory name to create the workspace in.                                                                                                          [string]
  -s, --inline-style        Include styles inline in the component TS file. By default, an external styles file is created and referenced in the component TypeScript file.        [boolean]
  -t, --inline-template     Include template inline in the component TS file. By default, an external template file is created and referenced in the component TypeScript file.    [boolean]
      --minimal             Create a workspace without any testing frameworks. (Use for learning purposes only.)                                                  [boolean] [default: false]
      --new-project-root    The path where new projects will be created, relative to the new workspace root.                                                  [string] [default: "projects"]
      --package-manager     The package manager used to install dependencies.                                                              [string] [choices: "npm", "yarn", "pnpm", "cnpm"]
  -p, --prefix              The prefix to apply to generated selectors for the initial project.                                                                    [string] [default: "app"]
      --routing             Generate a routing module for the initial project.                                                                                                     [boolean]
  -g, --skip-git            Do not initialize a git repository.                                                                                                   [boolean] [default: false]
      --skip-install        Do not install dependency packages.                                                                                                   [boolean] [default: false]
  -S, --skip-tests          Do not generate "spec.ts" test files for the new project.                                                                             [boolean] [default: false]
      --strict              Creates a workspace with stricter type checking and stricter bundle budgets settings. This setting helps improve maintainability and catch bugs ahead of time.
                            For more information, see https://angular.io/guide/strict-mode                                                                         [boolean] [default: true]
      --style               The file extension or preprocessor to use for style files.                                                     [string] [choices: "css", "scss", "sass", "less"]
      --view-encapsulation  The view encapsulation strategy to use in the initial project.                                               [string] [choices: "Emulated", "None", "ShadowDom"]
```

因為剛搞對嚴格模式的 debug 能力不太好 , 另外每次都要問你 routing & css 覺得很煩可以這樣下
```
ng new practice --strict=false --style=css --routing=true
```

此外想安裝其他 lib 的話 cd 進去就對啦 , 印象中 `--save-dev` 好像是開發期間才會用到?
```
cd practice
npm install font-awesome@4.7.0
npm install --save-dev json-server
```





### 啟動
首先找到 `package.json` 這個檔案 , 接著看到 `scripts` 裡面有一堆可以執行的選項 , 看是要做啥就去做對應的調整
啟動專案
```
npm start
```
跑起來預設為 `http://localhost:4200/` 好像沒衝到 port 就用預設的吧

另外因為要讓同事在同網段可以看到 , 所以可以多補這個 `npm run starthost`
```
"scripts": {
	"starthost": "ng serve --host 0.0.0.0 --disable-host-check"
}
```

### Debug
[參考這裡](https://code.visualstudio.com/docs/nodejs/angular-tutorial)
在 vscode 點蟲蟲 `Run And Debug` 他會幫你加上資料夾 & 設定 `.vscode\launch.json`
接著修改 json 改成你的 port 4200 就好了
```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "type": "chrome",
            "request": "launch",
            "name": "Launch Chrome against localhost",
            "url": "http://localhost:4200",
            "webRoot": "${workspaceFolder}"
        }
    ]
}
```
不然就直接 `Debug Url` 然後填 `http://localhost:4200` 也可以


### 注入
如果用 angular schematics 幫你產 service 預設會長下面這樣
```
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class LoadingService {
  constructor() { }
}
```

注意到 `providedIn: 'root'` 的部分 , 表示直接注入在 global , 然後都指到一個 instance , 等價在 `app.module.ts` 裡面的 `provideers` 裡面自己手寫這個部分
```
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { MapComponent } from './map/map.component';

@NgModule({
	declarations: [
		AppComponent,
		MapComponent
	],
	imports: [
		BrowserModule,
		AppRoutingModule

	],
	providers:[
		LoadingService
	],
	bootstrap: [AppComponent]
})
export class AppModule { }
```


如果想每次用不同的 instance 就不要加上 `providedIn: 'root'` , 接著在其他元件裡面這樣寫即可
```
import {Component, OnInit} from '@angular/core';
@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.css'],
	providers:[
		LoadingService
	]
})
export class AppComponent implements  OnInit {
	constructor() {

	}
}
```


### Loading
看課程學的 loading , 筆記下

`loading.service.ts`
```
import { BehaviorSubject, Observable, of, Subject } from 'rxjs';
import { Injectable } from '@angular/core';
import { concatMap, tap, finalize } from 'rxjs/operators';

@Injectable()
export class LoadingService {

	private loadingSubject = new BehaviorSubject<boolean>(false)
	loading$ : Observable<boolean> = this.loadingSubject.asObservable()

	showLoaderUntilCompleted<T>(obs$: Observable<T>) : Observable<T>{
	return of(null)
		.pipe(
			tap(()=> this.loadingOn()),
			concatMap(()=> obs$),
			finalize(()=>this.loadingOff())
		)
	}

	loadingOn(){
		this.loadingSubject.next(true)
	}

	loadingOff(){
		this.loadingSubject.next(false)
	}
}
```

`loading.component.ts`
```
import { Component, OnInit } from '@angular/core';
import {Observable} from 'rxjs';
import { LoadingService } from './loading.service';

@Component({
	selector: 'loading',
	templateUrl: './loading.component.html',
	styleUrls: ['./loading.component.css']
})
export class LoadingComponent implements OnInit {
	constructor(public loadingService: LoadingService) {
	}

	ngOnInit() {
	}
}
```

他這個有安裝 angular material , 應該可以自己換成喜歡的 css 就好

`loading.component.html`
```
<div class="spinner-container" *ngIf="loadingService.loading$ | async">
	<mat-spinner>
	</mat-spinner>
</div>
```


css 的部分他用常見的迷片蓋板寫法 , flex 固定在中間
```
.spinner-container {
	position: fixed;
	height: 100%;
	width: 100%;
	display: flex;
	justify-content: center;
	align-items: center;
	top: 0;
	left: 0;
	background:rgba(0, 0, 0, 0.32);
	z-index: 2000;
}
```



### 引入外部資源 css or js
這個最常見就是遇到 jq 仔在 spa 裡面繼續給你搞 jquery XD , 曾經最流行的東西現在被唾棄成這樣
找到 `angular.json` 然後修改 script 裡面要引入的函示庫即可 , 大概類似這樣 , 或丟進去 assets 裡
同理 bootstrap 或其他阿薩布魯的樣式也是加入至 styles 裡面即可
或是想模擬假 api 可以先準備個 json 檔案 , 丟在 assets 裡面
萬一這個 `angular.js` 有異動的話需要從新 `npm start` 才會 reload
```
"assets": [
	"src/api",
	"src/assets"
],
"scripts": [
	"src/jquery-3.6.1.js"
],
"styles" : [
	"node_module/bootstrap/dist/css/bootstrap.min.css",
	""
]
```



### Extension
建議不要裝那種整包的 , 有的綁一堆結果自己沒在用反而造成困擾 , 有的套件明明都沒更新還綁進去 ..

#### vscode
[Angular Language Service](https://marketplace.visualstudio.com/items?itemName=Angular.ng-template) 讓 vscode 讀懂 angular 相關語法

[angular2-switcher](https://marketplace.visualstudio.com/items?itemName=infinity1207.angular2-switcher) 
用 `alt + o` 快速切換 template & component 

[eslint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) 幫你驗證目前語法

[Angular Snippets Version 13](https://marketplace.visualstudio.com/items?itemName=johnpapa.Angular2) 加入一堆 `n-xxx` 的 tag or nippet

[Angular Schematics](https://marketplace.visualstudio.com/items?itemName=cyrilletuzi.angular-schematics) 讓你不用敲命令建立 `component` `service`

以下這兩個都跟路徑有關 , 沒裝的話有時候滿難做事
[Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
[Path Autocomplete](https://marketplace.visualstudio.com/items?itemName=ionutvmi.path-autocomplete)

[Auto Import](https://marketplace.visualstudio.com/items?itemName=steoates.autoimport) 有這個才有辦法自動 import 多少省點力

[HTML End Tag Labels](https://marketplace.visualstudio.com/items?itemName=anteprimorac.html-end-tag-labels) 這個寫 html 滿有用的 , 可以在結尾看到 class 名稱方便分辨

[TS/JS postfix completion](https://marketplace.visualstudio.com/items?itemName=ipatalas.vscode-postfix-ts) 有 postfix 就加減用下多省個一秒

[NX Console](https://marketplace.visualstudio.com/items?itemName=nrwl.angular-console)
這個後來才發現 , 比 `Angular Schematics` 功能更強但是更複雜 , 反正就是把 angular-cli 變成有 GUI 就對了 , 不過有些要自己手寫 , 視情況用

假設建立一個 LaSai service 要自己去指定路徑跟參數
`name *` => `LaSai`
`project` => `helloworld`
`path` => `./src/app/la-sai`

最後會生出這樣的指令 , 好複雜阿 @@!
```
npx nx generate @schematics/angular:service FontSize --project=helloworld --path=./src/app/la-sai --no-interactive
```

#### visual studio
[Angular Language Service 2022](https://marketplace.visualstudio.com/items?itemName=TypeScriptTeam.AngularLanguageService2022) 這個 2022/10/15 剛開發出來 XD
[Angular Html TS Switcher VS 2022](https://marketplace.visualstudio.com/items?itemName=OAS.05D8FE2B-55EC-4A28-8865-C2570F30A1C9) 不過這個快捷是 `ctrl + 2` 所以要自己 remap 為 `alt + o`

其他就乖打指令或是切回 vscode 去開發這個部分 , 後來遇到因為有兩個 module 所以他認不得要自動 import 進去哪個的問題要改這樣用 `--skip-import=true`
```
ng g component map --skip-import=true
```


#### chrome
[Angular DevTools](https://chrome.google.com/webstore/detail/angular-devtools/ienfalfjdbdpebioblfackkekamfmbnh) 這個算是 Chrome 的 extension , 安裝好以後按下 F12 會出現一個 Angular 頁籤 , 可以看到元件內的變數方便 debug

### 關閉 strict mode

找到 `tsconfig.json` 將設定有 `strict` 改成 false 吧 , 這個不改的話開發起來應該會被搞死 XD
其他好像還有些地方有 , 暫時沒詳細研究

```
  "compilerOptions": {
    "baseUrl": "./",
    "outDir": "./dist/out-tsc",
    "forceConsistentCasingInFileNames": true,
    "strict": false,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "sourceMap": true,
    "declaration": false,
    "downlevelIteration": true,
    "experimentalDecorators": true,
    "moduleResolution": "node",
    "importHelpers": true,
    "target": "es2020",
    "module": "es2020",
    "lib": [
      "es2020",
      "dom"
    ]
  },


  "angularCompilerOptions": {
    "enableI18nLegacyMessageIdFormat": false,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": true
  }  
```




### editorconfig
因為長期寫 .net 的關係 , 看到兩個空白就賭爛 , 所以就靠這樣解決 XD
效果可以看[這個影片](https://www.youtube.com/watch?v=_fcQDS1iTPw)
首先安裝這個一臉猥瑣的老鼠 [EditorConfig extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
接著加入或修改這個檔案 , 從此以後就跟討厭的兩個空白說掰掰 , 更噁爛的應該還有 `prettier` , 不過環境太亂了就暫時不搞
`.editorconfig`
```
# Editor configuration, see https://editorconfig.org
root = true

[*]
charset = utf-8
indent_style = tab
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.ts]
quote_type = single

[*.md]
max_line_length = off
trim_trailing_whitespace = false
```

### 常用會忘了 import 的 module

`FormsModule` , `HttpClientModule` 這兩老常常用 , 但是常常忘記
`app.module.ts`
```
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FooterComponent } from './footer/footer.component';
import { HeaderComponent } from './header/header.component';
import { TagsComponent } from './tags/tags.component';
import { ArticlesComponent } from './articles/articles.component';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

@NgModule({
	declarations: [
		AppComponent,
		FooterComponent,
		HeaderComponent,
		TagsComponent,
		ArticlesComponent
	],
	imports: [
		BrowserModule,
		AppRoutingModule,
		FormsModule,
		HttpClientModule
	],
	providers: [],
	bootstrap: [AppComponent]
})
export class AppModule { }
```

### 檔名 & 資料夾結構
檔名習慣一律使用 `小寫` 作為檔名 , 資料夾結構大概類似這樣 , 跟程式有關的丟在 `app` 底下就對了 , 像是 `model` , `service` 這類
範例: 假設建立一個 `fontSize` 的 component 會產生出這樣的檔案 `font-size.component.ts` 然後類別名稱會長這樣 `FontSizeComponent`

順便科普在 windows 用 `tree /F` 可以產出類似如下資料夾結構 , 但是沒辦法指定階層 , windows 可以考慮安裝這個 [tree-cli](https://www.npmjs.com/package/tree-cli) 用起來就跟 linux 類似
```
npm install -g tree-cli

treee -l 1
treee -l 2
```

linux 底下可以直接用 `tree -L 3` 指定階層 
資料夾結構如下
```
├── app
│   ├── app-routing.module.ts
│   ├── app.component.css
│   ├── app.component.html
│   ├── app.component.spec.ts
│   ├── app.component.ts
│   ├── app.module.ts
│   └── model
├── assets
├── environments
│   ├── environment.prod.ts
│   └── environment.ts
├── favicon.ico
├── index.html
├── main.ts
├── polyfills.ts
├── styles.css
└── test.ts

```

### Binding
#### Attribute vs Property
因為這兩個都翻譯成屬性 , 英文真噁 , 所以特別筆記下在 angular 裡面的定義 , 防止又忘了
`attribute` => html 標籤裡面寫的咚咚 , 如果你在 chrome 對這個元素點右鍵 , 他會有個選項叫做 `Edit Attribute`
```
<div id="qq" class=""></div>
```

`property` => dom tree 生出來的咚咚
```
qq = document.getElementById('qq')
qq.classList
```
太難解釋 XD [詳細可以看這篇](https://teagan-hsu.coderbridge.io/2020/12/28/javascript-dom-attribute-property/)
#### Attrbitue binding
以前 jquery 常常寫這樣 `data-xxx="ooo"` 在 angular 要寫這樣 `[attr.data-xxx]="ooo"`
```
<div id="lasai" [attr.xx]="ooo"></div>
<div id="lasai" [attr.data-xx]="ooo"></div>
```

這是一個工作上遇到的實例 , 套用 bootstrap 的 `list-group-item` , 底下有子選項 , 希望把子選項的數量也列出來 , 但是不想多加 `span`
所以就想到可以靠 css 的 `content` 搭配 `attr` 挖洞把數值傳進去
```
<div class="list-group overflow-auto  mt-2">
<button type="button"
class="list-group-item list-group-item-action"
[class.child-len]="true"
[attr.data-child-len]="item?.childItems?.length"
*ngFor="let item of items">
{{item.name}}
</button>
</div>
```

撰寫 css 要注意需要先開啟父層空間為 `relative` , 這樣偽元素定位才會正確
這裡翻書看到日本人推薦一個有趣的 [border-radius 工具](https://9elements.github.io/fancy-border-radius/) 方便拉出好看的點綴效果
```
.child-len {
  position: relative;
}

.child-len::before {
  content: attr(data-child-len);
  padding: 5px;
  left: 0px;
  width: 30px;
  height: 30px;
  line-height: 22px;
  text-align: center;
  position: absolute;
  border-radius: 100% 0% 100% 0% / 100% 37% 63% 0%;
  background-color: rgba(138, 201, 57, 0.75);
  color: white;
  z-index: -1;
  text-indent: 0;
}
```

#### Property binding
上面說到 property 是跟 dom 相關 , 最好的例子就是 `innerHtml` , 這樣就可以在裡面吃到 html
```
<div id="lasai" [innerHtml]="<p>helloworld</p>"></div>
```

#### Event binding
比較特別的地方就是要用 `$event` 當參數傳進去讓 function 接收 , 另外不確定是傳啥的話可以先在 function 接收的地方寫上 `any`
```
<button (click)="helloworld($event)"></button>

//helloworld(event: any){
//	console.log(event)
//}

helloworld(event: MouseEvent){
	console.log(event)
}
```

#### 雙向/香蕉 binding
angular 的雙向是兩個單向組合而成 , 要記這個噁爛的語法就要參考老外這句英文 `banana in the box [()]` 其實還滿像的啦 XD
跟那個啥 perl 的太空船符號有得拚 , 好像長這樣 `<->`
```
<div [(ngModel)]="banana"></div>
```

#### ngClass binding
注意要加上中括號 `[ngClass]` , 新手剛寫很容易忘記 , 還有其他寫法就懶得筆記了 XD
另外注意切換 class 不要白目加上 `.` , 例如 `.bg-text` 應該要寫 `bg-text`
```
<!-- 正確寫法 -->
<div [ngClass]="'text-white m-2 p-2 ' + getClasses()">
	Hello World
</div>

<!-- 錯誤寫法 -->
<div ngClass="'text-white m-2 p-2 ' + getClasses()">
	Hello World
</div>

<!-- 其他寫法 -->
<div [class.red]="items.length > 10">
	Hello World
</div>
```



#### ngStyle binding
這個我的記憶法就是裡面放 json , 然後 json 屬性都使用單引號即可
```
<div [ngStyle]="{ 'font-size' : '200px'}">
	龜
</div>
```

另外 style 還可以寫成這樣 `[style.fontSize]="'20px'"` 要串多個的話可以像下面這樣寫 
```
<div [(colorPicker)]="headColor"
	[style.background]="headColor"
	[style.width]="'100px'"
	[style.height]="'100px'"
	[style.borderRadius]="'50%'"
	[style.fontSize]="'20px'"></div>
```

#### 字串插值 binding (string interpolation binding)
這應該最簡單啦 , 用兩個花括號包著即可
```
<div>{{helloworld}}</div>
```

#### Lab 實作一隻烏龜
因為大致上玩過 binding 了 , 總要練習看看 , 結果可以看 [這裡](https://stackblitz.com/edit/angular-electronic-turtle)
這個 Lab 要改變烏龜的顏色 , 還有龜殼上面的文字

下載 [ngx-color-picker](https://www.npmjs.com/package/ngx-color-picker)
```
npm install ngx-color-picker --save
```

引用 `ngx-color-picker`

`app.module.ts`
```
import { ColorPickerModule } from 'ngx-color-picker';

@NgModule({
  ...
  imports: [
    ...
    ColorPickerModule
  ]
})
```

這裡要設定 `colorPicker`  讓他用雙向 binding

`turtle.component.html`
```
<div class="turtle">
	<div class="head"
		[(colorPicker)]="headColor"></div>
	<div class="foot-top-left"></div>
	<div class="foot-top-right"></div>
	<div class="shell">
		<div class="text"
			style="z-index:999999">
			<a href="https://tortoisegit.org/"
				target="_blank">{{ text }}</a>
		</div>
	</div>
	<div class="foot-bottom-left"></div>
	<div class="foot-bottom-right"></div>
</div>
```

`turtle.component.css`
```
* {
	margin: 0;
	padding: 0;
}

body {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 100vh;
}

.turtle {
	/* width: 400px;
	height: 400px;
	position: relative; */
	/* border: 1px solid; */
}

:host{
	--head-color: red
}
.head {
	width: 50px;
	height: 60px;
	border: 1px solid;
	border-radius: 50%;
	position: absolute;
	top: calc(50% - 30px - 110px);
	left: calc(50% - 25px);
	background-color: var(--head-color);
	transition: 1s;
}

.head:hover {
	background-color: pink;
	box-shadow: 0 0 50px pink;
	transition: 1s;
	transform: scale(1.2);
}

.head::after {
	content: '';
	position: absolute;
	width: 5px;
	height: 5px;
	top: 5px;
	right: 5px;
	border-radius: 50%;
	border: 1px solid;
	background-color: #000;
}

.head::before {
	content: '';
	position: absolute;
	width: 5px;
	height: 5px;
	top: 5px;
	left: 5px;
	border-radius: 50%;
	border: 1px solid;
	background-color: #000;
}

.shell {
	/* border: 5px solid; */
	position: absolute;
	margin: auto;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;

	border-radius: 50%;

	width: 200px;
	height: 220px;
	z-index: 10;
	background-color: rgb(16, 157, 95);
	/* background-color: rgb(0, 107, 0); */


	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 0 20px #0A0;

}

.shell::after {
	position: absolute;
	margin: auto;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	border-radius: 41%;
	width: 195px;
	height: 210px;
	content: '';
	border: 1px solid;
	z-index: 11;
	animation: move 5s linear infinite;
}

@keyframes move {
	to {
		transform: rotate(-1turn);
	}
}

@keyframes move2 {
	to {
		transform: rotate(90deg);
	}
}

.shell::before {
	position: absolute;
	margin: auto;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	border-radius: 45%;
	width: 200px;
	height: 200px;
	content: '';
	border: 1px solid;
	z-index: 11;
	animation: move2 1s linear infinite;
}


.text {
	margin: auto;
	font-family: '標楷體';
	color: #fff;
	font-size: 72pt;
	writing-mode: vertical-lr;
	text-align: center;
	vertical-align: middle;
	text-shadow:
		0 0 15px #fff,
		0 0 35px #fff;
}

.text a {
	text-decoration: none;
	color: #fff;
}

.foot-top-left {
	width: 30px;
	height: 50px;
	border: 1px solid;
	border-radius: 50%;
	position: absolute;
	top: calc(50% - 30px - 80px);
	left: calc(50% - 30px - 60px);
	transform: rotate(-20deg);

	background-color: #d4ffe2;
	animation: move-foot-top-left 1s alternate infinite;

}

@keyframes move-foot-top-left {
	to {
		transform: rotate(-33deg);
	}
}

.foot-top-right {
	width: 30px;
	height: 50px;
	border: 1px solid;
	border-radius: 50%;
	position: absolute;
	top: calc(50% - 30px - 80px);
	right: calc(50% - 30px - 60px);
	transform: rotate(20deg);

	background-color: #d4ffe2;
	animation: move-foot-top-right 1s alternate infinite;
}

@keyframes move-foot-top-right {
	to {
		transform: rotate(45deg);
	}
}

.foot-bottom-left {
	width: 30px;
	height: 50px;
	border: 1px solid;
	border-radius: 50%;
	position: absolute;
	bottom: calc(50% - 30px - 80px);
	left: calc(50% - 30px - 60px);
	transform: rotate(20deg);
	background-color: #d4ffe2;

	animation: move-foot-bottom-left 1s alternate infinite;
}

@keyframes move-foot-bottom-left {
	to {
		transform: rotate(43deg);
	}
}

.foot-bottom-right {
	width: 30px;
	height: 50px;
	border: 1px solid;
	border-radius: 50%;
	position: absolute;
	bottom: calc(50% - 30px - 80px);
	right: calc(50% - 30px - 60px);
	transform: rotate(-20deg);
	background-color: #d4ffe2;
	animation: move-foot-bottom-right 1s alternate infinite;
}

@keyframes move-foot-bottom-right {
	to {
		transform: rotate(-33deg);
	}
}

```

特別注意到關鍵這個片段在 `:host` 加上 css 變數 `--head-color`
```
:host{
	--head-color: red
}
.head {
	width: 50px;
	height: 60px;
	border: 1px solid;
	border-radius: 50%;
	position: absolute;
	top: calc(50% - 30px - 110px);
	left: calc(50% - 25px);
	background-color: var(--head-color);
	transition: 1s;
}
```

最後設定 `turtle.component.ts`
關鍵在使用 `HostBinding` 可以參考[這篇](https://decodedscript.com/ways-of-binding-css-variables-in-angular/)
```
import { Component, EventEmitter, HostBinding, Input, OnInit, Output } from '@angular/core';

@Component({
	selector: 'app-turtle',
	templateUrl: './turtle.component.html',
	styleUrls: ['./turtle.component.css']
})
export class TurtleComponent implements OnInit {

	constructor() { }

	ngOnInit(): void {
		// this.headColor = 'red'
	}

	private _headColor: string = '';

	@HostBinding("style.--head-color")
	@Input()
	get headColor() : string{
		return this._headColor
	}

	set headColor(headColor : string){
		this._headColor = headColor
		this.headColorChange.emit(this._headColor)
	}


	@Output()
	headColorChange = new EventEmitter<string>()

	@Input()
	text : string = ''

}
```

`app.component.ts`
```
import { Component } from '@angular/core';

@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.css']
})
export class AppComponent {
	headColor = '#d4ffe2'	
	text = '龜龜'
}
```

`app.component.html`
```
<h1>直接點烏龜頭修改顏色</h1>

<label>輸入其他字修改龜殼文字</label>
<input type="text"
	[(ngModel)]="text"
	[style.margin]="'10px'"
	maxlength="2" />

<app-turtle [(headColor)]="headColor" [text]="text"></app-turtle>
```


### 指令
這類用法跟以前在 angularjs 差不多 , 就是改成前面有 `*ng` , 不過以前怎麼寫的我突然也忘了 ..

#### ngSwitch
```
<div class="bg-info p-2 mt-1" [ngSwitch]="getProductCount()">
	<span *ngSwitchCase="2">There are 2 products</span>
	<span *ngSwitchCase="3">There are 3 products</span>
	<span *ngSwitchDefault>There are {{getProductCount()}} products</span>
</div>
```

另外這類指令會讓元素直接 `消失` , 不是隱藏 , 其他像是 `*ngIf` 等等也會有類似的效果
```
<div class="bg-info p-2 mt-1" ng-reflect-ng-switch="5">
<!--bindings={ "ng-reflect-ng-switch-case": "2" }-->
<!--bindings={ "ng-reflect-ng-switch-case": "3" }-->
<span>There are 5 products</span><!--container--></div>
<!--container-->
```

#### ngFor
for 就很直覺 , 另外還有 `first` , `last` , `index` 這類可以幫助微調
```
<table class="table table-sm table-bordered mt-1 text-dark">
	<tr>
		<th>Name</th>
		<th>Category</th>
		<th>Price</th>
	</tr>
	<tr *ngFor="let item of getProducts();let first = first;let i = index;let odd = odd;"
		[class.bg-primary]="odd" [class.bg-info]="!odd" [class.bg-danger]="first"
	>
		<td>{{i + 1}}</td>
		<td>{{item.name}}</td>
		<td>{{item.category}}</td>
		<td>{{item.price}}</td>
	</tr>
</table>
```

### 日期問題
安裝參考[這篇](https://fullstacksoup.blog/2020/06/17/angular-convert-date-to-sql-server-date-format/)
今天遇到一個問題用 `new Date()` , angular 新增時間到 sql server 時 , 差了八小時
本來想說在 api 上面做手腳但是 try 了半天 format 都沒辦法一致
web api 預設會打出這樣的 format `2023-03-28T08:02:18.513`
最後發現應該前端要用 `DatePipe` 然後這樣寫就可以過了
可以參考這個網站有整理很好的[表格](https://www.numenta.com/resources/htm/htm-studio/date-time-formats/)
```
"modifyDatetime": this.datepipe.transform(new Date(), 'yyyy-MM-ddTHH:mm:ss.SSS')!
```


### route
本來以為用了 angular 還可以混合後端寫 , 沒想到連 route 都前端在控制 , 真是狠 XD
這個設定看上去還算是直覺 , `**` 的部分大概就是直接導向到 `/store` , 其他就導向自己對應的頁面

`app.module.ts`
```
import { CheckoutComponent } from './store/checkout.component';
import { CartDetailComponent } from './store/cartDetail.component';
import { StoreComponent } from './store/store.component';
import { RouterModule } from '@angular/router';
import { NgModule } from "@angular/core";
import { BrowserModule } from "@angular/platform-browser";
import { AppComponent } from "./app.component";
import { StoreModule } from "./store/store.module";

@NgModule({
	imports: [BrowserModule, StoreModule,
		RouterModule.forRoot([
			{ path: "store", component: StoreComponent },
			{ path: "cart", component: CartDetailComponent },
			{ path: "checkout", component: CheckoutComponent },
			{ path: "**", redirectTo: "/store" }
		])],
	declarations: [AppComponent],
	bootstrap: [AppComponent]
})
export class AppModule { }
```

`app.component.ts`
```
import { Component, NO_ERRORS_SCHEMA } from '@angular/core';

@Component({
	selector: 'app',
	// templateUrl : './app.component.html',
	// template: '<store></store>'
	template: '<router-outlet></router-outlet>'

})
export class AppComponent {
	title = 'SportsStore';
}


```

我實務上遇到希望 route 父層可以帶個預設編號 , 不然 user 點到父層的話 , 畫面應該是一片空
`app-routing.module.ts`
```
{
	path: 'user-detail',
	redirectTo: 'user-detail/0',
	pathMatch : 'full'
},
{
	path: 'user-detail',
	component: UserDetailComponent,
	data: { breadcrumb: '使用者詳細資訊' },
	children: [
	{
		path: ':id',
		component: UserDetailComponent,
		data: { breadcrumb: (data: any) => `${data.userDetail.name}` },
		resolve: { userDetail: UserDetailResolverService },
		canActivate: [AuthGuard]
	},
],
	canActivate: [AuthGuard]
}
```

### .net 6 整合
我看他 .net 6 跟 .net core 3 差異滿大的 XD

執行命令
```
dotnet new angular -o HealthCheck
cd HealthCheck/ClientApp
```

建立好以後可以看到 `ClientApp` 裡面放了 Angular 的東西 , 其他跟 .net 蓋出來的差不多
另外用這個 template 建立出來的 angular 應該是 12 , 可以參考這篇[升級](https://ithelp.ithome.com.tw/articles/10275115)

```
angular-demo\HealthCheck\ClientApp via  v16.17.1
🌹 ng version
Your global Angular CLI version (14.2.4) is greater than your local version (12.2.2). The local Angular CLI version is used.

To disable this warning use "ng config -g cli.warnings.versionMismatch false".

     _                      _                 ____ _     ___
    / \   _ __   __ _ _   _| | __ _ _ __     / ___| |   |_ _|
   / △ \ | '_ \ / _` | | | | |/ _` | '__|   | |   | |    | |
  / ___ \| | | | (_| | |_| | | (_| | |      | |___| |___ | |
 /_/   \_\_| |_|\__, |\__,_|_|\__,_|_|       \____|_____|___|
                |___/


Angular CLI: 12.2.2
Node: 16.17.1 (Unsupported)
Package Manager: npm 8.19.2
OS: win32 x64

Angular: 12.2.2
... animations, cli, common, compiler, compiler-cli, core, forms
... platform-browser, platform-browser-dynamic, platform-server
... router

Package                         Version
---------------------------------------------------------
@angular-devkit/architect       0.1202.2
@angular-devkit/build-angular   12.2.2
@angular-devkit/core            12.2.2
@angular-devkit/schematics      12.2.2
@schematics/angular             12.2.2
rxjs                            6.6.7
typescript                      4.2.4

Warning: The current version of Node (16.17.1) is not supported by Angular.
```

執行以下命令看目前版本
```
ng version
```

更新時 `ng update` 萬一噴這個 `Package '@angular/cli' is not a dependency.` 要先 `npm install`
```
npm install
ng update

#Package '@angular/cli' is not a dependency.
```

最後可以到這裡 [官網更新網站](https://update.angular.io) 選你要更新的版本 , 貼上指令就可以更新啦
```
ng update @angular/core@14 @angular/cli@14
```


### SSR
感覺有夠麻煩 [看這篇](https://pieterjandeclippel.medium.com/server-side-rendering-in-asp-net-core-angular-2022-version-7aaed8157976) , 而且沒官方 Support 就暫時不搞 , 可能其他語言有吧 @@!?


### 整合 openlayers
因為以前搞 GIS 用 openlayers 也混了幾年的飯 , 加減玩看看

基本上參考 [這篇](https://medium.com/@pro.gramistka/create-interactive-maps-in-angular-12-project-with-openlayers-ba6683d6fe5b) 就可以做出來了 , 沒啥難度
注意到一定要在 `tsconfig.json` 設定這個 `"skipLibCheck":true` 不然會噴一堆鬼東西搞到沒法 debug

```
npm install --save ol
```

接著修改 `angular.json` 引用 openlayers 的樣式
```
"styles": [
  "src/styles.css",
  "node_modules/ol/ol.css"
],
```

建立 map 元件
```
ng generate component map
```

`map.component.html`
```
<div id="map" class="map"></div>
```

`map.component.css`
```
.map {
  width: 100%;
  height: 100vh;
}
```

這裡注意 `styleUrls` 用 `css` , 作者用 `scss`
`map.component.ts`
```
import { Component, OnInit } from '@angular/core';
import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import { OSM } from 'ol/source';
import TileLayer from 'ol/layer/Tile';
@Component({
  selector: 'app-map',
  templateUrl: './map.component.html',
  styleUrls: ['./map.component.css']
})
export class MapComponent implements OnInit {
  public map!: Map
  ngOnInit(): void {
    this.map = new Map({
    layers: [
      new TileLayer({
        source: new OSM(),
      }),
    ],
    target: 'map',
    view: new View({ 
      center: [0, 0],
      zoom: 2,maxZoom: 18, 
    }),
  });
 }
}
```

最後一步設定地圖到主元件上就收工了 `app.component.html`
```
<app-map></app-map>
```

### 整合 openlayers 2
嘗試把我以前做的奇怪美食地圖搬移看看 , 記錄下被坑的過程
安裝看起來很喇低賽的 [papercs](https://www.getpapercss.com/)
```
npm install papercss
```

`angular.json`
```
"styles": [
	"src/styles.css",
	"node_modules/ol/ol.css",
	"node_modules/papercss/dist/paper.css"
],
```

中間遇到最大的問題大概就是以前寫了一堆覆蓋 function 的方法 , 這個在 typescript 會吃土
在 `style` 這個方法裡面又有呼叫 `scaleAttractionsIcon` , `scaleAttractionsText` 這兩個方法
```
//景點圖層
var attractionsLayer = new ol.layer.Vector({
	renderMode: 'image',
	source: new ol.source.Vector({
		format: new ol.format.GeoJSON(),
		features: format.readFeatures(attractions)
	}),
	style: function (feature) {
		var style = new ol.style.Style({
			image: new ol.style.Icon(({
				src: setIconSrc(feature),
				scale: scaleAttractionsIcon()
			})),
			text: new ol.style.Text({
				text: scaleAttractionsText(feature),
				fill: new ol.style.Fill({
					color: '#000'
				}),
				stroke: new ol.style.Stroke({
					color: '#fff',
					width: 2
				}),
				offsetY: 24
			})
		});
		return style;
	},
});
```

可是這樣寫在 `typescript` & `angular` 裡面 `style` 會變成 `local function` , `this` 這個 `scope` 會抓不到 , 所以找不到 `this.scaleAttractionsIcon` , `this.scaleAttractionsText`
另外 `openlayers` 的 `Text` 類別裡面還有 `text` , 這個才是真正的文字
最後就是以前懶得管閃爍的問題 , 這次順手修下 , 把東西先 cache 到 array 裡面 , 有找到的話就丟出原本樣式
```
//cache 樣式用防止閃爍
styles: Array<Style> = []
	
scaleAttractionsIcon() {
	var zoom = this.map.getView().getZoom();

	if (zoom == 9) {
		return 0.4;
	}

	if (zoom < 9) {
		return 0.2;
	}

	return 1;
}

setIconSrc(feature: FeatureLike): string {
	var name = feature.getProperties()['Name'];
	console.log(name);
	return `assets/img/attractions-min/${name}.jpg`;
}

//景點圖層
attractionsLayer = new VectorLayer({
	source: new VectorSource({
		format: new GeoJSON(),
		features: new GeoJSON().readFeatures(this.attractions)
		//url: './data/attractions.geojson'
	}),

	style: feature => {
		let style: Style;
		// 從 styles 的 cache 裡面找出資料
		let isFind = this.styles.some(x => {
			return x.getText().getText() === feature.get('Name')
		})
		console.log('isFind', isFind)
		if (isFind) {
			// 如果 styles 的 cache 裡面有資料的話 , 回傳該名稱的樣式
			style = this.styles.filter(x => {
				return x.getText().getText() === feature.get('Name')
			})[0]
			return style
		} else {
			// 如果沒找到的話新增 style 並且 push 到裡面去 , 最後回傳
			style = new Style({
				image: new Icon(({
					src: this.setIconSrc(feature),
					scale: this.scaleAttractionsIcon()
				})),
				text: new Text({
					text: this.scaleAttractionsText(feature),
					fill: new Fill({
						color: '#000'
					}),
					stroke: new Stroke({
						color: '#fff',
						width: 2
					}),
					offsetY: 24
				})
			});
			this.styles.push(style)
			return style;
		}
	},
});
```


目前 code 大概長這樣 , 暫時能動 ,  有空接著搞 XD
`map.component.ts`
```
import { Component, Inject, Injectable, OnInit, AfterViewInit } from '@angular/core';
import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import { OSM } from 'ol/source';
import TileLayer from 'ol/layer/Tile';
import GeoJSON from 'ol/format/GeoJSON';
import VectorSource from 'ol/source/Vector';
import { Fill, Icon, Stroke, Style, Text } from 'ol/style';
import { getBottomLeft, getHeight, getWidth } from 'ol/extent';
import { toContext } from 'ol/render';
import VectorLayer from 'ol/layer/Vector';
import XYZ from 'ol/source/XYZ'
import { Control, defaults as defaultControls } from 'ol/control';
import { Size } from 'ol/size';
import { Feature } from 'ol';
import { Geometry } from 'ol/geom';
import { FeatureLike } from 'ol/Feature';

@Component({
	selector: 'app-map',
	templateUrl: './map.component.html',
	styleUrls: ['./map.component.css']
})
export class MapComponent implements OnInit{
	public map!: Map
	constructor() {
	}
	ngOnInit(): void {
		this.map = new Map({
			controls: defaultControls({
				attribution: false,
				zoom: false,
				rotate: false
			}).extend([

			]),
			// layers: this.layers,
			layers: [
				this.baseLayer,
				this.attractionsLayer
			],
			target: 'map',
			view: new View({
				projection: 'EPSG:4326',
				center: [120.4553, 22.873],
				zoom: 11,
				maxZoom: 18,
			}),
		});
	}

	scaleAttractionsIcon() {
		var zoom = this.map.getView().getZoom();

		if (zoom == 9) {
			return 0.4;
		}

		if (zoom < 9) {
			return 0.2;
		}

		return 1;
	}

	setIconSrc(feature: FeatureLike): string {
		var name = feature.getProperties()['Name'];
		console.log(name);
		return `assets/img/attractions-min/${name}.jpg`;
		// return ''

	}

	attractions = {
		"type": "FeatureCollection",
		"features": [
			{
				"type": "Feature",
				"properties": { "Name": "林老師卡好咖啡" },
				"geometry": { "type": "Point", "coordinates": [120.6817005, 22.9100108] }
			},
			{
				"type": "Feature",
				"properties": { "Name": "蛋黃酥冰" },
				"geometry": { "type": "Point", "coordinates": [120.4594596, 23.1247144] }
			},
			{
				"type": "Feature",
				"properties": { "Name": "台灣豬隊友" },
				"geometry": { "type": "Point", "coordinates": [120.3314311, 22.6418476] }
			},
		]
	};

	//定義基本底圖
	baseLayerUrl = 'https://wmts.nlsc.gov.tw/wmts/EMAP/default/GoogleMapsCompatible/{z}/{y}/{x}.png'
	
	//osm
	//baseLayerUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
	baseLayer = new TileLayer({
		source: new XYZ({
			url: this.baseLayerUrl,
		})
	});

	//osm
	osmLayer = new TileLayer({
		source: new OSM(),
	})
	
	//樣式
	twLayerStyles: Array<Style> = []
	
	//台灣
	twLayer = new VectorLayer({
		// renderMode: 'image',
		source: new VectorSource({
			format: new GeoJSON(),
			url: 'assets/data/tw.geojson'
		}),
		style: feature => {
			let style: Style
			let countryName = feature.getProperties()['COUNTYNAME'];
			console.log(countryName)

			let isFind = this.twLayerStyles.some(x => x.getText().getText() === countryName)
			if (isFind) {
				style = this.twLayerStyles.filter(x => x.getText().getText() === countryName)[0];
				return style
			} else {

				let style = new Style({
					stroke: new Stroke({
						color: 'rgba(0, 0, 0, 1)',
						width: 1
					}),
					text: new Text({
						text: countryName,
						fill: new Fill({ color: '#000' }),
						stroke: new Stroke({
							color: '#FF8800',
							width: 10
						}),
					})
				})
				this.twLayerStyles.push(style)
				return style
			}

		},
	});

	scaleAttractionsText(feature: FeatureLike): string | string[] {
		let name = feature.getProperties()['Name']
		return name
	}

	styles: Array<Style> = []

	//景點圖層
	attractionsLayer = new VectorLayer({
		source: new VectorSource({
			format: new GeoJSON(),
			features: new GeoJSON().readFeatures(this.attractions)
			//url: './data/attractions.geojson'
		}),

		style: feature => {
			let style: Style;
			// 從 styles 的 cache 裡面找出資料
			let isFind = this.styles.some(x => {
				return x.getText().getText() === feature.get('Name')
			})
			console.log('isFind', isFind)
			if (isFind) {
				// 如果 styles 的 cache 裡面有資料的話 , 回傳該名稱的樣式
				style = this.styles.filter(x => {
					return x.getText().getText() === feature.get('Name')
				})[0]
				return style
			} else {
				// 如果沒找到的話新增 style 並且 push 到裡面去 , 最後回傳
				style = new Style({
					image: new Icon(({
						src: this.setIconSrc(feature),
						scale: this.scaleAttractionsIcon()
					})),
					text: new Text({
						text: this.scaleAttractionsText(feature),
						fill: new Fill({
							color: '#000'
						}),
						stroke: new Stroke({
							color: '#fff',
							width: 2
						}),
						offsetY: 24
					})
				});
				this.styles.push(style)
				return style;
			}
		},
	});

}
```


### TodoMVC 練習
第一次自己寫破破爛爛的 QQ , 不過還是加減[保留](https://stackblitz.com/edit/lasai-todo?file=src%2Fapp%2Fapp.component.ts) 
後來發現保哥也有這個[練習](https://www.youtube.com/watch?v=aMeF8ksXv7o) , 不過他又切得更複雜 , 另外他的版本功能少了一兩個 , 不是原本版本 

[版型下載](https://github.com/tastejs/todomvc-app-template) 注意他的 css 在 `node_module` 裡面要自己搬出來
```
git clone https://github.com/tastejs/todomvc-app-template.git
cd todomvc-app-template
npm install
```

接著建立自己的 todomvc
```
ng new todomvc --strict=false --style=css --routing=true
```

加入這段到 `package.json` 方便另外一台電腦看
```
"scripts": {
	"starthost": "ng serve --host 0.0.0.0 --disable-host-check"
}
```

ps: 如果套其他版型可以在專案 root 那層先建立 `template` 資料夾然後把版丟進去 , 加入到 git 裡面版控

把 `app.component.html` 裡面內容清空
把版型的 `css` 複製到 `assets`
複製版型 `index.html` 內的 `head` 區塊部分到自己 `src\index.html` 裡面 , 特別注意保留 `<base href="/">`

```
<head>
	<base href="/">
	<meta charset="utf-8">
	<title>Todomvc</title>
	<meta name="viewport"
		content="width=device-width, initial-scale=1">
	<link rel="icon"
		type="image/x-icon"
		href="favicon.ico">
	<link rel="stylesheet"
		href="./assets/index.css">
	<link rel="stylesheet"
		href="./assets/base.css">
</head>
```

接著把版型 `body` 裡面的部分貼到 `app.component.html` , 接著執行看看 `http://localhost:4200/` 到此就正常了
```
ng serve
```

開啟 [Angular 版本的 TodoMVC](https://todomvc.com/examples/angular2/) 來看看它的效果 , 發現比其他版本還兩光偷懶了好幾個功能
所以用 [所以換成 Dart 版本的 TodoMVC](https://todomvc.com/examples/vanilladart/build/web/) 開始模擬效果

先修改 title 屬性
```
title = 'lasai todo'
```

然後做個 binding , 確認正常運作
```
<h1>{{title}}</h1>
```


如果 two way binding 陣亡的話要補 `FormsModule`
`app.module.ts`
```
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

@NgModule({
	declarations: [
		AppComponent
	],
	imports: [
		BrowserModule,
		AppRoutingModule,
		FormsModule
	],
	providers: [],
	bootstrap: [AppComponent]
})
export class AppModule { }
```


建立 `Todo` 的類別
```
export class Todo {
	constructor(
		id: number,
		title: string,
		complete: boolean,
		editing: boolean
	) {
		this.id = id
		this.title = title
		this.complete = complete
		this.editing = editing
	}
	id: number
	title: string = ''
	complete: boolean = false
	editing: boolean = false
}
```

建立 `IDGen` 類別
```
export class IdGen {
	id: number = 0
	public next(): number {
		this.id += 1
		return this.id
	}
}
```

`AppComponent`
```
export class AppComponent {
	title = 'lasai todo';

	//All
	//Active
	//Complete
	selected = 'All'

	selectedAll = true
	selectedActive = false
	selectedCompleted = false

	gen = new IdGen()

	todos: Todo[] = [
		new Todo(this.gen.next(), '買菜', true, false),
		new Todo(this.gen.next(), '洗衣服', false, false),
	]

	getTodos(): Todo[] {
		if (this.selectedAll)
			return this.todos

		if (this.selectedActive)
			return this.todos.filter(x => x.complete === false)

		if (this.selectedCompleted)
			return this.todos.filter(x => x.complete === true)
	}

	addTodo(todoInput: HTMLInputElement): void {
		if (todoInput.value.trim().length > 0) {
			let todo = new Todo(this.gen.next(), todoInput.value, false, false)
			this.todos.push(todo)
		}

		todoInput.value = ''
	}

	lostEvent(event, todo: Todo) {
		console.log(event)

		todo.editing = false
	}

	toggleEdit(todo: Todo) {
		console.log(todo)
		if (todo.editing === false) {
			todo.editing = true
		}
	}

	deleteTodo(todo: Todo) {
		this.todos = this.todos.filter(x => x.id != todo.id)
	}

	getActiveCount() {
		return this.todos.filter(x => x.complete === false).length
	}

	hasAnyCompleted() {
		return this.todos.some(x => x.complete == true)
	}

	clearCompleted() {
		this.todos.forEach(x => x.complete = false)
	}

	toggleClear() {
		switch (this.selected) {
			case 'All':
				let everyComplete = this.todos.every(x => x.complete == true)
				if (everyComplete) {
					this.todos.forEach(x => x.complete = false)
					return
				}


				let everyNotComplete = this.todos.every(x => x.complete == false)
				if (everyNotComplete) {
					this.todos.forEach(x => x.complete = true)
					return
				}

				let anyCompleted = this.todos.some(x => x.complete == true)
				if (anyCompleted) {
					this.todos.forEach(x => x.complete = true)
					return
				}

				break;
			case 'Active':
				this.todos.forEach(x => x.complete = true)
				break;
			case 'Completed':
				this.todos.forEach(x => x.complete = false)
				break;
		}
	}

	toggleSelected(tag) {
		console.log(tag.text)
		this.selected = tag.text
		switch (this.selected) {
			case 'All':
				this.selectedAll = true
				this.selectedActive = false
				this.selectedCompleted = false
				break;
			case 'Active':
				this.selectedAll = false
				this.selectedActive = true
				this.selectedCompleted = false
				break;
			case 'Completed':
				this.selectedAll = false
				this.selectedActive = false
				this.selectedCompleted = true
				break;
		}
	}
}
```


最後修改 html 然後把幾個 binding 的內容放進去
`app.component.html`
```
<section class="todoapp">
	<header class="header">
		<h1>{{title}}</h1>
		<input class="new-todo"
			placeholder="What needs to be done?"
			#todoInput
			(keyup.enter)="addTodo(todoInput)"
			autofocus>
	</header>

	<!-- This section should be hidden by default and shown when there are todos -->
	<section class="main">
		<input id="toggle-all"
			class="toggle-all"
			type="checkbox"
			(click)="toggleClear()">
		<label for="toggle-all" *ngIf="todos.length > 0">Mark all as complete</label>
		<ul class="todo-list" *ngFor="let todo of getTodos()">

			<li [class]="{ completed : todo.complete, editing : todo.editing }"
				>
				<div class="view">
					<input class="toggle"
						type="checkbox"
						[checked]="todo.complete"
						(change)="todo.complete = !todo.complete">
					<label
						(dblclick)="toggleEdit(todo)"
						(blur)="lostEvent($event, todo)"
					>{{todo.title}} ({{todo.id}})</label>
					<button class="destroy"
						(click)="deleteTodo(todo)"></button>
				</div>
				<input class="edit"
					#itemInput
					(mouseenter)="itemInput.focus()"
					(blur)="lostEvent($event, todo)"
					[(ngModel)]="todo.title"
					>
			</li>

		</ul>
	</section>

	<!-- This footer should be hidden by default and shown when there are todos -->
	<footer class="footer" *ngIf="todos.length > 0">
		<!-- This should be `0 items left` by default -->
		<span class="todo-count"><strong>{{getActiveCount()}}</strong> item left</span>
		<!-- Remove this if you don't implement routing -->
		<ul class="filters">
			<li>
				<a [ngClass]="selectedAll ? 'selected' : ''"
					#tagAll
					(click)="toggleSelected(tagAll)"
					href="javascript:;">All</a>
			</li>
			<li>

				<a [ngClass]="selectedActive ? 'selected' : ''"
					#tagActive
					(click)="toggleSelected(tagActive)"
					href="javascript:;">Active</a>
			</li>
			<li>
				<a [ngClass]="selectedCompleted ? 'selected' : ''"
					#tagCompleted
					(click)="toggleSelected(tagCompleted)"
					href="javascript:;">Completed</a>
			</li>
		</ul>
		<!-- Hidden if no completed items are left ↓ -->
		<button
			class="clear-completed"
			*ngIf="hasAnyCompleted()"
			(click)="clearCompleted()">Clear completed</button>
	</footer>
</section>

<footer class="info">
	<p>Double-click to edit a todo</p>
	<!-- Remove the below line ↓ -->
	<p>Template by <a href="http://sindresorhus.com">Sindre Sorhus</a></p>
	<!-- Change this out with your name and url ↓ -->
	<p>Created by <a href="http://todomvc.com">you</a></p>
	<p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
</footer>
```

### TodoMVC 練習 http 版

#### 建立後端 api
因為比較熟 .net 就用 .net 6 來寫看看

建立 `Models` 資料夾 , 加入以下類別
```
namespace TodoWebApi.Models
{
    public class Todo
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public bool Complete { get; set; }
        public bool Editing { get; set; }
    }
}
```


建立 `Repositories` 資料夾 , 然後加入以下類別
```
using TodoWebApi.Models;

namespace TodoWebApi.Repositories
{
    public interface ITodoRepo
    {
        List<Todo> GetTodos();
        Todo AddTod(Todo todo);
        Todo DeleteTodo(int id);

        Todo UpdateTodo(Todo todo);

    }

    public class IDGen
    {
        private int idCounter = 1;
        public int NextId() { return idCounter++; }
    }

    public class TodoRepo : ITodoRepo
    {
        IDGen gen = new IDGen();
        List<Todo> result = new List<Todo>();

        public TodoRepo()
        {
            var todo = new Todo()
            {
                Id = gen.NextId(),
                Title = "買 5O 嵐",
                Complete = true,
                Editing = false
            };
            result.Add(todo);

            todo = new Todo()
            {
                Id = gen.NextId(),
                Title = "問候正宜",
                Complete = true,
                Editing = false
            };
            result.Add(todo);


            todo = new Todo()
            {
                Id = gen.NextId(),
                Title = "測試",
                Complete = false,
                Editing = false
            };
            result.Add(todo);


            todo = new Todo()
            {
                Id = gen.NextId(),
                Title = "電龜",
                Complete = false,
                Editing = false
            };
            result.Add(todo);
        }


        public List<Todo> GetTodos()
        {
            return result;
        }
        public Todo AddTod(Todo todo)
        {
            todo.Id = gen.NextId();
            this.result.Add(todo);
            return todo;
        }
        public Todo DeleteTodo(int id)
        {
            var todo = this.result.Find(x => x.Id == id);
            if (todo != null)
                this.result.Remove(todo);

            return todo;
        }
        public Todo UpdateTodo(Todo todo)
        {
            var find = this.result.Find(x => x.Id == todo.Id);
            find.Complete = todo.Complete;
            find.Title = todo.Title;
            find.Editing = todo.Editing;
            Console.WriteLine(this.result);
            return find;
        }

        public List<Todo> ClearCompleted()
        {
            this.result.ForEach(x => x.Complete = false);
            return this.result;
        }


        public List<Todo> MakeCompleted()
        {
            this.result.ForEach(x => x.Complete = true);
            return this.result;
        }


    }
}
```


建立 Controller
```
using Microsoft.AspNetCore.Mvc;
using TodoWebApi.Models;
using TodoWebApi.Repositories;

namespace TodoWebApi.Controllers
{


    [ApiController]
    [Route("api/[controller]")]
    public class TodoController : ControllerBase
    {
        private ITodoRepo todoRepo;
        public TodoController(ITodoRepo todoRepo)
        {
            this.todoRepo = todoRepo; 
        }

        /// <summary>
        /// 取得待辦事項清單
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public List<Todo> GetTodos()
        {
            return todoRepo.GetTodos();
        }

        /// <summary>
        /// 更新待辦事項
        /// </summary>
        /// <param name="todo"></param>
        /// <returns></returns>

        [HttpPut]
        public Todo UpdateTodo(Todo todo)
        {
            var result = this.todoRepo.UpdateTodo(todo);
            Console.WriteLine(this.todoRepo.GetTodos());
            return result;
        }


        /// <summary>
        /// 新增待辦事項
        /// </summary>
        /// <param name="todo"></param>
        /// <returns></returns>
        [HttpPost]
        public Todo AddTod(Todo todo)
        {
            this.todoRepo.AddTod(todo);
            return todo;
        }

        /// <summary>
        /// 將待辦事項全數清除
        /// </summary>
        /// <returns></returns>
        [HttpPost("ClearCompleted")]
        public List<Todo> ClearCompleted()
        {
            var repo = this.todoRepo as TodoRepo;
            var result = repo.ClearCompleted();
            return result;
        }


        /// <summary>
        /// 標示待辦事項全數完成
        /// </summary>
        /// <returns></returns>
        [HttpPost("MakeCompleted")]
        public List<Todo> MakeCompleted()
        {
            var repo = this.todoRepo as TodoRepo;
            var result = repo.MakeCompleted();
            return result;
        }

        /// <summary>
        /// 刪除待辦事項
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete("{id:int}")]
        public Todo DeleteTodo(int id)
        {
            var todo = this.todoRepo.DeleteTodo(id);
            return todo;
        }

    }
}
```


這裡重點就是需要把 DI 的部分調成單體模式注入 , 才不會每次 request 都去 new TodoRepo 讓物件暫時保存在 memory 裡面
另外前端因為 port 不同應該為有 CORS , 這裡也需要設定下
最後如果要讓 api 有文件的話 , 在 `Project` => `Properties` => `Output` => `Documnet file`  打勾才會生出 xml 文件

`Program.cs`
```
using System.Reflection;
using TodoWebApi.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

//要這樣設定 DI 才會暫時用單體模式保存在記憶體裡面
builder.Services.AddSingleton<ITodoRepo, TodoRepo>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo { Title = "Todo", Version = "v1" });

    //Locate the XML file being generated by ASP.NET...
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.XML";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);

    //... and tell Swagger to use those XML comments.
    c.IncludeXmlComments(xmlPath);
    c.IncludeXmlComments(xmlPath);
});

//CORS設定
//https://stackoverflow.com/questions/70511588/how-to-enable-cors-in-asp-net-core-6-0-web-api-project
builder.Services.AddCors(p => p.AddPolicy("corsapp", builder =>
    {
        builder.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
    }));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//暫時不用 https
//app.UseHttpsRedirection();
 
//CORS設定
app.UseCors("corsapp");

app.UseAuthorization();

app.MapControllers();

app.Run();

```

最後調整 `launchSettings.json` , 特別注意要把 `localhost` 改成 `0.0.0.0` 這樣其他同網段電腦才可以訪問到

```
{
  "$schema": "https://json.schemastore.org/launchsettings.json",
  "iisSettings": {
    "windowsAuthentication": false,
    "anonymousAuthentication": true,
    "iisExpress": {
      "applicationUrl": "http://localhost:59664",
      "sslPort": 44389
    }
  },
  "profiles": {
    "TodoWebApi": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://0.0.0.0:5001;http://0.0.0.0:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}

```


#### 建立前端

如果後端沒設定 `CORS` 這裡要先設定 `CORS` , 不然會炸得不要不要的 , 要 try 的話記得先把剛剛後端的 CORS 註解起來
在你的專案根目錄加入這個檔案 `proxy.config.json`
```
{
	"context": "/",
	"target": "http://123.45.67:5000",
	"secure": false,
	"changeOrigin": true
}
```

`context` 是你的 api 前墜 , 如果你的 Controller prefix 有掛 api 的話會長這樣 `[Route("api/[controller]")]`
`target` 沒啥好說的就是你 api 的 ip 位置
`secure` 應該跟 https 有關
詳細可以看這篇保哥 [文章](https://blog.miniasp.com/post/2017/02/05/Setup-proxy-to-backend-in-Angular-CLI) , 又是保哥 XD
這時你的設定檔要寫這樣
```
{
	"context": "/api",
	"target": "http://123.45.67:5000",
	"secure": false,
	"changeOrigin": true
}
```

修改 `package.json`
```
"starthost": "ng serve --host 0.0.0.0 --disable-host-check --proxy-config proxy.config.json",
```

最後寫 Http 相關呼叫時也要加上 prefix 像是下面這樣
```
getTodos() : Observable<Todo[]> {
	// return this.http.get<Todo[]>('http://123.45.67.89:5000/api/Todo')
	return this.http.get<Todo[]>('api/Todo')
}
```


設定服務注入 `todo.service.ts` 
順便科普在這裡 `deleteTodo` 的 `url` 部分用 `反引號` 包著 , 常常忘記 `反引號` 的術語叫做 `backtick` aka `backquote`
```
`
```

```
import { Injectable, OnInit } from '@angular/core';
import { map, Observable } from 'rxjs';
import { Todo } from './todo';
import { HttpClient } from '@angular/common/http';

@Injectable({
	providedIn: 'root'
})
export class TodoService {

	constructor(private http: HttpClient) { }

	private todos: Todo[] = []

	getTodos() : Observable<Todo[]> {
		// return this.http.get<Todo[]>('http://123.45.67.89:5000/Todo')
		return this.http.get<Todo[]>('api/Todo')
	}

	deleteTodo(id : number){
		return this.http.delete<Todo>(`api/Todo/${id}`)
	}

	addTodo(todo: Todo){
		return this.http.post<Todo>('api/Todo', todo)
	}

	updateTodo(todo: Todo){
		return this.http.put<Todo>('api/Todo', todo)
	}

	makeCompleted(){
		return this.http.post<Todo[]>('api/Todo/MakeCompleted', {

		})
	}

	clearCompleted(){
		return this.http.post<Todo[]>('api/Todo/ClearCompleted', {

		})
	}
}

```

因為要用 di 注入 , 所以要調整 `app.module.ts`
```
import { TodoService } from './todo.service';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HttpClientModule } from '@angular/common/http';

@NgModule({
	declarations: [
		AppComponent
	],
	imports: [
		BrowserModule,
		AppRoutingModule,
		FormsModule,
		HttpClientModule
	],
	providers: [
		TodoService
	],
	bootstrap: [AppComponent]
})
export class AppModule { }
```

接著調整 `app.component.html`

```
<section class="todoapp">
	<header class="header">
		<h1>{{title}}</h1>
		<input class="new-todo"
			placeholder="What needs to be done?"
			#todoInput
			(keyup.enter)="addTodo(todoInput)"
			autofocus>
	</header>
	<!-- This section should be hidden by default and shown when there are todos -->
	<section class="main">
		<input id="toggle-all"
			class="toggle-all"
			type="checkbox"
			(click)="toggleClear()">
		<label for="toggle-all">Mark all as complete</label>
		<ul class="todo-list" *ngFor="let todo of filterTodos()">


			<li [class]="{ completed : todo.complete, editing : todo.editing }">
				<div class="view">
					<input class="toggle"
						type="checkbox"
						[checked]="todo.complete"
						(change)="updateTodo(todo)"
						>
					<label
						(dblclick)="toggleEdit(todo)"
						(blur)="lostEvent($event, todo)"
					>{{todo.title}} ({{todo.id}})</label>
					<button class="destroy" (click)="deleteTodo(todo)"></button>
				</div>
				<input class="edit"
					#itemInput
					(mouseenter)="itemInput.focus()"
					(blur)="lostEvent($event, todo)"
					[(ngModel)]="todo.title"
					>
			</li>

		</ul>
	</section>
	<!-- This footer should be hidden by default and shown when there are todos -->
	<!-- This footer should be hidden by default and shown when there are todos -->
	<footer class="footer" *ngIf="todos.length > 0">
		<!-- This should be `0 items left` by default -->
		<span class="todo-count"><strong>{{getActiveCount()}}</strong> item left</span>
		<!-- Remove this if you don't implement routing -->
		<ul class="filters">
			<li>
				<a [ngClass]="selectedAll ? 'selected' : ''"
					#tagAll
					(click)="toggleSelected(tagAll)"
					href="javascript:;">All</a>
			</li>
			<li>

				<a [ngClass]="selectedActive ? 'selected' : ''"
					#tagActive
					(click)="toggleSelected(tagActive)"
					href="javascript:;">Active</a>
			</li>
			<li>
				<a [ngClass]="selectedCompleted ? 'selected' : ''"
					#tagCompleted
					(click)="toggleSelected(tagCompleted)"
					href="javascript:;">Completed</a>
			</li>
		</ul>
		<!-- Hidden if no completed items are left ↓ -->
		<button
			class="clear-completed"
			*ngIf="hasAnyCompleted()"
			(click)="clearCompleted()">Clear completed</button>
	</footer>
</section>
<footer class="info">
	<p>Double-click to edit a todo</p>
	<!-- Remove the below line ↓ -->
	<p>Template by <a href="http://sindresorhus.com">Sindre Sorhus</a></p>
	<!-- Change this out with your name and url ↓ -->
	<p>Created by <a href="http://todomvc.com">you</a></p>
	<p>Part of <a href="http://todomvc.com">TodoMVC</a></p>
</footer>
```

最後調整 `app.component.ts`

```
import { TodoService } from './todo.service';
import { Component, OnInit } from '@angular/core';
import { Todo } from './todo';

@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
	public todoService: TodoService;

	//All
	//Active
	//Complete
	selected = 'All'

	selectedAll = true
	selectedActive = false
	selectedCompleted = false

	todos: Todo[] = []
	title = 'Lasai Todo';


	constructor(todoService: TodoService) {
		this.todoService = todoService
	}
	ngOnInit(): void {
		this.getTodos()
	}

	filterTodos(): Todo[] {
		if (this.selectedAll)
			return this.todos

		if (this.selectedActive)
			return this.todos.filter(x => x.complete === false)

		if (this.selectedCompleted)
			return this.todos.filter(x => x.complete === true)
	}


	getTodos() {
		this.todoService.getTodos()
			.subscribe(x => {
				this.todos = x
				console.log(x)
			});
	}

	deleteTodo(todo: Todo) {
		this.todoService.deleteTodo(todo.id).subscribe(resp => {
			console.log('server delete todo' + resp)
			this.todos = this.todos.filter(x => x.id != resp.id);
		})
	}

	addTodo(todoInput: HTMLInputElement): void {
		if (todoInput.value.trim().length > 0) {
			let todo = new Todo(0, todoInput.value, false, false)
			this.todoService.addTodo(todo).subscribe( resp=>{
				this.todos.push(resp)
			})
		}

		//清空 input 內的文字
		todoInput.value = ''
	}

	updateTodo(todo : Todo) : void{
		todo.complete = !todo.complete
		this.todoService.updateTodo(todo).subscribe(resp =>{
			console.log('server update todo' + resp)
		})
	}




	getActiveCount() {
		return this.todos.filter(x => x.complete === false).length
	}

	hasAnyCompleted() {
		return this.todos.some(x => x.complete == true)
	}

	clearCompleted() {
		this.todoService.clearCompleted().subscribe(resp=>{
			this.todos = resp
		})
	}

	lostEvent(event, todo: Todo) {
		console.log(event)

		todo.editing = false
		this.todoService.updateTodo(todo).subscribe(resp =>{
			console.log('server update todo' + resp)
		})
	}

	toggleEdit(todo: Todo) {
		console.log(todo)
		if (todo.editing === false) {
			todo.editing = true
		}
	}

	toggleClear() {
		switch (this.selected) {
			case 'All':
				//每一項都完成的話標示全部未完成
				let everyComplete = this.todos.every(x => x.complete == true)
				if (everyComplete) {
					// this.todos.forEach(x => x.complete = false)
					this.todoService.clearCompleted().subscribe(resp=>{
						console.log(resp)
						this.todos = resp
					})
					return
				}


				//每一個項目都還沒完成的話標示全部已完成
				let everyNotComplete = this.todos.every(x => x.complete == false)
				if (everyNotComplete) {
					// this.todos.forEach(x => x.complete = true)
					this.todoService.makeCompleted().subscribe(resp=>{
						console.log(resp)
						this.todos = resp
					})
					return
				}

				//有任何一個已經完成的話標示全部已完成
				let anyCompleted = this.todos.some(x => x.complete == true)
				if (anyCompleted) {
					// this.todos.forEach(x => x.complete = true)
					this.todoService.makeCompleted().subscribe(resp=>{
						console.log(resp)
						this.todos = resp
					})
					return
				}

				break;
			case 'Active':
				// this.todos.forEach(x => x.complete = true)
				this.todoService.makeCompleted().subscribe(resp=>{
					console.log(resp)
					this.todos = resp
				})
				break;
			case 'Completed':
				// this.todos.forEach(x => x.complete = false)
				this.todoService.clearCompleted().subscribe(resp=>{
					console.log(resp)
					this.todos = resp
				})
				break;
		}
	}

	toggleSelected(tag) {
		console.log(tag.text)
		this.selected = tag.text
		switch (this.selected) {
			case 'All':
				this.selectedAll = true
				this.selectedActive = false
				this.selectedCompleted = false
				break;
			case 'Active':
				this.selectedAll = false
				this.selectedActive = true
				this.selectedCompleted = false
				break;
			case 'Completed':
				this.selectedAll = false
				this.selectedActive = false
				this.selectedCompleted = true
				break;
		}
	}
}
```

### 升級 angularjs 到 angular 常見問題
因為舊版是用 `asp.net mvc + angularjs` 這個組合去做的 , 順手筆記下遇到的問題

#### 搬遷步驟
利用這個網站 [c# to typescript](https://csharptotypescript.azurewebsites.net/) 轉換物件為 typescript 的 interface or class

接著建立 service , 並且注入 `HttpClient` , 記得要在 `app.module.ts` 引用
```
import { HttpClientModule } from '@angular/common/http';
...

imports: [
	BrowserModule.withServerTransition({ appId: 'ng-cli-universal' }),
	HttpClientModule,
	FormsModule,
	RouterModule.forRoot([
		{ path: '', component: HomeComponent, pathMatch: 'full' },
		{ path: 'counter', component: CounterComponent },
		{ path: 'fetch-data', component: FetchDataComponent },
		{ path: 'data', component: DataComponent },
	])
],

```

接著包裝 service 類似下面這樣

```
...
import { HttpClient } from '@angular/common/http';
...

@Injectable({
	providedIn: 'root'
})
export class DataService {
	constructor( private httpClient : HttpClient) {}

	query(id : string) : Observable<Data[]> {
		return this.httpClient.get<Data[]>(`/api/FindData/${id}`)
	}
```

接著在 `component` 撈資料看看
```
items : Data[] = []

query(id: string) {
	this.data.query(ppid).subscribe(x => {
		this.items = x
		console.log(x)
	});
}

```

最後將 angularjs `ng-repeat` 改用 `ng-container` 包起來關注邏輯類似下面這樣
```
<div class="list-group mt-3">
	<ng-container *ngFor="let item of items">
		<a href="javascript:;"
			class="list-group-item list-group-item-action flex-column align-items-start">
			<div class="d-flex w-100 justify-content-between">
				<h5 class="mb-1">{{item.oId}}</h5>
				<small>{{item.name}}</small>
			</div>
			<p class="mb-1">{{item.desc}}</p>
		</a>
	</ng-container>
</div>
```

這種包資料的都搞定後可以逐步把其他 angularjs 上面的 function 也搬進來 , 先把 `$scope` 移除
接著把 `$score.search = function()` 改成 `search() {}` , 最後把 function 內的 `$scope` 改成 `this.xxx` 大致上就救活一個 function 了
`angularjs`
```
$scope.search = function () {
	$scope.findById($scope.id);
}
```

`angular`
```
search(){
	this.findById(this.id);
}
```

最後檢查 `ng-` 開頭的功能 , 慢慢將改成 angular 對應的語法即可

#### fontawesome 5
安裝 fontawesome 5
```
npm i @fortawesome/fontawesome-free@5.1.0-9
```

在 `angular.json` 加入引用
```
	"styles": [
		"node_modules/bootstrap/dist/css/bootstrap.min.css",
		"node_modules/@fortawesome/fontawesome-free/css/all.css",
		"src/styles.css"
	],
```

另外還有看到這個[官方元件](https://www.npmjs.com/package/@fortawesome/angular-fontawesome) 有空也可以玩看看

#### ModuleMapLoaderModule Error
註解 `app.server.module.ts` ModuleMapLoaderModule 的部分

```
import { NgModule } from '@angular/core';
import { ServerModule } from '@angular/platform-server';
// import { ModuleMapLoaderModule } from '@nguniversal/module-map-ngfactory-loader';
import { AppComponent } from './app.component';
import { AppModule } from './app.module';

@NgModule({
	imports: [
		AppModule,
		ServerModule,
		// ModuleMapLoaderModule
	],
	bootstrap: [AppComponent]
})
export class AppServerModule { }
```

#### proxy asp.net mvc web api
修改 `proxy.conf.js` 加入你的舊版 api 站台

```
const { env } = require('process');

const target = env.ASPNETCORE_HTTPS_PORT ? `https://localhost:${env.ASPNETCORE_HTTPS_PORT}` :
	env.ASPNETCORE_URLS ? env.ASPNETCORE_URLS.split(';')[0] : 'http://localhost:9287';

const PROXY_CONFIG = [
	{
		context: [
			"/weatherforecast",
		],
		target: target,
		secure: false
	},
	{
		context: "/qq",
		target: "http://localhost:1234",
		secure: false,
		changeOrigin: true
	}
]

module.exports = PROXY_CONFIG;
```




#### 解決 keyvalue 問題
我有個 case 是動態撈出物件 , 所以 table 的 header 會動態改變 , 舊版 `angularjs` 大概長這樣
```
<div class="table-responsive mt-2">
    <table class="table table-sm table-bordered table-hover">
        <thead class="table-success">
            <tr ng-repeat="item in filterTableHeader()">
                <th scope="col" ng-repeat="(key , value) in item">{{key}}</th>
            </tr>
        </thead>
        <tbody>
            <tr ng-repeat="item in items">
                <td ng-repeat="(key , value) in item"
                    style="white-space: nowrap;"
                    >{{value}}</td>
            </tr>
        </tbody>
    </table>
</div>
```

轉移到新版的話要改成以下這樣 , 關鍵點就是 pipe `keyvalue` 
```
<div class="table-responsive mt-2">
	<table class="table table-sm table-bordered table-hover">
		<thead class="table-success">
			<ng-container *ngFor="let yourObject of filterTableHeader()">
				<tr>
					<ng-container *ngFor="let item of yourObject | keyvalue: unsorted">
						<th scope="col">
							{{item.key}}
						</th>
					</ng-container>
				</tr>
			</ng-container>
		</thead>
		<tbody>
			<ng-container *ngFor="let yourObject of yourObjects">
				<tr>
					<ng-container *ngFor="let item of yourObject | keyvalue: unsorted">
						<td style="white-space: nowrap;">{{item.value}}</td>
					</ng-container>
				</tr>
			</ng-container>

		</tbody>
	</table>
</div>
```

不過他會從字母的 a 排到 z , 所以要增加一個 function unsorted 在你的 component 裡面 , 可以 [參考這篇](https://stackoverflow.com/questions/52793944/angular-keyvalue-pipe-sort-properties-iterate-in-order)
```
unsorted(a: any, b: any): number { return 0; }
```


#### 解決 ng-keypress

舊版 `angularjs` 大概長這樣
```
ng-keypress="($event.which === 13) ? search() : 0"
```

新版
```
(keyup.enter)="search()"
```


#### bootstrap4 input-group 掛掉
舊版 bootstrap4 `input-group-append` 有多這一層 , 在 bootstrap5 需要把它移除 , vscode 可以利用 `ctrl + shift + k` 快速解決
```
<div class="input-group">
	<input name=""
		type="text"
		class="form-control"
		placeholder=""/>

	<div class="input-group-append">
	
		<!--關鍵字搜尋-->
		<button class="btn btn-outline-secondary active" type="button">描述</button>
		
		<!--清除按鈕-->
		<button class="btn btn-outline-secondary"
			type="button"
			ng-click="clearCodeDesc()">
			X
		</button>
	</div>
</div>
```


#### 修正 angularjs filter 為 angular pipe

首先在 `angularjs` 上 , 我有個 filter 大概長這樣 , 當他是 `DESC` 則過濾 `DESC` 內容 , 如果是 `CODE` 則過濾 `CODE`
```
$scope.filterCodeDesc = function (item) {
	if ($scope.searchCodeDesc === '') {
		return item;
	} 

	if ($scope.searchBy === 'DESC') {
		//不分大小寫
		//類 sql like 搜尋
		return item.DESC.match(new RegExp(".*" + $scope.searchCodeDesc + ".*", "i"))
	} else {
		return item.CODE.match(new RegExp(".*" + $scope.searchCodeDesc + ".*", "i"))
	}
	
}
```

html 大概長這樣
```
ng-repeat="Code in Codes  | filter:filterCodeDesc"
```

新版 angular 好像沒有 filter , 不過有 pipe 所以這類的 code 可以改這樣 , 注意他的重點要改用 javascript 原生的 filter 去篩選條件
```
import { Pipe, PipeTransform } from '@angular/core';
import { Code } from '../models/code';

@Pipe({
	name: 'filterCodeDesc'
})
export class CodeDescPipe implements PipeTransform {

	transform(codes: Code[], searchBy: string, searchCodeDesc: string): Code[] {

		if (searchCodeDesc === '') {
			return codes;
		}

		if (searchBy === 'DESC') {
			//不分大小寫
			//類 sql like 搜尋
			return codes.filter(x => x.DESC.match(new RegExp(".*" + searchCodeDesc + ".*", "i")))
		} else {
			return codes.filter(x => x.CODE.match(new RegExp(".*" + searchCodeDesc + ".*", "i")))
		}
	}
}
```

html 長這樣
```
<ng-container *ngFor="let code of Codes | filterCodeDesc:searchBy:searchCodeDesc">
```


#### copy
以前 angularjs 有個 `angular.copy` 的 function 可以使用
現在要改這樣用展開運算子 , 參考[這篇](https://stackoverflow.com/questions/39506619/angular2-how-to-copy-object-into-another-object)
沒想到真正實戰展開運算子是在 typescript 反而不是 python XD

```
let copy = {...resp.data};
this.defectiveHandleOriginal = copy
```


#### 常見對照
`ng-class` => `ngClass`
`ng-style` => `ngStyle`
`ng-repeat` => `*ngFor`
`ng-model` => `[(ngModel)]`
`ng-click` => `(click)`

### focus
參考這篇 https://netbasal.com/autofocus-that-works-anytime-in-angular-apps-68cb89a3f057
注意一開始建立 directive 的 selector 不一樣 , 會叫做 `appAutofocus` , 原生 html 其實就有 `autofocus` 這個 attribute , 不過直接插上去好像是不會 work

### 多語系
可以參考這個人寫的 https://medium.com/allen%E7%9A%84%E6%8A%80%E8%A1%93%E7%AD%86%E8%A8%98/angular-ngx-translate-%E7%AD%86%E8%A8%98-84b8812419ab

因為 angular 內建多語系需要針對每個語言去編譯 , 非常麻煩 , 所以用 ngx-translate 這個套件在 `assets\i18n` 底下有個語言的 json 設定檔

前端只要這樣寫即可
```
{{ 'Menu.LanguageList.Chinese' | translate }}
```

另外如果要用程式去控制的話 , 例如跳 modal alert 等操作只要這樣寫即可
``` ts
let msg = this.translate.instant('Alert.AddProduct')
alert(msg)
```

### Breadcrumb 麵包屑
參考這篇 https://marco.dev/angular-breadcrumb
唯一的問題就是老外寫 `/` 在 subsite 會壞掉 , 應該改用 `./`
```
// Add an element for the current route part
if (route.data['breadcrumb']) {
  console.log('breadcrumb' , route.data['breadcrumb'])
  console.log('routeUrl' , routeUrl)
  const breadcrumb = {
    label: this.getLabel(route.data),
    url: './' + routeUrl.join('/')
  };
  breadcrumbs.push(breadcrumb);
}

```



### 靜態資源路徑問題
這是老生常談 , 我待過的地方 , 十有八九都會把 IIS 80 port 底下又掛一堆子網站
每次只要一遇到這個簡直就跟地獄沒兩樣 , 常常造成爭吵
起初我在 css background 的 url 是寫成 `/assets` 這樣會直接吃到 root 一上就爆炸
後來改用 `../../assets`  變成相對路徑 , 不過這樣寫會造成 build 時多出不必要的圖片檔案

``` css
background: url('../../assets/images/logo.png') no-repeat center;
```

可以參考這篇使用更好的做法
https://infinum.com/handbook/frontend/angular/angular-guidelines-and-best-practices/assets-and-caching

<table><thead>
<tr>
<th>Use case</th>
<th>Example</th>
</tr>
</thead><tbody>
<tr>
<td>HTML / images</td>
<td><code>&lt;img src="./assets/…"&gt;</code></td>
</tr>
<tr>
<td>XHR / fetch</td>
<td><code>http.get('./assets/…")</code></td>
</tr>
<tr>
<td>CSS <code>url()</code></td>
<td><code>url("^assets/…")</code></td>
</tr>
</tbody></table>

所以最後改用這樣寫 , 可以完全保證 subsite 抓到正確路徑 , 並且也不會產生額外圖片
``` css
background: url('^assets/images/logo.png') no-repeat center;
```

### Loading 頁面
應該就是無腦抄這篇 , 然後改個 css 應該就可以收工
https://danielk.tech/home/angular-how-to-add-a-loading-spinner

### 佈署到 iis
主要跟著這兩篇設定
https://blog.poychang.net/deploy-angular-to-iis-virtual-directory/
https://blog.miniasp.com/post/2017/01/17/Angular-2-deploy-on-IIS
`務必` 要先安裝[url rewrite](https://www.iis.net/downloads/microsoft/url-rewrite)
然後順便新增 `web.config` 在 `src` 底下
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="SPA" stopProcessing="true">
          <match url=".*" />
          <action type="Rewrite" url="/" />
          <conditions>
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
          </conditions>
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

接著在 `angular.json` 的 `assets` 調整設定這樣 `ng build --configuration=pord` 才會包含 `web.config`
```
"assets": [
  "src/favicon.ico",
  "src/assets",
  "src/silent-renew.html",
  "src/web.config"
],
```

### 升級
#### 升級 nodejs
Angular 16 需要 nodejs 18
在 windows 上直接回[官網下載](https://nodejs.org/en/download) nodejs 重新安裝他就會升級
```
node -v
v18.17.1
```

升級後可能要清除 npm cache 然後安裝套件看看噴什麼錯誤
```
npm cache clean --force
npm install
```

#### 升級 angular cli
https://update.angular.io/?v=14.0-16.0
```
🌹 ng version

     _                      _                 ____ _     ___
    / \   _ __   __ _ _   _| | __ _ _ __     / ___| |   |_ _|
   / △ \ | '_ \ / _` | | | | |/ _` | '__|   | |   | |    | |
  / ___ \| | | | (_| | |_| | | (_| | |      | |___| |___ | |
 /_/   \_\_| |_|\__, |\__,_|_|\__,_|_|       \____|_____|___|
                |___/


Angular CLI: 15.2.8
Node: 18.17.1
Package Manager: npm 8.19.2
OS: win32 x64

Angular: 15.2.9
... animations, cdk, common, compiler, compiler-cli, core, forms
... platform-browser, platform-browser-dynamic, router

Package                         Version
---------------------------------------------------------
@angular-devkit/architect       0.1502.8
@angular-devkit/build-angular   15.2.8
@angular-devkit/core            15.2.8
@angular-devkit/schematics      15.2.8
@angular/cli                    15.2.8
@schematics/angular             15.2.8
rxjs                            7.8.1
typescript                      4.9.5
```

執行 ng update 指令看要更新那些 , 更新前先 commit
```
🌹 ng update
Using package manager: npm
Collecting installed dependencies...
Found 32 dependencies.
    We analyzed your package.json, there are some packages to update:

      Name                               Version                  Command to update
     --------------------------------------------------------------------------------
      @angular/cdk                       15.2.9 -> 16.2.1         ng update @angular/cdk
      @angular/cli                       15.2.9 -> 16.2.0         ng update @angular/cli
      @angular/core                      15.2.9 -> 16.2.1         ng update @angular/core

    There might be additional packages which don't provide 'ng update' capabilities that are outdated.
    You can update the additional packages by running the update command of your package manager.
```

依序執行指令更新
```
ng update @angular/cdk
ng update @angular/cli
ng update @angular/core
```

#### 安裝 npm-check-updates
https://www.freecodecamp.org/news/how-to-update-npm-dependencies/
```
npm install -g npm-check-updates
```

檢查需要更新的項目
```
ncu
@ng-bootstrap/ng-bootstrap   ^14.1.1  →  ^15.1.1
@ngx-translate/core          ^14.0.0  →  ^15.0.0
@ngx-translate/http-loader    ^7.0.0  →   ^8.0.0
@types/jasmine                ~4.3.0  →   ~4.3.5
angular-auth-oidc-client     ^15.0.4  →  ^16.0.0
bootstrap                     ^5.2.3  →   ^5.3.1
jasmine-core                  ~4.5.0  →   ~5.1.0
jquery                        ^3.6.4  →   ^3.7.0
karma                         ~6.4.0  →   ~6.4.2
karma-chrome-launcher         ~3.1.0  →   ~3.2.0
karma-coverage                ~2.2.0  →   ~2.2.1
karma-jasmine-html-reporter   ~2.0.0  →   ~2.1.0
ngx-bootstrap                ^10.2.0  →  ^11.0.2
rxjs                          ~7.8.0  →   ~7.8.1
tslib                         ^2.3.0  →   ^2.6.2
typescript                    ~4.9.4  →   ~5.1.6
```

執行更新
```
ncu -u
```



### 書籍與課程
[Angular 高級編程, 3/e](https://www.tenlong.com.tw/products/9787302529170?list_name=trs-t) & [原始碼](https://github.com/Apress/pro-angular-6)
[Angular 高級編程, 4/e](https://www.tenlong.com.tw/products/9787302569572?list_name=srh) & [原始碼](https://github.com/Apress/pro-angular-9)
因為舊版差異有點大 , 所以如果買舊版的話有噴 error 可以拿新版 code 來修看看
不管學啥技術只要看 freeman 的書就對啦! 以前有買一本 , 後來好像有新版的就沒追啦 , 記得以前剛學 asp.net mvc 的時候也是買他的書 XD , 算是人能看懂的書 , 不過他這本書好硬 , 整個都是用手打 component XD , 新手看的話應該陣亡

[will 保哥 Angular 新手開發練功坊](https://www.accupass.com/event/2202160800111647084890) 去年特別自掏腰包上課 , 但後來都忙別的事 , 寫沒兩下就忘光了 XD

[凱哥寫程式](https://www.youtube.com/watch?v=F-kn4gULkjA&list=PLneJIGUTIItu6QrNxEBAUgTXZaHIpO8D9&index=2) 2022 年佛心免費課程 ~


### 其他資源
[typescript 新手指南](https://willh.gitbook.io/typescript-tutorial/basics)
[stackblitz](https://stackblitz.com/) 類似 codepen 的線上工具 
[c# to typescript](https://csharptotypescript.azurewebsites.net/)
