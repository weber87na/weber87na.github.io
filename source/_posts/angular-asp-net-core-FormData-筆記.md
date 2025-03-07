---
title: angular + asp.net core FormData 筆記
date: 2025-01-13 12:51:01
tags:
- angular
- asp.net core
---
&nbsp;
<!-- more -->

工作上 angular + .net core 遇到的問題, 問 chatgpt 半天也沒答出來
搞半天發現關鍵在兩個參數都要用 `FromForm` FromForm 好饒舌 ~ 自己腦子有點轉不過來 哈

```
[HttpPost]
[Route( "UploadExcel" )]
public async Task<IActionResult> UploadExcel( 
[FromForm] IFormFile file, 
[FromForm] string id )
```

angular 則是要設定 append, 這樣兩個參數才會都吃得到

```
const formData = new FormData();
formData.append('file', this.selectedFile, this.selectedFile.name);
formData.append('id', this.id);
```

angular service

```
uploadExcel(formData: FormData): Observable<any> {
	const apiUrl = '/yourapiurl';
	return this.http.post(apiUrl, formData);
}
```

搭配 bootstrap input group, 原理則是把 label 設定 for 並且把 form 設定為 display none


```
<form class="d-none">
  <input
    id="uploadExcel"
    name="uploadExcel"
    type="file"
    (change)="onFileSelected($event)"
    accept=".xlsx"
  />
</form>

<div class="form-group">
	<div class="input-group">
		<label
		class="btn btn-outline-secondary"
		style="
		  display: flex;
		  justify-content: center;
		  align-items: center;
		  height: 100%;
		  line-height: 100%;
		"
		for="uploadExcel"
		>Upload</label
		>
	</div>
</div>
```
