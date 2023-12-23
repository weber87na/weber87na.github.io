---
title: Line Notify 筆記
date: 2022-09-15 19:00:31
tags: line
---
&nbsp;
<!-- more -->

### 註冊及設定 Line Notify 服務
先到這個 [line notify 官網](https://notify-bot.line.me/zh_TW/)
`Client Id` => `your_client_id`
`Client Secret` => `your_client_secret`

`服務名稱` => `OAuth2Demo`
`服務概要` => `OAuth2Demo`
`服務網址` => `看是要填 local 網址還啥`
`企業／經營者名稱` => `OAuth2Demo`
`負責人姓名` => `你的名稱`
`電子郵件帳號` => `你的 email`
`Callback URL` => 分別加入 `https://oauth.pstmn.io/v1/callback` 及 `http://127.0.0.1:5500/line.html`
`注意這句 Callback 網址最多可登錄5個。請以換行區隔不同的網址。`

### 新方法取得 Access Token
以前在搞的時候記憶中沒這個功能 , 是後來才有的
要打的文件可以看[這裡](https://notify-bot.line.me/doc/en/)
接著開起 Postman , 沒玩過的話先用 `Create Collection` 他這個已經幫你包好了不用自己去組

接著在 `Authorization` => `Type` 選 `OAuth 2.0`
`Add auth data to` => `Request Headers`
`Header Prefix` => `Bearer`
`Grant Type` => `Authorization Code`
`Callback Url` => 把 `Authorize using browser` 勾選起來他會自動帶入 `https://oauth.pstmn.io/v1/callback`
`Auth URL` => `https://notify-bot.line.me/oauth/authorize` `注意他網站上多一個空白很雷`
`Access Token URL` => `https://notify-bot.line.me/oauth/token`
`Client ID` => `your_client_id`
`Client Secret` => `your_secret`
`Scope` => `notify`
`State` => `123 可以隨便你填寫`

點選 `Get New AccessToken` => `接著彈出瀏覽器` => `他會回你 token 類似下面這樣`
https://oauth.pstmn.io/v1/callback?code=abnaaaaso1uLYYG2es3Gft2J1&state=123

注意這裡會彈出要你允許 postman 的視窗 , chrome 有可能封鎖彈出視窗 , 點選一律允許 postman 即可
然後就可以拿到一組 `Access Token` 類似這樣 `z2eUasfwBVsfewc3g9255fEHPiGD2342a2ZVWogN6rURAlQ5123`
最後可以看他 console 給的訊息看看裡面有啥東西 , 做進階操作

### 呼叫 Get 取得 Code
這個要有一個網頁 UI , 所以用 vscode 然後加入以下的頁面

`line.html`
```
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Document</title>
</head>
<body>
    <button id="btn">LineNotify</button>
    <script>
        var btn = document.getElementById('btn');
        btn.addEventListener('click' , function(){
            console.log('click');
            lineNotify();
        });

        function lineNotify() {
            var url = 'https://notify-bot.line.me/oauth/authorize?';
            url += 'response_type=code';
            url += '&client_id=your_client_id';
            url += '&redirect_uri=http://127.0.0.1:5500/line.html';
            url += '&scope=notify';
            url += '&state=123';
            window.location.href = url;
        }
    </script>
</body>
</html>
```

最後他會回你類似這樣 , 然後就可以拿 code 去操作其他動作
http://127.0.0.1:5500/line.html?code=kf0afwfwfebgfjoiSrTkihipUSxeTn6IaS3&state=123


### Post 呼叫 Token
要打的文件可以看[這裡](https://notify-bot.line.me/doc/en/)
最大的重點就是先拿到 code 接著換 token

選 `Post` 網址填寫 => `https://notify-bot.line.me/oauth/token`

切到 `Body` 這個頁籤 , 然後選 `x-www-form-urlencoded` , 加入入以下參數

`grant_type` => `authorization_code`
`code` => `a0j2Ls23N0pIXeHqwfdkfl1HtjcDEH` 剛剛拿到的 code
`redirect_uri` => `http://127.0.0.1:5500/line.html` or `https://oauth.pstmn.io/v1/callback`
`client_id` => `fTrA8awfewfWy3vBhjmn8L3RM`
`client_secret` => `vGpjFY4NPvlTPjw90wefwregTigpdzHkVCRIpafsdfwijwfpGY`

```
{
    "status": 200,
    "message": "access_token is issued",
    "access_token": "2XnGP7fVAmCJHJEFycyMvQSwj2i2eaYWqNqlafwfewqL"
}
```


### Post 傳送訊息

選 `Post` 網址填寫 => `https://notify-api.line.me/api/notify`
`Authorization` 選 `Bearer Token` => `剛剛的 access_token`
切到 `Body` 這個頁籤 , 然後選 `x-www-form-urlencoded` , 加入入以下參數 , 然後 post 即可

`message` => `喇低賽`
