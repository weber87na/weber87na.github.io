---
title: .net 6 菲律賓匯率爬蟲
date: 2022-11-16 19:13:34
tags:
- c#
- 爬蟲
---
&nbsp;
<!-- more -->

### 原理分析
工作上同事遇到的問題 , 順手幫忙看看 , 除了三不五時噴出 `503` 的問題外 (可能被 DDoS 或是防止你太過頻繁呼叫) , 基本上沒啥太大困難
這個需求大概就是需要從 [菲律賓網站](https://www.bsp.gov.ph/SitePages/Statistics/exchangerate.aspx) 上抓取匯率 , 難得搞這麼正經的東西 , 第一想到就是爬蟲
所以開啟 chrome `F12` 看看有啥東東 , 秒得出以下結論可以秒抓到台灣的 tr 直接收工一半
```
document.querySelector('#ExRate #tb2 tr:nth-last-child(2)')
```

如果噴 503 會長這樣
```
Service Unavailable - DNS failure
The server is temporarily unable to service your request. Please try again later.
Reference #11.e44ac817.1668595598.24c9e93
```

開 F12 仔細觀察結果會發現其實他是去呼叫 `OData` 的 api 來撈出資料

encode
```
https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange%20Rate')/items?$select=*&$filter=Group%20eq%20%272%27&$orderby=Ordering%20asc
```

沒 encode
```
https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange Rate')/items?$select=*&$filter=Group eq '2'&$orderby=Ordering asc
```

只拿特定的國家幣別及需要的屬性
```
https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange%20Rate')/items?$select=Title,Symbol,EURequivalent,USDequivalent,PHPequivalent,PublishedDate,Modified,Created&$filter=Symbol%20eq%20%27CAD%27%20or%20Symbol%20eq%20%27CNY%27%20or%20Symbol%20eq%20%27EUR%27%20or%20Symbol%20eq%20%27HKD%27%20or%20Symbol%20eq%20%27JPY%27&$orderby=Ordering%20asc
```

### 前端 js 呼叫
因為沒搞過 js call OData Api , 原來是要加上 `xhr.setRequestHeader("Accept", "application/json");` 自己耍白痴又卡一陣子
```
var url = "https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange%20Rate')/items?$select=*&$filter=Group%20eq%20%272%27&$orderby=Ordering%20asc";
const xhr = new XMLHttpRequest();
xhr.open('GET', url);
xhr.setRequestHeader('Accept', 'application/json');
xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
xhr.onload = function(e) {
  if (this.status == 200) {
    console.log('response', this.response);
  }
};
xhr.send();
```

### powershell 撰寫

秘密都知道以後可以丟到 postman 產個 powershell 玩看看 , 他這個 api 預設給 xml , 所以要自己加上 headers 讓他吐 json
這裡不能用 `*` 來 select , 因為他的結果會有兩個 `ID` , 如果要陽春點就設定個排程把 powershell 丟進去看要做啥就收工了
``` powershell
$utf8 = New-Object System.Text.UTF8Encoding $false
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")

# $response = Invoke-RestMethod 'https://www.bsp.gov.ph/_api/web/lists/getByTitle(''Exchange Rate'')/items?$select=*&$filter=Group eq ''2''&$orderby=Ordering asc' -Method 'GET' -Headers $headers
$response = Invoke-RestMethod 'https://www.bsp.gov.ph/_api/web/lists/getByTitle(''Exchange Rate'')/items?$select=Title,Created,Modified,EURequivalent,USDequivalent,PHPequivalent&$filter=Group eq ''2''&$orderby=Ordering asc' -Method 'GET' -Headers $headers
$json = $response | ConvertTo-Json

if (!$response) {
    [System.IO.File]::WriteAllLines("test.json", $json, $utf8)
}
```

另外最好用 powershell 5.x 可以這樣查版本 , 安裝下載可以[參考微軟](https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/docs-conceptual/windows-powershell/wmf/setup/install-configure.md)
```
$PSVersionTable
```

如果噴權限錯誤可以用 admin 執行這句
```
Set-ExecutionPolicy RemoteSigned
```

### powershell 撰寫續

寫了都寫了 , 就順便搞看看怎麼連到 Oracle , 反正以前沒玩過 , 主要就是靠 `Oracle.ManagedDataAccess.dll` 其他就跟寫 ado.net 一樣
可以參考[這篇](https://tsql.tech/how-to-read-data-from-oracle-database-via-powershell-without-using-odbc-or-installing-oracle-client-and-import-it-to-sql-server-too/)
比較特別的是對方吐的 api 是 ISO 時間 , 台灣需要 +8 , 因為跟 .net 同源的關係 , 
微軟都處理好了可以這樣寫 `[System.DateTime]::Parse($item.PublishedDate).ToString("yyyy-MM-dd HH:mm:ss")`
另外就是 oracle 要用 `to_date('2022-11-16 16:00:00', 'YYYY-MM-DD HH24:MI:SS')` 日期格式才會正常
```
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
#
# "Title": "JAPAN",
# "Symbol": "JPY",
# "EURequivalent": "0.006893",
# "USDequivalent": "0.007166",
# "PHPequivalent": "0.4116",
# "PublishedDate": "2022-11-16T16:00:00Z",
# "Modified": "2022-11-17T00:45:22Z",
# "Created": "2020-07-16T09:09:16Z"
#
$response = Invoke-RestMethod 'https://www.bsp.gov.ph/_api/web/lists/getByTitle(''Exchange%20Rate'')/items?$select=Title,Symbol,EURequivalent,USDequivalent,PHPequivalent,PublishedDate,Modified,Created&$filter=Symbol eq ''CAD'' or Symbol eq ''CNY'' or Symbol eq ''EUR'' or Symbol eq ''HKD'' or Symbol eq ''JPY''&$orderby=Ordering asc' -Method 'GET' -Headers $headers

if ($response) {
    # 轉換 json 為 powershell 物件
    $json = $response | ConvertTo-Json
    $obj = $json | ConvertFrom-Json

    # 引用 oracle dll
    #https://devblogs.microsoft.com/scripting/use-oracle-odp-net-and-powershell-to-simplify-data-access/
    $OracleDLLPath = "D:\Oracle.ManagedDataAccess.dll"

    #Load Required Types and modules
    # 這裡有 error 不要管他
    Add-Type -Path $OracleDLLPath

    # 設定連線字串
    $datasource = "(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=123.45.67.89)(PORT=1521))(CONNECT_DATA=(SID=TEST))) "

    # 帳號密碼設定
    $username = "test"
    $password = "test"

    #Create the connection string
    $connectionstring = 'User Id=' + $username + ';Password=' + $password + ';Data Source=' + $datasource 

    try {
        # 建立連線
        $con = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($connectionstring)

        # 建立 command 物件
        $cmd = $con.CreateCommand()
        $cmd.CommandTimeout = 3600 #Seconds
        $cmd.FetchSize = 10000000 #10MB

        # 開啟連線
        $con.open()

        # 印出連線訊息
        "Connected to database: {0} running on host: {1} – Servicename: {2} – Serverversion: {3}" -f `
        $con.DatabaseName, $con.HostName, $con.ServiceName, $con.ServerVersion

        # loop 跑 5 筆資料
        ForEach ($item in $obj.value) {
            # 建立 insert 語法
            # 他這個時間應該是 ISO 時間 , 台灣時區需要 +8 powershell 因為是 .net 同源 , 所以已經處理這塊
            # PublishedDate 2022-11-16T16:00:00Z 所以會是台灣時間 2022-11-17 00:00:00
            # Modified 這個好像台灣時間早上會在更新一次 , 不確定你們要用啥
            $insertStatement = 
            "INSERT INTO BANK_RATE (Title, Symbol , PHPequivalent , PublishedDate  ,Modified)
            VALUES('{0}' , '{1}' , {2} , to_date('{3}', 'YYYY-MM-DD HH24:MI:SS') , to_date('{4}', 'YYYY-MM-DD HH24:MI:SS'))
            " -f `
            $item.Title , $item.Symbol , $item.PHPequivalent , [System.DateTime]::Parse($item.PublishedDate).ToString("yyyy-MM-dd HH:mm:ss") , [System.DateTime]::Parse($item.Modified).ToString("yyyy-MM-dd HH:mm:ss")

            # 變換 insert 語法
            $cmd.CommandText = $insertStatement

            # 印出 insert 語法
            $insertStatement

            # 印出屬性
            "Title: {0} , Symbol: {1} , PHPequivalent: {2} , PublishedDate: {3} , Modified: {4}" -f `
            $item.Title , $item.Symbol , $item.PHPequivalent , [System.DateTime]::Parse($item.PublishedDate).ToString("yyyy-MM-dd HH:mm:ss") , [System.DateTime]::Parse($item.Modified).ToString("yyyy-MM-dd HH:mm:ss")

            # 執行新增資料指令
            $effect = $cmd.ExecuteNonQuery()

            "insert {0} row" -f $effect

        }

        # 關閉連線
        $con.Close()
    }
    catch {
        Write-Error ("Cant open connection: {0}`n{1}" -f `
                $con.ConnectionString, $_.Exception.ToString())
    }

    finally {
        if ($con.State -eq 'Open') { $con.close() }
    }
}
```

### 撰寫 api
反正都動了 , 就寫成 .net 6 的 api 看看吧 , 這裡還是用下老朋友 [quicktype](https://app.quicktype.io/?l=csharp) 先把撈回來的 json 產為 c# 類別然後微調
接著寫個 `PHRateController` , 注意需要注入 `IHttpClientFactory` 還有就是用老派的 `Newtonsoft.Json` , 另外 503 or 其他狀況就看自己怎樣去調整囉

`PHRateController`
```
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Net.Http.Headers;

