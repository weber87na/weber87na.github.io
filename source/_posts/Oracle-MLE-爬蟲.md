---
title: Oracle MLE 爬蟲
date: 2022-11-28 18:21:58
tags:
- oracle
- js
---
&nbsp;
<!-- more -->

Oracle 也可以搞爬蟲!? 老實說這是自虐!! 為了玩看看 `Oracle MLE (Multilingual Engine)` 的功能才寫這篇 , 完全嘗試用 js + pl/sql 去處理
雖然解得不太好 , 但整個解出來還是挺有趣的 , 畢竟現在沒啥範例可看
首先先到 [這個網站](https://www.pnb.com.ph/index.php/foreign-exchange-rates?tpl=revamp) 看看匯率

### 正常 js 寫法
先用正常的 js 寫看看原理 , 基本上就是用到 css 的 selector , 外加 js 把 key & value 的 array 縫合成物件就收工了
```
//取自此網站
//https://www.pnb.com.ph/index.php/foreign-exchange-rates?tpl=revamp

//撈 table
var table = document.querySelector('.table-responsive table:nth-child(2)');

//保存結果
var result = [];

//轉換 HtmlCollection 讓 foreach 可以用
var rows = Array.from(table.rows)

//跳過前兩個沒用的 row
var sikp2rows = rows.slice(2,rows.length)

//迴圈
sikp2rows.map(row => {
	
	//轉換 HtmlCollection 讓 foeach 可以用
	var cells = Array.from(row.cells);
	
	//定義物件屬性
	var keys = ['Currency' , 'Buy' , 'Sell']
	
	//保存 cell 數值
	var values = []
	
	//迴圈取得 cell 數值
	cells.map(cell => values.push(cell.innerText))
	
	//建立匯率物件
	//https://stackoverflow.com/questions/47517488/zip-arrays-as-keys-and-values-of-an-object
	var rate = Object.assign(...keys.map((k, i) => ({ [k]: values[i] })));
	
	//保存結果
	result.push(rate);
});

//印出結果
console.log(result)
```


### Oracle MLE 寫法
接著玩看看噁爛的 MLE 寫法 , 目前好像只有 `require('mle-js-oracledb')` `require('mle-js-bindings')` `require("mle-js-plsqltypes")` 這三個 lib 可以用 , 也不支援 npm
這三個模組的用法可以看 [這邊](https://github.com/oracle-samples/mle-modules)
好在 Oracle 本身有 http request 功能可以用 , 礙於設定複雜 , 建議先看我之前寫的[這篇](https://www.blog.lasai.com.tw/2022/11/16/net-6-%E8%8F%B2%E5%BE%8B%E8%B3%93%E5%8C%AF%E7%8E%87%E7%88%AC%E8%9F%B2/#oracle)

首先建立資料表
```
create table test_rate(Currency varchar2(100) , Buy varchar2(100), Sell varchar2(100));
```

接著呼叫網頁看看能否正常取得內容 , 這裡要注意 , 如果你的檔案內容超過 `4000` 字請一定要用 stored procedure 的方式去存 , 預設會限制 `4000` 字的上限
所以你如果這樣呼叫的話最多只有 `4000` 字 , 另外務必要設定 `wallet` 及 `憑證` , 不然會噴 http 錯誤
```
--設定錢包
EXEC UTL_HTTP.set_wallet('file:/home/oracle/wallet', 'WalletPasswd123');

--呼叫 request
SELECT UTL_HTTP.REQUEST('https://www.pnb.com.ph/index.php/foreign-exchange-rates?tpl=revamp')
FROM DUAL;
```

正常呼叫 http request 以後就可以新增看看資料 , 老樣子要注意網址 encode 之類的問題
```
EXEC UTL_HTTP.set_wallet('file:/home/oracle/wallet', 'WalletPasswd123');
EXEC WWW_GET('https://www.pnb.com.ph/index.php/foreign-exchange-rates?tpl=revamp');

SELECT *
FROM WWW_DATA;
```

最後就是最噁心的地方來了 , 在 pl/sql 裡面跑 js
本來以為可以把 table 用 regex 找出來然後轉為 oracle 的 xmltype 搭配 xml query 應該就可以查了 , 不過礙於他的結構有問題 , 所以 parser 會噴 error
所以只好整個自幹 regex 自己 parser , 要測的話用老朋友 [regex101](https://regex101.com/) , 我這裡忘得差不多啦 , 寫得兩光兩光的
最後一個重點注意不要寫 `&` 在 js 裡面 , oracle 會認為是要傳遞參數進去 , 然後會一直彈出視窗
順帶一提一開始我用 regexp_substr 去撈這個 table 的正則不曉得為啥總是跑不出來 , 丟其他正則也很慢 , 也許這就是 Oracle MLE 的價值所在吧!
```
SET SERVEROUTPUT ON;
DECLARE
   ctx DBMS_MLE.context_handle_t := DBMS_MLE.create_context();
   --html_content varchar2(4000);
   html_content clob;
BEGIN
   DBMS_MLE.eval(ctx, 'JAVASCRIPT', q'~    
//example
//https://github.com/oracle-samples/mle-modules
const oracledb = require('mle-js-oracledb');
const bindings = require('mle-js-bindings');
const plsqltypes = require("mle-js-plsqltypes");


const conn = oracledb.defaultConnection();

//https://www.pnb.com.ph/index.php/foreign-exchange-rates?tpl=revamp
const query = `select dat , dat from www_data where num = 3`;

const options = { fetchInfo: { N: { type: oracledb.ORACLE_CLOB } } };
const queryResult = conn.execute(query, [], options);
const OracleClob = plsqltypes.OracleClob;
const result = queryResult.rows[0][0];

//取得 db 的 clob 長度
let length = result.length();


//從 clob 讀取 html
let html = result.read(length,1);
console.log('clob length:' + length);

//test
//https://regex101.com/

//以 regex 撈 table
let matches = html.matchAll(/<table+[^>]+>[\S\s]*?<\/table>/g);
let resultMatches = [...matches];

//取得我們需要的 table 內容
let htmlContent = resultMatches[2];

//console.log(resultMatches.length);
//console.log(resultMatches);

//以展開運算子 toString 後 , 取得 match 所有的 tr 元素 , 並且跳過前兩列撈出 tr
let rows = [...htmlContent.toString().matchAll(/<tr+.*>[\S\s]*?<\/tr>/gm)].splice(2,22);

//存放最後匯率結果
let rates = [];

//迴圈跑 tr
for(let row of rows){
    console.log(row);
	let m;
	
	//保存匯率數值
	var values = [];
	
	//建立匯率物件屬性
	var keys = ['Currency' , 'Buy' , 'Sell'];
	
	//過濾 td regex
    const cellsRegex = /<td+>([\S\s]*?)<\/td>|<td[\S\s]*?>([\S\s]*?)<\/td>/gm;
	
	//迴圈跑 td
	while ((m = cellsRegex.exec(row)) !== null) {
		if (m.index === cellsRegex.lastIndex) {
			regex.lastIndex++;
		}
        
		//迴圈取得 td 符合的數值
		m.forEach((match, groupIndex) => {
			if((groupIndex === 1 || groupIndex == 2) && (match !== undefined)){
				values.push(match);
			}
		});
	}
	
	//將 value and key 組合成 json 物件
    var rate = Object.assign(...keys.map((k, i) => ({ [k]: values[i] })));
	//console.log(rate);
    rates.push(rate);
}

//印出最後匯率的 array
console.log(rates);

//迴圈 insert 結果到 test_rate 資料表內
for(rate of rates){
    console.log(JSON.stringify(rate));
    //https://oracle-samples.github.io/mle-modules/docs/mle-js-oracledb/21c/
    var insertResult = conn.execute(`insert into test_rate values ('${rate.Currency}' , '${rate.Buy}' , '${rate.Sell}')`);
    var rowsInserted = insertResult.rowsAffected;
    console.log('rowsInserted:' + rowsInserted);
}
   ~');
    dbms_output.put_line('done');
    DBMS_MLE.drop_context(ctx);
END;
```
