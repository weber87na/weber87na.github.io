---
title: angular error 筆記
date: 2021-10-28 18:45:42
tags: angular
---
&nbsp;
<!-- more -->

最近搞 angular 把遇到的錯誤筆記一下 , 怕又忘了

### implicitly has an 'any' type
https://stackoverflow.com/questions/43064221/typescript-ts7006-parameter-xxx-implicitly-has-an-any-type

In your tsconfig.json file set the parameter "noImplicitAny": false under compilerOptions to get rid of this error.


### Can't bind to 'pa-attr' since it isn't a known property of 'td'
解法設定 `tsconfig.json` 內的屬性 `"strictTemplates": false`
```
  "angularCompilerOptions": {
    "enableI18nLegacyMessageIdFormat": false,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": false
  }

```

### error TS2322: Type 'null' is not assignable to type '{ [key: string]: any; }'
解法
加上 `| null` 即可
```
return (control:FormControl) : {[key: string]: any} | null => {
```

### error TS2322: Type 'Product | undefined' is not assignable to type 'Product'.

解法 1
加上驚嘆號騙他一定有值
```
getProduct(id: number): Product {
	return this.products.find(p => this.locator(p, id))!;
}

```

解法 2
加上型別
```
return <Product>this.products.find(p => this.locator(p, id));
```

解法 3
加上 undefined
```
getProduct(id: number): Product | undefined {
	return this.products.find(p => this.locator(p, id));
}
```


### error TS2345: Argument of type 'number | undefined' is not assignable to parameter of type 'number'

解法
加上型別 `<number>`
```
saveProduct(product: Product) {
	if (product.id == 0 || product.id == null) {
		product.id = this.generateID();
		this.products.push(product);
	} else {
		let index = this.products
			.findIndex(p => this.locator(p, <number>product.id));
		this.products.splice(index, 1, product);
	}
}

```


### Object is possibly 'undefined'
解法
都加上 `?` 運算子即可
```
swapProduct() {
	let p = this.products.shift();
	this.products.push(new Product(p?.id, p?.name, p?.category, p?.price));
}

```

或是多一個防止 null 的判斷式
```
swapProduct() {
	let p = this.products.shift();
	if(p != null) this.products.push(new Product(p.id, p.name, p.category, p.price));
}

```


### Can't bind to 'pa-attr' since it isn't a known property of 'td'.
解法要加上 `@Input("pa-attr")`

```
import {Directive, ElementRef, Attribute, Input} from "@angular/core";

@Directive({
  selector: "[pa-attr]",
})
export class PaAttrDirective{
  @Input("pa-attr")
  bgClass!: string;

  constructor(element: ElementRef , @Attribute("pa-attr") bgClass: string) {
    element.nativeElement.classList.add(bgClass || "bg-success" , "text-white");
  }
}

```

### error TS7006: Parameter '$event' implicitly has an 'any' type
解法
加上 any 或是 MouseEvent 即可
html
```
<button class="btn btn-sm btn-primary" (click)="search($event)">Search</button>
```
ts
```
search(event:any){
	alert(event)
}

search(event:MouseEvent){
	alert(event)
}
```


### Type 'Event' is not assignable to type 'string'.
`app.module.ts` 加入 `FormsModule` 即可
```
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent } from './app.component';
import { HeaderComponent } from './header/header.component';
import { FooterComponent } from './footer/footer.component';
import { ArticlesComponent } from './articles/articles.component';
import { TagsComponent } from './tags/tags.component';
import { FormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    FooterComponent,
    ArticlesComponent,
    TagsComponent
  ],
  imports: [
    BrowserModule ,
    FormsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
```


### 'Output' accepts too few arguments to be used as a decorator here. Did you mean to call it first and write '@Output()'
解法 Output 忘了加括號
另外常常會遇到 EventEmitter import 錯誤
因為 EventEmitter 會有好幾個 namespace 都有 , 一般情況下注意要 import angular/core 的才正確
```
@Output()
keywordchange = new EventEmitter<string>();
```



### error TS2729: Property 'originalList' is used before its initialization
解法
因為 ts 是有順序性的限制讓 originalList 放在前面即可
```
originalList : any[] = [{name : "test"}];
list = this.originalList;
```
