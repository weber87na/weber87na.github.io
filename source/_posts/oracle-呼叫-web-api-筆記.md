---
title: oracle 呼叫 web api 筆記
date: 2021-05-11 02:53:22
tags: oracle
---
&nbsp;
<!-- more -->

工作上遇到一個奇怪的需求 , 需要直接用 oracle 去呼叫 web api , 順手筆記一下 , 寫得比較散

### 下載 oracle image 並且執行
用 docker ps 看是否啟動成功 , 這邊其實要設定一堆東西 , 像是開啟 hyper-v , 設定 BIOS , 因為沒逐步筆記就沒寫 , 另外 windows 跟 linux 差異也不小
```
docker ps
```

萬一炸出以下 error
```
error during connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.38/images/json: open //./pipe/docker_engine: The system cannot find the file specified. In the default daemon configuration on Windows, the docker client must be run elevated to connect. This error may also indicate that the docker daemon is not running
```

請輸入以下命令即可
```
cd "C:\Program Files\Docker\Docker"
./DockerCli.exe -SwitchDaemon
```

登入才可以抓 oracle 的 docker , 拉 oracle docker
```
docker login
docker pull store/oracle/database-enterprise:12.2.0.1
```

查剛剛拉下來的 oracle 12c docker
```
docker image ls
```

--name 設定名稱 -p 設定 port 跟實體的 mapping
```
docker run -d -it --name oracle -p 1521:1521 -p 5500:5500 store/oracle/database-enterprise:12.2.0.1
```

停止所有 docker 容器
```
docker stop $(docker ps -q)
```

開啟容器 5865db66532a => 這個是 ID , 只要打前幾碼即可
```
docker ps -a
docker start 586
```

檢查 docker 容器狀態的 json
```
docker container inspect oracle

[
    {
        "Id": "5865db66532a6ffe1be068f0a1724ab5ee1f4bc033033f7ee3b7703a280219c3",
        "Created": "2021-02-04T06:25:02.6268732Z",
        "Path": "/bin/sh",
        "Args": [
            "-c",
            "/bin/bash /home/oracle/setup/dockerInit.sh"
        ],
		//.....
]
```

搭配 powershell 檢查 ip
```
(docker container inspect 56b | ConvertFrom-Json).NetworkSettings.Networks.IPAddress
```

移除 container
```
docker container rm oracle
```

### oracle container 操作與設定
sqlplus 登入
```
docker exec -it oracle bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
```

在 sqlplus 切換到 sysdba
```
connect sys as sysdba;
```
SID：ORCLCDB
帳號：SYS
密碼：Oradoc_db1


sql developer
我的環境 openjdk version "1.8.0_282"
sql developer 設定 java home
版本需要 1.8.0_171 or java 11.1 以下
[msopenjdk](https://www.microsoft.com/openjdk)
```
C:\Users\YourName\AppData\Roaming\sqldeveloper\20.4.1\product.conf
```
設定 product.conf
```
SetJavaHome C:\Program Files\Java\jdk-11.0.11+9
```

sqlplus 連線設定
資料庫類型 Oracle
使用者名稱 SYS
密碼 Oradoc_db1
主機名稱 localhost
連接 port 1521
SID or 服務名稱擇一即可
SID ORCLCDB
服務名稱 ORCLCDB.localdomain

oracle 日常操作
```
#登入
connect sys as sysdba
#密碼 oracle

#檢查版本
select banner from v$version where rownum = 1;

#撈目前 db
SELECT NAME FROM v$database;

#撈資料表
SELECT owner, table_name
FROM dba_tables;
```
設定 sql developer DBMS_OUTPUT.PUT_LINE('ERROR');
```
SET SERVEROUTPUT ON
```

### 實測 http get web request
這個網站可以通 GET [撈假資料]http://jsonplaceholder.typicode.com/
建立測試用的 stored procedure
[參考網址](https://technology.amis.nl/database/invoke-a-rest-service-from-plsql-make-an-http-post-request-using-utl_http-in-oracle-database-11g-xe/)
[主要參考](https://gist.github.com/ser1zw/3757715)
```
--資料表
CREATE TABLE WWW_DATA (num NUMBER, dat CLOB)
/
--建立 get 的 PROCEDURE
CREATE OR REPLACE PROCEDURE WWW_GET(url VARCHAR2)
IS
    request UTL_HTTP.REQ;
    response UTL_HTTP.RESP;
    n NUMBER;
    buff VARCHAR2(4000);
    clob_buff CLOB;
BEGIN
    UTL_HTTP.SET_RESPONSE_ERROR_CHECK(FALSE);
    request := UTL_HTTP.BEGIN_REQUEST(url, 'GET');

	--這個 json 的部分好像要補上 , 用老外的測試失敗
    UTL_HTTP.SET_HEADER(request, 'content-type', 'application/json');
    UTL_HTTP.SET_HEADER(request, 'User-Agent', 'Mozilla/4.0');
    response := UTL_HTTP.GET_RESPONSE(request);
    DBMS_OUTPUT.PUT_LINE('HTTP response status code: ' || response.status_code);

    IF response.status_code = 200 THEN
        BEGIN
            clob_buff := EMPTY_CLOB;
            LOOP
                UTL_HTTP.READ_TEXT(response, buff, LENGTH(buff));
		clob_buff := clob_buff || buff;
            END LOOP;
	    UTL_HTTP.END_RESPONSE(response);
	EXCEPTION
	    WHEN UTL_HTTP.END_OF_BODY THEN
                UTL_HTTP.END_RESPONSE(response);
	    WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
                DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                UTL_HTTP.END_RESPONSE(response);
        END;

	SELECT COUNT(*) + 1 INTO n FROM WWW_DATA;
        INSERT INTO WWW_DATA VALUES (n, clob_buff);
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR');
        UTL_HTTP.END_RESPONSE(response);
    END IF;

END;

/
SHOW ERRORS
/

--這句就是呼叫 web request
EXEC WWW_GET('http://jsonplaceholder.typicode.com/todos/1');

--測試實際撈資料
SELECT * FROM WWW_DATA;
/
QUIT;
```
