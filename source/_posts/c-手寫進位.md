---
title: c# 手寫進位
date: 2023-01-04 18:58:04
tags: c#
---
&nbsp;
<!-- more -->
工作上遇到的問題 , 搞得像是寫 leetcode , 順手筆記下 , 難得寫這種燒腦的東西

### 數字進位
如果是 `9` 的話直接把數字換成 `0` , 接著看看下個位數是否也是 `9`
反之將目前數字 +1 進位 , 當數字為 `99999` 時則回到 `00000`

```
//目前號碼
string[] numbers = new string[] { "9", "9", "8", "9", "9" };

int current = numbers.Length - 1;
while (current >= 0)
{
    if (numbers[current] == "9")
    {
        numbers[current] = "0";
    }
    else
    {
        var num = Convert.ToInt32(numbers[current]) + 1;
        numbers[current] = num.ToString();

        //當進位直接跳出
        break;
    }
    current--;
}

foreach (var item in numbers) Console.Write(item.ToString());

```

### 客製進位規則
編號首碼可以用 `0-9 a-z` , 排除 `I` , `O`
從 `00000` 開始 , 當數字為 `99999` 時 , 則進位到 `A0000`
當數字為 `A9999` 時進位 `B0000` 以此類推
共 `34` 個字母 , 所以組成 `34 * 10000` 個組合

這裡邏輯要調整下 , 多插個 head 的防守在前面處理即可
```
public class NumberGenerator
{
	/// <summary>
	/// 取得下個固定五碼的 SerialNumber
	/// </summary>
	/// <param name="currentSerialNumber">目前的 SerialNumber</param>
	/// <returns></returns>
	public string GetNext(string currentSerialNumber)
	{
		//轉換 string array , 不要用 char array 免得又要額外處理 ascii 相關問題
		var currentSerialNumberArray = currentSerialNumber.ToCharArray().Select(c => c.ToString()).ToArray();

		int current = currentSerialNumberArray.Length - 1;

		//當數字為 09 時 , 他會先去把 0 補起來
		//接著在跑 else 那句進位 , 所以輸出 10
		//當數字為 99999 時會回歸原點 00000
		while (current >= 0)
		{
			//假如到頭了
			//09999 => 0 是頭
			if (current == 0)
			{
				string head = currentSerialNumberArray[current];
				if(head != "Z")
				{
					int headCarryPos = codeList.IndexOf(head);

					//取得下個頭編號數字 or 字母
					string carryHead = codeList[headCarryPos + 1];

					//設定目前的頭進位
					currentSerialNumberArray[current] = carryHead;
				}
				else
				{
					//已經到 Z , 設定為 0 , 理論上不會有這麼多編號 , 如果走到這裡就表示東西壞了
					currentSerialNumberArray[current] = "0";
				}
				break;
			}


			//計算頭以外的進位方式
			if (currentSerialNumberArray[current] == "9")
			{
				currentSerialNumberArray[current] = "0";
			}
			else
			{
				//普通情況直接進位
				var num = Convert.ToInt32(currentSerialNumberArray[current]) + 1;
				currentSerialNumberArray[current] = num.ToString();

				//當進位直接跳出
				break;
			}
			current--;
		}

		//組合結果 serialNumber
		StringBuilder result = new StringBuilder();
		foreach (var item in currentSerialNumberArray)
			result.Append(item.ToString());

		return result.ToString();
	}

	private readonly List<string> codeList = new List<string> {
		  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		  "A", "B", "C", "D", "E", "F", "G", "H", "J", "K",
		  "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V",
		  "W", "X", "Y", "Z"
	};
```

順便補個單元測試 , 如果是 `MSTest` `TestCase` 則用 `DataRow` 代替
```
public class Tests
{
	[SetUp]
	public void Setup()
	{
	}

	[TestCase("00000","00001")]
	[TestCase("00099","00100")]
	[TestCase("99999","A0000")]
	[TestCase("89999","90000")]
	[TestCase("A0000","A0001")]
	[TestCase("A0001","A0002")]
	[TestCase("A0009","A0010")]
	[TestCase("A0789","A0790")]
	[TestCase("A9999","B0000")]
	[TestCase("Z9999","00000")]
	public void CarryNumAreEqual(
		string currentNumber,
		string expected)
	{
		NumberGenerator generator = new NumberGenerator();
		string serialNumber = generator.GetNext(currentNumber);
		Assert.AreEqual(expected, serialNumber);
	}
}

```


