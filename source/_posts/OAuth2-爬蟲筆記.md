---
title: OAuth2 爬蟲筆記
date: 2025-03-31 05:12:17
tags:
---

&nbsp;
<!-- more -->

## 登入網站
因為是 asp.net mvc 的關係, 所以會有 `__RequestVerificationToken` 這個防偽用的 token
而且他這個表單比較噁心, 需要把 `button` 塞 `login` 這樣才 post 得進去, 雷了老半天 XD
最好先手動在 chrome 登進去的時候看看 payload 丟啥免得後續缺參數
登進去就可以拿 cookie 之類的, 看想拿啥就拿啥
```
var formData = new Dictionary<string, string>
{
	{ "ReturnUrl", "" },
	{ "username", "username" },
	{ "pwd", "password" },

	//這個是關鍵
	{ "button", "login" },
	{ "__RequestVerificationToken", "yourRequestVerificationToken" },
	{ "RememberLogin", "false" },
};
```

## 拿 code
搞 OAuth2 的要訣就是拿 code 換 token
一般 OAuth2 搞的 api 通常都有 `client_id` `client_secret` 不過搞爬蟲又是另外一回是
路徑大概都會是這樣 `xxx-api-url/authorize`
參數類似以下這樣

client_id={client_id}&
redirect_uri={redirect_uri}&
response_type=code&
scope=openid profile xxapi&
nonce=abc123&
state=abc123&
code_challenge={code_challenge}&
code_challenge_method=S256

`nonce` 隨便亂填即可
`state` 隨便亂填即可
`code_verifier` 長度至少為 `43` 到 `128` 個字符的字串, 這個數值很重要, 務必要保留下來後續換 token 會使用到
`code_challenge` SHA256 處理過的 `Base64 String`
`code_challenge_method` 正常都是選 `S256` 其他方法的話就要用其他方式處理, line 好像就是用其他的 method, 有點忘了

以下是用 AI 產的類別, 可以幫我們處理 `code_verifier` `code_challenge` 這兩個參數
```
public class PKCEHelper
{
    // 生成隨機的 code_verifier
    public static string GenerateCodeVerifier(int length = 64)
    {
        var randomBytes = new byte[length];
        using (var rng = new RNGCryptoServiceProvider())
        {
            rng.GetBytes(randomBytes);
        }
        return Convert.ToBase64String(randomBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');
    }

    // 從 code_verifier 生成 code_challenge
    public static string GenerateCodeChallenge(string codeVerifier)
    {
        using (var sha256 = SHA256.Create())
        {
            var codeVerifierBytes = Encoding.ASCII.GetBytes(codeVerifier);
            var hashedBytes = sha256.ComputeHash(codeVerifierBytes);
            return Convert.ToBase64String(hashedBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');
        }
    }
}

```

當 HttpClient 發送出去請求取得 response 後, 可以用 `RequestMessage.RequestUri.ToString()` 取得返回 `code` 的整串網址
然後可以用類似以下程式碼取得 `code` 或其他參數

```
var uri = response.RequestMessage.RequestUri.ToString();

var parsedUrl = uri.Split('?')[1];
// 從 URL 中提取 code 參數
var queryParams = HttpUtility.ParseQueryString(parsedUrl);
var code = queryParams["code"]
```

## 換 token
拿完 code 以後就可以拿來換 token, 這把需要以下參數, 比較重要的就是 `code_verifier` `redirect_uri` 要跟先前拿 code 一致
可以用 `FormUrlEncodedContent` 這個類別來包參數, 最後打出去就大功告成了, 灑花 ~
路徑應該會是 xxx-api-url/token 而且通常可以不用登入直接 post 丟過去正確的話 token 就會回來
```
var postData = new Dictionary<string, string>
	{
		{ "grant_type", "authorization_code" },
		{ "client_id", "your_client_id" },
		{ "code", code },
		{ "code_verifier", "跟拿 code 一樣的 code_verifier" },
		{ "redirect_uri", " 跟拿 coed 一樣的 uri" }
	};
	
var content = new FormUrlEncodedContent(postData);
var response = await client.PostAsync(tokenUrl, content);	
```
