---
title: angular 實作類似 youtube loading 灰色色塊效果
date: 2025-01-13 12:53:23
tags: angular
---
&nbsp;
<!-- more -->

平常在看 youtube or fb 時, 通常影片載入之前會出現灰色色塊, 讓體驗更好點, 自己也很好奇不過不曉得要下啥關鍵字
今天終於發現原來是 `skeleton` 自己剛好在做 angular 專案就拿來用看看

安裝如下

```
npm i ngx-skeleton-loader
```

用法也不難, 我專案是 bootstrap4 所以大概這樣寫即可

```
<ng-container *ngIf="this.plan; else loadingContent">
	<!-- 其他你的 code -->
</ng-container>

<ng-template #loadingContent>
  <div class="row mb-2 mt-2">
    <div class="col-md-12">
      <ngx-skeleton height="34px" width="100px"></ngx-skeleton>
    </div>
  </div>
  <div class="row mb-2">
    <div class="col-md-12">
      <ngx-skeleton height="120px"></ngx-skeleton>
    </div>
  </div>
  <div class="row mb-2">
    <div class="col-md-6">
      <ngx-skeleton height="38px"></ngx-skeleton>
    </div>
    <div class="col-md-6"></div>
  </div>
  <div class="row mb-2">
    <div class="col-md-2">
      <ngx-skeleton height="38px"></ngx-skeleton>
    </div>
    <div class="col-md-4"></div>
    <div class="col-md-2">
      <ngx-skeleton height="38px"></ngx-skeleton>
    </div>
    <div class="col-md-4"></div>
  </div>
  <div class="row">
    <div class="col-md-6">
      <ngx-skeleton height="500px"></ngx-skeleton>
    </div>
    <div class="col-md-6">
      <ngx-skeleton height="500px"></ngx-skeleton>
    </div>
  </div>
</ng-template>
```
