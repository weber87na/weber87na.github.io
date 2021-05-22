---
title: csharp LeetCode Keyboard Row
date: 2021-02-11 17:24:46
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

直覺用 bool array 來保存看看字是否在 row 裡面 , 要注意比對時預設會區分大小寫 , 所以把字轉成小寫比對 , 應該可以用 linq 改成簡單點的方法 , 回頭再想
```
public class Solution {
        public  string[] FindWords(string[] words) {
            string firstRow = "qwertyuiop";
            string secondRow = "asdfghjkl";
            string thirdRow = "zxcvbnm";
            List<string> result = new List<string>( );
            foreach (string word in words)
            {
                bool[] holdFirst = new bool[word.Length];
                bool[] holdSecond = new bool[word.Length];
                bool[] holdThird= new bool[word.Length];
                for (int i = 0; i < word.Length; i++)
                {
                    holdFirst[i] = firstRow.Contains( word.ToLower()[i] );
                    holdSecond[i] = secondRow.Contains( word.ToLower()[i] );
                    holdThird[i] = thirdRow.Contains( word.ToLower()[i] );
                }
                var inFirstRow = holdFirst.ToList( ).All( x => x == true );
                var inSecondRow = holdSecond.ToList( ).All( x => x == true );
                var inThirdRow = holdThird.ToList( ).All( x => x == true );
                if (inFirstRow) result.Add( word );
                if (inSecondRow) result.Add( word );
                if (inThirdRow) result.Add( word );
            }
            return result.ToArray();
        }


}
```