### 遞迴數字進位
```
//var serialNumber = new SerialNumber(new string[] { "0", "1", "9" });
var serialNumber = new SerialNumber("019");
var result = serialNumber.GetNextNumber();
Console.WriteLine(result);
Console.Read();

public class SerialNumber
{
    private string[] numbers = new string[] { };
    public string[] Numbers { get { return numbers; } }
    public SerialNumber(string[] numbers)
    {
        this.numbers = numbers;
    }

    public SerialNumber(string numbers)
    {
        var chars = numbers.ToArray();
        List<string> strs = new List<string>();
        foreach (var item in chars) strs.Add(item.ToString());
        this.numbers = strs.ToArray();
    }

    //是否需要進位
    bool needCarryNum = true;

    //取得下個號碼
    public string GetNextNumber()
    {
        //重設狀態
        needCarryNum = true;
        return this.Calc(this.Numbers);
    }
    private string Calc(string[] numbers)
    {
        if (numbers.Length > 0)
        {
            //取得目前的元素
            var take = numbers.Take(1).ToArray()[0];

            //取得 splice 後的 array 讓他可以丟下去當遞迴參數
            var arr = numbers.Skip(1).ToArray();

            //假設資料為 0 1 9
            //運用遞迴 cache data , 首個會是 empty string => 9 => 1 => 0
            //所以最後這個會輸出 019 這樣的正序
            string cache = Calc(arr);

            if (take == "9" && needCarryNum == true)
                return "0" + cache;

            int n = 0;
            if (needCarryNum)
            {
                n = Convert.ToInt32(take) + 1;
                needCarryNum = false;
            }
            else
            {
                n = Convert.ToInt32(take);
            }

            return n.ToString() + cache;
        }

        return "";
    }
}
```


### 客製進位規則遞迴
```
public class SerialNumberGeneratorRecursive
{
    private int headLen = 0;
    private string[] numbers = new string[] { };
    public string[] Numbers { get { return numbers; } }
    public SerialNumberGeneratorRecursive(string[] numbers)
    {
        this.numbers = numbers;
        this.headLen = numbers.Length;
    }

    public SerialNumberGeneratorRecursive(string numbers)
    {
        var chars = numbers.ToArray();
        List<string> strs = new List<string>();
        foreach (var item in chars) strs.Add(item.ToString());
        this.numbers = strs.ToArray();
        this.headLen = numbers.Length;
    }

    //是否需要進位
    bool needCarryNum = true;

	private readonly List<string> codeList = new List<string> {
		  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		  "A", "B", "C", "D", "E", "F", "G", "H", "J", "K",
		  "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V",
		  "W", "X", "Y", "Z"
	};

    //取得下個號碼
    public string GetNextNumber()
    {
        //重設狀態
        needCarryNum = true;
        return this.Calc(this.Numbers);
    }
    private string Calc(string[] numbers)
    {
        if (numbers.Length > 0)
        {
            //取得目前的元素
            var take = numbers.Take(1).ToArray()[0];

            //取得 splice 後的 array 讓他可以丟下去當遞迴參數
            var arr = numbers.Skip(1).ToArray();

            //假設資料為 0 1 9
            //運用遞迴 cache data , 首個會是 empty string => 9 => 1 => 0
            //所以最後這個會輸出 019 這樣的正序
            string cache = Calc(arr);

            //假設已經走到頭部
            if (numbers.Length == headLen)
            {
                int headCarryPos = codeList.IndexOf(take);
                if (needCarryNum)
                {
                    if (take != "Z")
                    {
                        //取得下個頭編號數字 or 字母 非 Z 的話往下進位
                        string carryHead = codeList[headCarryPos + 1];
                        return carryHead + cache;
                    }

                    //Z99 這種情況直接回傳 000
                    return "0" + cache;
                }
                else
                {
                    //取得下個頭編號數字 or 字母 Z 的話保持 Z
                    string carryHead = codeList[headCarryPos];
                    return carryHead + cache;
                }
            }
            else
            {
                //假設走到 9 直接進位
                if (take == "9" && needCarryNum == true) return "0" + cache;

                //正常進位
                int n = 0;
                if (needCarryNum)
                {
                    n = Convert.ToInt32(take) + 1;
                    needCarryNum = false;
                }
                else
                {
                    n = Convert.ToInt32(take);
                }

                return n.ToString() + cache;
            }

        }

        //遞迴最深處
        return "";
    }
}


[TestClass]
public class UnitTestSerialNumberUseRecursive
{
	[TestMethod()]
	public void CarryNum_Z8999_Next_Z9000()
	{
		var generator = new SerialNumberGeneratorRecursive("Z8999");
		string serialNumber = generator.GetNextNumber();
		Assert.AreEqual("Z9000", serialNumber);
	}

	[TestMethod()]
	public void CarryNum_08999_Next_09000()
	{
		var generator = new SerialNumberGeneratorRecursive("08999");
		string serialNumber = generator.GetNextNumber();
		Assert.AreEqual("09000", serialNumber);
	}

	[TestMethod()]
	public void CarryNum_00000_Next_00001()
	{
		var generator = new SerialNumberGeneratorRecursive("00000");
		string serialNumber = generator.GetNextNumber();
		Assert.AreEqual("00001", serialNumber);
	}

	[TestMethod()]
	public void CarryNum_Z99_Next_000()
	{
		var generator = new SerialNumberGeneratorRecursive("Z99");
		string serialNumber = generator.GetNextNumber();
		Assert.AreEqual("000", serialNumber);
	}

	[TestMethod()]
	public void CarryNum_Y99_Next_Z00()
	{
		var generator = new SerialNumberGeneratorRecursive("Y99");
		string serialNumber = generator.GetNextNumber();
		Assert.AreEqual("Z00", serialNumber);
	}
}
```


