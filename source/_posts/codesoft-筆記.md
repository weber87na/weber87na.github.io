---
title: codesoft 筆記
date: 2022-10-30 18:55:04
tags: codesoft
---
&nbsp;
<!-- more -->

### 安裝
[codesoft 載點](https://www.teklynx.com/tw-APAC/products/label-design-solutions/codesoft)
下載完後點試用 , 可以用 30 天來 try
有買 license 的話 , 也是直接點選 `試用` => `接著點工具` => `網路管理`
最後注意 ip 要打這樣 `\\123.45.67.89` , 不然沒法按下確定 

後來發現如果試用期過了的話 , 好像會直接跳出 license manager , codesoft 的主應用程式並不會出現
這時候請到以下位置 `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TEKLYNX CODESOFT 2019`
接著找到 `網路管理` 點開就可以設定了
右鍵看下他執行啥 , 原來是在 codesoft 後面加上參數 , 還真是機車的設計 `"C:\Program Files (x86)\Teklynx\CODESOFT 2019\CS.exe" /NetSetDlg`

### example
[c# example](https://www.teklynx.com/tw-APAC/products/label-design-solutions/codesoft/development-tool-samples)
開啟他的 example 以後 , 這個路徑 `C:\Users\Public\Documents\Teklynx\CODESOFT\Samples\Labels` 裡面有 `.Lab` 的 codesoft 標籤格式編輯範例可以參考
這個目錄裡面也有幾隻程式可以參考 `C:\Users\Public\Documents\Teklynx\CODESOFT\Samples\Integration`

### 自訂變數
選擇 `表單` => `新增變數` 然後就可以編輯啦 , 特別注意命名

### 列印時的坑
因為標籤大小通常都不是 A4 紙 , 所以測試時萬一使用 `輸出紙張規格` => `A4` 印出來會有問題 , 他整個比例會跑走
所以直接點選列印 , 接著到印表機上面去看 , 印表機會跳沒有紙 , 這時候應該有進階選項可以選擇 , 在印表機上面重新選擇 `A4` 即可正常列印

順手記下 powershell 撈目前所有的 [Printer](https://serverfault.com/questions/419866/list-all-printers-using-powershell)
``` powershell
Get-WMIObject Win32_Printer -ComputerName $env:COMPUTERNAME
```

### ZPL
原來條碼有自己的語言 `ZPL` , 又多認識一個該死的動物 `斑馬` , 看起來就是噁爛 , 順便記錄下有用的資訊
```
^XA

^FX Top section with logo, name and address.
^CF0,60
^FO50,50^GB100,100,100^FS
^FO75,75^FR^GB100,100,100^FS
^FO93,93^GB40,40,40^FS
^FO220,50^FDIntershipping, Inc.^FS
^CF0,30
^FO220,115^FD1000 Shipping Lane^FS
^FO220,155^FDShelbyville TN 38102^FS
^FO220,195^FDUnited States (USA)^FS
^FO50,250^GB700,3,3^FS

^FX Second section with recipient address and permit information.
^CFA,30
^FO50,300^FDJohn Doe^FS
^FO50,340^FD100 Main Street^FS
^FO50,380^FDSpringfield TN 39021^FS
^FO50,420^FDUnited States (USA)^FS
^CFA,15
^FO600,300^GB150,150,3^FS
^FO638,340^FDPermit^FS
^FO638,390^FD123456^FS
^FO50,500^GB700,3,3^FS

^FX Third section with bar code.
^BY5,2,270
^FO100,550^BC^FD12345678^FS

^FX Fourth section (the two boxes on the bottom).
^FO50,900^GB700,250,3^FS
^FO400,900^GB3,250,3^FS
^CF0,40
^FO100,960^FDCtr. X34B-1^FS
^FO100,1010^FDREF1 F00B47^FS
^FO100,1060^FDREF2 BL4H8^FS
^CF0,190
^FO470,955^FDCA^FS

^XZ
```

[labelary](http://labelary.com/zpl.html)
[ZPL 手冊](https://www.zebra.com/content/dam/zebra_new_ia/en-us/manuals/printers/common/programming/zpl-zbi2-pm-en.pdf)
[c# lib BinaryKits.Zpl](https://github.com/BinaryKits/BinaryKits.Zpl)

### csv 設定
[官方說明](https://teklynx.microsoftcrmportals.com/knowledgebase/article/KA-02412/en-us)
如果要用 csv 他的路徑在這個底下
C:\Users\Public\Documents\Teklynx\CODESOFT\DATA\MAILING.TXT
C:\Users\Public\Documents\Teklynx\CODESOFT\DSC\MAILING.DSC

注意到他需要認得 csv 的 header 吃 DSC , Field 應該就是 `表單變數`
`Field1=Code` `Code` 即為你的表單變數

`MAILING.DSC`
```
[CS_DataFileDesc]
Version=320
FileType=ASCII_DELIMITED
RecordDelimiter=\013
FieldDelimiter=,
CharSet=255
Fields=7
Field1=Code
Field2=Name
Field3=FirstName
Field4=Address
Field5=City
Field6=State
Field7=Zip
```

選擇 `資料庫` => `開啟 ASCII 表格` => `資料檔案 (CSV)` => `說明檔案 (DSC)`
都設定好以後點 `列印` => `資料庫` => `所有紀錄` => 看你有幾筆資料他就會讓你去挑選 , 也可以選 `目前記錄` 就只會印一筆

### 版本問題
後續遇到在本機 2019 寫得好好的 , 一上線就噴 null , 搞了半天是版本的問題
所以它是沒辦法用低版本的 instance 去讀高版本的檔案 , 這點要特別注意
```
this file has been created with a more recent designer 2019.02.00
```

### COM 元件引用問題
今天自己 try 發現會噴噴 `CS1752` 以下 error , [爬文](https://stackoverflow.com/questions/2483659/interop-type-cannot-be-embedded)發現只要這樣設定就好了在 `References` => `LabelManager2` => `右鍵` =>  `Properties` => `Embed Interop Types` => `False`
順帶一提如果是用 .net 6 的話也已經支援 com object 可以安心用
```
Error	CS1752	Interop type 'ApplicationClass' cannot be embedded. Use the applicable interface instead.
```

元件引用位置如下
```
C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Interop.LabelManager2\v4.0_19.0.0.0__1904804c83c4f22a\Interop.LabelManager2.dll
```

### 防止 2015 讀取 2019 lab 檔的錯誤處理 csharp lab
設定 `UseUserInterface` 為 `true` 會在工作管理員的 `應用程式` 看到 , 預設為 `false` 會在 `背景處理程序` 看到
本來以為設定這個才會出現 `MsgBox` 後來發現不用
```
var app = new Tkx.Lppa.Application();
//設定這個會在應用程式出現正常用不到
//app.UseUserInterface = true;
```

`Version` 屬性提供你的 codesoft 版本號 , 這個 debug 萬一有出現各個 server 安裝不同版應該很有幫助 , 他會印這樣 `2015.01.00 ` 注意結尾有空白!
`SerializationVersion` 屬性應該在 debug 也可以有些用處 , 會顯示該版本存檔的版號
```
Console.WriteLine(app.Version);

//顯示 codesoft 保存檔案的版本 2015 為 1004
Console.WriteLine(app.SerializationVersion);
```

使用 C# with .NET Wrapper 內的 dll 檔 `Lppanet` 寫起來會相對容易 , 因為有實作 `IEnumerable` 讓一些常用的物件可以 `foreach`
像是下面最常見的操作表單變數功能 , 這個如果寫沒包 .net 版本的會想哭
``` csharp
foreach (var variable in doc.Variables.FormVariables)
{
	Console.WriteLine(variable.Name);
	Console.WriteLine(variable.Value);
	Console.WriteLine(variable.DisplayValue);
}
```

先前有提到版本問題 , 後來我發現其實有這個 Event 可以使用 `MsgBoxInvoked`
像我用 2015 開啟 2019 檔案 , 會直接在 codesoft 軟體上面跳個 dialog 然後顯示這句
```
This file has been created with a more recent designer (2019.02.00 ).
Please upgrade your designer.
```

這個 Event 就算是低版本讀高版本的檔案也是可以觸發出來 , 所以很有用
```
private void NetApp_MsgBoxInvoked(object sender, Tkx.Lppa.MsgBoxInvokedEventArgs e)
{
	//1
	Console.WriteLine("result:" + e.Result);
	Console.WriteLine("message:" + e.Message);
	//code 14
	Console.WriteLine("code:" + e.Code);
}
```

另外還有兩個事件可以搭配使用 `DocumentOpened` `DocumentClosed`
先說 `DocumentOpened` , 這個事件只有成功讀取了檔案之後才會觸發 , 所以如果低版本讀高版本檔案實際上目前的 `Document` 為 `null`
接著是 `DocumentClosed` 他可以與先前的 `MsgBoxInvoked` 搭配 , 就算低版本的讀取高版本檔案 , 依然會觸發他
不過它們兩帶的有用訊息只有 `Name` 有點可惜
```
private void NetApp_DocumentClosed(object sender, Tkx.Lppa.DocumentEventArgs e)
{
	Console.WriteLine("Close");
	Console.WriteLine(e.Name);
}
```

接著講 `GetLastError` `ErrorMessage` 這兩個函數 , 他們倆要搭配使用
我測 2015 讀 2019 會噴這樣的 `Can't open LAB file` 訊息
正常是給 `0` 及 `No error`
```
var errCode = app.GetLastError();
var errMsg = app.ErrorMessage((short)errCode);
//Can't open LAB file
Console.WriteLine(errMsg);
```

我的情境是 2015 讀 2019 `Lab` 檔案 , 本來我想說直接把 `GetLastError` 寫在 `MsgBoxInvoked` 裡面 , 可是發現好像沒用 , 這點要特別注意
```
private void NetApp_MsgBoxInvoked(object sender, Tkx.Lppa.MsgBoxInvokedEventArgs e)
{
	//No error
	var errCode = app.GetLastError();
	var errMsg = app.ErrorMessage((short)errCode);
	Console.WriteLine(errMsg);

	//1
	Console.WriteLine("result:" + e.Result);
	Console.WriteLine("message:" + e.Message);
	//code 14
	Console.WriteLine("code:" + e.Code);

	//No error
	errCode = app.GetLastError();
	errMsg = app.ErrorMessage((short)errCode);
	Console.WriteLine(errMsg);

}
```

後來我又實驗 `DocumentClosed` 這次有 `error code 14` 但是沒訊息
```
private void NetApp_DocumentClosed(object sender, Tkx.Lppa.DocumentEventArgs e)
{
	Console.WriteLine("Close");
	Console.WriteLine(e.Name);

	//code = 14 疑似版本問題
	var errCode = app.GetLastError();
	var errMsg = app.ErrorMessage((short)errCode);
	Console.WriteLine(errMsg);
}
```

最後附上一個測試讀取的 example
``` csharp
Tkx.Lppa.Application app = new Tkx.Lppa.Application();
public void Run3()
{
	app.MsgBoxInvoked += NetApp_MsgBoxInvoked;
	app.DocumentOpened += NetApp_DocumentOpened;
	app.DocumentClosed += NetApp_DocumentClosed;

	//這個可以讓他的 event 生效
	app.EnableEvents = true;

	//設定這個會在應用程式出現正常用不到
	//NetApp.UseUserInterface = true;

	//2015 => 1004
	Console.WriteLine(app.SerializationVersion);

	//顯示版本
	Console.WriteLine(app.Version);

	var dir = System.Environment.CurrentDirectory;
	//var docPath = Path.Combine(dir, "App_Data", "Test2015.lab");
	var docPath = Path.Combine(dir, "App_Data", "Test2019.lab");

	var doc = app.Documents.Open(docPath, true);
	if (doc is null)
	{
		var errCode = app.GetLastError();
		var errMsg = app.ErrorMessage((short)errCode);
		Console.WriteLine(errMsg);
		throw new Exception(errMsg);
	}
	else
	{
		Console.WriteLine(app.ActiveDocument.FullName);
		Console.WriteLine(doc.FullName);
		Console.WriteLine(doc.Name);
		Console.WriteLine(doc.Version);
	}

	//讀表單變數
	foreach (var variable in doc.Variables.FormVariables)
	{
		Console.WriteLine("Name:" + variable.Name);
		Console.WriteLine("Value:" + variable.Value);
		Console.WriteLine("DisplayValue:" + variable.DisplayValue);
	}

	doc?.Close();
	app?.Quit();
}

private void NetApp_DocumentClosed(object sender, Tkx.Lppa.DocumentEventArgs e)
{
	Console.WriteLine("Close");
	Console.WriteLine(e.Name);

	//code = 14 疑似版本問題
	var errCode = app.GetLastError();
	var errMsg = app.ErrorMessage((short)errCode);
	Console.WriteLine(errMsg);
}

private void NetApp_MsgBoxInvoked(object sender, Tkx.Lppa.MsgBoxInvokedEventArgs e)
{
	//No error
	var errCode = app.GetLastError();
	var errMsg = app.ErrorMessage((short)errCode);
	Console.WriteLine(errMsg);

	//1
	Console.WriteLine("result:" + e.Result);
	Console.WriteLine("message:" + e.Message);
	//code 14
	Console.WriteLine("code:" + e.Code);

	//No error
	errCode = app.GetLastError();
	errMsg = app.ErrorMessage((short)errCode);
	Console.WriteLine(errMsg);
}

private void NetApp_DocumentOpened(object sender, Tkx.Lppa.DocumentEventArgs e)
{
	Console.WriteLine("Opened");
	Console.WriteLine(e.Name);
}
```

### MsgBoxInvoked 補充
這是後來翻為 .net 6 發現的問題 , 所以這裡沒用包成 .net 的 wrapper 而是呼叫 com object
實務上每台機器的顯示語言不同 有 `簡體` `繁體` `英文` , 所以導致我之前埋的 log 沒生效 , 所以需要依照語言來判斷
另外發現他的 `license` 如果滿的話在 `new Application` 就會直接掛掉 , 好像在這個 `MsgBoxInvoked` 埋 log 也沒用
我自己測起來他的 license server 滿的時候會踢人 , 不過踢誰不一定 , 這裡還是嘗試一手
此外這裡會有很多訊息 , 不是只有錯誤訊息 , 像是列印完成也會有訊息跑到這裡

``` csharp
private void ApplicationClass_MsgBoxInvoked(int nResult, int nCode, string strMessage)
{
	//這句在 license 滿了的話應該也不會觸發 , 因為 new Application 的時候就直接噴 com error 了
	//但是他 license server 踢人是不一定的 , 所以如果有觸發到的話就會記錄下來(不確定)
	//這裡的 strMessage 不只會記錄錯誤的訊息 , 印東西完他也會記錄
	if (string.IsNullOrEmpty(strMessage) == false)
	{
		var lang = applicationClass.Options.Language;
		switch (lang)
		{
			//這句可以得到是否使用正確版本開啟 codesoft , 萬一有開錯先 log 處理
			case enumLanguage.lppxEnglish:
				if (strMessage.Contains("This file has been created with a more recent designer") || 
					strMessage.Contains("The maximum number of authorized users has been reached") || 
					strMessage.Contains("No license has been found")
					)

				{
					SfcPrintApiSrv.InfoBag = strMessage;
					Logger.Fatal(strMessage);
				}
				break;
			case enumLanguage.lppxSimplifiedChinese:
				//此文件由最新版本的设计软件 (2019.02.00 ) 所生成。\n请升级您的设计软件。
				if (strMessage.Contains("此文件由最新版本的设计软件") || 
					strMessage.Contains("已达到授权用户最大数") ||
					strMessage.Contains("未找到许可证") )
				{
					SfcPrintApiSrv.InfoBag = strMessage;
					Logger.Fatal(strMessage);
				}
				break;
			case enumLanguage.lppxTraditionalChinese:
				//此文件由最新版本的軟件 (2019.02.00 )所生成.\n請升級您的軟件.
				if (strMessage.Contains("此文件由最新版本的軟件") || 
					strMessage.Contains("已經達到最大的授權使用者數目") ||
					strMessage.Contains("找不到授權"))
				{
					SfcPrintApiSrv.InfoBag = strMessage;
					Logger.Fatal(strMessage);
				}
				break;
			default:
				break;
		}
	}
}

```

### 圖片問題
特別注意轉圖片的部分需要一同將圖片複製到 2015 的機器上 , ex 假設有兩張圖片 `tmp0.jpg` `tmp1.jpg` 需要將他們從 2019 的機器上面複製到 2015 的機器底下

另外不要直接用 `base64 string` , 不明原因造成部分圖片會錯誤 , 應該呼叫 `WriteOriginalFile` 把圖挖出來
``` csharp
image.WriteOriginalFile($@"D:\jaguar\tmp{i}.jpg");
```

### 位置偏移問題
每個物件都會有以下片段 , 這個 Move 一定要呼叫 , 否則你就算設定了 Left Top 也不見得有用
``` csharp
saveImage.Move(image.Left, image.Top);
```

### 條碼字體大小問題
在 Barcode 裡面字體會有不正常的 bug , 不明原因讓 codesoft 讀出來的字體大小會是小數點 0.0008 , 所以要乘 10000f
``` csharp
saveBarcode.HRFont = new Font(barcode.FontName, barcode.FontSize * 10000f);
```

### 條碼長度問題
2015 條碼的 `NarrowBarWidthDot` 屬性 `必須乘 2` , 不然會縮水只有一半長度
``` csharp
saveBarcode.NarrowBarWidthDot = barcode.NarrowBarWidthDot * 2;
```


### 讀取及建立 Text
我觀察他的封裝好像沒很完整 , 就算你用 foreach 也是會噴 null 之類的錯誤 , 所以要像下面這樣建立物件才對
另外你設定 Left & Top 實際上不見得有用 , 我後來發現呼叫 Move 函數才能正常
最後就是他字體大小好像也有 bug , 字體要乘 10000f , 其他物件建立方法也類似 , 就不一一列舉了
```
public void CreateTexts(DocDto doc, Document save)
{
	var count = doc.TextDtos.Count;
	for (int i = 0; i < count; i++)
	{
		var text = doc.TextDtos[i];
		var saveText = save.DocObjects.Texts.Add(text.Name);
		saveText.Name = text.Name;

		var rotation = (RotationAngle)Enum.Parse(typeof(RotationAngle), text.Rotation);
		saveText.Rotation = rotation;

		//datasource
		saveText.DataSourceNames = text.DataSourceNames;
		saveText.VariableName = text.VariableName;

		if (string.IsNullOrEmpty(text.DataSourceNames))
		{
			//字的內容設定
			saveText.Value = text.Value;
		}

		//font
		saveText.FontName = text.FontName;
		saveText.FontHeight = text.FontHeight;
		saveText.FontWidth = text.FontWidth;

		//todo 這句正常 FontSize 應該會顯示 12 , 可是 codesoft 這裡面疑似有 bug , 所以這裡要乘 10000f , 另外設定完也不見得 100% 準確
		saveText.Font = new Font(text.FontFamilyName, text.FontSize * 10000f);

		//位置
		saveText.Left = text.Left;
		saveText.Top = text.Top;
		saveText.Width = text.Width;
		saveText.Height = text.Height;

		saveText.MarginLeft = text.MarginLeft;
		saveText.MarginRight = text.MarginRight;
		saveText.MarginTop = text.MarginTop;
		saveText.MarginBottom = text.MarginBottom;

		var alignment = (Alignment)Enum.Parse(typeof(Alignment), text.Alignment);
		saveText.Alignment = alignment;
		var verticalAlignment = (VerticalAlignment)Enum.Parse(typeof(VerticalAlignment), text.VerticalAlignment);
		saveText.VerticalAlignment = verticalAlignment;

		saveText.Bold = text.Bold;
		saveText.Italic = text.Italic;

		var anchorPoint = (AnchorPointPosition)Enum.Parse(typeof(AnchorPointPosition), text.AnchorPoint);
		saveText.AnchorPoint = anchorPoint;

		//todo: 這句一定要呼叫不然會偏移
		saveText.Move(text.Left, text.Top);
	}
}
```

### Error code table
說明文件路徑在此 `C:\Program Files (x86)\Teklynx\CODESOFT 2019\Help\ActiveXa.chm`

| Key  | Value                                                    |
| ---- | -------------------------------------------------------- |
| 0    | No error                                                 |
| 1100 | Can't open TXT file                                      |
| 1101 | Can't open QRY file                                      |
| 1102 | Can't open DSC file                                      |
| 1103 | Can't open LAB file                                      |
| 1104 | Can't open POC file                                      |
| 1105 | Can't open LOG file                                      |
| 1200 | Can't open data file                                     |
| 1201 | Can't open query file                                    |
| 1202 | Can't open descriptor file                               |
| 1203 | Can't open label file                                    |
| 1204 | Can't open POC file                                      |
| 1205 | Can't open log file                                      |
| 1208 | Can't open BACKGROUND file                               |
| 1300 | Printer not found                                        |
| 1301 | Driver not found                                         |
| 1302 | Printlabel not supported with several document.          |
| 1400 | Incorrect Datasource enum value                          |
| 1401 | Incorrect Rotation enum value                            |
| 1402 | Incorrect HRAlign enum value                             |
| 1403 | Incorrect HRPosition enum value                          |
| 1404 | Incorrect HR check digit enum value                      |
| 1405 | Incorrect Anchor point enum value                        |
| 1406 | Incorrect counter base enum value                        |
| 1407 | Incorrect Label object enum value                        |
| 1408 | Incorrect view size enum value                           |
| 1409 | Incorrect view mode enum value                           |
| 1410 | Incorrect MeasureSystem enum value                       |
| 1411 | Incorrect dialog type enum value                         |
| 1412 | Incorrect language enum value                            |
| 1413 | Incorrect symbology enum value                           |
| 1414 | Incorrect built in document property enum value          |
| 1415 | Incorrect view orientation enum value                    |
| 1416 | Incorrect form prompt mode enum value                    |
| 1500 | Object not found                                         |
| 1501 | Can't create object                                      |
| 1502 | Variable not found                                       |
| 1503 | Can't create variable                                    |
| 1504 | Invalid font object                                      |
| 1505 | Invalid variable object                                  |
| 1506 | Name of item already used                                |
| 1507 | Property dependency failed                               |
| 1600 | Database not connected                                   |
| 1601 | Database connection failed                               |
| 1602 | TableLookup DSN not found                                |
| 1700 | Input mask not empty                                     |
| 1701 | Invalid data                                             |
| 1702 | Your counter value is outside of the allowed value range |
| 1703 | Superimposing is not allowed for some objects.           |
| 1704 | Error during the change of base.                         |
| 1800 | Shared variable violation                                |
| 1900 | Can't generate POC file                                  |
| 2000 | Number must be positive                                  |
| 2001 | Data type must be a boolean                              |
| 2002 | Invalid path                                             |
| 2003 | File already exists                                      |
| 2100 | Can't prompt dialog box (no active document)             |
| 3000 | Not sufficient access rights to perform this operation   |
| 3001 | No license found                                         |

### 列印偏移 撕線
如果有遇到列印偏移的問題 , 當程式與樣板都確認過沒問題 , 八成會是買標籤貼紙時沒有 `撕線` 搞得鬼
如果不是搞這個 case 我也是第一次知道這鬼東西
他的術語大概是以下幾種說法 , 我也不是很確定

* `虛線刀`
* `撕線`
* `騎縫線`
* `米線`
* `dotted line knife`
* `Dotted line Cutting knife`

可以看這個 [影片](https://www.aliexpress.com/i/1005003275044420.html) 認識看看
如果沒有這個虛線刀的痕跡 , 非常容易發生偏移狀況 , 然後互推責任開始吵架弄到都煩
長官最後想的解法竟然是在 `標籤` 跟 `標籤` 中間拿黑筆畫線 , 讓標籤機感應到 , 這標籤機也通靈 , 先畫個幾張定位就準了 , 真是暴雷的經驗...

### 暴雷的 Margin 單位問題
他這裡邊界 `MarginTop` `MarginLeft` `PageHeight` `PageWidth` 有個很雷的點 , 例如你設定邊界是 `3mm`
然而實際上他都要 `乘 100` , 所以變成 `3 * 100 = 300` , 超無言 XD
而且我翻文件好像都沒發現這個說明 , 我自己在 2015 2019 驗證過
可以用下面段 code 來驗證
``` csharp
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using LabelManager2;

namespace ConsoleAppPrint
{
    class Program
    {
        static void Main(string[] args)
        {
            var app = new ApplicationClass();
            string path = "D:\\Test.lab";
            _ = app.Documents.Open(path, false);
            var doc = app.ActiveDocument;

            Debug.WriteLine("MarginTop" + doc.Format.MarginTop);
            Debug.WriteLine("MarginLeft" + doc.Format.MarginLeft);
            Debug.WriteLine("PageHeight" + doc.Format.PageHeight);
            Debug.WriteLine("PageWidth" + doc.Format.PageWidth);

        }
    }
}
```
