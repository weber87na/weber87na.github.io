---
title: oracle rest data service lab
date: 2024-09-18 11:17:58
tags: oracle
---
&nbsp;
<!-- more -->

工作上遇到的問題, 雖然有 oracle 證照但是躺在那邊 10 年有了, 也早就忘光光, 工作以來也沒真的用到 oracle, 這次莫名其妙掃被到就玩看看 XD

老實說跟證照考的內容完全沒有任何關係 lol ~

## wsl 安裝 docker
因為沒有 systemctl 所以順便記下

```
# 看目前 ubunt 版本
lsb_release -a


sudo apt update
lsb_release -a
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo service docker start

# 權限設定
sudo usermod -aG docker ${USER}
su - ${USER}
id -nG
```

## Lab 環境架構

`10.1.23.45` => 我的電腦

`172.1.23.45` => `wsl ubuntu 20` (Windows Subsystem for Linux)

`docker` 上面跑 `oracle xe` (nguoianphu/docker-oracle-xe-11g)

wsl ubuntu 20 port 49161 mapping 到 docker port 1521

```
docker run -dit --name oracle11g -p 49160:22 -p 49161:1521 nguoianphu/docker-oracle-xe-11g
docker ps -a
CONTAINER ID   IMAGE                             COMMAND                  CREATED      STATUS                  PORTS
                        NAMES
bb3ea8c4c45d   nguoianphu/docker-oracle-xe-11g   "/bin/sh -c '/usr/sb…"   6 days ago   Up 2 hours              8080/tcp, 0.0.0.0:49160->22/tcp, [::]:49160->22/tcp, 0.0.0.0:49161->1521/tcp, [::]:49161->1521/tcp   oracle11g
```

wsl 又 mapping 到我機器的 port, 所以可以在內網連到

```
🌹 netsh interface portproxy show all

接聽 ipv4:             連線到 ipv4:

位址            連接埠      位址            連接埠
--------------- ----------  --------------- ----------
10.1.23.45     8080        172.1.23.45  8080
10.1.23.45     49161       172.1.23.45  49161
10.1.23.45     8443        172.1.23.45  8443
```

連到 oracle xe

```
sqlplus testuser1/testuser1@//localhost:49161/xe
```

跳到 oracle 的 docker container 裡面

```
docker exec -it oracle11g /bin/bash
```

## 安裝

安裝參考[這篇](https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-installation-on-tomcat) 不過我沒用 tomcat
官網好像寫說不能用 `tomcat9` 反正沒我的事, 放生 ~

