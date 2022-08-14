---
title: 結巴 jieba 分詞 lib 筆記
date: 2022-05-16 19:43:07
tags:
- python
- c#
---
&nbsp;
<!-- more -->

### python
最近遇到一個非常通靈的需求 , user 希望在留言欄內寫了些字眼 , 要求能夠分類出來
例如這樣 `好棒` , `好棒棒` , `很棒` 視為同一類 , 表示給予正面評價
如果是 `機車` , `wtf` , `GG` 這類 , 給予負面評價
剛開始沒啥方向 , 想說這種黑科技只能往 python 去看看應該比較多
在一翻尋找後發現這種類似的需求可能要用 `斷詞` 這類的術語去找 , 最後發現了這個 lib [jieba](https://github.com/fxsjy/jieba)
另外撰寫過程中又發現 , 除了斷詞外還需要過濾關鍵字 , 所以用了 [flashtext](https://github.com/vi3k6i5/flashtext)

```
pip3 install jieba
pip3 install flashtext
conda install pymssql
```

我這裡直接跑 jupyter notebook 來測試
```
#coding=utf8
import jieba
import jieba.analyse
import pymssql
import sys
import json

from flashtext import KeywordProcessor

#得到目前編碼
#print(sys.getdefaultencoding())

#https://github.com/vi3k6i5/flashtext
#https://github.com/fxsjy/jieba
#載入字典
filename = 'dict.txt'
jieba.load_userdict(filename)
keyword_processor = KeywordProcessor(case_sensitive=False)


#加入關鍵字
for str in get_keyword(filename):
    #print(str)
    keyword_processor.add_keyword(str)

#分詞
#換成 get_from_sql 則切成正式資料
for str in get_all():
    #print(str)
    seg_list = jieba.cut(str,use_paddle=True)
    result = keyword_processor.extract_keywords('/'.join(list(seg_list)))
    #print(seg_list)
    #print(result)
    if len(result) > 0:
        print(result)



def get_keyword(filename):
    lines = []
    with open(filename,"r",encoding="utf-8") as f:
        for line in f:
            #消除 UTF8-BOM 還有換行符號
            #https://blog.csdn.net/qq_38939991/article/details/116103252
            lines.append(line.lstrip("\ufeff").rstrip('\n'))
    return lines

def get_all():
    result = [
        "這個賣家真的很機車",
        "這個客戶真的很棒",
        "好棒棒",
        "GY 產品難用又垃圾",
        "我剛買回來馬上就壞了 GG",
        "舒服 ~",
        "無聊留言看看",
        "工程師測試"
    ]
    return result

def get_from_sql():
    #這裡跟 sql server 的定序有關 , 要找到跟你 DB 一樣的定序 , 繁體中文為 cp950
    #SELECT COLLATIONPROPERTY('Chinese_Taiwan_Stroke_CI_AS', 'CodePage')
    result = []
    conn = pymssql.connect(server='123.456.78',
                           user='1234',
                           password='12345678',
                           database='GGDB',
                           charset='cp950')


    cursor = conn.cursor(as_dict=True)
    cursor.execute(
u"""
select Comment
from Board
where Comment is not null
and (
	Comment like '%機車%' or
	Comment like '%wtf%' or
	Comment like '%GY%' or
	Comment like '%GG%' or
	Comment like '%FQ%' or
	Comment like '%好棒%' or
	Comment like '%好棒棒%' or
	Comment like '%很棒%'
)
order by Comment
""".encode('cp950')
    )
    comments = cursor.fetchall()
    for row in comments:
        result.append(row['Comment'])
        #print(row['Comment'])
    conn.close()
    return result
```


dict
```
wtf
GY
GG
FQ
機車
好棒
好棒棒
很棒
```


### c#
後來發現它也有 [.net 的實作](https://github.com/anderscui/jieba.NET/) , 所以也在轉寫一次看看
唯一要注意的就是他的 `Resources` 要丟到 `bin` 底下 , 不然就是要設定到其他目錄
本來也想在 jupyter 上面測試看看 , 可是一直吃不到 `Resources` 只好放棄
```
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using static System.Linq.Enumerable;
using static System.Console;
using static System.Math;
using System.Data.SqlClient;
using System.Data;

using System.Diagnostics;
using System.IO;
using System.Resources;

using Unit = System.ValueTuple;
using System.Xml.Linq;

using System.Collections;
using System.Resources;
using JiebaNet.Segmenter;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            var kp = new KeywordProcessor();
            kp.AddKeywords(
                new[] {
                    "GY",
                    "GG",
                    "好棒棒",
                    "好棒"
            });

            //https://github.com/anderscui/jieba.NET/
            //預設目錄叫做 Resources 在此手動修改目錄名稱 , 執行務必確保 bin 底下有這個資料夾
            JiebaNet.Segmenter.ConfigManager.ConfigFileBaseDir = AppDomain.CurrentDomain.BaseDirectory + @"jiebanet_config";
            var segmenter = new JiebaSegmenter();

            //載入自己定義的字典
            segmenter.LoadUserDict("dict.txt");

            //計算看看最後有多少詞進入到分類
            var total = new List<string>();

            foreach (var item in GetAll().ToList())
            {
                //分詞
                var segments = segmenter.Cut(item, cutAll: true);
                //Console.WriteLine("{0}", string.Join("/", segments));

                //拿分詞找關鍵字
                var result = kp.ExtractKeywords(string.Join("/", segments));

                //計算到底有多少關鍵詞
                if (result.Count() > 0) total.Add(item);

                //輸出關鍵詞關係
                result.ToList().ForEach(x =>
                {
                    Console.WriteLine($"{x} / parent:{item}");
                });

                //分隔線
                if (result.Count() > 0) Console.WriteLine($"====================================");
            }

            //看筆數
            Console.WriteLine($"total: {total.Count}");
        }

        static List<string> GetAll()
        {
            //模擬 db 資料
            return new List<string> {
				"這個賣家真的很機車",
				"這個客戶真的很棒",
				"好棒棒",
				"GY 產品難用又垃圾",
				"我剛買回來馬上就壞了 GG",
				"舒服 ~",
				"無聊留言看看",
				"工程師測試"
            };
        }
    }
}

```

