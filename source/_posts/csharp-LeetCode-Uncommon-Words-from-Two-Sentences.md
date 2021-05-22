---
title: csharp LeetCode Uncommon Words from Two Sentences
date: 2021-02-17 02:07:15
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

這題用 linq 寫了半天 , 一開始想得太過複雜 , 後來發現只要先把兩個字串進行連結 , 接著找出只出現一次的就搞定了
```
public class Solution {
        public  string[] UncommonFromSentences(string A, string B) {
            return string.Concat(A, " ", B)
                .Split( )
                .GroupBy( x => x )
                .Where( x => x.Count( ) == 1 )
                .Select( x => x.Key )
                .ToArray( );
        }
}
```