[系統需求](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/19.2/aelig/installing-REST-data-services.html#GUID-F6A4F94A-D62F-4A35-A471-6306332DF522)

Oracle Database (Enterprise Edition, Standard Edition or Standard Edition One) release 11.1 or later,
or Oracle Database 11g Release 2 Express Edition. => `以 xe 實測 ok`

Java JDK 8 or later. => 他這裡應該是指 oracle database 那台

如果跑 ords 則需要 Java 11

```
SELECT * FROM v$version;

Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
```

[ORDS 下載位置](https://www.oracle.com/database/sqldeveloper/technologies/db-actions/download/)

先下載回來然後解壓, 會長以下這樣

```
gg@HQ-XOAH-P05:~$ mkdir ords
gg@HQ-XOAH-P05:~$ cd ords
gg@HQ-XOAH-P05:~/ords$ unzip ords-24.2.3.201.1847.zip
gg@HQ-XOAH-P05:~/ords$ ls
LICENSE.txt  NOTICE.txt  THIRD-PARTY-LICENSES.txt  bin  databases  docs  examples  global  icons  lib  linux-support  logs  ords.war  scripts
```

現在執行安裝指令, 執行下去他會跳出問你想要設定的選項, 這裡的帳號要用 sys 不然會陣亡, 可以看[官網說明](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/24.2/ordig/installing-REST-data-services.html#GUID-6F65915E-0030-4E69-9380-C93150FC107A)
他還有個快速[教學](https://www.youtube.com/watch?v=prkcgJLsfw4)

```
java -jar ords.war install

  Enter a number to select the database connection type to use
    [1] Basic (host name, port, service name)
    [2] TNS (TNS alias, TNS directory)
    [3] Custom database URL
  Choose [1]:
  Enter the database host name [localhost]:
  Enter the database listen port [1521]: 49161
  Enter the database service name [orcl]: xe
  Provide database user name with administrator privileges.
    Enter the administrator username: sys
  Enter the database password for SYS AS SYSDBA:
  
Retrieving information.
ORDS is not installed in the database. ORDS installation is required.
```

接著會跳其他設定, 這裡就直接預設, 安裝完後他就直接啟動, 有點瞎 XD

```
  Enter a number to update the value or select option A to Accept and Continue
    [1] Connection Type: Basic
    [2] Basic Connection: HOST=localhost PORT=49161 SERVICE_NAME=xe
           Administrator User: SYS AS SYSDBA
    [3] Database password for ORDS runtime user (ORDS_PUBLIC_USER): <generate>
    [4] ORDS runtime user and schema tablespaces:  Default: SYSAUX Temporary TEMP
    [5] Additional Feature: Database Actions
    [6] Configure and start ORDS in Standalone Mode: Yes
    [7]    Protocol: HTTP
    [8]       HTTP Port: 8080
    [9]   APEX static resources location:
    [A] Accept and Continue - Create configuration and Install ORDS in the database
    [Q] Quit - Do not proceed. No changes
  Choose [A]:
The setting named: db.connectionType was set to: basic in configuration: default
The setting named: db.hostname was set to: localhost in configuration: default
The setting named: db.port was set to: 49161 in configuration: default
The setting named: db.servicename was set to: xe in configuration: default
The setting named: plsql.gateway.mode was set to: proxied in configuration: default
The setting named: db.username was set to: ORDS_PUBLIC_USER in configuration: default
The setting named: db.password was set to: ****** in configuration: default
The setting named: feature.sdw was set to: true in configuration: default
The global setting named: database.api.enabled was set to: true
The setting named: restEnabledSql.active was set to: true in configuration: default
The global setting named: standalone.http.port was set to: 8080
The global setting named: standalone.static.context.path was set to: /ords
The global setting named: standalone.doc.root was set to: /home/gg/ords/global/doc_root
The setting named: security.requestValidationFunction was set to: wwv_flow_epg_include_modules.authorize in configuration: default
2024-09-20T02:51:09.781Z INFO        Created folder /home/gg/ords/logs
2024-09-20T02:51:09.781Z INFO        The log file is defaulted to the current working directory located at /home/gg/ords/logs
2024-09-20T02:51:09.803Z INFO        Installing Oracle REST Data Services version 24.2.3.r2011847 in NON_CDB
2024-09-20T02:51:10.923Z INFO        ... Verified database prerequisites
2024-09-20T02:51:11.261Z INFO        ... Created Oracle REST Data Services proxy user
2024-09-20T02:51:11.766Z INFO        ... Created Oracle REST Data Services schema
2024-09-20T02:51:12.276Z INFO        ... Granted privileges to Oracle REST Data Services
2024-09-20T02:51:44.205Z INFO        ... Created Oracle REST Data Services database objects
2024-09-20T02:52:06.180Z INFO        Completed installation for Oracle REST Data Services version 24.2.3.r2011847. Elapsed time: 00:00:56.350

2024-09-20T02:52:07.197Z INFO        Completed configuring PL/SQL gateway user for Oracle REST Data Services version 24.2.3.r2011847. Elapsed time: 00:00:01.14

2024-09-20T02:52:07.199Z INFO        Log file written to /home/gg/ords/logs/ords_install_2024-09-20_105109_78151.log
2024-09-20T02:52:07.322Z INFO        HTTP and HTTP/2 cleartext listening on host: 0.0.0.0 port: 8080
2024-09-20T02:52:07.337Z INFO        Disabling document root because the specified folder does not exist: /home/gg/ords/global/doc_root
2024-09-20T02:52:07.337Z INFO        Default forwarding from / to contextRoot configured.
2024-09-20T02:52:09.235Z INFO        Configuration properties for: |default|lo|
db.servicename=xe
db.hostname=localhost
db.password=******
conf.use.wallet=true
security.requestValidationFunction=wwv_flow_epg_include_modules.authorize
standalone.static.context.path=/ords
database.api.enabled=true
db.username=ORDS_PUBLIC_USER
standalone.http.port=8080
restEnabledSql.active=true
resource.templates.enabled=false
plsql.gateway.mode=proxied
db.port=49161
feature.sdw=true
config.required=true
db.connectionType=basic
standalone.doc.root=/home/gg/ords/global/doc_root

2024-09-20T02:52:09.235Z WARNING     *** jdbc.MaxLimit in configuration |default|lo| is using a value of 10, this setting may not be sized adequately for a production environment ***
2024-09-20T02:52:09.236Z WARNING     *** jdbc.InitialLimit in configuration |default|lo| is using a value of 10, this setting may not be sized adequately for a production environment ***
2024-09-20T02:52:15.842Z INFO

Mapped local pools from /home/gg/ords/databases:
  /ords/                              => default                        => VALID


2024-09-20T02:52:15.923Z INFO        Oracle REST Data Services initialized
Oracle REST Data Services version : 24.2.3.r2011847
Oracle REST Data Services server info: jetty/10.0.21
Oracle REST Data Services java info: OpenJDK 64-Bit Server VM 11.0.24+8-post-Ubuntu-1ubuntu320.04
```

正常執行 ords 要這樣下

```
java -jar ords.war serve
```

他有提供一個 web 後台, 可以看[這篇](https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-sql-developer-web)
比較雷的是以為他中文的綱要是 schema, 實際上則是你開啟 ords mapping 的路徑, 這裡用 `qq` 的話在 `web sql developer` 就要先填 `qq`
同理 `OAuth2 Administration` 會直接要你敲 `Schema`

```
BEGIN
  ORDS.enable_schema(
    p_enabled             => TRUE,
    p_schema              => 'TESTUSER1',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'qq',
    p_auto_rest_auth      => FALSE
  );
    
  COMMIT;
END;
/
```

萬一前面安裝時忘了解鎖這兩個帳號 `APEX_PUBLIC_USER` `ORDS_PUBLIC_USER` 會噴類似的錯誤, 記得使用 sys 登入然後解鎖

`ORDS was unable to make a connection to the database. The database user specified by db.username configuration setting is locked. The connection pool named: |default|lo| had the following error(s): ORA-28000: the account is locked`

`Caused by: java.sql.SQLException: ORA-28000: the account is locked`

```
sqlplus sys@localhost:49161 as sysdba

ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK;
```

## 以 Oracle 預存程序實作 api

主要參考這篇[文章](https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-create-basic-rest-web-services-using-plsql)

礙於篇幅因素, 這裡以 `rest-v9` 為範例示範 CRUD, 其他篇幅請參照他的系列文章及 Oracle 官方文件

請先安裝 postman 進行以下 lab

這裡可以連到以下我 wsl 底下 docker 的 oracle xe 或是自己 pull oracle xe 的 docker image 來裝看看

`username` => `system`

`password` => `oracle`

`ip` => `10.1.23.45`

`port` => `49161`

`sid` => `xe`

```
# 讓自己的 wsl 內的 oracle xe 可以讓內網其他人連到
# powershell
# mapping to docker oracle xe
# netsh interface portproxy add v4tov4 listenaddress=10.1.23.45 listenport=49161 connectaddress=172.1.23.45 connectport=49161
```

### 建立測試用帳號

登入 system

`sqlplus system/oracle@//localhost:49161/xe`

```
CONN / AS SYSDBA
--ALTER SESSION SET CONTAINER=pdb1;

--DROP USER testuser1 CASCADE;
CREATE USER testuser1 IDENTIFIED BY testuser1
  DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE TYPE TO testuser1;
GRANT CREATE PROCEDURE TO testuser1;
```

以 `testuser1` 登入建立測試資料 `sqlplus testuser1/testuser1@//localhost:49161/xe`

```
CREATE TABLE EMP (
  EMPNO NUMBER(4,0),
  ENAME VARCHAR2(10 BYTE),
  JOB VARCHAR2(9 BYTE),
  MGR NUMBER(4,0),
  HIREDATE DATE,
  SAL NUMBER(7,2),
  COMM NUMBER(7,2),
  DEPTNO NUMBER(2,0),
  CONSTRAINT PK_EMP PRIMARY KEY (EMPNO)
  );

insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7369,'SMITH','CLERK',7902,to_date('17-DEC-80','DD-MON-RR'),800,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7499,'ALLEN','SALESMAN',7698,to_date('20-FEB-81','DD-MON-RR'),1600,300,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7521,'WARD','SALESMAN',7698,to_date('22-FEB-81','DD-MON-RR'),1250,500,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7566,'JONES','MANAGER',7839,to_date('02-APR-81','DD-MON-RR'),2975,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7654,'MARTIN','SALESMAN',7698,to_date('28-SEP-81','DD-MON-RR'),1250,1400,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7698,'BLAKE','MANAGER',7839,to_date('01-MAY-81','DD-MON-RR'),2850,null,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7782,'CLARK','MANAGER',7839,to_date('09-JUN-81','DD-MON-RR'),2450,null,10);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7788,'SCOTT','ANALYST',7566,to_date('19-APR-87','DD-MON-RR'),3000,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7839,'KING','PRESIDENT',null,to_date('17-NOV-81','DD-MON-RR'),5000,null,10);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7844,'TURNER','SALESMAN',7698,to_date('08-SEP-81','DD-MON-RR'),1500,0,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7876,'ADAMS','CLERK',7788,to_date('23-MAY-87','DD-MON-RR'),1100,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7900,'JAMES','CLERK',7698,to_date('03-DEC-81','DD-MON-RR'),950,null,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7902,'FORD','ANALYST',7566,to_date('03-DEC-81','DD-MON-RR'),3000,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7934,'MILLER','CLERK',7782,to_date('23-JAN-82','DD-MON-RR'),1300,null,10);
commit;
```

### 啟用 ORDS
這個步驟最為重要, 他這裡的 `p_url_mapping_pattern` 表示路徑 `http://localhost:8080/ords/hr/` 這個 `hr` 不能重複

```
BEGIN
  ORDS.enable_schema(
    p_enabled             => TRUE,
    p_schema              => 'TESTUSER1',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'hr',
    p_auto_rest_auth      => FALSE
  );

  COMMIT;
END;
/


SELECT parsing_schema,
       pattern
FROM   user_ords_schemas;
```

這裡如果要玩的話可以改用自己喜歡的 `test`

```
BEGIN
  ORDS.enable_schema(
    p_enabled             => TRUE,
    p_schema              => 'test',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'test',
    p_auto_rest_auth      => FALSE
  );

  COMMIT;
END;
/
```

### 撰寫預存程序
建立預存程序 (insert) create_employee

```
CREATE OR REPLACE PROCEDURE create_employee (
  p_empno     IN  emp.empno%TYPE,
  p_ename     IN  emp.ename%TYPE,
  p_job       IN  emp.job%TYPE,
  p_mgr       IN  emp.mgr%TYPE,
  p_hiredate  IN  VARCHAR2,
  p_sal       IN  emp.sal%TYPE,
  p_comm      IN  emp.comm%TYPE,
  p_deptno    IN  emp.deptno%TYPE
)
AS
BEGIN
  INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
  VALUES (p_empno, p_ename, p_job, p_mgr, TO_DATE(p_hiredate, 'YYYY-MM-DD'), p_sal, p_comm, p_deptno);
EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;
/
```

建立預存程序 (update) amend_employee

```
CREATE OR REPLACE PROCEDURE amend_employee (
  p_empno     IN  emp.empno%TYPE,
  p_ename     IN  emp.ename%TYPE,
  p_job       IN  emp.job%TYPE,
  p_mgr       IN  emp.mgr%TYPE,
  p_hiredate  IN  VARCHAR2,
  p_sal       IN  emp.sal%TYPE,
  p_comm      IN  emp.comm%TYPE,
  p_deptno    IN  emp.deptno%TYPE
)
AS
BEGIN
  UPDATE emp
  SET ename    = p_ename,
      job      = p_job,
      mgr      = p_mgr,
      hiredate = TO_DATE(p_hiredate, 'YYYY-MM-DD'),
      sal      = p_sal,
      comm     = p_comm,
      deptno   = p_deptno
  WHERE empno  = p_empno;
EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;
/
```

建立預存程序 (delete) remove_employee

```
CREATE OR REPLACE PROCEDURE remove_employee (
  p_empno  IN  emp.empno%TYPE
)
AS
BEGIN
  DELETE FROM emp WHERE empno = p_empno;
EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;
/
```

### 撰寫 ORDS API

`define_module` => 先定義模組名稱, 然後定義他的路徑

`define_template` => 定義在哪個路徑, 他這裡用 `employees/`

因為我們一開始定義在 `hr` 底下

所以他的最終路徑會長這樣 `http://localhost:8080/ords/hr/rest-v9/employees/`

這裡還可以在 `define_handler` 補個註解 `p_comments` => `get all employees` 這樣他會在 swagger 產出該方法說明
後來發現[老外](https://www.thatjeffsmith.com/archive/2020/02/how-to-customize-your-openapi-doc-for-oracle-rest-data-services/)寫說可以用 markdown, 會更詳細些

```
BEGIN
  ORDS.define_module(
    p_module_name    => 'rest-v9',
    p_base_path      => 'rest-v9/',
    p_items_per_page => 0);

  ORDS.define_template(
   p_module_name    => 'rest-v9',
   p_pattern        => 'employees/');

  -- READ : All records.
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM emp',
    p_items_per_page => 0);

  -- INSERT
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           create_employee (p_empno    => :empno,
                                            p_ename    => :ename,
                                            p_job      => :job,
                                            p_mgr      => :mgr,
                                            p_hiredate => :hiredate,
                                            p_sal      => :sal,
                                            p_comm     => :comm,
                                            p_deptno   => :deptno);
                         END;',
    p_items_per_page => 0);

  -- UPDATE
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'PUT',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           amend_employee(p_empno    => :empno,
                                          p_ename    => :ename,
                                          p_job      => :job,
                                          p_mgr      => :mgr,
                                          p_hiredate => :hiredate,
                                          p_sal      => :sal,
                                          p_comm     => :comm,
                                          p_deptno   => :deptno);
                         END;',
    p_items_per_page => 0);

  -- DELETE
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'DELETE',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           remove_employee(p_empno => :empno);
                         END;',
    p_items_per_page => 0);

  -- READ : One Record
  ORDS.define_template(
   p_module_name    => 'rest-v9',
   p_pattern        => 'employees/:empno');

  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/:empno',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM emp WHERE empno = :empno',
    p_items_per_page => 0);

  COMMIT;
END;
/
```

### 以 GET 取得所有 employees

GET 就把他想像成 sql 的查詢即可, 用 get 可以直接用 chrome 點以下網址即可獲得結果, 不須 postman

http://10.1.23.45:8080/ords/hr/rest-v9/employees/

### 以 GET 取得特定編號員工
http://10.1.23.45:8080/ords/hr/rest-v9/employees/7499

### 以 POST 新增員工
http://10.1.23.45:8080/ords/hr/rest-v9/employees/

```
{ "empno": 9999, "ename": "HALL", "job": "ANALYST", "mgr": 7782, "hiredate": "2016-01-01", "sal": 1000, "comm": null, "deptno": 10 }
```

### 以 PUT 更新員工
http://10.1.23.45:8080/ords/hr/rest-v9/employees/

```
{ "empno": 9999, "ename": "WOOD", "job": "ANALYST", "mgr": 7782, "hiredate": "2016-01-01", "sal": 1000, "comm": null, "deptno": 20 }
```

### 以 DELETE 刪除員工

http://10.1.23.45:8080/ords/hr/rest-v9/employees/

```
{ "empno": 9999 }
```

## 查目前的 API 路徑
http://10.1.23.45:8080/ords/hr/open-api-catalog/

```
    "items": [{
            "name": "rest-v1",
            "links": [{
                    "rel": "canonical",
                    "href": "http://10.1.23.45:8080/ords/hr/open-api-catalog/rest-v1/",
                    "mediaType": "application/openapi+json"
                }
            ]
        }, {
            "name": "rest-v3",
            "links": [{
                    "rel": "canonical",
                    "href": "http://10.1.23.45:8080/ords/hr/open-api-catalog/rest-v3/",
                    "mediaType": "application/openapi+json"
                }
            ]
...
```

可以點選 `links` => `href` 內的網址, 點開會有標準的 openapi json
http://10.1.23.45:8080/ords/hr/rest-v1/

```
{
    "openapi": "3.0.0",
    "info": {
        "title": "ORDS generated API for rest-v1",
        "version": "1.0.0"
    },
    "servers": [{
            "url": "http://10.1.23.45:8080/ords/hr/rest-v1/"
        }
    ],
    "paths": {
        "/employees/": {
            "get": {
                "description": "Retrieve records from rest-v1",
                "responses": {
                    "200": {
                        "description": "The queried record.",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "items": {
                                            "type": "array",
                                            "items": {
                                                "type": "object",
                                                "properties": {
                                                    "comm": {
                                                        "$ref": "#/components/schemas/NUMBER"
                                                    },
                                                    "deptno": {
                                                        "$ref": "#/components/schemas/NUMBER"
                                                    },
                                                    "empno": {
                                                        "$ref": "#/components/schemas/NUMBER"
                                                    },
                                                    "ename": {
                                                        "$ref": "#/components/schemas/VARCHAR2"
                                                    },
                                                    "hiredate": {
                                                        "$ref": "#/components/schemas/DATE"
                                                    },
                                                    "job": {
                                                        "$ref": "#/components/schemas/VARCHAR2"
                                                    },
                                                    "mgr": {
                                                        "$ref": "#/components/schemas/NUMBER"
                                                    },
                                                    "sal": {
                                                        "$ref": "#/components/schemas/NUMBER"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "parameters": []
            }
        }
    },
    "components": {
        "schemas": {
            "DATE": {
                "type": "string",
                "format": "date-time",
                "pattern": "^\\d{4}-[01]\\d-[0123]\\dT[012]\\d:[0-5]\\d:[0-5]\\d(.\\d+)?(Z|([-+][012]\\d:[0-5]\\d))$"
            },
            "NUMBER": {
                "type": "number"
            },
            "VARCHAR2": {
                "type": "string"
            }
        }
    }
}
```

貼到 [editor.swagger.io](https://editor.swagger.io/) 即可看見目前以 PL/SQL 實作之 api 結果

或是使用 redocly 即可在本機產生 swagger 文件

```
redocly build-docs http://10.1.23.45:8080/ords/hr/open-api-catalog/rest-v9/ --output=index.html
```

## https 設定

這裡遇到 Invalid SNI [參考老外](https://peterobrien.blog/2024/02/29/invalid-sni-what-is-it-and-how-to-fix-it/)

```
java -jar ords.war --config /home/gg/ords config set security.verifySSL false
java -jar ords.war --config /home/gg/ords config set standalone.https.port 8443
java -jar ords.war --config /home/gg/ords config set standalone.https.host localhost
```

他設定檔的位置應該在此 `vim ~/ords/global/settings.xml`

設定完後就可以用 https 來訪問

https://localhost:8443/ords/hr/open-api-catalog/

`settings.xml`

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Saved on Thu Sep 12 17:54:51 CST 2024</comment>
<entry key="database.api.enabled">true</entry>
<entry key="security.verifySSL">false</entry>
<entry key="standalone.doc.root">/home/gg/ords/global/doc_root</entry>
<entry key="standalone.http.port">8080</entry>
<entry key="standalone.https.host">localhost</entry>
<entry key="standalone.https.port">8443</entry>
<entry key="standalone.static.context.path">/ords</entry>
</properties>
```

## OAuth

### Basic Authentication

請參考[這篇](https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-authentication)

他這裡有串命令官網文件, 跟這教學都沒更新, 只要用下面命令即可正常增加 `user`

```
java -jar ords.war config user add emp_user emp_role

```

命令如下

```
BEGIN
  ORDS.create_role(
    p_role_name => 'emp_role'
  );

  COMMIT;
END;
/
```

```
DECLARE
  l_roles_arr    OWA.vc_arr;
  l_patterns_arr OWA.vc_arr;
BEGIN
  l_roles_arr(1)    := 'emp_role';
  l_patterns_arr(1) := '/employees/*';

  ORDS.define_privilege (
    p_privilege_name => 'emp_priv',
    p_roles          => l_roles_arr,
    p_patterns       => l_patterns_arr,
    p_label          => 'EMP Data',
    p_description    => 'Allow access to the EMP data.'
  );

  COMMIT;
END;
/
```

不用 https 的話就直接下 http://localhost:8080/ords/hr/employees/7788 就直接有結果


### client credentials
這裡要先記得開啟 api 保護

```
DECLARE
  l_roles_arr    OWA.vc_arr;
  l_patterns_arr OWA.vc_arr;
BEGIN
  l_roles_arr(1)    := 'emp_role';
  l_patterns_arr(1) := '/rest-v9/employees/*';
  
  ORDS.define_privilege (
    p_privilege_name => 'emp_priv',
    p_roles          => l_roles_arr,
    p_patterns       => l_patterns_arr,
    p_label          => 'EMP Data',
    p_description    => 'Allow access to the EMP data.'
  );
   
  COMMIT;
END;
/



BEGIN
  OAUTH.create_client(
    p_name            => 'emp_client',
    p_grant_type      => 'client_credentials',
    p_owner           => 'My Company Limited',
    p_description     => 'A client for Emp management',
    p_support_email   => 'tim@example.com',
    p_privilege_names => 'emp_priv'
  );

  COMMIT;
END;
/


SELECT id, name, client_id, client_secret
FROM   user_ords_clients;



BEGIN
  OAUTH.grant_client_role(
    p_client_name => 'emp_client',
    p_role_name   => 'emp_role'
  );

  COMMIT;
END;
/
```

這裡因為是 client credentials 所以只會有 access token, 所以要驗證 token 過期的方法就是看狀態是否 401
可以參考這兩篇

https://www.jmjcloud.com/blog/ords-securing-services-using-oauth2-2-legged
https://www.jmjcloud.com/blog/ords-changing-the-default-oauth2-token-expiry-lifetime

### Authorization Code

```
BEGIN
  OAUTH.create_client(
    p_name            => 'emp_client',
    p_grant_type      => 'authorization_code',
    p_owner           => 'My Company Limited',
    p_description     => 'A client for Emp management',
    p_redirect_uri    => 'https://localhost:8443/ords/hr/redirect',
    p_support_email   => 'tim@example.com',
    p_support_uri     => 'https://localhost:8443/ords/hr/support',
    p_privilege_names => 'emp_priv'
  );

  COMMIT;
END;
/

SELECT id, name, client_id, client_secret
FROM   user_ords_clients;
```

這裡的 `state` 就隨便寫即可, 這裡用 ok

https://localhost:8443/ords/hr/oauth/auth?response_type=code&client_id=Z4lbymKnlaG2JHtKgDD0uQ..&state=ok

之後會噴這個 401 畫面

輸入帳號 `emp_user` 及你的密碼即可登入

接著跳這頁要你允許給權限

然後他會跳這頁給你 `code` 這裡是 `rml0SJA1Rx-fe0rCYZaOJg`, 好像有時效性

https://localhost:8443/ords/hr/redirect?code=rml0SJA1Rx-fe0rCYZaOJg&state=ok

用 curl or postman 拿 code 換 token, oauth 最重要口訣就是拿 code 換 token

```
curl -i -k --user r20KPMlOwi0sYkjkQrH5LQ..:hQPkQgZgVsKEoa4rtW9gXQ.. --data "grant_type=authorization_code&code=vjokEevUwIavYYMRyFLsIg" https://localhost:8443/ords/hr/oauth/token

{"access_token":"gdDAou1H3SC5ufnQxMoi_Q","token_type":"bearer","expires_in":3600,"refresh_token":"HOo1Uh1Y4pW5PxS3UlJv9A"}
```

最後用 postman 打看看, 也可用 curl

### hostname 問題

這裡一樣想對外有可能會噴 `Invalid SNI` [參考老外](https://peterobrien.blog/2024/02/29/invalid-sni-what-is-it-and-how-to-fix-it/)

另外還需要先把 `~/ords/global/standalone` 底下的這兩個檔案 `self-signed.key` `self-signed.pem` 刪除

接著跑這個命令, 他好像只能指定 `唯一` 一個, 所以應該是選真實 ip

```
# for linux
# java -jar ords.war --config /home/gg/ords config set standalone.https.host 172.1.23.45

# for 真實 ip
java -jar ords.war --config /home/gg/ords config set standalone.https.host 10.1.23.45
```

最後先把 `ords` 的 web server 重啟

```
java -jar ords.war serve
```

### delete

```
BEGIN
  OAUTH.revoke_client_role(
    p_client_name => 'emp_client',
    p_role_name   => 'emp_role'
  );

  COMMIT;
END;
/

BEGIN
  OAUTH.delete_client(
    p_name => 'emp_client'
  );

  COMMIT;
END;
/
```

```
BEGIN
  ORDS.delete_privilege_mapping(
    p_privilege_name => 'emp_priv',
    p_pattern => '/employees/*'
  );

  COMMIT;
END;
/

BEGIN
  ORDS.delete_privilege (
    p_name => 'emp_priv'
  );

  COMMIT;
END;
/

BEGIN
  ORDS.delete_role(
    p_role_name => 'emp_role'
  );

  COMMIT;
END;
/
```

### ACL 設定
https://oracle-base.com/articles/11g/fine-grained-access-to-network-services-11gr1

ACL 要這樣設定

```
BEGIN
	dbms_network_acl_admin.create_acl (    
	acl         => 'utl_http.xml',         
	description => 'HTTP Access',          
	principal   => 'SYSTEM',               
	is_grant    => TRUE,                   
	privilege   => 'connect',              
	start_date  => null,                   
	end_date    => null                    
	);

	dbms_network_acl_admin.add_privilege (  
	acl        => 'utl_http.xml',           
	principal  => 'SYSTEM',                 
	is_grant   => TRUE,                     
	privilege  => 'resolve',                
	start_date => null,                     
	end_date   => null
	);

	dbms_network_acl_admin.assign_acl (
	acl        => 'utl_http.xml',
	host       => '*'
	);
	
	COMMIT;
END;
/
```

這裡要把 UTL_HTTP 開給使用者
並開 acl, 注意 username 要大寫
不然會噴這樣 ORA-44416: Invalid ACL: Unresolved principal ‘testuser1’

```
GRANT EXECUTE ON UTL_HTTP TO testuser1;

BEGIN
	dbms_network_acl_admin.add_privilege (  
	acl        => 'utl_http.xml',           
	principal  => 'TESTUSER1',                 
	is_grant   => TRUE,                     
	privilege  => 'connect',                
	start_date => null,                     
	end_date   => null
	);
	
	COMMIT;
END;
/
```

最後用 TESTUSER1 呼叫個外部的 api 看看, 如果要 https 還要設定錢包, 這裡就懶得弄了


```
SELECT UTL_HTTP.REQUEST('http://jsonplaceholder.typicode.com/comments?postId=1') DOC 
FROM DUAL;
```

### PL/SQL 用核發的 access token 呼叫 ords 的 api
code 如下, 也是雷了半天

```
declare
  l_http_request   utl_http.req;
  l_http_response  utl_http.resp;
  l_text           varchar2(32767);
begin
  -- Make a HTTP request and get the response.
  --l_http_request  := utl_http.begin_request('http://localhost:8080/ords/hr/rest-v9/employees/');
  l_http_request  := utl_http.begin_request('http://172.24.141.71:8080/ords/hr/rest-v9/employees/');
  UTL_HTTP.set_header(l_http_request, 'Authorization', 'Bearer _PccQv26yDHZcovbgXhpzg');

  l_http_response := utl_http.get_response(l_http_request);

  -- Loop through the response.
  begin
    loop
      utl_http.read_text(l_http_response, l_text, 32766);
      dbms_output.put_line(l_text);
    end loop;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(l_http_response);
  end;
exception
  when others then
    utl_http.end_response(l_http_response);
    raise;
end;
/
```

這裡我測如果用 localhost 的話會噴這樣, 好像只能用 ip 太專業不懂 XD?

```
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>400 Bad Request</TITLE>
</HEAD><BODY><H1>Bad Request</H1>
The HTTP client sent a request that this server could not understand.</BODY></HTML>
```

### PL/SQL 拿 ords client_credentials 核發的 access token

拿 token 要用 client_id client_secret 先組 base64 出來, 可以參考[這篇](https://stackoverflow.com/questions/34637761/how-to-pass-credentials-and-download-file-from-a-url-on-11g-oracle-pl-sql)

```
select utl_raw.cast_to_varchar2(
		utl_encode.base64_encode(
			utl_i18n.string_to_raw('B5NgfoBVLS1ndtq4dRJ0Ew..:fPkowxijRbTmvWwM5Pr9Bw..', 'AL32UTF8')
		)
	)
from dual;
```

但是組完後會發現一個問題, 他的字串會有換行符號, 如果這樣丟的話會發生錯誤

“QjVOZ2ZvQlZMUzFuZHRxNGRSSjBFdy4uOmZQa293eGlqUmJUbXZXd001UHI5Qncu
Lg==”

實際上應該要長這樣
“QjVOZ2ZvQlZMUzFuZHRxNGRSSjBFdy4uOmZQa293eGlqUmJUbXZXd001UHI5QncuLg==”

所以可以用以下方式得到一個正確的

```
select
	REPLACE(
		REPLACE(
			utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_i18n.string_to_raw('B5NgfoBVLS1ndtq4dRJ0Ew..:fPkowxijRbTmvWwM5Pr9Bw..', 'AL32UTF8'))
		), CHR(10), ''), CHR(13), '')
from dual;
```

最後參考[這篇](https://intelligent-advisor.com/main/authenticating-oracle-intelligent-advisor-rest-api-from-sql/) 就可以把 token 印出來囉, 灑花 ~

```
DECLARE
    http_req         utl_http.req;
    http_resp        utl_http.resp;
    l_authresponse   utl_http.resp;
    l_authraw        VARCHAR2(32767);
    l_authreqbody    VARCHAR2(2000);
    v_url            VARCHAR2(2000) := 'http://172.24.141.71:8080/ords/hr/oauth/token';
	content          VARCHAR2(4000) := 'grant_type=client_credentials';
BEGIN 
    http_req := utl_http.begin_request(v_url, 'POST');
    utl_http.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
    --utl_http.set_header(http_req, 'Authorization', 'Basic ' || 'QjVOZ2ZvQlZMUzFuZHRxNGRSSjBFdy4uOmZQa293eGlqUmJUbXZXd001UHI5QncuLg==');	

	utl_http.set_header(http_req, 'Authorization',
	'Basic ' || 
	REPLACE(
		REPLACE(
			utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_i18n.string_to_raw('B5NgfoBVLS1ndtq4dRJ0Ew..:fPkowxijRbTmvWwM5Pr9Bw..', 'AL32UTF8'))
		), CHR(10), ''), CHR(13), '')
	);
	
    utl_http.set_header(http_req, 'Content-Length', length(content));
    utl_http.write_text(http_req, content);
    dbms_output.put_line(content);
    l_authresponse := utl_http.get_response(http_req);
    utl_http.read_text(l_authresponse, l_authraw);
    dbms_output.put_line(l_authraw);
    utl_http.end_response(l_authresponse);
END;
/
```


### PL/SQL 用 authorization code 的 refresh token 取得 access token

這也雷滿久的, 也沒啥文件 QQ
如果是 `authorization code` 的流程會給你 `refresh token`, 如果 `client_credentials` 則不會給你

這裡一樣先到 `http://localhost:8080/ords/hr/oauth/auth?response_type=code&client_id=HUQp7hr7ZAyrnRpOPBbKpw..&state=xxoo` 換 code
然後用 curl 拿 code 換 token

```
curl -i -k --user HUQp7hr7ZAyrnRpOPBbKpw..:DBxFUd6GawcrXWrvokg94g.. --data "grant_type=authorization_code&code=FeCS-XY0HhYNFAQ6u_K0Uw" http://10.1.54.180:8080/ords/hr/oauth/token

{"access_token":"lYKKov2fbVXfCk6IbeBhFQ","token_type":"bearer","expires_in":3600,"refresh_token":"PKJpJDhBOMfXEWpqtTncKw"}
```

接著要得到 refresh token 他的 curl 是這樣打的, 他也是用 post `application/x-www-form-urlencoded` 的方式來得到 token

```
curl --location 'http://localhost:8080/ords/hr/oauth/token' \
--header 'Authorization: Basic SFVRcDdocjdaQXlyblJwT1BCYktwdy4uOkRCeEZVZDZHYXdjclhXcnZva2c5NGcuLg==' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=refresh_token' \
--data-urlencode 'refresh_token=PKJpJDhBOMfXEWpqtTncKw'
```

要記得他跟 client_credentials 發的 client_id , client_secret 是不同低, 可以查這張表看是否已經建立

```
select * from user_ords_clients;
```

以下為 PL/SQL 範例, 應該是不太會用到, 就玩看看 lol
這裡還要注意如果用 `&` PL/SQL 會當成要輸入變數值, 所以先用 `SET DEFINE OFF` 關閉他

```
SET DEFINE OFF;
DECLARE
    http_req         utl_http.req;
    http_resp        utl_http.resp;
    l_authresponse   utl_http.resp;
    l_authraw        VARCHAR2(32767);
    l_authreqbody    VARCHAR2(2000);
    v_url            VARCHAR2(2000) := 'http://172.24.141.71:8080/ords/hr/oauth/token';
	content          VARCHAR2(4000) := 'grant_type=refresh_token&refresh_token=PKJpJDhBOMfXEWpqtTncKw';
BEGIN 
    http_req := utl_http.begin_request(v_url, 'POST');
    utl_http.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
    --utl_http.set_header(http_req, 'Authorization', 'Basic ' || 'SFVRcDdocjdaQXlyblJwT1BCYktwdy4uOkRCeEZVZDZHYXdjclhXcnZva2c5NGcuLg==');	

	utl_http.set_header(http_req, 'Authorization',
	'Basic ' || 
	REPLACE(
		REPLACE(
			utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_i18n.string_to_raw('HUQp7hr7ZAyrnRpOPBbKpw..:DBxFUd6GawcrXWrvokg94g..', 'AL32UTF8'))
		), CHR(10), ''), CHR(13), '')
	);
	
    utl_http.set_header(http_req, 'Content-Length', length(content));
    utl_http.write_text(http_req, content);
    dbms_output.put_line(content);
    l_authresponse := utl_http.get_response(http_req);
    utl_http.read_text(l_authresponse, l_authraw);
    dbms_output.put_line(l_authraw);
    utl_http.end_response(l_authresponse);
END;
/
```

### c# call ords

他的 client credentials 是用 username:password 這種模式, 整個詭異 XD

可以看[這篇](https://www.jmjcloud.com/blog/ords-securing-services-using-oauth2-2-legged)

```
[ApiController]
[Route("[controller]")]
public class EmpController : ControllerBase
{

    private readonly ILogger<EmpController> _logger;

    public EmpController(ILogger<EmpController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    [Route("GetEmp")]
    public async Task<IActionResult> Get()
    {
        using HttpClient http = new();
        http.DefaultRequestHeaders.Add("Authorization", "Bearer uPjC3RgmEoQ02whkst0Wug");
        var resp = await http.GetAsync("http://localhost:8080/ords/hr/rest-v9/employees/");
        var json = await resp.Content.ReadAsStringAsync();
        Console.WriteLine(json);
        return Ok(json);
    }

    [HttpGet]
    [Route("GetToken")]
    public async Task<IActionResult> GetToken()
    {
        using HttpClient client = new();

        string url = "http://localhost:8080/ords/hr/oauth/token";

        // 設定用戶名和密碼
        var username = "B5NgfoBVLS1ndtq4dRJ0Ew..";
        var password = "fPkowxijRbTmvWwM5Pr9Bw..";
        var byteArray = Encoding.ASCII.GetBytes($"{username}:{password}");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));
        var content = new StringContent("grant_type=client_credentials", Encoding.UTF8, "application/x-www-form-urlencoded");

        // 發送 POST 請求
        HttpResponseMessage response = await client.PostAsync(url, content);

        // 確認請求成功
        response.EnsureSuccessStatusCode();

        // 讀取響應內容為字串
        string jsonResponse = await response.Content.ReadAsStringAsync();

        // 顯示取得的 JSON
        Console.WriteLine(jsonResponse);

        return Ok(jsonResponse);
    }

    [HttpGet]
    [Route("GetRefreshToken")]
    public async Task<IActionResult> GetRefreshToken()
    {
        using HttpClient client = new();

        string url = "http://localhost:8080/ords/hr/oauth/token";

        // 設定用戶名和密碼
        var username = "B5NgfoBVLS1ndtq4dRJ0Ew..";
        var password = "fPkowxijRbTmvWwM5Pr9Bw..";
        var byteArray = Encoding.ASCII.GetBytes($"{username}:{password}");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));
        var content = new StringContent(
            "grant_type=refresh_token&refresh_token=0BgjL6JmXB7H22j2iSYEpA", 
            Encoding.UTF8, 
            "application/x-www-form-urlencoded");

        // 發送 POST 請求
        HttpResponseMessage response = await client.PostAsync(url, content);

        // 確認請求成功
        response.EnsureSuccessStatusCode();

        // 讀取響應內容為字串
        string jsonResponse = await response.Content.ReadAsStringAsync();

        // 顯示取得的 JSON
        Console.WriteLine(jsonResponse);

        return Ok(jsonResponse);

    }
		
}
```

## 其他

### 時區

可以參考[這裡](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/24.2/orddg/developing-REST-applications.html#GUID-2AFE28A3-26D3-4600-8BEB-E130DFAA25DB)
如果是 windows 需要設定環境變數, 這篇 有說明各種 java 關於 `OPTIONS` 的區別
變數 => `_JAVA_OPTIONS`
值 => `-Duser.timezone=Asia/Taipei`

linux 則是啟動時直接下 `java -Duser.timezone=Asia/Taipei -jar ords.war serve` 就搞定惹
或是設定環境變數 `JVM_TIMEZONE`

```
vim ~/.bashrc
export JVM_TIMEZONE="Asia/Taipei"
```

### windows 安裝

後來發現如果 windows 安裝他好像會自動偵測 `tnsnames.ora` 然後就會直接出現在選單裡

C:\Users\YOURUSERNAME\Oracle\network\admin\tnsnames.ora

```
docker11g =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 49161))
	(CONNECT_DATA = 
		(SERVICE_NAME=xe))
  )
```
