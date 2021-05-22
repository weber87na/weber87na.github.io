---
title: csharp LeetCode Richest Customer Wealth
date: 2021-02-11 07:37:20
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

這題也是典型的雙迴圈 , 大概 N 多年沒這樣用 `Jagged Array` 有點忘了怎麼抓維度 , java 好像沒這鬼東西
主要先抓高多少 `int yLen = accounts.Length` 接著抓每個高度的寬多少 `int xLen = accounts[y].Length`
```
        public int MaximumWealth(int[][] accounts) {
            int yLen = accounts.Length;
            int max = 0;
            for(int y = 0; y < yLen; y++) {
                //取得 x 位置的長度
                int xLen = accounts[y].Length;
                //目前客戶
                int currentCustom = 0;
                //計算目前客戶財產
                for(int x = 0; x < xLen; x++) {
                    //目前格子
                    int cell = accounts[y][x];
                    currentCustom += cell;
                }
                //判斷目前最有錢的客戶
                if (max <= currentCustom) max = currentCustom;
            }
            return max;
        }
 
```

後來想到看可否用 LINQ 來解 , 偷看老外還真的有 , 真賊 , 先用 select 重新 remapping , 然後靠著 sum 把每行加總 , 最後 max , 簡潔有力
```
    public class Solution
    {
        public int MaximumWealth(int[][] accounts) {
            return accounts.Select( x => x.Sum( ) ).Max( );
        }
    }
```
