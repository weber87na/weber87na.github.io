---
title: .net core LINE PAY API v3 筆記
date: 2020-08-03 11:48:27
tags:
- .net core
- line
---
&nbsp;
<!-- more -->
必看影片
https://ithelp.ithome.com.tw/articles/10226877

沙箱申請
https://pay.line.me/tw/developers/techsupport/sandbox/creation?locale=zh_TW

測試訂單
https://pay.line.me/jp/developers/apis/onlineApis?locale=zh_TW

HMACSHA256 算法
https://docs.microsoft.com/zh-tw/dotnet/api/system.security.cryptography.hmacsha256?view=netcore-3.1

公式
Signature = Base64(HMAC-SHA256(Your ChannelSecret, (Your ChannelSecret + URI + RequestBody + nonce)))

程式碼撰寫
先利用json2csharp將json物件轉換為c#類別，這個實際情況類別會更複雜，在此先能跑而已
http://json2csharp.com/
測試json如下
``` json
{
	"amount":4000,
	"currency":"TWD",
	"orderId":"order504ac11a-1888-4410-89b2-75382fef61b3",
"packages":
	[
		{
			"id":"20191011I001","amount":4000,"name":"測試",
			"products":[
				{
				"name":"測試商品","quantity":2,"price":2000
				}
			]
		}
	],
	"redirectUrls":{"confirmUrl":"https://6ddcf789.ngrok.io/confitmUrl",
	"cancelUrl":"https://6ddcf789.ngrok.io/cancelUrl"
	}
}
```
C#類別
``` csharp
public class Product
{
	public string name { get; set; }
	public int quantity { get; set; }
	public int price { get; set; }
}

public class Package
{
	public string id { get; set; }
	public int amount { get; set; }
	public string name { get; set; }
	public List<Product> products { get; set; }
}

public class RedirectUrls
{
	public string confirmUrl { get; set; }
	public string cancelUrl { get; set; }
}

public class LineForm
{
	public int amount { get; set; }
	public string currency { get; set; }
	public string orderId { get; set; }
	public List<Package> packages { get; set; }
	public RedirectUrls redirectUrls { get; set; }
}
```


撰寫核心加密算法
特別注意這邊很重要因為我們使用中文，稍早我們撰寫訂單時故意用中文，如果你訂單用英文不需要UTF8Encoding也可以跑，但是防止錯誤編碼使用UTF8Encoding比較直接了當。
此外要回傳Base64字串

參考
https://stackoverflow.com/questions/12185122/calculating-hmacsha256-using-c-sharp-to-match-payment-provider-example

``` csharp
public static string LinePayHMACSHA256(string key, string message)
{
	System.Text.UTF8Encoding encoding = new System.Text.UTF8Encoding();
	byte[] keyByte = encoding.GetBytes(key);

	HMACSHA256 hmacsha256 = new HMACSHA256(keyByte);

	byte[] messageBytes = encoding.GetBytes(message);
	byte[] hashmessage = hmacsha256.ComputeHash(messageBytes);

	//注意他原本的公式是直接轉為string
	return Convert.ToBase64String(hashmessage);
}
```
這邊要參考先前的公式進行組合
string channelSecret = "你的LINE後台金鑰";

這個nonce要保留下來這樣postman執行時也需要這串
string nonce = Guid.NewGuid().ToString();
可能會長這樣
3ac44b8e-50bc-463e-b48b-bc238f3bb935

這邊是呼要request所以要這樣寫，如果有其他操作要自己替換，特別注意前面不要加http://xxxxx很單純只要寫Uri即可，非完全的網址。
string requestUri = " /v3/payments/request ";

將JSON物件轉換為JSON字串，實際在MVC的話一進來就是JSON物件只要轉換為字串即可。
``` csharp
LineForm json = new LineForm { 
	amount = 4000,
	currency = "TWD",
	orderId = "order504ac11a-1888-4410-89b2-75382fef61b3",
	packages = new List<Package> { 
		new Package{
			id = "20191011I001",
			amount = 4000,
			name = "測試",
			products = new List<Product>{
				new Product{
					name = "測試商品",
					quantity = 2,
					price = 2000
				}
			}
		}
	},
	redirectUrls = new RedirectUrls
	{
		confirmUrl = "https://6ddcf789.ngrok.io/confitmUrl",
		cancelUrl = "https://6ddcf789.ngrok.io/cancelUrl"
	}
};
string form = JsonConvert.SerializeObject(json);
```

