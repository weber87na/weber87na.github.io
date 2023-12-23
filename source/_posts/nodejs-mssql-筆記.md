---
title: nodejs mssql 筆記
date: 2023-11-02 18:22:57
tags: js
---
&nbsp;
<!-- more -->

最近因為要建立大量測試資料去對應正式環境的情境 , 如果用 `sql` 建立的話大概直接登出
礙於環境問題 , 覺得用 `nodejs` 最方便 , 所以筆記下

安裝 [mssql](https://github.com/tediousjs/node-mssql#readme)
```
npm install mssql
```

首先定義連線設定 , 大概有兩種方式 `es6` or `commonjs`

### es6
如果要用 `es6` 應該還要在 `package.json` 設定 `"type": "module"`
然後定義連線 `sqlConfig.js`
``` js
export default {
    user: '',
    password: '',
    server: '',
    database: '',
    port: 1433,
    options: {
        //如果是 azure 才使用 true , 其他好像都設定 false
        encrypt: false
    }
};
```

然後直接 import 即可
``` js
import sqlConfig from './sqlConfig.js';
```

接著撰寫撈資料的部分 , 就收工了
如果要 insert 的話也是直接把 sql 語法改寫為 insert 程式碼不用改
這裡有個要注意的大雷 , 如果你習慣不寫分號當結尾的話 , 那個 `async function` 的地方應該會噴 `error` , 記得加上分號

``` js
import sqlConfig from './sqlConfig.js';
import sql from 'mssql';
(async function () {
    try {
        let pool = await sql.connect(sqlConfig);
        let cmd = `select 1 as num`;
        let result = await pool.request().query(cmd);

        console.log(result.recordset);

        pool.close();
    } catch (err) {
        console.log('query error', err);
    }
})();

sql.on('error', err => {
    console.log('oops error', err);
});
```


### commonjs
``` js
const sqlConfig = {
    user: '',
    password: '',
    server: '',
    database: '',
    port: 1433,
    options: {
        //如果是 azure 才使用 true , 其他好像都設定 false
        encrypt: false
    }
};

module.exports = sqlConfig;
```

`commonjs` 則是用以下這樣 `import` 其他讀資料都一樣
``` js
const sql = require('mssql');
const sqlConfig = require('./sqlConfig');
```

### 匯出 json
這裡大概要注意的就是 `async` 會給 `promise` , 所以要在結果前面加上 `await` 就可以啦
然後 `writeFile` 要吃 `string` , 所以用 `JSON.stringify` 把 `json` 轉為 `string`

``` js
import sqlConfig from './sqlConfig.js';
import sql from 'mssql';

let data = (async function () {
    try {
        let pool = await sql.connect(sqlConfig);
        let cmd = `select 1 as num`;
        let result = await pool.request().query(cmd);

        // console.log(result);
        // console.log(result.recordsets);
        // console.log(result.recordset);

        pool.close();

        return result.recordset;
    } catch (err) {
        console.log('query error', err);
    }
})();

let jsonStr = JSON.stringify(await data);
writeFile('test.json', jsonStr, (err)=>{
    if(err) throw err;
    console.log('done');
});
```


### 匯出 csv
匯出 `csv` 查了下可以用這套[export-to-csv](https://www.npmjs.com/package/export-to-csv)

```
npm install export-to-csv
```

這裡一樣記得要加上 await

``` js
import sqlConfig from './sqlConfig.js';
import sql from 'mssql';
import { writeFile } from "node:fs";
import { Buffer } from "node:buffer";
import { mkConfig, generateCsv, asString } from "export-to-csv";

const csvConfig = mkConfig({ useKeysAsHeaders: true, filename: 'test' });

let data = (async function () {
    try {
        let pool = await sql.connect(sqlConfig);
        let cmd = `select 1 as num`;
        let result = await pool.request().query(cmd);

        // console.log(result);
        // console.log(result.recordsets);
        // console.log(result.recordset);

        pool.close();

        return result.recordset;
    } catch (err) {
        console.log('query error', err);
    }
})();

const csv = generateCsv(csvConfig)(await data);
const filename = `${csvConfig.filename}.csv`;
const csvBuffer = new Uint8Array(Buffer.from(asString(csv)));

// Write the csv file to disk
writeFile(filename, csvBuffer, (err) => {
    if (err) throw err;
    console.log("file saved: ", filename);
});

sql.on('error', err => {
    console.log('oops error', err);
});
```
