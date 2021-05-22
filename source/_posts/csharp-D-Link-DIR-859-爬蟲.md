---
title: csharp D-Link DIR-859 爬蟲
date: 2021-01-16 00:28:23
tags:
- csharp
- 爬蟲
---
&nbsp;
<!-- more -->

繼之前的取得 IP or MacAddress 又遇到個變態的問題，要抓 D-Link 上面的設備 IP，感覺對這些很陌生，先寫個爬蟲來試看看，以後有更好的方法再換
爬蟲有一堆 lib 可以選擇，這次用 [puppeteer-sharp](https://github.com/hardkoded/puppeteer-sharp) 比較困難點就是要注意操作 ajax or 按鈕這類動作要讓他睡，
此外操作 DOM 的方式也是滿特別的建議要看這個官方的單元測試 [最重要的 example](https://github.com/hardkoded/puppeteer-sharp/blob/master/lib/PuppeteerSharp.Tests/ElementHandleTests/EvaluateFunctionTests.cs)

## full example
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