參考官方公式組合出來
Signature = Base64(HMAC-SHA256(Your ChannelSecret, (Your ChannelSecret + URI + RequestBody + nonce)))
``` csharp
LineForm json = new LineForm { 
	amount = 4000,
	currency = "TWD",
	orderId = "order504ac11a-1888-4410-89b2-75382fef61b3",
	packages = new List<Package> { 
		new Package{
			id = "20191011I001",
			amount = 4000,
			name = "測試",
			products = new List<Product>{
				new Product{
					name = "測試商品",
					quantity = 2,
					price = 2000
				}
			}
		}
	},
	redirectUrls = new RedirectUrls
	{
		confirmUrl = "https://6ddcf789.ngrok.io/confitmUrl",
		cancelUrl = "https://6ddcf789.ngrok.io/cancelUrl"
	}
};
string form = JsonConvert.SerializeObject(json);
string result = LinePayHMACSHA256(ChannelSecret, ChannelSecret + requestUri + form + nonce);
```

使用postman測試
先選擇POST
並且輸入以下網址https://sandbox-api-pay.line.me/v3/payments/request
接著在Header上填入對應的值
Content-Type
application/json

X-LINE-ChannelId
你的LINE PAY後台商店編號

X-LINE-Authorization-Nonce
先前c#這串保留下來的值
string nonce = Guid.NewGuid().ToString();
3ac44b8e-50bc-463e-b48b-bc238f3bb935

X-LINE-Authorization
使用公式組合出來的base64字串
string result = LinePayHMACSHA256(ChannelSecret, ChannelSecret + requestUri + form + nonce);
iVY2vGxJNJ+ivjxNfa/Rj1QC4SKblidDs0J3NrKNgXU=

接著填寫Body
Body只要填寫訂單的JSON物件即可
body => raw => json
``` javascript
{
	"amount":4000,
	"currency":"TWD",
	"orderId":"order504ac11a-1888-4410-89b2-75382fef61b3",
	"packages":[
		{
			"id":"20191011I001","amount":4000,"name":"測試",
			"products":[{"name":"測試商品","quantity":2,"price":2000}]
		}
	],
	"redirectUrls":
	{
		"confirmUrl":"https://6ddcf789.ngrok.io/confitmUrl",
		"cancelUrl":"https://6ddcf789.ngrok.io/cancelUrl"
	}
}
```


成功以後會出現如下JSON
``` javascript
{
    "returnCode": "0000",
    "returnMessage": "Success.",
    "info": {
        "paymentUrl": {
            "web": "https://sandbox-web-pay.line.me/web/payment/wait?transactionReserveId=S3JROFFsQ2g1Ukd3YzNRTUlQRUJFcFZ2aDdHbEx5T2pVNjh0ZFBPQ3NRNWRhbU9PUHl6dHJ3WklWUHBvTUZ4ag",
            "app": "line://pay/payment/S3JROFFsQ2g1Ukd3YzNRTUlQRUJFcFZ2aDdHbEx5T2pVNjh0ZFBPQ3NRNWRhbU9PUHl6dHJ3WklWUHBvTUZ4ag"
        },
        "transactionId": 2020022600460257310,
        "paymentAccessToken": "877307055245"
    }
}
```

如果1106標頭(Header)資訊錯誤，則表示先前的GUID或是密鑰有寫錯，導致加密錯誤
特別注意當我們取得paymentUrl以後需要使用手機開啟，最好不要用電腦去點開，
否則之後可能會出現錯誤，所以在撰寫時最好申請兩組沙箱來使用，防止錯誤

