---
title: 升級 angularjs 至 angular
date: 2024-09-06 10:48:14
tags: angular
---

&nbsp;
<!-- more -->

因為工作的關係, 要把前後分離, 以前前端是 cshtml + angularjs 這種混亂的組合, 現在要翻 angular 非常痛苦, 順手筆記下
因為寫得斷斷續續的, 所以用這樣 cookbook 的方式

## href hash 導致跳錯地方的問題
這算是老生常談 , 因為在 angular 的 routing 是允許 # 這種格式 , 所以 angularjs 寫 href=”#” 就變成惡夢

```
<a href="#" />
```

angular

```
<a href="javascript:void(0)" />
```

## Can’t bind to ‘ngModel’ since it isn’t a known property of ‘input’.ngtsc(-998002)
這個通常都是忘了引用 `FormsModule`

```ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms'; // Import FormsModule

import { AppComponent } from './app.component';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    FormsModule // Add FormsModule here
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

## NG01352: If ngModel is used within a form tag, either the name attribute must be set or the form control must be defined as ‘standalone’ in ngModelOptions
在 input 給上 name 即可

```
<input type="text" name="myInput" [(ngModel)]="myModel">
```

## ng-show
```
*ngIf=xxx"
```

## ng-disable
ng-disable => [disable]

## ng-repeat
angularjs
```
<div ng-repeat="item in items">
  {{ item.name }}
</div>
```

angular
```
<div *ngFor="let item of items">
  {{ item.name }}
</div>
```

## js to ts
https://js2ts.com/

## 沿用 jquery

```
npm i --save-dev @types/jquery
npm install jquery --save
```

angular.json

```
"scripts": [
  "node_modules/jquery/dist/jquery.min.js"
]
```

## angular.toJson

https://stackoverflow.com/questions/38372134/how-to-convert-an-object-to-json-correctly-in-angular-2-with-typescript

```
angular.toJson(xxx)
```

## jquery & jquery ui 定義檔

如果不用定義檔的話直接這樣寫

```
declare var $: any;
```

要使用定義檔的話則先安裝

```
npm install @types/jquery --save-dev
npm install @types/jqueryui --save-dev
```

接著在文件這樣 import

```
import * as $ from 'jquery';
```

### jquery plugin ztree 安裝

因為之前的案子用這個套件, 影響太大暫時沒空把它改成 angular 的套件, 只好先這樣上
用之前記得要先安裝 jquery

```
npm install ztree
```

`angular.json` 裡要這樣設定, 這裡設定完以後記得還是要 `ng build` 不然一邊做一邊改這個不會生效

```
"styles": [
	"node_modules/ztree/css/zTreeStyle/zTreeStyle.css",
],
"scripts": [
	"node_modules/ztree/js/jquery.ztree.all.js",
	"node_modules/ztree/js/jquery.ztree.exhide.js"
]
```

元件則是這樣寫, 另外這裡還有個自己遇到的雷, 以前會專案用 $timeout 這個東西來延遲, 在 angular 則要使用 setTimeout
不然 ztree 拿到的物件會是 null
另外這裡還有 onClick, 不能直接寫 onClick: this.onClick,
而是要寫成 `this.onClick.bind(this)` 才能順利拿到 angular 資料, 不然會造成 scope 錯誤, 拿到 null

```
declare var $: any;
@Component({
  selector: 'app-xxx',
  templateUrl: `XXX.component.html`,
  styleUrls: ['./XXX.component.css'],
  changeDetection: ChangeDetectionStrategy.Default,
})
export class XXXComponent implements OnInit {

  initZTree(): void {
    const setting = {
      view: {
        fontCss: { color: '#333' }
      },
      data: {
        simpleData: {
          enable: true
        }
      },
      callback:{
	    onClick: this.onClick.bind(this)
	  }	  
    };

    const zNodes = [
      { id: 1, pId: 0, name: "父節點 1", open: true },
      { id: 11, pId: 1, name: "子節點 1-1" },
      { id: 12, pId: 1, name: "子節點 1-2" }
    ];

    $.fn.zTree.init($('#tree'), setting, zNodes);
  }


}
```

## $index
```
<div *ngFor="let item of items; let i = index">
  Index: {{ i }}, Value: {{ item }}
