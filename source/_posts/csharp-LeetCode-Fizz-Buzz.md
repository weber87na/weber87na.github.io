---
title: csharp LeetCode Fizz Buzz
date: 2021-02-16 06:44:06
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

這題算是滿簡單的大部分寫法都差不多 , 所以寫個 linq 版本的 , 關鍵就是用 Enumerable 的 Range 產生出資料, 搭配 Select 進行 ReMapping 即可
```
public class Solution {
        public IList<string> FizzBuzz(int n)
        {
            var nums = Enumerable.Range( 1, n ).Select( x => {
                if (x % 3 == 0 && x % 5 == 0) return "FizzBuzz";
                if (x % 3 == 0) return "Fizz";
                if (x % 5 == 0) return "Buzz";
                return x.ToString();
            } 
            ).ToList();
            return nums;
        }
}
```
常見寫法 , 注意要把 3 & 5 擋在最前面
```
public class Solution {
        public IList<string> FizzBuzz(int n)
        {
            var nums = Enumerable.Range( 1, n );
            List<string> list = new List<string>( );
            foreach (var item in nums)
            {
                if (item % 3 == 0 && item % 5 == 0) {
                    list.Add( "FizzBuzz" ); 
                    continue;
                }
                if (item % 3 == 0)
                {
                    list.Add( "Fizz" );
                    continue;
                }
                if (item % 5 == 0) {
                    list.Add( "Buzz" ); 
                    continue; 
                };
                list.Add( item.ToString( ) );
            }

            return list;
        }
}
```