namespace PHRateWebApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PHRateController : ControllerBase
    {

        private readonly ILogger<PHRateController> _logger;
        private readonly IHttpClientFactory _clientFactory;

        public PHRateController(
            ILogger<PHRateController> logger,
            IHttpClientFactory clientFactory)
        {
            _logger = logger;
            _clientFactory = clientFactory;
        }

        [Route(nameof(Get))]
        [HttpGet()]
        public async Task<IActionResult> Get()
        {
            var client = _clientFactory.CreateClient();
            client.DefaultRequestHeaders
                  .Accept
                  .Add(new MediaTypeWithQualityHeaderValue("application/json"));

            //全部匯率
            //https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange%20Rate')/items?$select=*&$orderby=Ordering%20asc
            //

            //decode
            //https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange%20Rate')/items?$select=*&$filter=Group%20eq%20%272%27&$orderby=Ordering%20asc

            //沒 decode
            //https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange Rate')/items?$select=*&$filter=Group eq '2'&$orderby=Ordering asc
            var url = $"https://www.bsp.gov.ph/_api/web/lists/getByTitle('Exchange Rate')/items?$select=*&$filter=Group eq '2'&$orderby=Ordering asc";

            var resp = await client.GetAsync(url);
            if (resp.IsSuccessStatusCode)
            {
                var stream = await resp.Content.ReadAsStringAsync();
                var json = JsonConvert.DeserializeObject<ODataResp>(stream);
                return Ok(json);
            }
            else
            {
                return NotFound();
            }
        }
        
    }


    public class ODataResp
    {
        [JsonProperty("odata.metadata")]
        public Uri OdataMetadata { get; set; }

        [JsonProperty("value")]
        public List<Value> Value { get; set; }
    }

    public class Value
    {
        [JsonProperty("odata.type")]
        public string OdataType { get; set; }

        [JsonProperty("odata.id")]
        public Guid OdataId { get; set; }

        [JsonProperty("odata.etag")]
        public string OdataEtag { get; set; }

        [JsonProperty("odata.editLink")]
        public string OdataEditLink { get; set; }

        [JsonProperty("FileSystemObjectType")]
        public long FileSystemObjectType { get; set; }

        [JsonProperty("Id")]
        public long ValueId { get; set; }

        [JsonProperty("ServerRedirectedEmbedUri")]
        public object ServerRedirectedEmbedUri { get; set; }

        [JsonProperty("ServerRedirectedEmbedUrl")]
        public string ServerRedirectedEmbedUrl { get; set; }

        [JsonProperty("ContentTypeId")]
        public string ContentTypeId { get; set; }

        [JsonProperty("Title")]
        public string Title { get; set; }

        [JsonProperty("ComplianceAssetId")]
        public object ComplianceAssetId { get; set; }

        [JsonProperty("Unit")]
        public string Unit { get; set; }

        [JsonProperty("Symbol")]
        public string Symbol { get; set; }

        [JsonProperty("EURequivalent")]
        public string EuRequivalent { get; set; }

        [JsonProperty("USDequivalent")]
        public string UsDequivalent { get; set; }

        [JsonProperty("PHPequivalent")]
        public string PhPequivalent { get; set; }

        [JsonProperty("Ordering")]
        public long Ordering { get; set; }

        [JsonProperty("Group")]
        public string Group { get; set; }

        [JsonProperty("PublishedDate")]
        public DateTimeOffset PublishedDate { get; set; }

        [JsonProperty("ID")]
        public long Id { get; set; }

        [JsonProperty("Modified")]
        public DateTimeOffset Modified { get; set; }

        [JsonProperty("Created")]
        public DateTimeOffset Created { get; set; }

        [JsonProperty("AuthorId")]
        public long AuthorId { get; set; }

        [JsonProperty("EditorId")]
        public long EditorId { get; set; }

        [JsonProperty("OData__UIVersionString")]
        public string ODataUiVersionString { get; set; }

        [JsonProperty("Attachments")]
        public bool Attachments { get; set; }

        [JsonProperty("GUID")]
        public Guid Guid { get; set; }
    }
}
```

留意需要加上 `builder.Services.AddHttpClient();` 不然無法 work
`Program.cs`
```
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddHttpClient();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.Run();

