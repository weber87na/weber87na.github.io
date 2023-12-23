---
title: Strategy Pattern 筆記
date: 2023-06-25 04:47:04
tags: 
- design pattern
- c#
---
&nbsp;
<!-- more -->

工作上遇到的類似情境 , 有多種廠牌需要影印 , 當有新的客戶就會有類似需求
看前人留下的 code 是用一個很肥的超級類別 , 然後每次有新客戶就插入類似的 `AsusPrint` , `ApplePrint` 等等 , 然後用 case 切換
大概類似這樣

```
class SuperPrinter
{
    public void Print(string cat)
    {
        switch (cat)
        {
            case "Asus":
				AsusPrint();
                break;
            case "Apple":
				ApplePrint();
                break;
            default:
                break;
        }
    }

    public void ApplePrint()
    {
        Console.WriteLine("Apple");
    }

    public void AsusPrint()
    {
        Console.WriteLine("Asus");
    }
	
	//很肥的內部細節...
}
```

自己研究下發現 , 其實可以套用 `Strategy Pattern` 讓程式碼更好維護 , 不然真的想死 XD , `Strategy Pattern` 最大的重點就是可以 `抽換演算法` 正巧符合這個情境
其他高深寫法可以參考[這篇](https://blog.jamesmichaelhickey.com/strategy-pattern-implementations/)

```
Printer printer = new Printer();
printer.Print();

printer.SetStrategy(new AsusStrategy());
printer.Print();

var dict = new Dictionary<string, PrintStrategy>
{
    {"Asus", new AsusStrategy() },
    {"Apple", new AppleStrategy() },
};
var asus = dict["Asus"];
var apple = dict["Apple"];

printer.SetStrategy(apple);
printer.Print();

printer.SetStrategy(asus);
printer.Print();

Console.ReadLine();

interface PrintStrategy
{
    void Print();
}

class AsusStrategy : PrintStrategy
{
    public void Print()
    {
        Console.WriteLine("Asus");
    }
}

class AppleStrategy : PrintStrategy
{
    public void Print()
    {
        Console.WriteLine("Apple");
    }
}

class Printer
{
    private PrintStrategy _printStrategy;
    public Printer()
    {
        _printStrategy = new AppleStrategy();
    }

    //應該也可以在建構子強制讓人設定策略
    public void SetStrategy(PrintStrategy printStrategy)
    {
        _printStrategy = printStrategy;
    }

    public void Print()
    {
        _printStrategy.Print();
    }
}
```
