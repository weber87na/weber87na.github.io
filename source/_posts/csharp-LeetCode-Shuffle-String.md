---
title: csharp LeetCode Shuffle String
date: 2021-02-11 08:47:07
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

自己寫了一下 , 發現大部分人也都一樣的解法 , 只是我更加喜歡額外放個變數 , 方便 debug
```
        public string RestoreString(string s, int[] indices) {
            var result = new char[s.Length];
            for (int i = 0; i < s.Length; i++)
            {
                var strIndex = indices[i];
                var currentStr = s[i];
                result[strIndex] = currentStr;
            }
            return new string( result );
        }
```

想用其他方法弄看看 , 看老外原來有 SortedDictionary 這鬼東西 , 這樣寫起來更加好讀
```
        public string RestoreString(string s, int[] indices) {
            var dict = new SortedDictionary<int, char>( );
            for(int i = 0; i < s.Length; i++)
            {
                dict.Add( indices[i], s[i] );
            }
            return new string( dict.Values.ToArray( ) );
        }
```