```

### oracle
本來是不太想搞這個咚咚的 , 不過實在非常好奇 , 加上以前只有在 windows 裝過 oracle 測試環境 , 今天就來玩看看 XD , 沒想到真自虐 `ps: 建議按照順序閱讀 , 否則有可能環節漏掉就陣亡`

#### docker
docker 安裝 oracle 相關可以 [參考這篇](https://www.developersoapbox.com/creating-oracle-database-xe-18c-docker-container/)
首先 pull 這個 oraclelinux 的 image , 因為有 `8.7` 秉持沙雕精神就用它
```
docker pull oraclelinux:8.7
```

接著啟動 container 並且跳進去 , 這裡記得要 mapping 1521 port 等等 sql developer 才可以連
```
docker run -dit --name oracle -p 1521:1521 oraclelinux:8.7
docker exec -it oracle /bin/bash
```

要關掉的話可以這樣下
```
docker stop oracle

#或這樣關閉
#docker container ls -a
#CONTAINER ID   IMAGE             COMMAND       CREATED       STATUS                      PORTS     NAMES
#a4d10c477327   oraclelinux:8.7   "/bin/bash"   9 hours ago   Exited (0) 39 seconds ago             oracle
#docker stop a4d10c477327
```

移除
```
docker container rm a4d
```

#### 安裝 oracle database 21c
安裝無腦檔案
```
dnf install -y oracle-database-preinstall-21c
```

安裝其他會用到的工具 (option)
```
#可能不用 java 如果 orapki 噴找不到 java 才裝
yum install java-1.8.0-openjdk
yum install vim
```

到 oracle [官網下載](https://www.oracle.com/tw/database/technologies/oracle-database-software-downloads.html) 這個 `oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm` 安裝檔 , 丟到內部機器裡面
```
cd /home/oracle
curl -O http://123.45.67.89:5500/oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm
dnf install -y oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm
```

中間會噴這個 error , 需要加入環境變數
```
su: cannot open session: Permission denied
[SEVERE] The su command is not configured properly or the oracle user does not have the required privileges to install the Oracle database. If you are running in a container environment, ensure to set the environment variable ORACLE_DOCKER_INSTALL=true and try again.
error: %prein(oracle-database-ee-21c-1.0-1.x86_64) scriptlet failed, exit status 1

