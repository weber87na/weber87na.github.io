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

### nodejs 用法
首先可以到他的官方[Puppeteer](https://pptr.dev/)
安裝後預設會在 `$HOME/.cache/puppeteer` 底下安裝最近版本的 chrome
Windows 等價於 `%userprofile%/.cache/puppeteer`

```
npm i puppeteer
```

預設 nodejs 是沒法跑的 , 要在 package.json 加上 `"type": "module"`
```
{
    "type": "module",
    "dependencies": {
        "puppeteer": "^21.4.1"
    }
}
```

新版的 `headless` 參數有些不一樣
``` js
    //開啟 chrome
    const browser = await puppeteer.launch({
        //這個設定 false 會跑出 chrome GUI
        headless: false,

        //新版要這樣寫才會把 headless 關閉 (不會跑出 chrome GUI)
        // headless: 'new',
        defaultViewport: null,
        args: ['--start-maximized']
    });
```

然後官方給的 example 預設開啟會是一個空頁 , 然後又開一頁 , 可以改這樣寫就只會有一頁
``` js
    //這樣寫才不會有空白頁面
    const pages = await browser.pages();
    const page = pages[0];
```

然後就是 `帳號` `密碼` `登入`
``` js
    //進去登入頁面
    const loginUrl = '';
    await page.goto(loginUrl);

    const username = '';
    const password = '';
    const usernameSelector = '#username';
    await page.waitForSelector(usernameSelector);
    await page.focus(usernameSelector);
    //輸入帳號
    await page.keyboard.type(username);

    const passwordSelector = '#password';
    await page.waitForSelector(passwordSelector);
    await page.focus(passwordSelector);
    //輸入密碼
    await page.keyboard.type(password);

    //這裡 click 以後會自動跳進去
    const loginSelector = '#login';
    await page.waitForSelector(loginSelector);
    await page.click(loginSelector);
```

再來是用 `evaluate` 去使用 `querySelector` 最後回傳數值
``` js
    const downloadViewUrl = await page.evaluate(() => {
        let aTag = document.querySelector('#leftsidebar a')
        return aTag.href;
    });
    await page.goto(downloadViewUrl);
```

最後是一個存成 `json` 的方法
```
    //存成 json 正式應該要存到 db
    const finalResult = JSON.stringify(resultRows);
    fs.writeFile('data.json', finalResult, (error) => {
        if (error) {
            console.log(error)
            throw error
        }
        console.log('done!')
    })
```


然後下面大致上是一個 example code

``` js
import puppeteer from 'puppeteer';
import * as fs from 'fs';


(async () => {
    //開啟 chrome
    const browser = await puppeteer.launch({
        //這個設定 false 會跑出 chrome GUI
        headless: false,

        //新版要這樣寫才會把 headless 關閉 (不會跑出 chrome GUI)
        // headless: 'new',
        defaultViewport: null,
        args: ['--start-maximized']
    });

    //打開新頁 這樣寫有空白頁
    // const page = await browser.newPage();

    //這樣寫才不會有空白頁面
    const pages = await browser.pages();
    const page = pages[0];

    //設定視窗大小
    // await page.setViewport({ width: 1080, height: 1024 });

    //進去登入頁面
    const loginUrl = '';
    await page.goto(loginUrl);

    const username = '';
    const password = '';
    const usernameSelector = '#uername';
    await page.waitForSelector(usernameSelector);
    await page.focus(usernameSelector);
    //輸入帳號
    await page.keyboard.type(username);

    const passwordSelector = '#pssword';
    await page.waitForSelector(passwordSelector);
    await page.focus(passwordSelector);
    //輸入密碼
    await page.keyboard.type(password);

    //這裡 click 以後會自動跳進去
    const loginSelector = '#login';
    await page.waitForSelector(loginSelector);
    await page.click(loginSelector);

    const OXUrl = '';
    await page.goto(OXUrl);

    //點到 table 然後選
    const tableSelector = '#main table';
    await page.waitForSelector(tableSelector);
    await page.click(tableSelector);

    //這裡用另外一種方式去使用 querySelector
    const firstSensorUrl = await page.evaluate(() => {
        let rows = document.querySelector('#main table tbody tr');
        let firstSensorATag = rows.querySelector('td:nth-child(4) > a')
        console.log(firstSensorATag.href);
        return firstSensorATag.href;
    });
    console.log(firstSensorUrl);
    await page.goto(firstSensorUrl);

    //這裡跳到 Download 那頁
    const downloadViewUrl = await page.evaluate(() => {
        let aTag = document.querySelector('#leftsidebar a')
        return aTag.href;
    });
    await page.goto(downloadViewUrl);

    //總共有 17 個欄位 , 最後兩個看起來沒啥用
    //取得需要的 title 資訊
    const titles = await page.evaluate(() => {
        let heads = document.querySelectorAll('#main table thead tr th')
        let result = []
        for (const [key, value] of Object.entries(heads)) {
            if (key <= 15) result.push(value.innerText)
        }
        return result
    });

    //取得實際數值
    const realValues = await page.evaluate(() => {
        let values = document.querySelectorAll('#main table tbody tr td')
        let result = []
        let row = []
        let counter = 0
        for (const [key, value] of Object.entries(values)) {
            //當 row 數量到 16 時 ,  push 進去結果 , 並且 row 清空
            if (row.length === 16) {
                result.push(row)
                row = []
            }

            //塞入表格的數值
            if (counter < 16) row.push(value.innerText)

            counter++

            //大於 17 時歸零
            if (counter > 17) counter = 0
        }
        return result
    });

    //組合 title/value 之結果
    let pairs = []
    let resultRows = []
    //先算有幾條數值的 rows , 然後才算 title
    for (let r = 0; r < realValues.length; r++) {
        for (let i = 0; i < titles.length; i++) {
            //取得 title
            let title = titles[i]

            //拿整條 row
            let row = realValues[r]

            //row 裡面有數值 , 總數會跟 title match
            let value = row[i]

            //組合 pair 物件
            let pair = {
                'title': title,
                'value': value
            }
            pairs.push(pair)
        }
        resultRows.push(pairs)
        pairs = []
    }
    console.log(resultRows)

    //https://blog.openreplay.com/how-to-read-and-write-json-in-javascript/
    //存成 json 正式應該要存到 db
    const finalResult = JSON.stringify(resultRows);
    fs.writeFile('data.json', finalResult, (error) => {
        if (error) {
            console.log(error)
            throw error
        }
        console.log('done!')
    })

    //關閉 chrome
    await browser.close();
})();
```

### nodejs angularjs 範例
這是一個 angularjs 的範例 , 利用 `window.angular.element(document.querySelector('body')).scope()` 抓到 `scope`
然後就可以輕鬆拿 angularjs 裡面的變數
這種 binding 做的東東就算你直接塞數值進去 html 的 tag 裡面 , 也只是表象
最好還是要把數值塞進去真正變數裡面 , 另外這樣塞畫面上還是不會看到數值變化
所以還需要抓取 html tag 方便 debug
```
await page.evaluate(() => {
	//取得 angular
	let scope = window.angular.element(document.querySelector('body')).scope()

	//取得工時
	let hours = scope.form.workobj[0].hours

	//我的工作內容
	let genDesc = '執行爬蟲 (web crawler) 自動下載需求單之 excel 並 scan 檔案產生相對應 sql 及核對欄位 , 建立於 db';

	//取得今日
	let theDate = new Date().toISOString().slice(0, 10).replace('-', '/').replace('-', '/')

	//設定 angular 實際值
	scope.form.workobj[0].workDesc = genDesc
	scope.form.workobj[0].actworkinghours = hours
	scope.form.workobj[0].launchDate = theDate
	scope.form.workobj[0].actcompletionDate = theDate


	//找到定位節點
	let workContentCell = Array.from(document.querySelectorAll('th')).find(ele => ele.textContent === '工作內容')

	//取得要簽核的 table
	let workTable = workContentCell.parentNode.parentNode

	//實際工作時數
	let workActTime = workTable.querySelectorAll('input')[0]

	//實際完成日期
	let workActDate = workTable.querySelectorAll('input')[1]

	//上線日期
	let workCompleteDate = workTable.querySelectorAll('input')[2]

	//工作內容簡述
	let workDesc = workTable.querySelector('textarea')

	//設定 html 元素上的數值 , 障眼法
	workActDate.value = theDate
	workCompleteDate.value = theDate
	workDesc.innerText = genDesc
	workActTime.value = hours


	//存檔
	document.querySelector('ul a:nth-child(1)').click()
});
```

### linux nodejs puppeteer
先確認 ubuntu 版本 , 我之前用 20.04 配的 nodejs 好像是 14.x , 爬蟲用的 puppeteer 需要 16.x
```
lsb_release -a

No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 20.04.6 LTS
Release:        20.04
Codename:       focal
```

首先安裝 chrome
```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
```

接著更新 nodejs 到 16.x
可以參考[這裡](https://github.com/nodesource/distributions/blob/master/README.md)
教學可以看[這篇](https://joshtronic.com/2021/05/09/how-to-install-nodejs-16-on-ubuntu-2004-lts/)
```
sudo apt update
sudo apt upgrade
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
```

然後更新 npm 並且安裝 puppeteer
```
npm install -g npm@10.2.1
mkdir test
cd test
npm i puppeteer
```

設定 `package.json` 的 `"type": "module"`
``` json
{
	"type": "module",
	"dependencies": {
		"puppeteer": "^21.4.1"
	}
}
```

最後可以跑這段他會 show 出 `關於 Google`
這裡如果你沒 `GUI` 一定要用 `headless`
``` js
import puppeteer from 'puppeteer';
import * as fs from 'fs';

(async () => {
	//開啟 chrome
	const browser = await puppeteer.launch({
		//這個設定 false 會跑出 chrome GUI
		headless: true,

		//新版要這樣寫才會把 headless 關閉 (不會跑出 chrome GUI)
		// headless: 'new',
		defaultViewport: null,
		args: ['--start-maximized']
	});

	//這樣寫才不會有空白頁面
	const pages = await browser.pages();
	const page = pages[0];

	const googleUrl = 'https://www.google.com.tw/?hl=zh_TW';
	await page.goto(googleUrl);

	const aboutSelector = '.MV3Tnb';
	await page.waitForSelector(aboutSelector);

	const text = await page.evaluate(() => {
		let aTag = document.querySelector('.MV3Tnb');
		return aTag.innerText;
	});

	console.log(text);
    //關閉 chrome
    await browser.close();
})();
```
