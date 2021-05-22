---
title: .net core 畜牲爬蟲
date: 2020-08-03 22:46:08
tags:
- asp.net core
- .net core
- 爬蟲
- 畜牲
---
&nbsp;
<!-- more -->
整理資料無意間翻到以前做過，後來卻沒用到的爬蟲API
主要使用[套件 anglesharp](https://anglesharp.github.io/)
爬蟲目標[網站](http://ppg.naif.org.tw/naif/MarketInformation/Cattle/twStatistics.aspx)
寫得比較不好的部分就是沒把WebClient換成HttpClient並且用DI方式注入，我就懶，有機會再改寫

``` csharp
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using AngleSharp;
using AngleSharp.Html.Dom;
using Demo.Models;
using CsvHelper;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Demo.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CowController : ControllerBase
    {
        /// <summary>
        /// 取得行政院農委會肉牛產地行情價格(月報表)
        /// </summary>
        /// <param name="beginYear">起始年(必須為4碼,自2010開始至2019) ex:2019</param>
        /// <param name="beginMonth">起始月(必須為1或2碼 , 1~12) ex:9</param>
        /// <param name="endYear">終止年(必須為4碼,自2010開始至2019) ex:2019</param>
        /// <param name="endMonth">終止月(必須為1或2碼 , 1~12) ex:9</param>
        /// <returns>回傳牛隻價格json陣列
        /// [
        /// {"時間":"2019","閹公牛":"140","肥育肉用母牛":"138","肥育乳公牛550公斤以上":"118","週齡仔公牛(隻)":"1,998","乳公架仔牛150-200公斤":"102"}
        /// ]
        /// </returns>
        [HttpGet]
        [Route("month")]
        public async Task<IActionResult> Month(string beginYear, string beginMonth,
    string endYear, string endMonth)
        {
            //anglesharp
            //https://anglesharp.github.io/

            var context = BrowsingContext.New(AngleSharp.Configuration.Default.WithDefaultLoader());

            //畜生網站
            var url = "http://ppg.naif.org.tw/naif/MarketInformation/Cattle/twStatistics.aspx";

            //載入畜生網站
            var queryDocument = await context.OpenAsync(url);

            //取得asp.net 自動產生的 viewstate 及其他特殊變數
            var viewstate = queryDocument.QuerySelector("#__VIEWSTATE");
            var viewstategenerator = queryDocument.QuerySelector("#__VIEWSTATEGENERATOR");
            var eventvalidation = queryDocument.QuerySelector("#__EVENTVALIDATION");

            var viewstateVal = viewstate.GetAttribute("value");
            var viewstategeneratorVal = viewstategenerator.GetAttribute("value");
            var eventvalidationVal = eventvalidation.GetAttribute("value");


            //參考自保哥
            //https://blog.miniasp.com/post/2010/01/23/Emulate-Form-POST-with-WebClient-class
            using (WebClient wc = new WebClient())
            {
                try
                {
                    wc.Encoding = Encoding.UTF8;

                    //傳送參數
                    NameValueCollection dict = new NameValueCollection();

                    dict["__VIEWSTATE"] = viewstateVal;
                    dict["__VIEWSTATEGENERATOR"] = viewstategeneratorVal;
                    dict["__EVENTVALIDATION"] = eventvalidationVal;

                    //週統計參數(時間必須是週一)懶得寫
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$TextBox_d_beg"] = "2019-10-01";
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$TextBox_d_end"] = "2019-10-01";

                    //統計類型(週,月,年)
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$time"] = "RadioButton_m";

                    //月起始
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_begYear"] = beginYear;
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_begMonth"] = beginMonth;

                    //月終止
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_endYear"] = endYear;
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_endMonth"] = endMonth;

                    //年
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_y_beg"] = "2019";
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_y_end"] = "2019";

                    //查詢按鈕
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$Button_query"] = @"查詢";


                    byte[] bResult = wc.UploadValues(url, dict);

                    string resultHtml = Encoding.UTF8.GetString(bResult);

                    //Console.WriteLine(resultHtml);

                    var resultDocument = await context.OpenAsync(req => req.Content(resultHtml));
                    var table = resultDocument.QuerySelector("#ContentPlaceHolder_contant_ContentPlaceHolder_contant_Panel_data > table") as IHtmlTableElement;


                    List<Dictionary<string, string>> cows =
                        new List<Dictionary<string, string>>();

                    //第一行為header所以跳過
                    int counter = 0;
                    foreach (IHtmlTableRowElement tr in table.Rows)
                    {
                        if (counter > 0)
                        {
                            var cow = new Dictionary<string, string> {
                                { "時間" , tr.Cells[0].TextContent },
                                { "閹公牛" , tr.Cells[1].TextContent },
                                { "肥育肉用母牛" , tr.Cells[2].TextContent },
                                { "肥育乳公牛550公斤以上" , tr.Cells[3].TextContent },
                                { "週齡仔公牛(隻)" , tr.Cells[4].TextContent },
                                { "乳公架仔牛150-200公斤" , tr.Cells[5].TextContent },
                            };
                            cows.Add(cow);
                        }
                        counter++;
                    }

                    return Ok(cows);

                }
                catch (WebException ex)
                {
                    throw new Exception("無法連接遠端伺服器");
                }
            }
        }

		        /// <summary>
        /// 取得行政院農委會肉牛產地行情價格(年報表)
        /// </summary>
        /// <param name="beginYear">起始年(必須為4碼,自2010開始至2019) ex:2019</param>
        /// <param name="endYear">終止年(必須為4碼,自2010開始至2019) ex:2019</param>
        /// <returns>
        /// 回傳牛隻價格json陣列
        /// [{"時間":"2019","閹公牛":"140","肥育肉用母牛":"138","肥育乳公牛550公斤以上":"118","週齡仔公牛(隻)":"1,998","乳公架仔牛150-200公斤":"102"},{"時間":"平均","閹公牛":"140","肥育肉用母牛":"138","肥育乳公牛550公斤以上":"118","週齡仔公牛(隻)":"1,998","乳公架仔牛150-200公斤":"102"}]
        /// </returns>
        [HttpGet]
        [Route("year")]
        public async Task<IActionResult> Year(string beginYear, string endYear)
        {
            //anglesharp
            //https://anglesharp.github.io/

            var context = BrowsingContext.New(AngleSharp.Configuration.Default.WithDefaultLoader());

            //畜生網站
            var url = "http://ppg.naif.org.tw/naif/MarketInformation/Cattle/twStatistics.aspx";

            //載入畜生網站
            var queryDocument = await context.OpenAsync(url);

            //取得asp.net 自動產生的 viewstate 及其他特殊變數
            var viewstate = queryDocument.QuerySelector("#__VIEWSTATE");
            var viewstategenerator = queryDocument.QuerySelector("#__VIEWSTATEGENERATOR");
            var eventvalidation = queryDocument.QuerySelector("#__EVENTVALIDATION");

            var viewstateVal = viewstate.GetAttribute("value");
            var viewstategeneratorVal = viewstategenerator.GetAttribute("value");
            var eventvalidationVal = eventvalidation.GetAttribute("value");


            //參考自保哥
            //https://blog.miniasp.com/post/2010/01/23/Emulate-Form-POST-with-WebClient-class
            using (WebClient wc = new WebClient())
            {
                try
                {
                    wc.Encoding = Encoding.UTF8;

                    //傳送參數
                    NameValueCollection dict = new NameValueCollection();

                    dict["__VIEWSTATE"] = viewstateVal;
                    dict["__VIEWSTATEGENERATOR"] = viewstategeneratorVal;
                    dict["__EVENTVALIDATION"] = eventvalidationVal;

                    //週統計參數(時間必須是週一)懶得寫
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$TextBox_d_beg"] = "2019-10-01";
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$TextBox_d_end"] = "2019-10-01";

                    //統計類型(週,月,年)
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$time"] = "RadioButton_y";

                    //月起始
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_begYear"] = "2019";
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_begMonth"] = "1";

                    //月終止
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_endYear"] = "2019";
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_m_endMonth"] = "1";

                    //年
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_y_beg"] = beginYear;
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$DropDownList_y_end"] = endYear;

                    //查詢按鈕
                    dict["ctl00$ctl00$ContentPlaceHolder_contant$ContentPlaceHolder_contant$Button_query"] = @"查詢";


                    byte[] bResult = wc.UploadValues(url, dict);

                    string resultHtml = Encoding.UTF8.GetString(bResult);

                    //Console.WriteLine(resultHtml);

                    var resultDocument = await context.OpenAsync(req => req.Content(resultHtml));
                    var table = resultDocument.QuerySelector("#ContentPlaceHolder_contant_ContentPlaceHolder_contant_Panel_data > table") as IHtmlTableElement;


                    List<Dictionary<string, string>> cows =
                        new List<Dictionary<string, string>>();

                    //第一行為header所以跳過
                    int counter = 0;
                    foreach (IHtmlTableRowElement tr in table.Rows)
                    {
                        if (counter > 0)
                        {
                            var cow = new Dictionary<string, string> {
                                { "時間" , tr.Cells[0].TextContent },
                                { "閹公牛" , tr.Cells[1].TextContent },
                                { "肥育肉用母牛" , tr.Cells[2].TextContent },
                                { "肥育乳公牛550公斤以上" , tr.Cells[3].TextContent },
                                { "週齡仔公牛(隻)" , tr.Cells[4].TextContent },
                                { "乳公架仔牛150-200公斤" , tr.Cells[5].TextContent },
                            };
                            cows.Add(cow);
                        }
                        counter++;
                    }

                    return Ok(cows);

                }
                catch (WebException ex)
                {
                    throw new Exception("無法連接遠端伺服器");
                }
            }
        }
    }

}
```