# 開 vim 編輯
vim ~/.bashrc
export ORACLE_DOCKER_INSTALL=true

# reload 讓環境變數生效
source ~/.bashrc
dnf install -y oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm
```

接著執行這串要等一陣子 , 大概 5 - 7 分鐘內 , [聽個 Larissa Liveir](https://www.youtube.com/watch?v=2e-LyJcxhsI)
<iframe width="853" height="480" src="https://www.youtube.com/embed/2e-LyJcxhsI" title="Wicked Game - Larissa Liveir" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

```
/etc/init.d/oracledb_ORCLCDB-21c configure
```

config 好當然要來連線看看 , 預設 sqlplus 在這個底下
```
/opt/oracle/product/21c/dbhome_1/bin
```

設定環境變數
```
vim ~/.bashrc

PATH=/opt/oracle/product/21c/dbhome_1/bin:/home/oracle/.local/bin:/home/oracle/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
export ORACLE_HOME=/opt/oracle/product/21c/dbhome_1/
export ORACLE_SID=ORCLCDB
export ORACLE_BASE=/opt/oracle

source ~/.bashrc
```

看目前監聽狀態
```
lsnrctl status
```

查看 service 狀態
```
service --status-all
```

#### 登入 oracle
用 oracle 帳號進去的話一樣要設定環境變數
```
su - oracle
sqlplus / as sysdba
```

或是跳出以後用 oracle 進去 bash
順帶一提要從 sqlplus 跳走用 ctrl + d
```
docker exec -it --user oracle oracle /bin/bash
sqlplus / as sysdba

#SQL*Plus: Release 21.0.0.0.0 - Production on Tue Nov 22 14:58:39 2022
#Version 21.3.0.0.0
#
#Copyright (c) 1982, 2021, Oracle.  All rights reserved.
#
#
#Connected to:
#Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
#Version 21.3.0.0.0
```

修改密碼
```
ALTER USER SYS IDENTIFIED BY 123456;
ALTER USER SYSTEM IDENTIFIED BY 123456;
```

接著就可以用 sql developer 登入進去
Name => docker-oracle21c
`使用者名稱` => `SYSTEM`
密碼 => `123456`
`主機名稱` => `localhost`
`PORT` => `1521`
`SID` => `ORCLCDB`


設定 ACL
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
END;
```