### 16進位
這裡定義一個環狀取得進位
```
public class SerialNumberRing
{
    private readonly List<string> carryRing = new List<string> {
          "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
          "A", "B", "C", "D", "E", "F",
    };

    public readonly List<string> CarryRing16 = new List<string> {
          "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
          "A", "B", "C", "D", "E", "F",
    };

    public SerialNumberRing()
    {
        carryRing = CarryRing16;
    }
    public SerialNumberRing(List<string> carryRing)
    {
        this.carryRing = carryRing;
    }

    private string GetNextCarry(string num)
    {
        var index = carryRing.IndexOf(num);
        if(index == carryRing.Count - 1) return carryRing[0];

        var carry = carryRing[index + 1];
        return carry;
    }

    public string GetNext(string numbers)
    {
        var currentNumberArray = numbers.ToCharArray().Select(c => c.ToString()).ToArray();
        return GetNext(currentNumberArray);
    }

    public string GetNext(string[] numbers)
    {
        int current = numbers.Length - 1;
        while (current >= 0)
        {
            if(numbers[current] == carryRing[ carryRing.Count - 1])
            {
                numbers[current] = carryRing[0];
            }
            else
            {
                var num = numbers[current];
                var carry = GetNextCarry(num);
                numbers[current] = carry;
                break;
            }
            current--;
        }
        
        string result = BuildResult(numbers);
        return result;
    }

    private string BuildResult(string[] numbers)
    {
        string result = "";
        foreach (var item in numbers) result += item.ToString();
        return result;
    }
}


[TestClass()]
public class UnitTestSerialNumberRingUseLoop
{
	[DataRow("00000", "00001")]
	[DataRow("00009", "0000A")]
	[DataRow("0000A", "0000B")]
	[DataRow("0000F", "00010")]
	[DataRow("FFF", "000")]
	[DataRow("FFE", "FFF")]
	[DataRow("FF9", "FFA")]
	[TestMethod()]
	public void CarryNumAreEqual(
		string currentNumber,
		string expected)
	{
		var generator = new SerialNumberRing();
		string serialNumber = generator.GetNext(currentNumber);
		Assert.AreEqual(expected, serialNumber);
	}
}

```
