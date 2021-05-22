---
title: csharp LeetCode Running Sum of 1d Array
date: 2021-02-11 11:23:54
tags:
- csharp
- LeetCode
---
&nbsp;
<!-- more -->

看這題以我的直覺會寫成比較囉嗦的語法
```
public class Solution {
    public int[] RunningSum(int[] nums) {
        int[] result = new int[nums.Length];
        int prevSum = 0;
        for(int i = 0 ; i < nums.Length; i++){
            if(i > 0)
                prevSum += nums[i];
            else
                prevSum = nums[i];
            
            result[i] = prevSum;
        }
        return result;
    }
}
```
後來想想其實可以寫作索引起始為 1 去修改 nums
以上兩種都算是大多數人的想法
```
public class Solution {
    public int[] RunningSum(int[] nums) {
        for(int i = 1 ; i < nums.Length; i++){
            nums[i] += nums[i - 1];
        }
        return nums;
    }
}
```
又看看有無 linq 解法 , 好像這類型的問題只要用 linq 的 select 即可解決 , 而且是函數式不會直接修改到原始 array 資料
```
public class Solution {
    public int[] RunningSum(int[] nums) {
        int sum = 0;
        return nums.Select(x => sum += x).ToArray();
    }
}
```