</div>
```

## vim 多語系轉換

```
q velxi{{'<Esc>eli'}}<Esc>hhli | trans<Esc>
```

## rowspan
Can’t bind to ‘rowspan’ since it isn’t a known property of ‘td’.ngtsc(-998002)

```
<td [attr.rowspan]="someValue">Content</td>
```

## angularjs filter to angular pipe

在 angularjs 內的 filter 需要轉為 pipe 才能用
angularjs

```
ngApp.filter('numberFixedLen', () => (a, b) => (1e4 + "" + a).slice(-b));
```

angular

```
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'numberFixedLen' })
export class NumberFixedLenPipe implements PipeTransform {
  transform(value: any, length: number): string {
    return (1e4 + "" + value).slice(-length);
  }
}
```

## select option

這個問題要注意的點就是需要把 `ng-change` 改為 `ngModelChange`
另外把 option 新建標籤移到 select 裡面
最後要補上 `name`

angularjs

```
<select id="xxx" 
	ng-model="searchParam.xxx" 
	ng-options="item.Code as ( item.xxx ) for item in list" 
	ng-change="search()" 
	class="form-control text-left">
	<option value="">請選擇</option>
</select>
```

angular

```
<select
	id="xxx"
	[(ngModel)]="searchParam.xxx"
	(ngModelChange)="search()"
	class="form-control text-left"
	name="code"
  >
	<option disabled hidden value="">
	  請選擇
	</option>

	<option *ngFor="let item of list" [value]="item.xxx">
	  {{ item.xxx }}
	</option>
  </select>
```

## limitTo

angularjs

```
<tr ng-repeat="data in datas | limitTo:100">
```

angular

```
<div *ngFor="let item of items | slice:0:100">
  <!-- 顯示 item 的內容 -->
</div>
```

## loop 一堆屬性 interface 的值
假設有 26 個屬性, 依序寫非常麻煩, 可以用以下方法

```
interface Station{
	A : string,
	B : string,
	C : string,
	//...
	Z : string
}
```

html

```
*ngFor="let data of Objectvalues(dataArr)"
```

component

```
Objectvalues = Object.values
```

## ng-value

這個在 angular 沒有要改用 [value]

## ngOnInit 設定 url 上有 query string 切換物件數值
我有一個物件希望當 url 上面有 id 時設定某種預設值, 如果普通網址進來則設定 beginDate moment()
關鍵在於這裡 `moment.Moment | null`

```
queryObj = {
	beginDate: moment() as moment.Moment | null,
	endDate: moment() as moment.Moment | null,
	id: '',
};
  
ngOnInit(): void {
	//先拿 id
	if(id === 'xxx'){
      this.queryObj.beginDate = null;
      this.queryObj.endDate = null;
      this.queryObj.id = id!;
      this.search();
	}
}
```

## bootstrap modal
舊版好像是這樣, 有點忘了
$(‘#xxx’).modal();

我的解法是改用這套 ngx

https://valor-software.com/ngx-bootstrap/#/components/modals?tab=overview

## keyvalue pipe 排序的問題
本來我在 angularjs 有一段動態從 db 撈資料表的功能, 因為每次查詢的表可能不同, 所以丟給前端結果也不同

```
<div class="table-responsive mt-2">
    <table class="table table-sm table-bordered table-hover">
        <thead class="table-success">
            <tr ng-repeat="sub in header()">
                <th scope="col" ng-repeat="(key , value) in sub">{{key}}</th>
            </tr>
        </thead>
        <tbody>
            <tr ng-repeat="sub in subList">
                <td ng-repeat="(key , value) in sub"
                    style="white-space: nowrap;">
                    {{value}}
                </td>
            </tr>
        </tbody>
    </table>
</div>
```

可是在 angular 預設的 keyvalue pipe 好像是依照 字母排序
所以要依照老外這篇說明 改寫成下列這樣即可

```
// Preserve original property order
originalOrder = (a: KeyValue<number,string>, b: KeyValue<number,string>): number => {
  return 0;
}

// Order by ascending property value
valueAscOrder = (a: KeyValue<number,string>, b: KeyValue<number,string>): number => {
  return a.value.localeCompare(b.value);
}

// Order by descending property key
keyDescOrder = (a: KeyValue<number,string>, b: KeyValue<number,string>): number => {
  return a.key > b.key ? -1 : (b.key > a.key ? 1 : 0);
}
```

```
<div class="table-responsive mt-2">
  <table class="table table-sm table-bordered table-hover">
    <thead class="table-success">
      <tr *ngFor="let sub of header()">
        <th
          scope="col"
          *ngFor="let pair of sub | keyvalue : originalOrder"
        >
          {{ pair.key }}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr *ngFor="let sub of subList">
        <td
          *ngFor="let pair of sub | keyvalue : originalOrder"
          style="white-space: nowrap"
        >
          {{ pair.value }}
        </td>
      </tr>
    </tbody>
  </table>
</div>
```
