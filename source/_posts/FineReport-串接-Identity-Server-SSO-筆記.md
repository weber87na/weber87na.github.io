---
title: FineReport 串接 Identity Server SSO 筆記
date: 2023-03-08 00:01:59
tags:
- finereport
- csharp
---
&nbsp;
![finereport](https://www.finereport.com/jp/wp-content/themes/newsite/banner-try4.png)
<!-- more -->

為了設定這個大概前後折磨了 24 小時有 , 差點精神崩潰 , 他的參數實在太噁心
首先要註冊 , 偏偏我註冊 `FineReport` 他們家官網剛好壞掉 , 註冊注意手機號碼要輸入完整 `0987987987` , 不要因為看到他有 `+886` 就以為會自動幫你轉
接著下載這個 [類Oauth2單點登錄插件](https://help.fanruan.com/finereport/index.php?doc-view-4947.html) , 然後用本地安裝匯入進去 , 我的 `FineReport` 是 11 版 , 記得看下版本

### 重要連結
幾個很重要連結 , 萬一設定錯會頻繁使用到 , 另外 Plugin 文件最好都先看下
`Plugin 文件 1` => `https://help.fanruan.com/finereport/index.php?doc-view-4947.html`
`Plugin 文件 2` => `https://help.fanruan.com/finereport/doc-view-5037.html`
`FineReport 後台` => `http://localhost:8075/webroot/decision`
`FineReport 後台 login` => `http://localhost:8075/webroot/decision/login`

`Identity Server 文件` => `https://docs.duendesoftware.com/identityserver/v6` 這裡用新版的文件看起來比較舒服 , 用法應該都一樣
`Identity Server 個人訊息` => `https://localhost:44310`

`Identity Server Admin 後台` => `https://localhost:44303`
`管理 Identity Server 4 的 client 用` => `https://localhost:44303/Configuration/Clients`

`查 Identity Server endpoint` => `https://localhost:44310/.well-known/openid-configuration` 這次會用到以下三個
`authorization_endpoint 拿 code 用` => `https://localhost:44310/connect/authorize`
`token_endpoint 換 token 用` => `https://localhost:44310/connect/token`
`userinfo_endpoint 得到使用者資訊用` => `https://localhost:44310/connect/userinfo`

`debug 用 , 因為參數很容易設定錯 , 這時就要看他解` => `https://localhost:44303/Log/ErrorsLog`

### Identity Server Clients 參數設定
看這裡之前可以先 [參考](https://www.blog.lasai.com.tw/2022/09/27/IdentityServer4-%E7%AD%86%E8%A8%98/) 我之前寫的筆記 , 不然有點複雜
首先到 `https://localhost:44303/Configuration/Clients` 然後設定

`Add Client` => `Web Application - Server side Authorization Code Flow with PKCE`

`Name`
`Client Id` => `test`
`Client Name` => `test`

`Basics`
`Require Pkce` => `關閉` 如果打開的話會去驗 Pkce
`Allow Access Token Via Browser` => `開啟` 好像 postman 要 debug 要開這個有點忘了
`Allowed Scopes` => `openid` `email` `profile` `roles` 忘了哪個才是得到 name , 如果沒設定的話好像 `FineReport` 會在最後環節噴 error
`Redirect Uris` => `http://localhost:8075/webroot/decision` 導回 `FineReport` 頁面
`Allowed Grant Types` => `authorization_code`
`Client Secrets` => `點 Manage Client Secrets 按鈕` => `Secret Value` => `test` => `Add Client Secret`

`Consent Screen`
`Require Consent` => `開啟`
`Client Uri` => `http://localhost:8075/webroot/decision`

### FineReport 參數設定
設定這裡之前最好先開 postman 起來打看看 , 比較好 debug , 不然會設定到抓狂

`系統管理` => `單點整合` => `PC端訪問`
`是否開啓單點功能` => `開啟`

#### 基本配置
`基本配置`
`動態獲取報表域名` => `我沒勾選`
`報表平台位址` => `http://localhost:8075/webroot/decision`
`保留平台登入頁` => `勾選`
`登入失敗處理邏輯` => 建議一定要勾選 `展示報錯` , 否則很難去 debug
`是否通過cookie傳遞` => `勾選`

#### 初始參數
`初始參數`
`Client ID` => `test`
`Client Secret` => `test`
`Grant Type` => `authorization_code`
`Token Name` => `code`
`Scope` => `openid email profile roles`
`認證API位址` 這個我看了很久才懂 , 他類似變數的概念包他的特殊關鍵字或方法
這裡是 `requestURL` 他會把 `http://localhost:8075/webroot/decision` 傳進去就對了
這個網址主要是跟 `Identity Server` 拿 code , 接著有 code 才能換 token 參考[這裡](https://docs.duendesoftware.com/identityserver/v6/reference/endpoints/authorize/)
```
${"https://localhost:44310/connect/authorize?response_type=code&scope=openid email profile roles&client_id=test&redirect_uri=" + requestURL}
```

#### 令牌申請
`令牌申請`
`請求位址` => `POST` 這裡會去跟 `Identity Server` 拿 token 參考[這裡](https://docs.duendesoftware.com/identityserver/v6/reference/endpoints/token/)
```
https://localhost:44310/connect/token
```

`請求頭` => `不設定`

`請求體` => `x-www-form-urlencoded` => 新增 6 個參數
`code` => `${code}` 這邊的 `${code}` 是最大關鍵 , 正常人不會想到他文件上寫的變數概念可以放在這裡吧
`grant_type` => `authorization_code`
`scope` => `openid email profile roles`
`client_secret` => `test`
`redirect_uri` => `http://localhost:8075/webroot/decision`
`client_id` => `test`

`請求結果` => 新增 1 個參數 , 這裡非常重要他會把這個 `access_token` 變成參數然後傳給最後一步
`access_token` => `access_token`

#### 使用者資訊
`使用者資訊`
`請求位址` => `GET` => `https://localhost:44310/connect/userinfo`
`請求頭` => 新增 1 個參數
`Authorization` => `${"Bearer " + access_token}` 特別留意 Bearer 後面有個空白 , 參考[這裡](https://docs.duendesoftware.com/identityserver/v6/reference/endpoints/userinfo/)

`請求體` => `不設定`

`請求結果` => 新增 1 個參數
`fr_login_name` => `name` 這裡為啥設定 name 呢 , 因為打回來的結果是這樣 , 他會帶入到 `FineReport`
```
{
    "sub": "18bb6b18-39e2-4f63-b7fb-24d5b85dcf89",
    "name": "admin",
    "role": "SkorubaIdentityAdminAdministrator",
    "preferred_username": "admin",
    "email": "admin@skoruba.com",
    "email_verified": true
}
```

另外你的 Identity Server 上面的 user 帳號要在 FineReport 裡面預先設定 , 不然會噴找不到 username 的錯誤
`系統管理` => `使用者管理` => `新增使用者` => `帳號` 

這裡 `帳號` 就是 `fr_login_name` 等價 userinfo 傳回來的 `name`
也有可能 Identity Server 上面定義其他自己的附加屬性當成 FineReport 上面的帳號這個欄位 , 像是下面假設 `account_name` 為實際帳號
就應該要設定 `fr_login_name` => `account_name`
```
{
    "sub": "18bb6b18-39e2-4f63-b7fb-24d5b85dcf89",
    "name": "admin",
    "account_name" : "S123456789" , 
    "role": "SkorubaIdentityAdminAdministrator",
    "preferred_username": "admin",
    "email": "admin@skoruba.com",
    "email_verified": true
}
```
