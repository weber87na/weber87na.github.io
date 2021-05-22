---
title: csharp LeetCode Two Sum
date: 2021-02-10 21:17:53
tags:
- chsarp
- LeetCode
---
&nbsp;
<!-- more -->

無聊看 Leet Code 覺得網路上好像都沒啥 c# 版本 , 覺得賭爛 , 自己來玩看看順便翻譯
這題直覺就是想到雙迴圈搞出來用傳統的 for
``` csharp
        public int[] TwoSum1(int[] nums, int target)
        {
            var result = new int[2];
            for (int i = 0; i < nums.Length; i++) {
                for(int j = i + 1; j < nums.Length; j++) { 
                    if(nums[i] + nums[j] == target)
                    {
                        result[0] = i;
                        result[1] = j;
                        return result;
                    }
                }
            }
            return result;
        }

```

遇到這種東西多半都會要你省時間改成單迴圈 , 算是空間換時間 , 偷看 java 是用 HashMap 其實就是 .net 裡面的 Dictionary
這 Dictionary 內的邏輯有點反 , 要把 target - 目前數值當成 key 放進去 , 把索引位置當成 value

``` csharp
        public int[] TwoSum2(int[] nums, int target)
        {
            Dictionary<int, int> dict = new Dictionary<int, int>( );
            var result = new int[2];
            for (int i = 0; i < nums.Length; i++)
            {
                //目前陣列的數值
                var currentValue = nums[i];
                if(dict.ContainsKey( target - currentValue ))
                {
                    //取得陣列索引
                    result[0] = dict[target - currentValue];
                    result[1] = i;
                    break;
                }
                else
                {
                    //值 , 陣列的索引(1,2,3,4,5...)
                    dict.Add(currentValue , i );
                }
            }
            return result;
        }
```
