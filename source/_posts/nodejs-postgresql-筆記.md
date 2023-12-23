---
title: nodejs postgresql 筆記
date: 2023-11-02 18:23:58
tags:
- postgresql
- nodejs
---
&nbsp;
<!-- more -->

### 安裝
安裝主要看[這篇](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-20-04)
```
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql.service
```

用 `postgres` 登入
```
psql -d postgres
```

然後用 psql 看看版本 `\q` 可以退出 `psql`
```
psql select version();
```

修改讓對外可以連線 , [參考自此](https://stackoverflow.com/questions/3278379/how-to-configure-postgresql-to-accept-all-incoming-connections)
```
sudo vim /etc/postgresql/12/main/pg_hba.conf
```

找到 `ipv4` 那句 , 改成這樣
```
host  all  all 0.0.0.0/0 md5
```

接著改 `postgresql.conf`
```
sudo vim /etc/postgresql/12/main/postgresql.conf
```

重新載入 config
```
SELECT pg_reload_conf();
```

接著重啟服務
```
service postgresql restart
```

接著設定下密碼 [參考自此](https://stackoverflow.com/questions/12720967/how-can-i-change-a-postgresql-user-password)
```
sudo -u postgres psql
postgres=# \password postgres
Enter new password: <new-password>
postgres=# \q
```


### 查詢
程式碼範例可以看[這裡](https://node-postgres.com/)
另外[微軟](https://learn.microsoft.com/zh-tw/azure/postgresql/single-server/connect-nodejs) 也有例子可以看 XD

安裝 `pg`
```
npm install pg
```


記得先在 `package.json` 補上 `"type": "module",`

用 `es6` 的話要這樣寫

連線設定檔的 `ssl` 要 `false` 不然也會噴錯
``` js
import pg from 'pg'

const { Client } = pg;

const config = {
    host: 'localhost',
    user: 'postgres',
    password: 'postgres',
    database: 'postgres',
    port: 5432,
    //ssl: true
};


const client = new Client(config);
await client.connect();

const res = await client.query('SELECT $1::text as message', ['Hello world!']);
console.log(res.rows[0].message);
await client.end();
```


### 新增
新增前先看看時區對不對
```
select current_setting('TIMEZONE');

 current_setting
-----------------
 Asia/Taipei
```


然後建個假的溫度表看看
``` sql
create table temperature_data (
	id serial primary key,
	thetime timestamp with time zone,
	temperature double precision
);
```


接著新增看看有無正常
``` js
import pg from 'pg'

const { Client } = pg;

const config = {
    host: 'localhost',
    user: 'postgres',
    password: 'postgres',
    database: 'postgres',
    port: 5432,
    //ssl: true
};


const client = new Client(config);
await client.connect();

const res = await client.query(`insert into temperature_data(thetime , temperature) values(now() , 26.85)`);
console.log(res);
await client.end();
```

看起來只有 `rowCount` 有用
```
Result {
  command: 'INSERT',
  rowCount: 1,
  oid: 0,
  rows: [],
  fields: [],
  _parsers: undefined,
  _types: TypeOverrides {
    _types: {
      getTypeParser: [Function: getTypeParser],
      setTypeParser: [Function: setTypeParser],
      arrayParser: [Object],
      builtins: [Object]
    },
    text: {},
    binary: {}
  },
  RowCtor: null,
  rowAsArray: false,
  _prebuiltEmptyResultObject: null
}
```

### 結合 express
CRUD [參考](https://blog.logrocket.com/crud-rest-api-node-js-express-postgresql/)

```
npm install express
```

```
// const express = require('express')
import pg from 'pg'
import express from 'express'

const { Pool } = pg;
const config = {
    host: 'localhost',
    user: 'postgres',
    password: 'postgres',
    database: 'postgres',
    port: 5432,
    //ssl: true
};
const pool = new Pool(config);

const app = express()
const port = 3000
app.listen(port)

app.get('/', async (req, res) => {
    const sqlResult = await pool.query('select * from temperature_data;');
    const rows = sqlResult.rows;
    res.send(rows)
})
```

### crontab
可以參考[這篇](https://stackoverflow.com/questions/5849402/how-can-you-execute-a-node-js-script-via-a-cron-job)
然後到[這個網站](https://crontab.guru/) 可以協助編輯 `crontab`

先用 `which` 查出 `nodejs` 安裝路徑 `/usr/local/bin/node`
```
which node
```

看看目前有啥任務
```
crontab -l
```

編輯 crontab 表達式
```
crontab -e
```

設定每分鐘 `insert` 資料進去
```
*/1 * * * * /usr/local/bin/node /home/ladisai/pgtest/index.js
```

用 `postgres` 登入進去 , 並且查有無成功

```
psql -d postgres
select * from temperature_data;
```

或是可以這樣用 , 先在 index.js 最上面加上
```
#!/usr/bin/env node
```

接著給權限 , 讓他變成可執行的 `script`
```
chmod +x index.js
```

測試看看能否執行
```
./index.js
```

最後修改 `crontab`
```
crontab -e
```

編輯 crontab 如下即可
```
#*/1 * * * * /usr/local/bin/node /home/ladisai/pgtest/index.js
*/1 * * * * /home/ladisai/pgtest/index.js
```
