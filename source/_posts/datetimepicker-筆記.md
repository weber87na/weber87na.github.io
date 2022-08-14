---
title: datetimepicker 筆記
date: 2022-03-08 03:20:28
tags: jquery
---

&nbsp;
<!-- more -->

由於做迷片的朋友要維護老系統 , 只幫忙看看古早時候 bootstrap3 datetimepicker 是怎麼用的 , [參考官方](https://getdatepicker.com/4/)
首先是安裝 , 屎運有提供 nuget , 他會一起幫你把 momentjs 裝好
```
PM> Install-Package Bootstrap.v3.Datetimepicker.CSS
```

官方範例
```
<head>
  <script type="text/javascript" src="/scripts/jquery.min.js"></script>
  <script type="text/javascript" src="/scripts/moment.min.js"></script>
  <script type="text/javascript" src="/scripts/bootstrap.min.js"></script>
  <script type="text/javascript" src="/scripts/bootstrap-datetimepicker.*js"></script>
  <!-- include your less or built css files  -->
  <!--
  bootstrap-datetimepicker-build.less will pull in "../bootstrap/variables.less" and "bootstrap-datetimepicker.less";
  or
  <link rel="stylesheet" href="/Content/bootstrap-datetimepicker.css" />
  -->
</head>
```

他這裡有個雷 , 就是預設的 moment js 不會載中文 , 所以要手動指定這個 , 因為老系統用 asp.net 所以設定 `ResolveUrl` 好像更安全些
```
<script src="<%=ResolveUrl("~/Scripts/moment-with-locales.js")%>"></script>
```

`html`
```
<!-- https://getdatepicker.com/4/ -->
<div class="container">
	<div class='col-md-6'>
		<div class="form-group">
			<div class='input-group date' id='begin-datetimepicker'>
				<input type='text' class="form-control" />
				<span class="input-group-addon">
					<span class="glyphicon glyphicon-calendar"></span>
				</span>
			</div>
		</div>
	</div>
	<div class='col-md-6'>
		<div class="form-group">
			<div class='input-group date' id='end-datetimepicker'>
				<input type='text' class="form-control" />
				<span class="input-group-addon">
					<span class="glyphicon glyphicon-calendar"></span>
				</span>
			</div>
		</div>
	</div>
</div>
```

注意這裡要寫 `locale`
```
<script type="text/javascript">
	//文件參考
	//https://getdatepicker.com/4/#using-locales
	$('#begin-datetimepicker').datetimepicker({
		locale: 'zh-tw',
		format: 'L'
	});

	$('#end-datetimepicker').datetimepicker({
		locale: 'zh-tw',
		format: 'L',

		//這串一定要寫
		//Important! See issue #1075
		useCurrent: false
	});

	$("#begin-datetimepicker").on("dp.change", function (e) {
		$('#end-datetimepicker').data("DateTimePicker").minDate(e.date);
	});

	$("#end-datetimepicker").on("dp.change", function (e) {
		$('#begin-datetimepicker').data("DateTimePicker").maxDate(e.date);
	});
</script>

```

取值會回傳 Moment 物件
```
$('#begin-datetimepicker').data("DateTimePicker").viewDate().format();
```