中文亂碼設定
.net core預設會把中文進行encoding所以輸出時如果看到類似這種\u54C1 output
若真的需要輸出中文方便log或trace可以使用以下設定
``` csharp
var pot = new JsonSerializerOptions{
	PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
	//關鍵點可以輸出中文
	Encoder = System.Text.Encoding.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
};
string order = JsonSerializer.Serialize<LineForm>(json,opt);
```

full example
``` csharp
using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ConsoleCoreLinePay
{
    class Program
    {
        static void Main(string[] args)
        {
            //LINE 後台的 Channel Secret Key
            string channelSecret = "YourSecretKey";

            //LINE PAY 的 Request 網址
            string requestUri = "/v3/payments/request";

            LineForm json = new LineForm
            {
                Amount = 4000,
                Currency = "TWD",
                OrderId = "order504ac11a-1888-4410-89b2-75382fef61b3",
                Packages = new List<Package> {
        new Package{
            Id = "20191011I001",
            Amount = 4000,
            Name = "測試",
            Products = new List<Product>{
                new Product{
                    Name = "測試商品",
                    Quantity = 2,
                    Price = 2000
                }
            }
        }
    },
                RedirectUrls = new RedirectUrls
                {
                    ConfirmUrl = "https://6ddcf789.ngrok.io/confitmUrl",
                    CancelUrl = "https://6ddcf789.ngrok.io/cancelUrl"
                }
            };

            //舊版會讓中文字以中文的方式顯示在 console 上
            //.net core 會把 utf8 字元改成如 python 那種格式 \u6E2C\u8A66\u5546\u54C1
            var opt = new JsonSerializerOptions
            {
                //設定Json屬性為駝峰小寫
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                //設定這樣就會顯示正常的中文
                Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
            };
            string order = JsonSerializer.Serialize<LineForm>(json , opt);


            Console.WriteLine("測試");
            Console.WriteLine("order json :");
            Console.WriteLine(order);

            //一次性的Guid
            //這邊如果需要測試記得保存一下
            string nonce = Guid.NewGuid().ToString();
            Console.WriteLine("Authorization-Nonce:");
            Console.WriteLine(nonce);

            //理論上的公式
            //特別注意toJson的地方範例是用NodeJs將JSON轉為JSON string
            //LinePayHMACSHA256(ChannelSecret, ChannelSecret + requestUri + toJson(form) + nonce);

            string result = LinePayHMACSHA256(
                channelSecret,
                channelSecret + requestUri + order + nonce);
            Console.WriteLine("Authorization:");
            Console.WriteLine(result);
        }

        public static string LinePayHMACSHA256(string key, string data)
        {
            System.Text.Encoding encoding = new System.Text.UTF8Encoding();
            byte[] keyByte = encoding.GetBytes(key);

            HMACSHA256 hmacsha256 = new HMACSHA256(keyByte);

            byte[] messageBytes = encoding.GetBytes(data);
            byte[] hashmessage = hmacsha256.ComputeHash(messageBytes);

            return Convert.ToBase64String(hashmessage);

        }
    }

    public class Product
    {
        [JsonPropertyName("name")]
        public string Name { get; set; }

        [JsonPropertyName("quantity")]
        public int Quantity { get; set; }

        [JsonPropertyName("price")]
        public int Price { get; set; }
    }

    public class Package
    {
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("amount")]
        public int Amount { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; }

        [JsonPropertyName("products")]
        public List<Product> Products { get; set; }
    }

    public class RedirectUrls
    {
        [JsonPropertyName("confirmUrl")]
        public string ConfirmUrl { get; set; }

        [JsonPropertyName("cancelUrl")]
        public string CancelUrl { get; set; }
    }

    public class LineForm
    {
        //[JsonPropertyName("amount")]
        public int Amount { get; set; }

        //[JsonPropertyName("currency")]
        public string Currency { get; set; }

        //[JsonPropertyName("orderId")]
        public string OrderId { get; set; }

        //[JsonPropertyName("packages")]
        public List<Package> Packages { get; set; }

        //[JsonPropertyName("redirectUrls")]
        public RedirectUrls RedirectUrls { get; set; }
    }
}

```
