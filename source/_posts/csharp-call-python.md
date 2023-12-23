---
title: csharp call python
date: 2023-06-02 18:47:29
tags:
- python
- csharp
---
&nbsp;
<!-- more -->

### 環境準備
主要參考[這篇](https://somegenericdev.medium.com/calling-python-from-c-an-introduction-to-pythonnet-c3d45f7d5232) , 不過雷一堆
我自己是用 `anaconda` 作為 `python` 環境 , 首先要確認自己是 `x86` 還是 `x64`
```
import platform
print(platform.architecture())
```

接著新增一個 `net4.8` 的 `console` 然後安裝 [pythonnet](https://github.com/pythonnet/pythonnet)
然後開啟 `configuration manager` 假設你是 `x64` 複製一份給 `x64` 然後記得要切換到 `x64`
接著照著以下程式碼設定應該就可以動了
這裡面最雷的部分應該就是要額外設定路徑 , 可以參考 [這篇](https://stackoverflow.com/questions/51864404/pythonnet-import-error-visbrain-in-anaconda-3)
```
using Python.Runtime;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleAppPy
{
    internal class Program
    {
        static void Main(string[] args)
        {
            // Modify Path
            //string path = @"C:\tools\Anaconda3\envs;" + Environment.GetEnvironmentVariable("PATH", EnvironmentVariableTarget.Machine);

            // Set Path
            //Environment.SetEnvironmentVariable("PATH", path, EnvironmentVariableTarget.Process);

            // Set PythonHome
            Environment.SetEnvironmentVariable("PYTHONHOME", @"C:\tools\Anaconda3", EnvironmentVariableTarget.Process);

            // Set PythonPath
            // ONLY SET THIS IF YOU ARE SURE WHAT YOU ARE DOING
            Environment.SetEnvironmentVariable("PYTHONPATH", @"C:\tools\Anaconda3\Lib", EnvironmentVariableTarget.Process);


            //Runtime.PythonDLL = @"C:\\tools\\Anaconda3\\python38.dll";
            //PythonEngine.PythonHome = Environment.GetEnvironmentVariable("PYTHONHOME", EnvironmentVariableTarget.Process);

            //string pythonDll = @"C:\\tools\\Anaconda3\\python38.dll";
            //Environment.SetEnvironmentVariable("PYTHONNET_PYDLL", pythonDll);

            Runtime.PythonDLL = @"C:\\tools\\Anaconda3\\python38.dll";
            //Runtime.PythonDLL = @"C:\tools\Anaconda3\envs\excel\python311.dll";
            PythonEngine.Initialize();
            using (Py.GIL())
            {
                PythonEngine.RunSimpleString(@"print(""helloworld"")");
            }
        }
    }
}
```

### 串接 ddddocr

```
using Python.Runtime;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleAppPy
{
    internal class Program
    {
        static void Main(string[] args)
        {
            ConfigPythonPath();
            string result = "";
            var text = RunPythonCodeAndReturn(
@"
import ddddocr

ocr = ddddocr.DdddOcr()
with open('C:\captcha_images\img1.png', 'rb') as f:
    img_bytes = f.read()
res = ocr.classification(img_bytes)
",
"res");


            Console.WriteLine("text:" + text.ToString().ToUpper());
        }

        static void ConfigPythonPath()
        {
            // Modify Path
            //string path = @"C:\tools\Anaconda3\envs;" + Environment.GetEnvironmentVariable("PATH", EnvironmentVariableTarget.Machine);

            // Set Path
            //Environment.SetEnvironmentVariable("PATH", path, EnvironmentVariableTarget.Process);

            // Set PythonHome
            //Environment.SetEnvironmentVariable("PYTHONHOME", @"C:\tools\Anaconda3", EnvironmentVariableTarget.Process);
            Environment.SetEnvironmentVariable("PYTHONHOME", @"C:\tools\Anaconda3\envs\excel", EnvironmentVariableTarget.Process);

            // Set PythonPath
            // ONLY SET THIS IF YOU ARE SURE WHAT YOU ARE DOING
            //Environment.SetEnvironmentVariable("PYTHONPATH", @"C:\tools\Anaconda3\Lib", EnvironmentVariableTarget.Process);
            Environment.SetEnvironmentVariable("PYTHONPATH", @"C:\tools\Anaconda3\envs\excel\Lib", EnvironmentVariableTarget.Process);


            //Runtime.PythonDLL = @"C:\\tools\\Anaconda3\\python38.dll";
            //PythonEngine.PythonHome = Environment.GetEnvironmentVariable("PYTHONHOME", EnvironmentVariableTarget.Process);

            //string pythonDll = @"C:\\tools\\Anaconda3\\python38.dll";
            //Environment.SetEnvironmentVariable("PYTHONNET_PYDLL", pythonDll);

            //Runtime.PythonDLL = @"C:\\tools\\Anaconda3\\python38.dll";
            Runtime.PythonDLL = @"C:\tools\Anaconda3\envs\excel\python311.dll";


        }
        public static string RunPythonCodeAndReturn(string pycode, string returnedVariableName) {
            string returnedVariable = "";
            PythonEngine.Initialize();
            using (Py.GIL())
            {
                using (var scope = Py.CreateScope())
                {
                    scope.Exec(pycode);
                    returnedVariable=scope.Get<string>(returnedVariableName);
                }
            }
            return returnedVariable;
        }


    }
}

```


### 搭配 Puppeteer ddddocr 破解驗證碼

首先要先把 img 轉為 base64
先用 `WaitForSelectorAsync` 取得 `img` 標籤 , 接著用 `EvaluateFunctionAsync` 把 js 插進去
用 canvas 建立出來的 base64 預設會帶有 `image/png;base64,` , 所以要把它去除
```
                        var img = await page.WaitForSelectorAsync(@"img");
                        var jsCode =
@"() => {
	var img = document.querySelector('img');
	var canvas = document.createElement('canvas');
	canvas.width = img.width;
	canvas.height = img.height;
	var ctx = canvas.getContext('2d');
	ctx.drawImage(img, 0, 0);
	var base64 = canvas.toDataURL();
    var strOnly = canvas.toDataURL('image/png').split(';base64,')[1]
	return strOnly;
}";

                        var b64 = await img.EvaluateFunctionAsync<string>(jsCode);
```

接著回顧老外的 [說明](https://somegenericdev.medium.com/calling-python-from-c-an-introduction-to-pythonnet-c3d45f7d5232) 定義一個這樣的 function
```
        public static object RunPythonCodeAndReturn(string pycode, object parameter, string parameterName, string returnedVariableName)
        {
            object returnedVariable = new object();
            PythonEngine.Initialize();
            using (Py.GIL())
            {
                using (var scope = Py.CreateScope())
                {
                    scope.Set(parameterName, parameter.ToPython());
                    scope.Exec(pycode);
                    returnedVariable = scope.Get<object>(returnedVariableName);
                }
            }
            return returnedVariable;
        }
```


接著在 c# 宣告 `b64` 這個變數 , 讓他承接 js 回傳的 base64 字串結果
然後再把 `b64` 丟入 `python` 內去辨識就大功告成

```
                        var b64 = await img.EvaluateFunctionAsync<string>(jsCode);

                        Console.WriteLine(b64);
                        var deText = RunPythonCodeAndReturn(
@"
import ddddocr
import base64
imgdata = base64.b64decode(b64)
ocr = ddddocr.DdddOcr()
res = ocr.classification(imgdata)
print(res)

",
            b64, "b64", "res");

```


程式碼大概長這樣
```
        static async Task<string> Crack(string username, string pwd)
        {
            string result = "";
            try
            {
                //await new BrowserFetcher( ).DownloadAsync( BrowserFetcher.DefaultRevision );
                using (var browser = await Puppeteer.LaunchAsync(new LaunchOptions()
                {
                    Headless = false,
                    ExecutablePath = @"C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
                }))
                {
                    using (var page = await browser.NewPageAsync())
                    {
                        await page.GoToAsync("http://yourip/index.php");
                        await page.WaitForSelectorAsync(@"input[name='password']");
                        await page.FocusAsync("input[name='password']");
                        await page.Keyboard.TypeAsync(pwd);
                        var img = await page.WaitForSelectorAsync(@"img");
                        var jsCode =
@"() => {
	var img = document.querySelector('img');
	var canvas = document.createElement('canvas');
	canvas.width = img.width;
	canvas.height = img.height;
	var ctx = canvas.getContext('2d');
	ctx.drawImage(img, 0, 0);
	var base64 = canvas.toDataURL();
    var strOnly = canvas.toDataURL('image/png').split(';base64,')[1]
	return strOnly;
}";

                        var b64 = await img.EvaluateFunctionAsync<string>(jsCode);

                        Console.WriteLine(b64);
                        var deText = RunPythonCodeAndReturn(
@"
import ddddocr
import base64
imgdata = base64.b64decode(b64)
ocr = ddddocr.DdddOcr()
res = ocr.classification(imgdata)
print(res)

",
            b64, "b64", "res");

                        await page.FocusAsync("input[name='authcode']");
                        await page.Keyboard.TypeAsync(deText.ToString());
                        await page.ClickAsync("input[name='submit']");
                    }
                }

                return await Task.FromResult(result);
            }
            catch (Exception ex)
            {
                throw;
            }
        }

```

### 破解三民書局驗證碼
特別注意這裡要安裝 7.0 的 PuppeteerSharp 後續的版本不曉得為啥 headless 會掛掉 , 暫時沒研究
大致上重點如下

找出相對應的 html 標籤
```
#Account
#pwd
#HumanPass
button[type="submit"]
#CaptchaImg
```

接著發現他有個 `ReloadCaptchaImg` 方法 , 呼叫後會得到這樣的網址 https://www.sanmin.com.tw/other/captcha/27
可以多打幾個 request , 先自己測試辨識效果看看
```
ReloadCaptchaImg() {
	var a = Math.floor(Math.random() * (100 - 0));
	$('#CaptchaImg').attr('src', '/other/captcha/' + a);
}
```

然後發現他有個雷 , 他的 img size 實際上是 90 * 35 , 可是 html tag 上面是 70 * 34
所以如果插 js 直接用他的長寬下去會發現圖片被裁切掉一個字
```
var img = document.querySelector('#CaptchaImg');
var canvas = document.createElement('canvas');
canvas.width = 90;
canvas.height = 35;
var ctx = canvas.getContext('2d');
ctx.drawImage(img, 0, 0);
var base64 = canvas.toDataURL();
var strOnly = canvas.toDataURL('image/png').split(';base64,')[1]
return strOnly;
```

另外因為 python 有縮排要求 , 所以如果你 format c# 的 code 可能會連同 python 的 code 一起被縮排然後噴得莫名其妙 , 最後程式碼如下
```

        static async Task<string> GetSanMin(string username, string pwd)
        {
            string result = "";
            try
            {
                using (var browser = await Puppeteer.LaunchAsync(new LaunchOptions()
                {
                    Headless = false,
                    ExecutablePath = @"C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
                }))
                {
                    var page = await browser.NewPageAsync();
                    await page.GoToAsync("https://www.sanmin.com.tw/member/login/?ReturnUrl=%2fmember%2findex");


                    await page.WaitForSelectorAsync("#Account");
                    await page.FocusAsync("#Account");
                    await page.Keyboard.TypeAsync(username);
                    Thread.Sleep(3000);

                    await page.WaitForSelectorAsync("#pwd");
                    await page.FocusAsync("#pwd");
                    await page.Keyboard.TypeAsync(pwd);
                    Thread.Sleep(3000);


                    var img = await page.WaitForSelectorAsync(@"#CaptchaImg");
                    var jsCode =
@"() => {
                    	var img = document.querySelector('#CaptchaImg');
                    	var canvas = document.createElement('canvas');
                    	canvas.width = 90;
                    	canvas.height = 35;
                    	var ctx = canvas.getContext('2d');
                    	ctx.drawImage(img, 0, 0);
                    	var base64 = canvas.toDataURL();
                        var strOnly = canvas.toDataURL('image/png').split(';base64,')[1]
                    	return strOnly;
                    }";

                    var b64 = await img.EvaluateFunctionAsync<string>(jsCode);

                    Console.WriteLine(b64);
                    var deText = RunPythonCodeAndReturn(
@"
import ddddocr
import base64
imgdata = base64.b64decode(b64)
ocr = ddddocr.DdddOcr()
res = ocr.classification(imgdata)
print(res)

",
        b64, "b64", "res");

                    await page.FocusAsync("#HumanPass");
                    await page.Keyboard.TypeAsync(deText.ToString());


                    Thread.Sleep(3000);
                    await page.ClickAsync("button[type='submit']");

                    Thread.Sleep(3000);
                }

                return await Task.FromResult(result);
            }
            catch (Exception ex)
            {
                throw;
            }
        }
```
