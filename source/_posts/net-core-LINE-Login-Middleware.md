---
title: .net core LINE Login Middleware
date: 2020-08-03 22:23:48
tags:
- line
- .net core
- asp.net core
---
&nbsp;
<!-- more -->
無意中發現以前寫過Line Login的 Middleware 到底是參考來的還是自己寫的已不可考
前端可以參考[董大神](http://studyhost.blogspot.com/2019/04/clinebot30-line-loginemail.html)

後端 Middleware
``` csharp
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Demo.Middlewares
{

    public class LineCallbackResult
    {
        [JsonPropertyName("access_token")]
        public string AccessToken { get; set; }

        [JsonPropertyName("token_type")]
        public string TokenType { get; set; }

        [JsonPropertyName("refresh_token")]
        public string RefreshToken { get; set; }

        [JsonPropertyName("expires_in")]
        public int ExpiresIn { get; set; }

        [JsonPropertyName("scope")]
        public string Scope { get; set; }

        [JsonPropertyName("id_token")]
        public string IdToken { get; set; }
    }

    public class LineLoginMiddleware
    {
        private readonly RequestDelegate _next;
        public LineLoginMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            //取得line login callback 的 url query string code
            string code = context.Request.Query["code"];

            if (code != null)
            {
                //填寫post需要的line login參數
                var dict = new Dictionary<string, string>();
                dict.Add("grant_type", "authorization_code");
                dict.Add("code", code);
                dict.Add("redirect_uri", "http://localhost:5000/index.html");
                dict.Add("client_id", "yourid");
                dict.Add("client_secret", "yourkey");

                //執行post
                using (var client = new HttpClient())
                {
                    //注意utf8防止亂碼
                    client.DefaultRequestHeaders.TryAddWithoutValidation("Content-Type", "application/x-www-form-urlencoded; charset=utf-8");

                    var req = new HttpRequestMessage(
                            HttpMethod.Post,
                        @"https://api.line.me/oauth2/v2.1/token")
                    {
                        Content = new FormUrlEncodedContent(dict)
                    };
                    var res = await client.SendAsync(req);
                    var json = await res.Content.ReadAsStreamAsync();
                    LineCallbackResult callbackResult =
                        await JsonSerializer.DeserializeAsync<LineCallbackResult>(json);

                    Console.WriteLine(callbackResult.AccessToken);
                    Console.WriteLine(callbackResult.TokenType);
                    Console.WriteLine(callbackResult.RefreshToken);
                    Console.WriteLine(callbackResult.ExpiresIn);
                    Console.WriteLine(callbackResult.Scope);
                    Console.WriteLine(callbackResult.IdToken);
                    Console.WriteLine("--------------------");

                    //Console.WriteLine(callbackResult.access_token);
                    //Console.WriteLine(callbackResult.token_type);
                    //Console.WriteLine(callbackResult.refresh_token);
                    //Console.WriteLine(callbackResult.expires_in);
                    //Console.WriteLine(callbackResult.scope);
                    //Console.WriteLine(callbackResult.id_token);
                    Console.WriteLine("--------------------");

                    //https://jwt.io/
                    //解析id_token的功能
                    var JwtSecurityToken = new System.IdentityModel.Tokens.Jwt.JwtSecurityToken(callbackResult.IdToken);

                    //打印user的訊息
                    foreach (var claims in JwtSecurityToken.Claims)
                    {
                        Console.WriteLine(@$"{claims.Type} : {claims.Value}");
                    }
                }
            }
            await _next.Invoke(context);
        }
    }
}

```