建立 user 參考[這篇](https://stackoverflow.com/questions/33330968/error-ora-65096-invalid-common-user-or-role-name-in-oracle)
```
sqlplus / as sysdba
create user user1 identified by 1;
grant create session to user1
```

查 http 的 json 剛剛有設定 ACL 所以會正常 , 沒設定會噴 error
```
SELECT UTL_HTTP.REQUEST('http://jsonplaceholder.typicode.com/comments?postId=1') DOC 
FROM DUAL;
```

接著查 https 這時候應該會噴 error `ORA-29024: 憑證驗證失敗`
留意到 url `空白` 要換成 `%20`
```
SELECT UTL_HTTP.REQUEST('https://www.bsp.gov.ph/_api/web/lists/getByTitle(''Exchange%20Rate'')/items?$select=Title,Symbol,EURequivalent,USDequivalent,PHPequivalent,PublishedDate,Modified,Created&$filter=Symbol%20eq%20''CAD''%20or%20Symbol%20eq%20''CNY''%20or%20Symbol%20eq%20''EUR''%20or%20Symbol%20eq%20''HKD''%20or%20Symbol%20eq%20''JPY''&$orderby=Ordering%20asc')
FROM DUAL;

ORA-29273: HTTP 要求失敗
ORA-06512: 在 "SYS.UTL_HTTP", line 1530
ORA-29024: 憑證驗證失敗
ORA-06512: 在 "SYS.UTL_HTTP", line 380
ORA-06512: 在 "SYS.UTL_HTTP", line 1470
ORA-06512: 在 line 1
29273. 00000 -  "HTTP request failed"
*Cause:    The UTL_HTTP package failed to execute the HTTP request.
*Action:   Use get_detailed_sqlerrm to check the detailed error message.
           Fix the error and retry the HTTP request.
```

#### wallet 與憑證設定
建立 wallet [主要參考這篇](https://oracle-base.com/articles/misc/utl_http-and-ssl) 或 [這篇](https://doyensys.com/blogs/how-to-access-https-ssl-url-via-utl-http-using-the-orapki-wallet-command/)
```
cd ~
mkdir wallet
orapki wallet create -wallet /home/oracle/wallet -pwd WalletPasswd123 -auto_login
```

如果密碼不符合規則會噴以下 error 乖乖用複雜的密碼
```
PKI-01002: Invalid password. Passwords must have a minimum length of eight characters and contain alphabetic characters combined with numbers or special characters
```

接著到 [菲律賓匯率網站](https://www.bsp.gov.ph/SitePages/Default.aspx) 下載憑證
點`鎖頭` => `憑證` => `憑證路徑` =>  (注意這裡暴雷卡爆久 , 要點選 root) 這裡是 `Digit Cert` => `檢視憑證` =>
`這時又彈出一個視窗` => `詳細資料` => `複製到檔案`
`彈出精靈視窗` => `下一步` => `Base64 編碼 X.50.9 (.CER)(S)` => `下一步` => 選你要的檔名存檔 , 我用 `phprate_root.cer`


最後加入憑證 好像不吃相對路徑? 會噴 `Unable to read certificate at ~/crt/phprate_root.crt`
```
cd /home/oracle
mkdir crt
cd crt
orapki wallet add -wallet /home/oracle/wallet -trusted_cert -cert "/home/oracle/crt/phprate_root.cer" -pwd WalletPasswd123
```

憑證長這樣懶得下載可以直接複製這串去用即可
```
-----BEGIN CERTIFICATE-----
MIIDxTCCAq2gAwIBAgIQAqxcJmoLQJuPC3nyrkYldzANBgkqhkiG9w0BAQUFADBs
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSswKQYDVQQDEyJEaWdpQ2VydCBIaWdoIEFzc3VyYW5j
ZSBFViBSb290IENBMB4XDTA2MTExMDAwMDAwMFoXDTMxMTExMDAwMDAwMFowbDEL
MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
LmRpZ2ljZXJ0LmNvbTErMCkGA1UEAxMiRGlnaUNlcnQgSGlnaCBBc3N1cmFuY2Ug
RVYgUm9vdCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMbM5XPm
+9S75S0tMqbf5YE/yc0lSbZxKsPVlDRnogocsF9ppkCxxLeyj9CYpKlBWTrT3JTW
PNt0OKRKzE0lgvdKpVMSOO7zSW1xkX5jtqumX8OkhPhPYlG++MXs2ziS4wblCJEM
xChBVfvLWokVfnHoNb9Ncgk9vjo4UFt3MRuNs8ckRZqnrG0AFFoEt7oT61EKmEFB
Ik5lYYeBQVCmeVyJ3hlKV9Uu5l0cUyx+mM0aBhakaHPQNAQTXKFx01p8VdteZOE3
hzBWBOURtCmAEvF5OYiiAhF8J2a3iLd48soKqDirCmTCv2ZdlYTBoSUeh10aUAsg
EsxBu24LUTi4S8sCAwEAAaNjMGEwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQF
MAMBAf8wHQYDVR0OBBYEFLE+w2kD+L9HAdSYJhoIAu9jZCvDMB8GA1UdIwQYMBaA
FLE+w2kD+L9HAdSYJhoIAu9jZCvDMA0GCSqGSIb3DQEBBQUAA4IBAQAcGgaX3Nec
nzyIZgYIVyHbIUf4KmeqvxgydkAQV8GK83rZEWWONfqe/EW1ntlMMUu4kehDLI6z
eM7b41N5cdblIZQB2lWHmiRk9opmzN6cN82oNLFpmyPInngiK3BD41VHMWEZ71jF
hS9OMPagMRYjyOfiZRYzy78aG6A9+MpeizGLYAiJLQwGXFK3xPkKmNEVX58Svnw2
Yzi9RKR/5CYrCsSXaQ3pjOLAEFe4yHYSkVXySGnYvCoCWw9E1CAx2/S6cCZdkGCe
vEsXCS+0yx5DaMkHJ8HSXPfqIbloEpw8nL+e/IBcm2PN7EeqJSdnoDfzAIJ9VNep
+OkuE6N36B9K
-----END CERTIFICATE-----
```


寫錯需要移除可以用這樣
```
#orapki wallet remove -wallet [path] -trusted_cert_all -pwd [pwd]

orapki wallet remove -wallet /home/oracle/wallet -trusted_cert_all -pwd WalletPasswd123
```

如果你的憑證是從 windows 抓來的會有 ^M 符號 [參考](https://serverfault.com/questions/316907/ssl-error-unable-to-read-server-certificate-from-file) , 可以安裝 dos2unix 消除 `要切回 root`
在此沒移除也沒差 oracle 還是可以正常運作
```
# 看看憑證有無 ^M 符號
vim -b /home/oracle/crt/phprate_root.cer
yum install dos2unix
dos2unix phprate_root.cer
```

查 wallet
```
orapki wallet display -wallet /home/oracle/wallet

#Oracle PKI Tool Release 21.0.0.0.0 - Production
#Version 21.3.0.0.0
#Copyright (c) 2004, 2021, Oracle and/or its affiliates. All rights reserved.
#
#Requested Certificates:
#User Certificates:
#Trusted Certificates:
#Subject:        CN=DigiCert High Assurance EV Root CA,OU=www.digicert.com,O=DigiCert Inc,C=US
```

接著測試看看 , 應該就不會噴 error
```
EXEC UTL_HTTP.set_wallet('file:/home/oracle/wallet', 'WalletPasswd123');
SELECT UTL_HTTP.REQUEST('https://www.bsp.gov.ph/_api/web/lists/getByTitle(''Exchange%20Rate'')/items?$select=Title,Symbol,EURequivalent,USDequivalent,PHPequivalent,PublishedDate,Modified,Created&$filter=Symbol%20eq%20''CAD''%20or%20Symbol%20eq%20''CNY''%20or%20Symbol%20eq%20''EUR''%20or%20Symbol%20eq%20''HKD''%20or%20Symbol%20eq%20''JPY''&$orderby=Ordering%20asc')
FROM DUAL;
```


#### 撰寫預存程序
建立以下預存程序 , [參考自此](https://gist.github.com/ser1zw/3757715) , 礙於這個 case 使用 ODATA 所以需要指定回傳的 format 為 json
故追加這句
```
UTL_HTTP.SET_HEADER(request, 'Accept', 'application/json');
```

建立資料表
```
CREATE TABLE WWW_DATA (num NUMBER, dat CLOB)
```

完整 code
```
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
	UTL_HTTP.SET_HEADER(request, 'Accept', 'application/json');
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
```


執行 , 特別注意到此處的 `空白` 需要用 `%20` 進行替換 , 此外單引號要加上 escape , `因為很重要所以再次強調!!`
另外 `set_wallet` 應該每個新的 session 都要去執行才會動
```
EXEC UTL_HTTP.set_wallet('file:/home/oracle/wallet', 'WalletPasswd123');
EXEC WWW_GET('https://www.bsp.gov.ph/_api/web/lists/getByTitle(''Exchange%20Rate'')/items?$select=Title,Symbol,EURequivalent,USDequivalent,PHPequivalent,PublishedDate,Modified,Created&$filter=Symbol%20eq%20''CAD''%20or%20Symbol%20eq%20''CNY''%20or%20Symbol%20eq%20''EUR''%20or%20Symbol%20eq%20''HKD''%20or%20Symbol%20eq%20''JPY''&$orderby=Ordering%20asc')

SELECT *
FROM WWW_DATA 
```

最後查 `WWW_DATA` 可以得到以下 JSON
```
{
    "odata.metadata": "https://www.bsp.gov.ph/_api/$metadata#SP.ListData.Exchange_x0020_RateListItems&$select=Title,Symbol,EURequivalent,USDequivalent,PHPequivalent,PublishedDate,Modified,Created",
    "value": [{
            "odata.type": "SP.Data.Exchange_x0020_RateListItem",
            "odata.id": "cc83ebb5-6b90-4b2e-bb3d-c60c9ce54b17",
            "odata.etag": "\"670\"",
            "odata.editLink": "Web/Lists(guid'6f6c6388-3b31-45f6-b1d4-b77cddb6202b')/Items(34)",
            "Title": "JAPAN",
            "Symbol": "JPY",
            "EURequivalent": "0.006868",
            "USDequivalent": "0.007036",
            "PHPequivalent": "0.4033",
            "PublishedDate": "2022-11-21T16:00:00Z",
            "Modified": "2022-11-22T00:42:35Z",
            "Created": "2020-07-16T09:09:16Z"
        }, {
            "odata.type": "SP.Data.Exchange_x0020_RateListItem",
            "odata.id": "4fa166fa-a5f0-4a82-93c5-68c4bdc9dd1f",
            "odata.etag": "\"664\"",
            "odata.editLink": "Web/Lists(guid'6f6c6388-3b31-45f6-b1d4-b77cddb6202b')/Items(36)",
            "Title": "HONGKONG",
            "Symbol": "HKD",
            "EURequivalent": "0.125089",
            "USDequivalent": "0.128154",
            "PHPequivalent": "7.3450",
            "PublishedDate": "2022-11-21T16:00:00Z",
            "Modified": "2022-11-22T00:42:36Z",
            "Created": "2020-07-16T09:09:16Z"
        }, {
            "odata.type": "SP.Data.Exchange_x0020_RateListItem",
            "odata.id": "192937e0-abdf-459f-9974-c800725d3a6f",
            "odata.etag": "\"661\"",
            "odata.editLink": "Web/Lists(guid'6f6c6388-3b31-45f6-b1d4-b77cddb6202b')/Items(38)",
            "Title": "CANADA",
            "Symbol": "CAD",
            "EURequivalent": "0.725876",
            "USDequivalent": "0.743660",
            "PHPequivalent": "42.6221",
            "PublishedDate": "2022-11-21T16:00:00Z",
            "Modified": "2022-11-22T00:42:36Z",
            "Created": "2020-07-16T09:09:16Z"
        }, {
            "odata.type": "SP.Data.Exchange_x0020_RateListItem",
            "odata.id": "11f3ed23-51f7-4014-9573-c7c58209f946",
            "odata.etag": "\"658\"",
            "odata.editLink": "Web/Lists(guid'6f6c6388-3b31-45f6-b1d4-b77cddb6202b')/Items(48)",
            "Title": "EUROPEAN MONETARY UNION",
            "Symbol": "EUR",
            "EURequivalent": "1.000000",
            "USDequivalent": "1.024500",
            "PHPequivalent": "58.7182",
            "PublishedDate": "2022-11-21T16:00:00Z",
            "Modified": "2022-11-22T00:42:37Z",
            "Created": "2020-07-16T09:09:20Z"
        }, {
            "odata.type": "SP.Data.Exchange_x0020_RateListItem",
            "odata.id": "5f5f3ccc-86e3-4d1d-85c0-76810fe96768",
            "odata.etag": "\"654\"",
            "odata.editLink": "Web/Lists(guid'6f6c6388-3b31-45f6-b1d4-b77cddb6202b')/Items(50)",
            "Title": "CHINA",
            "Symbol": "CNY",
            "EURequivalent": "0.136191",
            "USDequivalent": "0.139528",
            "PHPequivalent": "7.9969",
            "PublishedDate": "2022-11-21T16:00:00Z",
            "Modified": "2022-11-22T00:42:37Z",
            "Created": "2020-07-16T09:09:21Z"
        }
    ]
}
```

萬一噴 503 會長這樣
```
"<HTML><HEAD>
<TITLE>Service Unavailable</TITLE>
</HEAD><BODY>
<H1>Service Unavailable - DNS failure</H1>
The server is temporarily unable to service your request.  Please try again
later.<P>
Reference&#32;&#35;11&#46;e44ac817&#46;1669126316&#46;1354ad7b
</BODY></HTML>
"
```

最後展開 json array , 因為之前有在 sql server 玩過類似的 , 這票函數都長差不多 , 其他 json 操作還有 `json_value` & `json_query` 函數
```
SELECT
    jt.Title,
    jt.Symbol,
    jt.EURequivalent,
    jt.USDequivalent,
    jt.PHPequivalent,
    jt.PublishedDate,
    jt.Modified,
    jt.Created
FROM WWW_DATA d , JSON_TABLE(
    d.dat ,
    '$.value[*]'
    COLUMNS (
        Title VARCHAR2,
        Symbol VARCHAR2,
        EURequivalent NUMBER,
        USDequivalent NUMBER,
        PHPequivalent NUMBER,
        PublishedDate TIMESTAMP,
        Modified TIMESTAMP,
        Created TIMESTAMP
    )
) jt;
```

#### sql developer 設定
oracle sql developer 日期格式可以參考這篇來設定
https://oracledeli.wordpress.com/2013/03/07/sql-developer-date-time-format/

YYYY-MM-DD HH24:MI:SS
YYYY-MM-DD HH24:MI:SSXFF
YYYY-MM-DD HH24:MI:SSXFF TZR

設定 UI 英文的話可以在 `sqldeveloper\sqldeveloper\bin\sqldeveloper.confg` 裡面加上這兩句
```
#change ui
AddVMOption -Duser.language=en 
AddVMOption -Duser.country=US
```

#### pl/sql developer 設定
[PL/SQL Developer 載點](https://www.allroundautomations.com/products/pl-sql-developer/)
Oracle Client 可以在 [這裡下載](https://www.oracle.com/tw/database/technologies/instant-client/winx64-64-downloads.html) 設定可以看 [這裡](https://blog.poychang.net/oracle-client-windows/)

先新增資料夾 `C:\oracle\network\admin`
接著新增 `TNSNAMES.ORA` 加入以下內容
```
ConnectName  = 
  (DESCRIPTION = 
    (ADDRESS = 
      (PROTOCOL = TCP)
      (HOST = 123.45.67.89)
      (PORT = 1521)
    )
    (CONNECT_DATA = 
      (SID = ORCLCDB)
    )
  )
```

接著加入環境變數 `ORACLE_HOME` => `C:\oracle`
開 PL/SQL Developer 設定 `Preferences` => `OCI library` => `C:\oracle\instantclient_11_2\oci.dll` 這樣應該就可以連接到啦

#### vscode
可以看看這個[說明影片](https://www.youtube.com/watch?v=u4hCAMzOTH4)
試起來老樣子難用 , 首先先安裝這個鬼玩意 [Oracle Developer Tools for VS Code (SQL and PLSQL)](https://marketplace.visualstudio.com/items?itemName=Oracle.oracledevtools)
接著在 oracle server 打這句 , 他會 dump 連線的訊息給你
```
tnsping ORCLCDB
#(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 123.45.67.89)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = ORCLCDB)))
```

接著參考[這頁資訊](https://docs.oracle.com/en/database/oracle/developer-tools-for-vscode/getting-started/connecttns.html#GUID-E805A7BA-9706-478F-B400-865BBA2AAD03)
注意看他這段 `~/.vscode/extensions/oracle.oracledevtools-21.3.0/sample/network` 裡面有 sample 給你參考怎麼設定
先在 `C:\Users\YOURNAME\Oracle\network\admin` 新增 `tnsnames.ora`
接著把剛剛 server dump 的那串資訊至貼入 `tnsnames.ora` 大概就長這樣
```
oracle21c = (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 123.45.67.89)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = ORCLCDB)))
```

接著點 `Oracle Explorer` 會出現一個很難用的畫面 , 然後開始設定
Create New Connection 
`Connection Type` => `TNS Alias`

然後他會要你選資料夾
`TNS Admin Location *` => `C:\Users\YOURNAME\Oracle\network\admin`

接著你如果有一堆 alias 他會列出來可以選
`TNS Alias *` => `oracle21c`
`User name *` => `SYSTEM`
`Password` => `123456`
`Connection name *` => `oracle21c`

### 其他 Oracle 疑難雜症

#### failure to open file
後來莫名其妙噴 `ORA-28759: failure to open file` 因為太晚有點恍神 , 後來看看權限發現不小心用 root 去蓋 wallet
```
ll

drwxr-xr-x 1 oracle dba  4096 Nov 25 05:47 ./
drwxr-xr-x 1 root   root 4096 Nov 27  2015 ../
-rw------- 1 oracle dba    13 Nov 25 05:40 .bash_history
-rw-r--r-- 1 oracle dba   220 Apr  9  2014 .bash_logout
-rw-r--r-- 1 oracle dba  3637 Apr  9  2014 .bashrc
-rw-r--r-- 1 oracle dba   675 Apr  9  2014 .profile
drwxr-xr-x 2 root   root 4096 Nov 25 05:47 crt/
drwx------ 2 root   root 4096 Nov 25 05:44 wallet/
```

解法修正為 oracle dba 即可
```
chown -R oracle:dba ./crt/
chown -R oracle:dba ./wallet/
```

另外 12c 會噴 `ora-28860 fatal ssl error` 無解.. 還是乖乖用 21c 吧

#### service 啟動關閉
另外發現如果 docker 把 container 關閉的話 oracle 也是會跟著關閉低 , [參考](https://juanmercadoit.com/2020/04/08/how-to-start-stop-and-restart-database-easy-in-oracle-19/)
```
/etc/init.d/oracledb_ORCLCDB-21c start
/etc/init.d/oracledb_ORCLCDB-21c stop
/etc/init.d/oracledb_ORCLCDB-21c restart
```

#### 沒辦法輸出內容
記得要打開輸出 `SET SERVEROUTPUT ON;`
