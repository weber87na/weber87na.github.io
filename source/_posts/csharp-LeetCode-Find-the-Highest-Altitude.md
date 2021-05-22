---
title: csharp LeetCode Find the Highest Altitude
date: 2021-02-11 13:29:59
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

這題我直覺是最後要補零 , 懶得算太多直接用 linq 的 max
```
        public int LargestAltitude(int[] gain) {
            var list = new List<int>( );
            for(int i = 0; i < gain.Length; i++) {
                if (i == 0)
                    list.Add( gain[i]);
                else
                    list.Add( gain[i] + list[i - 1]);
            }
            list.Insert( 0, 0 );
            return list.Max();
        }
```

看有的老外會用 Math.Max 來操作
```
        public static int LargestAltitude(int[] gain) {
            int curAltitude = 0;
            int highestAltitude = 0; // what we'll return
            
            foreach (int g in gain) {
                curAltitude += g;
                highestAltitude = Math.Max(highestAltitude, curAltitude);
            }
            
            return highestAltitude;
        }
```
