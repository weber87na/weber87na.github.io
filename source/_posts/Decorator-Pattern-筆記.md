---
title: Decorator Pattern 筆記
date: 2023-06-26 18:34:00
tags:
- design pattern
- c#
---
&nbsp;
<!-- more -->

一樣翻自 java , 這裡最大重點就是 `new` 出物件的時候不要用 `var` , 要明確指明 `Beverage` 不然就發揮不出他寫很爽的裝飾感
實務上自己是沒這樣寫過 , 看老外是包 log 可以看[這篇](https://www.csharptutorial.net/csharp-design-patterns/csharp-decorator-pattern/)

```
//這裡不要用 var 要明確給 Beverage 型別不然會有問題
Beverage espresso = new Espresso();
Console.WriteLine(espresso.Description);
Console.WriteLine(espresso.Cost());
Console.WriteLine();

//加牛奶
espresso = new Milk(espresso);
Console.WriteLine(espresso.Description);
Console.WriteLine(espresso.Cost());
Console.WriteLine();

//雙倍牛奶
espresso = new Milk(espresso);
Console.WriteLine(espresso.Description);
Console.WriteLine(espresso.Cost());
Console.WriteLine();

//加奶油
espresso = new Whip(espresso);
Console.WriteLine(espresso.Description);
Console.WriteLine(espresso.Cost());

//Component
abstract class Beverage
{
    public virtual string Description
    {
        get;
        set;
    } = "Unknown beverage";

    public virtual double Cost() { return 0; }

    public virtual void Style()
    {
        Console.WriteLine("this is a taiwanese style coffee");
    }
}

class Decaf : Beverage
{
    public Decaf()
    {
        Description = "Decaf";
    }
    public override double Cost()
    {
        return 125;
    }
}

class HouseBlend : Beverage
{
    public HouseBlend()
    {
        Description = "HouseBlend";
    }
    public override double Cost()
    {
        return 300;
    }
}


class Espresso : Beverage
{
    public Espresso()
    {
        Description = "Espresso";
    }
    public override double Cost()
    {
        return 150;
    }

}


class DarkRoast : Beverage
{
    public DarkRoast()
    {
        Description = "DarkRoast";
    }
    public override double Cost()
    {
        return 250;
    }
}

//調味料
class CondimentDecorator : Beverage
{
    protected Beverage Beverage;
    public override string Description { get => base.Description; set => base.Description = value; }
}


class Milk : CondimentDecorator
{
    public Milk(Beverage beverage)
    {
        this.Beverage = beverage;
    }

    public override double Cost()
    {
        return this.Beverage.Cost() + 75;
    }

    public override string Description
    {
        get => this.Beverage.Description + " Milk";
        set => base.Description = value;
    }
}

class Whip : CondimentDecorator
{
    public Whip(Beverage beverage)
    {
        this.Beverage = beverage;
    }

    public override double Cost()
    {
        return this.Beverage.Cost() + 15;
    }

    public override string Description
    {
        get => this.Beverage.Description + " Whip";
        set => base.Description = value;
    }
}

class Soy : CondimentDecorator
{
    public Soy(Beverage beverage)
    {
        this.Beverage = beverage;
    }

    public override double Cost()
    {
        return this.Beverage.Cost() + 25;
    }

    public override string Description
    {
        get => this.Beverage.Description + " Soy";
        set => base.Description = value;
    }
}

class Mocha : CondimentDecorator
{
    public Mocha(Beverage beverage)
    {
        this.Beverage = beverage;
    }

    public override double Cost()
    {
        return this.Beverage.Cost() + 50;
    }

    public override string Description
    {
        get => this.Beverage.Description + " Mocha";
        set => base.Description = value;
    }

    public override void Style()
    {
        base.Style();
        Console.WriteLine("Also, it has italian style...");
    }
}

```
