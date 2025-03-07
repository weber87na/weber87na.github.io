---
title: sqlplus 亂碼
date: 2024-09-25 11:52:48
tags: oracle
---
&nbsp;
<!-- more -->

參考[強國人](https://www.cnblogs.com/monkey6/p/14580308.html) 及 [這篇](https://sportingmobile.blogspot.com/2016/07/sqlplus.html)

```
select * 
from v$nls_parameters 
where parameter in ('NLS_LANGUAGE','NLS_TERRITORY','NLS_CHARACTERSET');

查出來會長這樣
PARAMETER VALUE
NLS_LANGUAGE AMERICAN
NLS_TERRITORY AMERICA
NLS_CHARACTERSET AL32UTF8
```

最後在 linux 環境變數設以下這樣即可

```
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
```
