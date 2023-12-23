---
title: FineReport 串接 Line Login 筆記
date: 2023-03-27 18:44:54
tags:
- sso
- line
- finereport
---
![finereport](https://www.finereport.com/jp/wp-content/themes/newsite/banner-try4.png)
<!-- more -->

以下幾個連結務必要看下
https://developers.line.biz/en/docs/line-login/integrate-line-login/#making-an-authorization-request
https://developers.line.biz/en/reference/line-login/
https://developers.line.biz/en/docs/line-login/integrate-line-login/#scopes

## postman 串接 line login
老樣子拿 code 換 token 不過串接 finereport 要用 verify 才可以拿到 email

### 拿 code
首先釐清幾個基本參數用途
`response_type` => `code` 第一步就是先拿到 code 然後換 token
`client_id` => 你的 Line Login Channel ID

`redirect_uri` => 你要 redirect 的地方 , 可能是 `http://127.0.0.1:5500/index.html` 之類的
他這個在後台可以按下 enter 設定多組 , 另外注意看看自己的網址最後有沒有反斜線 , 多個反斜線應該會陣亡
另外在 postman 可以設定把 `Authorize using browser` 打勾 , 然後 line 後台設定 `https://oauth.pstmn.io/v1/callback` 這個 url 就可以導到 postman 給你測試用的

`state` => 防偽造這個隨便填就好
`scope` => 這裡想拿全部訊息 `profile%20openid%20email` 所以填這樣 , 這裡的 `%20` 表示空白
另外想拿 email 的話要在 `OpenID Connect` 讓他 Applied

搞定後會 return 一個類似這樣的網址給你 `http://localhost:5000/index.html?code=234fawTOe1Ps3AWFzFwfeWRG&state=123`

實作 html 程式碼如下
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible"
        content="ie=edge">
    <title></title>
</head>

<body>
    <button id="btn">login</button>
    <script>
        var btn = document.querySelector('#btn');
        btn.addEventListener('click', function () {
            let client_id = 'your client id';
            let redirect_uri = 'http://localhost:5000/index.html';
            let link = 'https://access.line.me/oauth2/v2.1/authorize?';
            link += 'response_type=code';
            link += '&client_id=' + client_id;
            link += '&redirect_uri=' + redirect_uri;
            link += '&state=123';
            link += '&scope=openid%20profile%20email';
            window.location.href = link;
        })
    </script>
</body>

</html>
```

### 換 token
`method` => `post` 
`網址` => `https://api.line.me/oauth2/v2.1/token`
`content type` => `x-www-form-urlencoded`
`grant_type` => `authorization_code`
`code` => `剛剛的 code`
`client_id` => `你的 Line Login Channel ID`
`client_secret` => `你的 Line Login Channel Secret`
`redirect_uri` => `http://127.0.0.1:5500/index.html`

### 取得 userinfo
https://developers.line.biz/en/reference/line-login/#userinfo

`method` => `get or post`
網址 => `https://api.line.me/oauth2/v2.1/userinfo`
`Authorization` => `Bearer 剛剛得到的 token` 老樣子 Bearer 後面記得加上空白才接 `access_token`

這步最後會拿到類似以下結果跟 profile 類似 , 感覺要串 finereport 會有困難 , 建議用 verify 取得 email 當成帳號
```
{
  "sub": "U1234567890abcdef1234567890abcdef",
  "name": "Taro Line",
  "picture": "https://profile.line-scdn.net/0h8pWWElvzZ19qLk3ywQYYCFZraTIdAGEXEhx9ak56MDxDHiUIVEEsPBspMG1EGSEPAk4uP01t0m5G"
}
```

### 取得 email
如果要用 email 當作 finereport 的帳號的話應該使用這個
參考這篇 https://developers.line.biz/en/reference/line-login/#verify-id-token
`method` => `post`
`網址` => `https://api.line.me/oauth2/v2.1/verify`
`content type` => `x-www-form-urlencoded`
`client_id` => `你的 Line Login Channel ID`
`id_token` => `換 token 裡面的 id_token`


## 實戰 finereport 串接 line login

`系統管理` => `單點整合` => `PC端訪問`
`是否開啓單點功能` => `開啟`

### 基本配置
`基本配置`
`動態獲取報表域名` => `我沒勾選`
`報表平台位址` => `http://localhost:8075/webroot/decision`
`保留平台登入頁` => `勾選`
`登入失敗處理邏輯` => 建議一定要勾選 `展示報錯` , 否則很難去 debug
`是否通過cookie傳遞` => `勾選`

### 初始參數
初始參數
`Client ID` => `你的 Line Login Channel ID`
`Client Secret` => `你的 Line Login Channel Secret`
`Grant Type` => `authorization_code`
`Token Name` => `code`
`Scope` => `openid email profile`
`State` => `123` 這裡要注意下 , 因為 line login 裡面一定要設定 state , 務必要填這個選項
認證API位址 , 記得把 client_id 換成你的即可
```
${"https://access.line.me/oauth2/v2.1/authorize?response_type=code&scope=openid email profile&state=123&client_id=12345&redirect_uri=" + requestURL}
```

### 令牌申請
`請求位址` => `POST` => `https://api.line.me/oauth2/v2.1/token`
`請求頭` => `不設定`

`請求體` => `x-www-form-urlencoded` => 新增 6 個參數

`code` => `${code}`
`grant_type` => `authorization_code`
`scope` => `openid email profile`
`redirect_uri` => `http://localhost:8075/webroot/decision`
`client_id` => `你的 Line Login Channel ID`
`client_secret` => `你的 Line Login Secret`

`請求結果` => 新增一個參數 , 這步最為重要 , 這裡設定 `id_token` 之後會把 `id_token` 當作變數傳遞 , 稍後用 verify 才能取得 email
`id_token` => `id_token`

### 使用者資訊
`請求位址` => `POST` => `https://api.line.me/oauth2/v2.1/verify`
`請求頭` => `不設定`

`請求體` => `x-www-form-urlencoded` 新增兩個參數
`id_token` => `${id_token}`
`client_id` => `你的 Line Login Channel ID`

請求結果 => 新增 1 個參數
`fr_login_name` => `email`

因為 line login 會給你類似這樣的 json , 我們拿 email 當作 finereport 的帳號 , 這裡的 name 是指 displayName , 所以可能有空格
```
{
    "iss": "https://access.line.me",
    "sub": "U26f5bcxxx123441",
    "aud": "1653899999",
    "exp": 1679899999,
    "iat": 1679899999,
    "amr": [
        "linesso"
    ],
    "name": "La Di Sai",
    "picture": "https://profile.line-scdn.net/0hyk42FKcKJkQJSzPt1f1ZEzUOKCl-1234567890XXXXXLGIXZnltcXgfeOOOOO-XXXXX",
    "email": "yourmail@gmail.com"
}
```

最後一樣要在 finereport 上面先新增使用者 , 不然會噴找不到 username 的錯誤
`系統管理` => `使用者管理` => `新增使用者` => `帳號`
