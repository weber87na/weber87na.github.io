---
title: csharp LeetCode Defanging an IP Address
date: 2021-02-11 08:18:25
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

這題基本上最無腦就用 string 的 Replace 就做完了..
不過是要練習就用練習的方法去想看看
主要就是找到點符號時在前後插入括號
由於這樣會動態調整 array 所以要在 Insert 以後補上新的 i 位置
```
public class Solution {
        public string DefangIPaddr(string address) {
            var list = address.ToList( );
            for(int i = 0; i < list.Count; i++)
            {
                if(list[i] == '.')
                {
                    list.Insert( i , '[' );
                    i += 1;
                    list.Insert( i + 1, ']' );
                    i += 1;
                }
            }
            string result = new string( list.ToArray( ) );
            return result;
        }
}
```
