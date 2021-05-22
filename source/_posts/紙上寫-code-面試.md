---
title: 紙上寫 code 面試
date: 2020-10-26 16:05:23
tags:
- 面試
---
&nbsp;
<!-- more -->
今天去面試，感覺好久沒參加這麼正式的場合，有點生疏，腦子看到試卷一片空白，感覺要紙上 coding 超不容易，太過緊張，回家換成電腦寫看看就搞定了。

Q:列出以下星星
```
    *
   **
  * *
 *  *
***** 
```
ANS:解答
``` csharp
        static void PrintStar(int m = 5)
        {
            for (int i = 1; i <= m; i++)
            {
                for (int j = 0; j < m - i; j++)
                    Console.Write(" ");

                for (int j = 0; j < i; j++)
                {
                    if (i == m)
                        Console.Write("*");
                    else
                    {
                        if (j == 0 || j == i - 1 )
                            Console.Write("*");
                        else
                            Console.Write(" ");
                    }

                }

                Console.WriteLine();
            }
        }

```
Q2:寫個函數讓字串反轉
```
        static string StrReverse(string str)
        {
            string result = "";
            for(int i = str.Length - 1; i >= 0; i--)
            {
                result += str[i];
            }
            return result;
        }

```
Q3:將數字 123456789 標示為 123,456,789
```
        static string FormatMoney(string str)
        {
            string result = "";
            string reverse = "";
            int counter = 0;
            for(int i = str.Length - 1; i >= 0; i--)
            {
                if(counter == 2 && i > 0)
                {
                    reverse += str[i];
                    reverse += ",";
                    counter = 0;
                }
                else
                {
                    reverse += str[i];
                    counter++;
                }
            }

            for(int i = reverse.Length - 1; i >= 0; i--)
            {
                result += reverse[i];
            }
            return result;
        }

```

後來又面一家有紙上寫 code ，有了上次經驗這次就相對沒那麼緊張了(還是超緊張)，不過回家後想不起來半題，印象中這次有 SQL 子查詢。我有在紙上成功寫出這題，大概長這樣
``` sql
select Name , (select count(*) form Q4 x where x.id = y.id)
from Test y
```

某天剛睡醒跟智障一樣，又收到一家奇怪的面試方法 AI 面試!!還滿特別的，不過我 windows 又中了 update 的問題暫時作罷，只能等設備正常
接著 HR 又出了兩題寫完後回傳附件，比較友善，不然用紙筆寫當下那種壓力簡直噁心。
一題算是整合題用 map api + 地址 api 鋪上星巴克資訊加上部分操作功能，最花時間就是申請 api key，還要填給 google 一堆資料。
第二題是計算時鐘夾角，比較重點就是分針計算還有夾角大於 180 度需要扣掉 360 度
``` 
        static double ClockAngle(int hour, int minute)
        {
            if (hour > 12 || hour < 0 )
                throw new ArgumentException("時針範圍為 1 - 12");

            if (minute > 60 || minute < 0)
                throw new ArgumentException("分針範圍為 1 - 60");

            //分針一分鐘走 6 度
            double minuteDeg = minute * 6;

            //時針一小時走 30 度
            //每分鐘走 0.5 度
            double hourDeg = hour * 30 + minute * 0.5;

            //結果等於兩數相減取絕對值
            double angle = Math.Abs(minuteDeg - hourDeg);

            //夾角取得不大於 180 度的 , 所以用 360 減去結果換算
            double result = 0;
            if (angle > 180)
                result = 360 - angle;
            else
                result = angle;

            return result;
        }

```
