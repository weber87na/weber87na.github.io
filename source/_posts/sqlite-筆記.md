---
title: sqlite 筆記
date: 2023-11-06 19:08:45
tags:
- sqlite
- js
---
&nbsp;
<!-- more -->
### 日常
注意下他的日期要用 `datetime('now','localtime')`

```
create table temperature_data (
	id integer primary key,
	thetime datetime,
	temperature REAL
);

insert into temperature_data(thetime , temperature) values(datetime('now','localtime') , 22.5);

select * from temperature_data;

select datetime('now','localtime');
select datetime('now');

--轉為 localtime
select datetime(thetime, 'localtime') from temperature_data;

--查資料表有無建立
select * from sqlite_master;
```


### 資料型別
[資料型別](https://www.sqlite.org/datatype3.html)
NULL. The value is a NULL value.

INTEGER. The value is a signed integer, stored in 0, 1, 2, 3, 4, 6, or 8 bytes depending on the magnitude of the value.

REAL. The value is a floating point value, stored as an 8-byte IEEE floating point number.

TEXT. The value is a text string, stored using the database encoding (UTF-8, UTF-16BE or UTF-16LE).

BLOB. The value is a blob of data, stored exactly as it was input.


### sqlite-web
因為是檔案式可以考慮安裝 [sqlite-web](https://github.com/coleifer/sqlite-web) 來操作` 遠端` 測試檔案
這套好像是 `flask` 做的 , 要跑在背景可能參考[這篇](https://stackoverflow.com/questions/36465899/how-to-run-flask-server-in-the-background)

```
sudo apt install python3-pip
pip3 install sqlite-web
```

我測 windows 也沒問題 , 密碼預設是抓環境變數 `SQLITE_WEB_PASSWORD`

看要訂怎樣 global 或是該 user
```
#for user
#vim ~/.bashrc

#for global
vim /etc/environment

export SQLITE_WEB_PASSWORD=TEST
```

要對外的話要這樣下
for windows
```
sqlite_web --host 0.0.0.0 --password --no-browser 'C:\testdb\test.db'
```

for linux
```
sqlite_web --host 0.0.0.0 --password --no-browser test.db
```

跑背景 , 最簡單就是搞個 `&` 符號在結尾
```
sqlite_web --host 0.0.0.0 --password --no-browser test.db &
```

列出 process
```
ps

#   PID TTY          TIME CMD
# 902146 pts/0    00:00:12 zsh
# 910883 pts/0    00:00:00 sqlite_web
# 910962 pts/0    00:00:00 ps
```

砍掉 , 可以參考[這篇](https://blog.gtwang.org/linux/linux-kill-killall-xkill/) 或 [這篇](https://www.cyberciti.biz/faq/how-force-kill-process-linux/)
久沒用 linux 又忘了
```
kill -9 910883
```


### sqlitebrowser
猜應該是 qt 寫的 , 一臉 qt 臉
這個 [sqlitebrowser](https://sqlitebrowser.org/dl/) 在 windows 才用吧
最大重點應該就是記得要關閉資料庫連線

### cli tool
看是要用官方的 [cli](https://sqlite.org/cli.html)
或是這套偷懶的 [litecli](https://github.com/dbcli/litecli)
我自己是用偷懶的 , 我測 windows 也是能用

安裝
```
pip3 install litecli
```

建 db
```
mkdir sqlite-test
cd ~/sqlite-test
litecli 'test.db'
```


### 整合 nodejs sequelize
這裡要注意 , 現在 `v7` 在 `alpha` 看文件別翻錯

https://sequelize.org/docs/v6/
```
npm install sequelize sqlite3

```

自己搞了陣子 , 發現 sqlite 的日期只會用 `utc` , 然後這個 `ORM` 的新增的時間又有點雷包雷包
會長大概這樣 `2023-01-06 09:46:06.292 +00:00` 後面有帶 `+00:00` 暫時無解 , 不過最後時間是一樣低

example code
```
import { Sequelize, DataTypes, Model, QueryTypes } from 'sequelize';

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: 'test.db'
});
class TemperatureData extends Model {
}

TemperatureData.init({
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false
    },
    thetime: {
        type: DataTypes.DATE,
        allowNull: false,
		// 寫這樣他反而會用他 ORM 內建的變數 , 不是 DB 的預設數值
        // defaultValue: Sequelize.NOW
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
    },

    temperature: {
        //sqlite REAL
        type: DataTypes.FLOAT,
    }
}, {
    sequelize,

    //自動複數化
    freezeTableName: true,

    //自訂表名
    tableName: 'temperature_data',

    //不要他系統自己加的欄位
    createdAt: false,
    updatedAt: false
});

(async () => {
    // create table example
    // force: true 會刪表
    await sequelize.sync({ force: true });
    // console.log('同步模型');

    // insert example
    // 他這裡新增的會會長這樣 2023-01-06 09:09:36.761 +00:00
    // let now = getDateString(new Date());
    // console.log('now' , now)
    const insertRow = await TemperatureData.create({ temperature: 26.03 });
    // const insertRow2 = await TemperatureData.create({ temperature: 27.03 });
    // const insertRow3 = await TemperatureData.create({ temperature: 28.03, thetime: (new Date()).toISOString() });
    // const insertRow4 = await TemperatureData.create({ temperature: 28.03, thetime: new Date() });
    console.log(insertRow.toJSON())
    // console.log(insertRow2.toJSON())
    // console.log(insertRow3.toJSON())
	// console.log(insertRow4.toJSON())

    //要這樣看 , 不要直接 log 印
    // console.log(row.toJSON());

	//query example 1
    // const rows1 = await TemperatureData.findAll();
    // console.log(rows1)

    //query example 2
    // const rows2 = await sequelize.query('select * from temperature_data', { type: QueryTypes.SELECT });
    //這裡他會是給 UTC
    //要轉 localtime 要用以下方法
    //new Date(Date.parse('2023-01-06 09:09:36.761 +00:00'))
    // console.log(rows2);
})();
```
