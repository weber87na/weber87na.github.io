---
title: NCL Color Bar 轉換
date: 2020-07-15 01:20:49
tags:
- ncl
- c#
- geoserver
---
&nbsp;
<!-- more -->
&nbsp;&nbsp;&nbsp;&nbsp;
<!-- more -->
工作上常常會遇到一些圖表呈現或是數值呈現 , 這時候就需要好看的 Color Bar!
<img src="https://www.ncl.ucar.edu/Document/Graphics/ColorTables/Images/MPL_gist_rainbow_tibet.png" />
還好以前搞過 [NCL](https://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml) 上面有不少漂亮的 Color Bar 可以[下載](http://www.ncl.ucar.edu/Document/Graphics/ColorTables/Files/) 比較好看的大概就是 MPL 開頭的 , 下載下來的檔案會像是以下這種格式

```
ncolors= 128
# r g b
0.572226 0.834894 0.777009
0.610796 0.849781 0.770242
0.649366 0.864667 0.763476
0.687935 0.879554 0.756709
```

但是一般常用的多半是 HEX 很多年前寫個 c# 小程式轉換 , 不過印象中 NCL 好像自己就有類似的函數
``` csharp
//讀取color文字檔
//name , r , g , b
//轉換 rgb 為 hex
var files = Directory.EnumerateFiles(@"D:\rgb\", "*.rgb");

foreach (var file in files)
{
	var fileName = Path.GetFileNameWithoutExtension(file);

	var lines = File.ReadAllLines(@"D:\rgb\" + fileName + ".rgb");
	List<string> colorList = new List<string>();

	//寫入檔案
	var flag = false;
	var skipColorCount = 0;
	List<string> hexs = new List<string>();

	int skip = 2;
	int counter = 1;
	foreach (var line in lines)
	{
		if (counter <= skip)
		{
			counter++;
			continue;
		}

		flag = !flag;
		if (flag == false)
		{
			continue;
		}

		//skipColorCount++;
		//if (skipColorCount % 16 != 0)
		//{
		//    continue;
		//}

		var lineResult = line.Split(' ');
		//string name = lineResult[0];
		int r = Convert.ToInt32(Convert.ToDouble(lineResult[0]) * 255.0);
		int g = Convert.ToInt32(Convert.ToDouble(lineResult[1]) * 255.0);
		int b = Convert.ToInt32(Convert.ToDouble(lineResult[2]) * 255.0);
		Color color = Color.FromArgb(r, g, b);

		string hex = color.R.ToString("X2") + color.G.ToString("X2") + color.B.ToString("X2");

		hexs.Add(hex);

		//writer.WriteLine("#{0}", hex);

		//writer.WriteLine(string.Format("<option value='{0}' style='background: #{1};'>{0}</option>", name, hex));
	}

	using (StreamWriter writer = new StreamWriter(@"D:\rgb\" + fileName + ".txt"))
	{
		foreach (var hex in hexs)
		{
			writer.WriteLine("#{0}", hex);
		}
	}

	hexs.Reverse();
	using (StreamWriter writer = new StreamWriter(@"D:\rgb\" + fileName + "-inv.txt"))
	{
		foreach (var hex in hexs)
		{
			writer.WriteLine("#{0}", hex);
		}
	}
}

```
如果不夠用的話也可以試試 ncwms 設計的 [Color Bar](https://github.com/Reading-eScience-Centre/edal-java/tree/master/graphics/src/main/resources/palettes)
<img src="https://reading-escience-centre.gitbooks.io/ncwms-user-guide/content/images/palettes.png" />
