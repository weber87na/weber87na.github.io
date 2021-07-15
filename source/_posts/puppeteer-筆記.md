---
title: puppeteer 筆記
date: 2021-01-16 00:28:23
tags:
- csharp
- 爬蟲
---
&nbsp;
<!-- more -->

### csharp D-Link DIR-859 爬蟲
繼之前的取得 IP or MacAddress 又遇到個變態的問題，要抓 D-Link 上面的設備 IP，感覺對這些很陌生，先寫個爬蟲來試看看，以後有更好的方法再換
爬蟲有一堆 lib 可以選擇，這次用 [puppeteer-sharp](https://github.com/hardkoded/puppeteer-sharp) 比較困難點就是要注意操作 ajax or 按鈕這類動作要讓他睡，
此外操作 DOM 的方式也是滿特別的建議要看這個官方的單元測試 [最重要的 example](https://github.com/hardkoded/puppeteer-sharp/blob/master/lib/PuppeteerSharp.Tests/ElementHandleTests/EvaluateFunctionTests.cs)

``` csharp
using PuppeteerSharp;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace ConsoleDIR859
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine( "DIR-859 Get Client IP Example:" );
                string pwd = "your password";
                var ips = GetAllDeviceIP(pwd );
                foreach (var ip in ips.Result) Console.WriteLine( ip );
                Console.WriteLine( "Press Any Key To Exit.." );
                Console.ReadKey( );
            }
            catch (Exception ex)
            {
                Console.WriteLine( ex );
                throw;
            }
        }

        static async Task<string[]> GetAllDeviceIP(string pwd)
        {
            try
            {
                await new BrowserFetcher( ).DownloadAsync( BrowserFetcher.DefaultRevision );
                using (var browser = await Puppeteer.LaunchAsync( new LaunchOptions( )
                {
                    Headless = true
                } ))
                {
                    using (var page = await browser.NewPageAsync( ))
                    {
                        await page.GoToAsync( "http://192.168.0.1/info/Login.html" );
                        await page.WaitForSelectorAsync( "#admin_Password" );
                        await page.FocusAsync( "#admin_Password" );
                        Thread.Sleep( 500 );
                        await page.Keyboard.TypeAsync( pwd );
                        await page.ClickAsync( "#logIn_btn" );
                        var result = await page.WaitForNavigationAsync( );

                        //var home = result.TextAsync( );
                        //Console.WriteLine(home);
                        //Console.WriteLine( result.Url );

                        var resp = await page.GoToAsync( result.Url );
                        Thread.Sleep( 3000 );
                        await page.ClickAsync( "#client_image" );

                        Thread.Sleep( 1000 );
                        string content = await page.GetContentAsync( );

                        //Console.WriteLine( content );
                        //File.WriteAllText( "context.html" ,content  );
                        

                        //參考自官方單元測試
                        //https://github.com/hardkoded/puppeteer-sharp/blob/master/lib/PuppeteerSharp.Tests/ElementHandleTests/EvaluateFunctionTests.cs

                        var clientItems = await page.QuerySelectorAsync( "#Client_items" );
                        var ips = await clientItems.QuerySelectorAllHandleAsync( ".client_IPv4Address" )
                            .EvaluateFunctionAsync<string[]>( "nodes => nodes.map(n => n.innerText)" );

                        return ips;
                    }
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}

```

### java CheckIn
無聊寫個 java 版本的運用 , 主要使用這個 lib [jvppeteer](https://github.com/fanyong920/jvppeteer) , 寫起來跟 .net 版本的有點不太一樣 , 好像更無腦

先在 pom.xml 加入這段安裝套件
```
<dependencies>
	<dependency>
		<groupId>io.github.fanyong920</groupId>
		<artifactId>jvppeteer</artifactId>
		<version>1.1.3</version>
	</dependency>
</dependencies>
```

撰寫 code
```
package com.company;

import com.ruiyun.jvppeteer.core.Puppeteer;
import com.ruiyun.jvppeteer.core.browser.Browser;
import com.ruiyun.jvppeteer.core.browser.BrowserFetcher;
import com.ruiyun.jvppeteer.core.page.ElementHandle;
import com.ruiyun.jvppeteer.core.page.JSHandle;
import com.ruiyun.jvppeteer.core.page.Page;
import com.ruiyun.jvppeteer.options.LaunchOptions;
import com.ruiyun.jvppeteer.options.LaunchOptionsBuilder;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutionException;

public class Main {

    public static void main(String[] args) throws IOException, ExecutionException, InterruptedException {

        Page page = LoadPage();

        //量體溫
        health(page);

        //上班打卡
        //checkIn(page);

        //下班打卡
        //checkOut(page);
    }

    public static Page LoadPage() throws IOException, ExecutionException, InterruptedException {
        String path = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
        ArrayList<String> argList = new ArrayList<>();

        //BrowserFetcher.downloadIfNotExist(null);
        LaunchOptions options = new LaunchOptionsBuilder().withArgs(argList).withHeadless(false).withExecutablePath(path).build();
        argList.add("--no-sandbox");
        argList.add("--disable-setuid-sandbox");
        Browser browser = Puppeteer.launch(options);
        Page page = browser.newPage();
		Strin url = "http://127.0.0.1:5500/index.html";
        page.goTo(url);
        return page;
    }


    public static void health(Page page) throws ExecutionException, InterruptedException {
        Thread.sleep(5000);
        List<String> select = page.select("select", Collections.singletonList("number:1"));
        for (String s : select) {
            System.out.println(s);
        }
    }

    public static void checkIn(Page page) throws ExecutionException, InterruptedException {
        Thread.sleep(2000);
        ElementHandle btn = page.$(".checkIn");
        String text = btn.getProperty("textContent").toString();
        System.out.println(text);
		btn.click();
    }

    public static void checkOut(Page page) throws ExecutionException, InterruptedException {
        Thread.sleep(2000);
        ElementHandle btn = page.$(".checkOut");
        String text = btn.getProperty("textContent").toString();
        System.out.println(text);
		btn.click();
    }
}

```

### csharp CheckIn
需要注意有可能會殘留一堆的 browser 在處理程序上應該是要呼叫這句關掉 `await browser.CloseAsync` 體驗上反而 java 版本比較好寫
```
using PuppeteerSharp;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace CheckInCrawler
{
    class Program
    {

		static string url = "http://127.0.0.1:5500/index.html";

        static void Main( string[] args )
        {
            try
            {

                if (args[0]?.ToUpper() == "CheckIn".ToUpper())
                {
                    CheckIn().Wait();
                }

                if (args[0]?.ToUpper() == "CheckOut".ToUpper())
                {
                    CheckOut().Wait();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine( "Error" );
                Console.WriteLine( ex );
            }

            Console.ReadLine();
        }

        static async Task Health()
        {
            await new BrowserFetcher().DownloadAsync( BrowserFetcher.DefaultRevision );
            var browser = await Puppeteer.LaunchAsync( new LaunchOptions
            {
                Headless = false
            } );
            var page = await browser.NewPageAsync();

            await page.GoToAsync( url );
            await Health( page );
            Thread.Sleep( 2500 );
        }
        static async Task Health(Page page)
        {
            try
            {
                Thread.Sleep( 5000 );
                var healthSelect = await page.QuerySelectorAllAsync(
                    "select"
                    );
                var select = healthSelect[0];
                //選擇健康
                if(select != null)
                {
                    var normal = await select.SelectAsync( "number:1" );
                    Console.WriteLine( $"health:number" );
                    Thread.Sleep( 2500 );
                }
                else
                {
                    Console.WriteLine("Health Select Is Null");
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine( "Health Error:" );
                Console.WriteLine(ex.ToString());
                Console.WriteLine( "Continue:" );
            }
        }

        static async Task CheckIn()
        {
            await new BrowserFetcher().DownloadAsync( BrowserFetcher.DefaultRevision );
            var browser = await Puppeteer.LaunchAsync( new LaunchOptions
            {
                Headless = false
            } );
            var page = await browser.NewPageAsync();

            await page.GoToAsync( url );
            Thread.Sleep( 2500 );

            await Health( page );

            var btnCheckIn = await page.QuerySelectorAllAsync( ".CheckIn" );
            Thread.Sleep( 2500 );
            var btn = btnCheckIn[0];
            if(btn is not null)
            {
                await btn.ClickAsync();
                Console.WriteLine( "checkIn" );
                Thread.Sleep( 2500 );
            }
            else
            {
                Console.WriteLine("CheckIn Btn Is Null");
            }
            //await browser.CloseAsync();
        }


        static async Task CheckOut()
        {
            await new BrowserFetcher().DownloadAsync( BrowserFetcher.DefaultRevision );
            var browser = await Puppeteer.LaunchAsync( new LaunchOptions
            {
                Headless = false
            } );
            var page = await browser.NewPageAsync();

            await page.GoToAsync( url );
            Thread.Sleep( 2500 );

            await Health( page );

            var btnCheckIn = await page.QuerySelectorAllAsync( ".CheckOut" );
            Thread.Sleep( 2500 );
            var btn = btnCheckIn[0];
            if(btn is not null)
            {
                await btn.ClickAsync();
                Console.WriteLine( "checkOut" );
                Thread.Sleep( 2500 );
            }
            else
            {
                Console.WriteLine("CheckOut Btn Is Null");
            }
            //await browser.CloseAsync();
        }
    }
}

```
