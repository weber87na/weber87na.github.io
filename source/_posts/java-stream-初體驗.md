---
title: java stream 初體驗
date: 2022-09-14 18:52:44
tags: java
---
&nbsp;
<!-- more -->

今天同事遇到的問題 , 邏輯要都有填寫與都沒填寫才能過驗證 , 因為邏輯非常複雜寫得有點看不懂 , 於是想說拿 Stream 搞看看 , 寫起來跟 js 差不多 , java 沒在寫都忘光啦 XD
要注意 Stream 的部分要套用多個的話一定要這樣寫 , 不然會噴 error
```
import java.util.Arrays;
import java.util.function.Supplier;
import java.util.stream.Stream;

public class Main {
    public static void main(String args[]) {

        boolean onlyA = ans("A 有填" , null);
        System.out.println("A 有填 B 沒填:" + onlyA);

        boolean onlyB = ans(null , "B 有填" );
        System.out.println("A 沒填 B 有填:" + onlyB);

        boolean bothNull = ans(null , null);
        System.out.println("都沒填:" + bothNull);

        boolean bothNotNull = ans("A 有填" , "B 有填" );
        System.out.println("都有填:" + bothNotNull);
    }

    //參考這裡
    //https://www.jianshu.com/p/27310d283dda
    //判斷要嘛都填 , 要嘛都沒填
    public static boolean ans(String a,String b){
        String[] array = { a , b };
        Stream<String> stream = Arrays.stream(array);
        Supplier<Stream<String>> streamSupplier = () -> Stream.of(array);

        boolean bothMatch = streamSupplier.get().allMatch(x->empty(x));
        boolean bothNotMatch = streamSupplier.get().allMatch(x->!empty(x));

        return bothMatch || bothNotMatch;
    }

    //https://stackoverflow.com/questions/3598770/check-whether-a-string-is-not-null-and-not-empty
    public static boolean empty( final String s ) {
        // Null-safe, short-circuit evaluation.
        return s == null || s.trim().isEmpty();
    }
}
```
