---
title: c# 影像處理筆記
date: 2024-11-01 12:10:34
tags: c#
---


<p class="codepen" data-height="600" data-default-tab="result" data-slug-hash="OJKqXXL" data-pen-title="LaSai Image Processing" data-user="weber87na" style="height: 600px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/OJKqXXL">
  LaSai Image Processing</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>


<!-- more -->

最近練習 c 語言, 剛好拿個影像處理的 code 轉為 c# 玩看看, 順手筆記下

## 灰階

他原始 c 的 code 如下

這裡要注意 `bitDepth` 若為 24 則表示有 RGB 三色, 大小則為 `height * width * 3`
`bitDepth` 小於等於 8 則吃 `colorTable` 開闢的大小為 `height * width`

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    FILE *fIn = fopen("images/lena_color.bmp", "rb");
    FILE *fOut = fopen("images/lena_gray.bmp", "wb");

    unsigned char imgHeader[54];
    unsigned char colorTable[1024];

    if (fIn == NULL)
    {
        printf("Unable to open image\n");
    }

    for (int i = 0; i < 54; i++)
        imgHeader[i] = getc(fIn);

    fwrite(imgHeader, sizeof(unsigned char), 54, fOut);

    int height = *(int *)&imgHeader[22];
    int width = *(int *)&imgHeader[18];
    int bitDepth = *(int *)&imgHeader[28];

    if (bitDepth <= 8)
    {
        fread(colorTable, sizeof(unsigned char), 1024, fIn);
        fwrite(colorTable, sizeof(unsigned char), 1024, fOut);
    }

    int imgSize = height * width;
    unsigned char buffer[imgSize][3];

    for (int i = 0; i < imgSize; i++)
    {
        buffer[i][0] = getc(fIn);
        buffer[i][1] = getc(fIn);
        buffer[i][2] = getc(fIn);

        int temp = 0;
        temp = (buffer[i][0] * 0.3) + (buffer[i][1] * 0.59) + (buffer[i][2] * 0.11);

        putc(temp, fOut);
        putc(temp, fOut);
        putc(temp, fOut);
    }

    printf("Success!\n");
    fclose(fIn);
    fclose(fOut);

    return 0;
}
```

轉為 c# 如下, 有 chatgpt 真速度 XD

自己覺得比較難的點應該是這句 `int width = *(int *)&imgHeader[18];` 他會撈 `18 19 20 21` 這塊 data
在 c# 則是用 `int width = BitConverter.ToInt32(imgHeader, 18)` 讓他去撈這塊
這邊如果直接寫成 `int width = imgHeader[18];` 的話就取錯數值了

此外 c# 的 `2d array` 是用 `[,]` 表示
如果寫成 `[][]` 則表示 `jagged array` 這點跟 c 不太一樣

還有 c 的 `unsigned char` 在 c# 是用 `byte`

讀取的部分 c# 則是用函數 Read 就可以一口氣讀取 `int bytesRead = fIn.Read(imgHeader, 0, imgHeader.Length)`, 不用搞個 loop

還有他的範例 code 顏色順序是 `RGB`, 懷疑可能是錯的 XD?
我記憶中應該是 `BGR` 才正確, 所以修正下


```
string inputFilePath = "images/lena_color.bmp";
string outputFilePath = "images/lena_gray.bmp";

// 打開輸入和輸出文件
using FileStream fIn = new FileStream(inputFilePath, FileMode.Open, FileAccess.Read);
using FileStream fOut = new FileStream(outputFilePath, FileMode.Create, FileAccess.Write);

byte[] imgHeader = new byte[54];
byte[] colorTable = new byte[1024];

// 讀取 BMP 標頭
int bytesRead = fIn.Read(imgHeader, 0, imgHeader.Length);
if (bytesRead != imgHeader.Length)
{
    Console.WriteLine("Unable to read image header");
    return;
}

// 寫入標頭到輸出文件
fOut.Write(imgHeader, 0, imgHeader.Length);

// 獲取圖像的寬度、高度和位深度
int height = BitConverter.ToInt32(imgHeader, 22);
int width = BitConverter.ToInt32(imgHeader, 18);
int bitDepth = BitConverter.ToInt16(imgHeader, 28);

Console.WriteLine($"height: {height}");
Console.WriteLine($"width: {width}");
Console.WriteLine($"bitDepth: {bitDepth}");

// 如果位深度小於等於 8，讀取顏色表
if (bitDepth <= 8)
{
    fIn.Read(colorTable, 0, colorTable.Length);
    fOut.Write(colorTable, 0, colorTable.Length);
}

// 計算圖像大小
int imgSize = height * width;
byte[,] buffer = new byte[imgSize, 3];

// 讀取圖像數據並轉換為灰階
for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    buffer[i, 0] = (byte)blue;
    buffer[i, 1] = (byte)green;
    buffer[i, 2] = (byte)red;

    int temp = 0;
    //轉換灰階公式 
    //R * 0.299 + G * 0.587 + B * 0.114
    temp = (int)(red * 0.299) + (int)(green * 0.587) + (int)(blue * 0.114);
    fOut.WriteByte((byte)temp);
    fOut.WriteByte((byte)temp);
    fOut.WriteByte((byte)temp);
}


Console.WriteLine("Success!");
```

## 二值化

二值化只需要給個 threshold 當小於 threshold 則給黑色 0, 大於則給白色 255

```
gray = (int)(red * 0.299) + (int)(green * 0.587) + (int)(blue * 0.114);
binValue = 0;
if(gray < threshold) binValue = 0;
else binValue = 255;
fOut.WriteByte((byte)binValue);
fOut.WriteByte((byte)binValue);
fOut.WriteByte((byte)binValue);
```

## 亮度

亮度調整則是看要變亮還是變暗, 變亮的話就讓數值往 255 靠攏, 反之則往 0 靠攏即可
這裡往暗部調整練下指標, 他直接用 void, 參數要用 `unsigned char *value`, 呼叫時記得加上 `&` 符號即可, 像這樣 `to_darkness(&buffer[i][0])`

```
#define BRIGHTNESS 50
#define DARKNESS 50

int to_brightness(int value)
{
    if (value + BRIGHTNESS >= 255)
        return 255;
    else
        return value + BRIGHTNESS;
}

//用法
//to_darkness(&buffer[i][0]);
void to_darkness(unsigned char *value)
{
    if (*value - DARKNESS <= 0)
        *value = 0;
    else
        *value = *value - DARKNESS;
}



int main(){
	//略
}
```

這裡 c# 的寫法如下, 首先需要在 `csproj` 裡面設定打開 `unsafe` 功能

```
 <PropertyGroup>
   <OutputType>Exe</OutputType>
   <TargetFramework>net8.0</TargetFramework>
   <ImplicitUsings>enable</ImplicitUsings>
   <Nullable>enable</Nullable>
<!-- 加入這行打開 unsafe 功能 -->
   <AllowUnsafeBlocks>True</AllowUnsafeBlocks>
 </PropertyGroup>
```

接著寫亮度調整的函數, 比較特別的是需要在函數開頭加上 `unsafe` 關鍵字

```
unsafe void ToBrightness(byte* value)
{
    const int BRIGHTNESS = 100;
    if (*value + BRIGHTNESS >= 255) *value = 255;
    else *value += BRIGHTNESS;
}


unsafe void ToDarkness(byte* value)
{
    const int DARKNESS = 100;
    if (*value - DARKNESS <= 0) *value = 0;
    else *value -= DARKNESS;
}
```

呼叫時要先開一個 `unsafe` 區塊, 用 `fixed` 撈指標, 最後跟 c 一樣呼叫就可以惹, 整個炫炮 ~

```
unsafe
{
	for (int j = 0; j < 3; j++)
	{
		fixed (byte* ptr = &buffer[i, j])
		{
			ToBrightness(ptr);
			fOut.WriteByte(*ptr);
		}
	}
}
```

## 直方圖 Histogram

這裡的 c# code 如下
首先開闢 `int[,] ihist = new int[3, 256]` 來放 bgr 每個 pixel 的色彩索引
因為色彩會由 `0 ~ 255` 共 `256` 個值, 開闢空間要注意下 `不要寫成 255`, 這裡一樣用 `bgr` 的順序來記錄

接著開一個 sum array 來存目前 pixel 數量

然後用 for loop 把目前 pixel 的 index 與 sum 保存起來

接著宣告 `float[,] hist = new float[3, 256]` 來保存結果
用 loop 將 `保存色彩數值 / sum` 來取得每個點位直方圖的數值即可

```
string inputFilePath = "images/lena_color.bmp";
string outputFilePath = "images/histogram_rgb.txt";

// 打開輸入和輸出文件
using FileStream fIn = new FileStream(inputFilePath, FileMode.Open, FileAccess.Read);
using StreamWriter fOut = new StreamWriter(outputFilePath);

byte[] imgHeader = new byte[54];

int bytesRead = fIn.Read(imgHeader, 0, imgHeader.Length);
if (bytesRead != imgHeader.Length)
{
    Console.WriteLine("Unable to read image header");
    return;
}

int height = BitConverter.ToInt32(imgHeader, 22);
int width = BitConverter.ToInt32(imgHeader, 18);

//影像大小 (高 * 寬)
int imgSize = height * width;

//記錄 rgb 的 0 - 255 色彩索引
int[,] ihist = new int[3, 256];

//記錄 rgb 目前加總數量
int[] sum = new int[3];

for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    ihist[0, blue] = ihist[0, blue] + 1;
    ihist[1, green] = ihist[1, green] + 1;
    ihist[2, red] = ihist[2, red] + 1;
	
    sum[0]++;
    sum[1]++;
    sum[2]++;
}

//最終結果
float[,] hist = new float[3, 256];

for (int i = 0; i < 256; i++)
{
    hist[0, i] = (float)ihist[0, i] / (float)sum[0];
    hist[1, i] = (float)ihist[1, i] / (float)sum[1];
    hist[2, i] = (float)ihist[2, i] / (float)sum[2];
    fOut.Write("{0} {1} {2}" , hist[0 , i].ToString("F6"), hist[1 , i].ToString("F6"), hist[2 , i].ToString("F6"));
    if (i < 255) fOut.WriteLine();
}
```

看他的課程用 gnuplot 懶得安裝的話可以直接用這個線上版本 https://gnuplot.io/
可以跟這個網站 https://sisik.eu/histo 畫出來的對照, 不過身材會有點走鐘走鐘 XD
然後敲入以下 code 來執行, 就可以畫出來三個 band 的直方圖惹


```
# 設定標題
set title "RGB Histogram"

# 設定x軸範圍
set xlabel "Pixel Value"
set xrange [0:255]

# 設定y軸範圍
set ylabel "Frequency"

# 設定顏色，這裡是紅色、綠色和藍色通道的顏色
set style line 1 linecolor rgb "blue"  linetype 1 linewidth 2
set style line 2 linecolor rgb "green" linetype 1 linewidth 2
set style line 3 linecolor rgb "red" linetype 1 linewidth 2

# 繪製直方圖，使用三列資料，並設定不同顏色
plot "data3.txt" using 1 with lines linestyle 1 title "Blue", \
     "data3.txt" using 2 with lines linestyle 2 title "Green", \
     "data3.txt" using 3 with lines linestyle 3 title "Red"
```

或是用 python 來畫也可以, 這裡要注意 rgb 順序, js 是 rgb , c or c# 是 bgr

```
#jupyter notebook
import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("histogram_rgb.txt")

# 假設資料是三列，分別代表紅色、綠色和藍色的像素值
blue = data[:, 0]
green = data[:, 1]
red = data[:, 2]

plt.plot(blue,'b')
plt.plot(green,'g')
plt.plot(red,'r')


# 設定標題和軸標籤
plt.title('RGB Histogram')
plt.xlabel('Pixel Value')
plt.ylabel('Frequency')

# 顯示圖例
plt.legend(['blue','green','red'])

# 顯示圖表
plt.show()
```

這裡 js 比較特別
開闢 2d array 需要用 Array(256).fill(0) 才會塞 0 在裡面, 其他就差不多

```
histogram(canvas) {
  let ctx = canvas.getContext("2d");
  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
  const pixels = imageData.data;

  let ihist = [
    new Array(256).fill(0),
    new Array(256).fill(0),
    new Array(256).fill(0),
  ];

  let sum = [0, 0, 0];

  for (let i = 0; i < pixels.length; i += 4) {
    const r = pixels[i]; // 紅色
    const g = pixels[i + 1]; // 綠色
    const b = pixels[i + 2]; // 藍色
    const a = pixels[i + 3]; // 透明度

    ihist[0][r] = ihist[0][r] + 1;
    ihist[1][g] = ihist[1][g] + 1;
    ihist[2][b] = ihist[2][b] + 1;

    sum[0]++;
    sum[1]++;
    sum[2]++;
  }

  let hist = [
    new Array(256).fill(0),
    new Array(256).fill(0),
    new Array(256).fill(0),
  ];

  let str = "";

  for (let i = 0; i < 256; i++) {
    hist[0][i] = ihist[0][i] / sum[0];
    hist[1][i] = ihist[1][i] / sum[1];
    hist[2][i] = ihist[2][i] / sum[2];

    let r = hist[0][i].toFixed(6);
    let g = hist[1][i].toFixed(6);
    let b = hist[2][i].toFixed(6);
    str += `${r} ${g} ${b}`;
    if (i < 255) str += "\n";
  }

  return str;
}
```

## Histogram Equalization

延續讀取出 Histogram 的數值以後, 可以用 Histogram Equalization 來讓色彩平均分布

這邊先宣告一個用來存結果的 array `int[,] histEq = new int[3, 256]`

接著雙重 loop 跑 `累積分布函數 CDF cumulative distribution function`, 問 gpt 說加 0.5 效果會比較好

再來把 Position 歸位, 因為一開始檔案有先讀過一次了, 此時位置為 -1, 將他調整到 54
依序把 bgr 數值拿出來, 並且丟入 histEq 這個 array 對應的索引取得新的數值, 最後寫入檔案便可

驗證可以到這個網站 https://www7.lunapic.com/editor/?action=adaptive-equalize 來看看結果是否一樣

```
string inputFilePath = "images/lena_color.bmp";
string outputFilePath = "images/lenaeq.bmp";

// 打開輸入和輸出文件
using FileStream fIn = new FileStream(inputFilePath, FileMode.Open, FileAccess.Read);
using FileStream fOut = new FileStream(outputFilePath, FileMode.Create, FileAccess.Write);
//using StreamWriter fOut = new StreamWriter(outputFilePath);

byte[] imgHeader = new byte[54];
byte[] colorTable = new byte[1024];

// 讀取 BMP 標頭
int bytesRead = fIn.Read(imgHeader, 0, imgHeader.Length);
if (bytesRead != imgHeader.Length)
{
    Console.WriteLine("Unable to read image header");
    return;
}

// 寫入標頭到輸出文件
fOut.Write(imgHeader, 0, imgHeader.Length);

// 獲取圖像的寬度、高度和位深度
int height = BitConverter.ToInt32(imgHeader, 22);
int width = BitConverter.ToInt32(imgHeader, 18);
int bitDepth = BitConverter.ToInt16(imgHeader, 28);

//Console.WriteLine($"height: {height}");
//Console.WriteLine($"width: {width}");
//Console.WriteLine($"bitDepth: {bitDepth}");

// 如果位深度小於等於 8，讀取顏色表
if (bitDepth <= 8)
{
    fIn.Read(colorTable, 0, colorTable.Length);
    //fOut.Write(colorTable, 0, colorTable.Length);
}

// 計算圖像大小
int imgSize = height * width;

int[,] ihist = new int[3, 256];
int[] sum = new int[3];

for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    ihist[0, blue] = ihist[0, blue] + 1;
    ihist[1, green] = ihist[1, green] + 1;
    ihist[2, red] = ihist[2, red] + 1;
    sum[0]++;
    sum[1]++;
    sum[2]++;
}

float[,] hist = new float[3, 256];

for (int i = 0; i < 256; i++)
{
    hist[0, i] = (float)ihist[0, i] / (float)sum[0];
    hist[1, i] = (float)ihist[1, i] / (float)sum[1];
    hist[2, i] = (float)ihist[2, i] / (float)sum[2];
}

//累積分布函數 CDF cumulative distribution function
int[,] histEq = new int[3, 256];
for (int i = 0; i < 256; i++)
{
    float cdfBlueSum = 0.0f;
    float cdfGreenSum = 0.0f;
    float cdfRedSum = 0.0f;
    for (int j = 0; j <= i; j++)
    {
        cdfBlueSum += hist[0, j];
        cdfGreenSum += hist[1, j];
        cdfRedSum += hist[2, j];
    }
    //加 0.5 的話會得到比較優的效果
    histEq[0, i] = (int)(255 * cdfBlueSum + 0.5);
    histEq[1, i] = (int)(255 * cdfGreenSum + 0.5);
    histEq[2, i] = (int)(255 * cdfRedSum + 0.5);
}

//因為已經讀過一次, 所以需要移動位置跳過 header 也可以用 Seek 函數
fIn.Position = 54;
for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    var blueEq = histEq[0, blue];
    var greenEq = histEq[1, green];
    var redEq = histEq[2, red];

    fOut.WriteByte((byte)blueEq);
    fOut.WriteByte((byte)greenEq);
    fOut.WriteByte((byte)redEq);
}

Console.WriteLine("Success!");
```

他原始的 c 程式碼如下, 不過他是只做灰階, 我是做 RGB

```
#include <stdio.h>
#include <stdlib.h>
#define BMP_HEADER_SIZE         54
#define BMP_COLOR_TABLE_SIZE    1024
#define CUSTOM_IMG_SIZE         512*512

float IMG_HIST[255];

void  imageReader(const char *imgName,
                  int *_height,
                  int *_width,
                  int *_bitDepth,
                  unsigned char *_header,
                  unsigned char *_colorTable,
                  unsigned char *_buf
                  );
 void imageWriter(const char *imgName,
                 unsigned char *header,
                 unsigned char *colorTable,
                 unsigned char *buf,
                 int bitDepth) ;

void ImgHistogram(unsigned char * _imgData, int imgRows, int imgCols, float hist[]);
void ImgHistogramEqualization(unsigned char *_inputImgData, unsigned char *_outputImgData,int imgRows,int imgCols);

int main()
{
    int imgWidth, imgHeight,imgBitDepth;
    unsigned char imgHeader[BMP_HEADER_SIZE];
    unsigned char imgColorTable[BMP_COLOR_TABLE_SIZE];
    unsigned char imgBuffer[CUSTOM_IMG_SIZE];
    unsigned char imgBuffer2[CUSTOM_IMG_SIZE];

    const char imgName[] = "lena512.bmp";
    const char newImgName[] ="lena_eqz.bmp";

    imageReader(imgName,&imgHeight,&imgWidth,&imgBitDepth,&imgHeader[0],&imgColorTable[0],&imgBuffer[0]);
    ImgHistogramEqualization(&imgBuffer[0],&imgBuffer2[0],imgHeight,imgWidth);
    imageWriter(newImgName,imgHeader,imgColorTable,imgBuffer2,imgBitDepth);

    return 0;
}

void imageWriter(const char *imgName,
                 unsigned char *header,
                 unsigned char *colorTable,
                 unsigned char *buf,
                 int bitDepth)
   {
     FILE *fo = fopen(imgName,"wb");
     fwrite(header,sizeof(unsigned char),54,fo);
     if(bitDepth <=8)
     {
         fwrite(colorTable,sizeof(unsigned char),1024,fo);
     }
     fwrite(buf,sizeof(unsigned char),CUSTOM_IMG_SIZE, fo);
     fclose(fo);

   }

   void  imageReader(const char *imgName,
                  int *_height,
                  int *_width,
                  int *_bitDepth,
                  unsigned char *_header,
                  unsigned char *_colorTable,
                  unsigned char *_buf
                  )
{
    int i;
    FILE *streamIn;
    streamIn = fopen(imgName,"rb");

    if(streamIn ==(FILE *)0)
    {

        printf("Unable to read image \n");
    }

    for(i =0;i<54;i++)
    {
        _header[i] = getc(streamIn);
    }

    *_width = *(int *)&_header[18];
    *_height = *(int *)&_header[22];
    *_bitDepth = *(int *)&_header[28];

    if(*_bitDepth <=8)
    {
        fread(_colorTable,sizeof(unsigned char),1024,streamIn);
    }

    fread(_buf,sizeof(unsigned char),CUSTOM_IMG_SIZE,streamIn);

    fclose(streamIn);
}


void ImgHistogram(unsigned char * _imgData, int imgRows, int imgCols, float hist[])
{
  FILE *fptr;
  fptr = fopen("image_hist.txt","w");
  int x,y,i,j;
  long int ihist[255];
  long int sum;

  for(i=0;i<=255;i++)
  {
      ihist[i] = 0;
  }
  sum =0;
  for(y =0;y<imgRows;y++)
  {
      for(x=0;x<imgCols;x++)
      {
          j = *(_imgData+x+y*imgCols);
          ihist[j] = ihist[j] +1;
          sum = sum +1;

      }
  }

    for( i =0;i<255;i++)
    {
        hist[i] = (float)ihist[i]/(float)sum;

    }


     for(int i=0;i<255;i++)
     {
         fprintf(fptr,"\n%f",hist[i]);
     }

    fclose(fptr);

}

void ImgHistogramEqualization(unsigned char *_inputImgData, unsigned char *_outputImgData,int imgRows,int imgCols)
{
    int x,y,i,j;
    int histeq[256];
    float hist[256];
    float sum;

    ImgHistogram(&_inputImgData[0], imgRows,imgCols,&hist[0]);

    for(i=0;i<255;i++)
    {
        sum =0.0;
        for(j=0;j<=i;j++)
        {
            sum = sum+hist[j];
        }
        histeq[i] = (int)(255*sum+0.5);
    }
    for(y =0;y<imgRows;y++)
    {
        for(x=0;x<imgCols;x++)
        {
            *(_outputImgData+x+y*imgCols) =  histeq[*(_inputImgData+x+y*imgCols)];
        }
    }
}
```

## 負片效果 aka 靈異效果 filter
負片效果比較簡單, 不管灰階或彩色只要用 `255 - 目前色彩` 就可以了

```
for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    fOut.WriteByte((byte)(255 - blue));
    fOut.WriteByte((byte)(255 - green));
    fOut.WriteByte((byte)(255 - red));
}
```

## 影像模糊 aka 迷片效果 filter
首先要準備一個 3x3 的 array filter
這個 filter 會計算每個 pixel 周圍 3x3 區域內的平均值來進行模糊處理

平常在讀影像時都會由 `寬高起始值 0` ~ `寬高結束值`
這裡的迴圈因為要放 3x3 filter 所以由 `寬高起始值 + 1` ~ `寬高結束值 - 1`

不過這樣做會有黑邊, 最後還要再補下讓黑邊的 pixel 是上下或是左右的 pixel

```
string inputFilePath = "images/lena_color.bmp";
string outputFilePath = "images/lena_blur.bmp";

// 打開輸入和輸出文件
using FileStream fIn = new FileStream(inputFilePath, FileMode.Open, FileAccess.Read);
using FileStream fOut = new FileStream(outputFilePath, FileMode.Create, FileAccess.Write);

byte[] imgHeader = new byte[54];
byte[] colorTable = new byte[1024];

// 讀取 BMP 標頭
int bytesRead = fIn.Read(imgHeader, 0, imgHeader.Length);
if (bytesRead != imgHeader.Length)
{
    Console.WriteLine("Unable to read image header");
    return;
}

// 寫入標頭到輸出文件
fOut.Write(imgHeader, 0, imgHeader.Length);

// 獲取圖像的寬度、高度和位深度
int height = BitConverter.ToInt32(imgHeader, 22);
int width = BitConverter.ToInt32(imgHeader, 18);
int bitDepth = BitConverter.ToInt16(imgHeader, 28);

Console.WriteLine($"height: {height}");
Console.WriteLine($"width: {width}");
Console.WriteLine($"bitDepth: {bitDepth}");

// 如果位深度小於等於 8，讀取顏色表
if (bitDepth <= 8)
{
    fIn.Read(colorTable, 0, colorTable.Length);
    fOut.Write(colorTable, 0, colorTable.Length);
}

// 計算圖像大小
int imgSize = height * width;

//目前影像
byte[,] buffer = new byte[imgSize, 3];

//輸出影像
byte[,] outBuffer = new byte[imgSize, 3];


//讀取目前影像的 pixel
for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    buffer[i, 0] = (byte)blue;
    buffer[i, 1] = (byte)green;
    buffer[i, 2] = (byte)red;
}

//因為是 3*3 所以數值要用 9
float blur = 1.0f / 9.0f;
float[,] filter = {
    {blur , blur , blur},
    {blur , blur , blur},
    {blur , blur , blur},
};

for (int y = 1; y < height - 1; y++)
{
    for (int x = 1; x < width - 1; x++)
    {
        float sum0 = 0.0f;
        float sum1 = 0.0f;
        float sum2 = 0.0f;

        //對 3x3 的 filter loop 算出加權平均結果
        for (int fy = -1; fy <= 1; fy++)
        {
            for (int fx = -1; fx <= 1; fx++)
            {
                //原始值
                //var blue = buffer[y * width + x, 0];
                //var red = buffer[y * width + x, 1];
                //var green = buffer[y * width + x, 1];

                //blur 模糊值
                var blue = filter[fy + 1, fx + 1] * buffer[(y + fy) * width + (x + fx), 0];
                var green = filter[fy + 1, fx + 1] * buffer[(y + fy) * width + (x + fx), 1];
                var red = filter[fy + 1, fx + 1] * buffer[(y + fy) * width + (x + fx), 2];

                sum0 += blue;
                sum1 += green;
                sum2 += red;
            }
        }

        //把加權值丟到目前這個 pixel
        outBuffer[y * width + x, 0] = (byte)sum0;
        outBuffer[y * width + x, 1] = (byte)sum1;
        outBuffer[y * width + x, 2] = (byte)sum2;
    }
}

//黑邊處理
for (int y = 0; y < height; y++)
{
    for (int x = 0; x < width; x++)
    {
        // 對於最上面一行，設置與下一行相同
        if (y == 0)
        {
            outBuffer[y * width + x , 0 ] = buffer[(y + 1) * width + x , 0];
            outBuffer[y * width + x , 1 ] = buffer[(y + 1) * width + x , 1];
            outBuffer[y * width + x , 2 ] = buffer[(y + 1) * width + x , 2];
        }
        // 對於最下面一行，設置與上一行相同
        else if (y == height - 1)
        {
            outBuffer[y * width + x, 0 ] = buffer[(y - 1) * width + x, 0 ];
            outBuffer[y * width + x, 1 ] = buffer[(y - 1) * width + x, 1 ];
            outBuffer[y * width + x, 2 ] = buffer[(y - 1) * width + x, 2 ];
        }

        // 對於最左邊一列，設置與右邊相同
        if (x == 0)
        {
            outBuffer[y * width + x, 0 ] = buffer[y * width + (x + 1), 0];
            outBuffer[y * width + x, 1 ] = buffer[y * width + (x + 1), 1];
            outBuffer[y * width + x, 2 ] = buffer[y * width + (x + 1), 2];
        }
        // 對於最右邊一列，設置與左邊相同
        else if (x == width - 1)
        {
            outBuffer[y * width + x , 0] = buffer[y * width + (x - 1), 0];
            outBuffer[y * width + x , 1] = buffer[y * width + (x - 1), 1];
            outBuffer[y * width + x , 2] = buffer[y * width + (x - 1), 2];
        }
    }
}


for (int i = 0; i < imgSize; i++)
{
    var blue = outBuffer[i, 0];
    var green = outBuffer[i, 1];
    var red = outBuffer[i, 2];

    fOut.WriteByte(blue);
    fOut.WriteByte(green);
    fOut.WriteByte(red);
}

Console.WriteLine("Success!");
```

## Sepia Filter 老照片效果
這個真的超神奇的, 不要問為什麼會這樣 XD

看他課程也跟這裡的算法一樣 https://stackoverflow.com/questions/1061093/how-is-a-sepia-tone-created
不曉得到底是啥妖術 ~

```
for (int i = 0; i < imgSize; i++)
{
    var blue = fIn.ReadByte();
    var green = fIn.ReadByte();
    var red = fIn.ReadByte();

    var sepiaRed = (red * .393) + (green * .769) + (blue * .189);
    var sepiaGreen = (red * .349) + (green * .686) + (blue * .168);
    var sepiaBlue = (red * .272) + (green * .534) + (blue * .131);
    if (sepiaRed >= 255) sepiaRed = 255;
    if (sepiaGreen >= 255) sepiaGreen = 255;
    if (sepiaBlue >= 255) sepiaBlue = 255;


    fOut.WriteByte((byte)sepiaBlue);
    fOut.WriteByte((byte)sepiaGreen);
    fOut.WriteByte((byte)sepiaRed);
}
```

## Discrete Convolution
這個 example 實在有點困難, 就算依靠 ChatGPT 幫忙翻不過也是沒辦法 100% 正確, 後來修了下

這裡要注意到的在 c 裡面 `signed char` 對應到 c# 應該是 `sbyte`

`(byte*)System.Runtime.InteropServices.Marshal.AllocHGlobal(size);` 則可以用來代替 `malloc`

```
unsafe
{
    //2D Discrete convolution
    void Convolve(int imgRows, int imgCols, Mask myMask, byte* input_buf, byte* output_buf)
    {
        long y, x, fy, fx, yIndex, xIndex;
        int ms, im = 0, val;
        byte* tmp;

        //the outer summation loop
        for (y = 0; y < imgRows; ++y)
            for (x = 0; x < imgCols; ++x)
            {
                val = 0;
                for (fy = 0; fy < myMask.Rows; ++fy)
                    for (fx = 0; fx < myMask.Cols; ++fx)
                    {
                        ms = *(myMask.Data + fy * myMask.Rows + fx);
                        yIndex = y - fy;
                        xIndex = x - fx;
                        if (yIndex >= 0 && xIndex >= 0)
                            im = *(input_buf + yIndex * imgRows + xIndex);
                        val += ms * im;
                    }
                if (val > 255) val = 255;
                if (val < 0) val = 0;
                tmp = output_buf + y * imgRows + x;
                *tmp = (byte)val;
            }
    }
	
    void Convolve2(int imgRows, int imgCols, Mask myMask, byte[] inputBuf, byte[] outputBuf)
    {
        int val;
        int ms, im = 0;
        int yIndex, xIndex;

        // the outer summation loop
        for (int y = 0; y < imgRows; ++y)
        {
            for (int x = 0; x < imgCols; ++x)
            {
                val = 0;

                // Iterate through the mask
                for (int fy = 0; fy < myMask.Rows; ++fy)
                {
                    for (int fx = 0; fx < myMask.Cols; ++fx)
                    {
                        ms = *(myMask.Data + fy * myMask.Rows + fx);

                        yIndex = y - fy;
                        xIndex = x - fx;

                        // Check if the indices are within bounds
                        if (yIndex >= 0 && xIndex >= 0)
                        {
                            // Get the grayscale pixel value from the input buffer
                            im = inputBuf[(yIndex * imgCols + xIndex)]; // For grayscale, it's just one value
                        }

                        val += ms * im; // Apply the convolution operation
                    }
                }

                // Clamp the result to be between 0 and 255
                if (val > 255) val = 255;
                if (val < 0) val = 0;

                // Store the result back into the output buffer
                outputBuf[y * imgCols + x] = (byte)val;
            }
        }
    }
	
	
	

    void ImageWriter(string imgName, byte[] header, byte[] colorTable, byte[] buf, int bitDepth)
    {
        using (FileStream fs = new FileStream(imgName, FileMode.Create, FileAccess.Write))
        using (BinaryWriter writer = new BinaryWriter(fs))
        {
            // Write the header
            writer.Write(header, 0, 54);

            // Write the color table if bit depth is <= 8
            if (bitDepth <= 8)
            {
                writer.Write(colorTable, 0, 1024);
            }

            // Write the image buffer
            writer.Write(buf, 0, buf.Length);
        }
    }



    void ImageReader(string imgName, out int height, out int width, out int bitDepth,
                     byte[] header, byte[] colorTable, byte[] buf)
    {
        using (FileStream fs = new FileStream(imgName, FileMode.Open, FileAccess.Read))
        using (BinaryReader reader = new BinaryReader(fs))
        {
            // Read the header (54 bytes)
            reader.Read(header, 0, 54);

            // Read the width, height, and bit depth
            width = BitConverter.ToInt32(header, 18);
            height = BitConverter.ToInt32(header, 22);
            bitDepth = BitConverter.ToInt16(header, 28);

            // If the bit depth is <= 8, read the color table
            if (bitDepth <= 8)
            {
                reader.Read(colorTable, 0, 1024);
            }

            // Read the image data
            reader.Read(buf, 0, buf.Length);
        }
    }

    byte* malloc(int size)
    {
        return (byte*)System.Runtime.InteropServices.Marshal.AllocHGlobal(size);
    }

    const int BMP_HEADER_SIZE = 54;
    const int BMP_COLOR_TABLE_SIZE = 1024;
    const int CUSTOM_IMG_SIZE = 256 * 256;

    int imgWidth, imgHeight, imgBitDepth;
    byte[] imgHeader = new byte[BMP_HEADER_SIZE];
    byte[] imgColorTable = new byte[BMP_COLOR_TABLE_SIZE];
    byte[] imgBuffer = new byte[CUSTOM_IMG_SIZE];
    byte[] imgBuffer2 = new byte[CUSTOM_IMG_SIZE];

    string imgName = "cameraman.bmp";
    string newImgName = "cameraman_new.bmp";


    Mask lpMask;
    lpMask.Rows = lpMask.Cols = 5;

    // 使用 unsafe 操作分配內存
    lpMask.Data = (sbyte*)malloc(25);

    // 設置所有 mask 的值為 -1
    sbyte* tmp = lpMask.Data;
    for (int i = 0; i < 25; ++i)
    {
        *tmp = (sbyte)-1; // 將每個值設置為 -1
        ++tmp;
    }

    // 設置中間的值為 24
    tmp = lpMask.Data + 13;
    *tmp = 24;

    // 讀取圖像
    ImageReader(imgName, out imgHeight, out imgWidth, out imgBitDepth, imgHeader, imgColorTable, imgBuffer);

    // 進行卷積操作
    fixed (byte* ptrImgBuffer = imgBuffer,  ptrImgBuffer2 = imgBuffer2)
        Convolve(imgHeight, imgWidth, lpMask, ptrImgBuffer, ptrImgBuffer2);

	//或用這個函數
	//Convolve2(imgHeight, imgWidth, lpMask, imgBuffer, imgBuffer2);

    // 輸出圖像
    ImageWriter(newImgName, imgHeader, imgColorTable, imgBuffer2, imgBitDepth);

    Console.WriteLine("Success!");


}


public unsafe struct Mask
{
    public int Rows;
    public int Cols;
    public sbyte* Data;
}
```

## 邊緣人檢測 Detecting Lines with a Line Detector
他這裡原版用 `LineDetector` 寫起來比較噁心, 要將 1d 指標算成 2d
我自己則是寫個 `byteArrayTo2D` 先把 `byte*` 轉為 `byte[,]`
然後用 `LineDetector2D` 去檢測邊緣比較輕鬆
不過這裡有個詭異的點, 他的條件要用 `y < imgRows - 1 x < imgCols` 才會正確, 不然 array 會越界
不太曉得為啥跟指標的條件不太一樣, 這種太細的邏輯最難 debug
最後意外發現原來 `byte[,]` 好像可以直接轉為 `pointer` 不用多處理一手

```
using System.Runtime.InteropServices;
int BMP_HEADER_SIZE = 54;
int BMP_COLOR_TABLE_SIZE = 1024;
int CUSTOM_IMG_SIZE = 512 * 512;

unsafe
{

    void ImageWriter(string imgName, byte* header, byte* colorTable, byte* buf, int bitDepth)
    {
        // 打開文件以寫入
        using (FileStream fs = new FileStream(imgName, FileMode.Create, FileAccess.Write))
        {
            using (BinaryWriter writer = new BinaryWriter(fs))
            {
                // 寫入 header
                for (int i = 0; i < BMP_HEADER_SIZE; i++)
                {
                    writer.Write(*(header + i));
                }

                // 如果位深度 <= 8，則寫入顏色表
                if (bitDepth <= 8)
                {
                    for (int i = 0; i < BMP_COLOR_TABLE_SIZE; i++)
                    {
                        writer.Write(*(colorTable + i));
                    }
                }

                // 寫入圖像數據
                for (int i = 0; i < CUSTOM_IMG_SIZE; i++)
                {
                    writer.Write(*(buf + i));
                }
            }
        }
    }

    void ImageReader(string imgName, int* height, int* width, int* bitDepth,
                     byte[] header, byte[] colorTable, byte[] buf)
    {
        using (FileStream fs = new FileStream(imgName, FileMode.Open, FileAccess.Read))
        using (BinaryReader reader = new BinaryReader(fs))
        {
            // Read the header (54 bytes)
            reader.Read(header, 0, 54);

            // Read the width, height, and bit depth
            *width = BitConverter.ToInt32(header, 18);
            *height = BitConverter.ToInt32(header, 22);
            *bitDepth = BitConverter.ToInt16(header, 28);

            // If the bit depth is <= 8, read the color table
            if (*bitDepth <= 8)
            {
                reader.Read(colorTable, 0, 1024);
            }

            // Read the image data
            reader.Read(buf, 0, buf.Length);
        }
    }

    void LineDetector(byte* _inputImgData, byte* _outputImgData,
                          int imgCols, int imgRows, int[,] MASK)
    {
        int x, y, i, j, sum;

        for (y = 1; y <= imgRows - 1; y++)
        {
            for (x = 1; x <= imgCols - 1; x++)
            {
                sum = 0;
                for (i = -1; i <= 1; i++)
                {
                    for (j = -1; j <= 1; j++)
                    {
                        //這表示圖片目前的 pixel
                        //*(_inputImgData + x + i + (long)(y + j) * imgCols)

                        //目前移動到 mask 的格子
                        //MASK[i + 1, j + 1]
                        sum = sum + *(_inputImgData + x + i + (long)(y + j) * imgCols) * MASK[i + 1, j + 1];
                    }
                }
                if (sum > 255)
                    sum = 255;
                if (sum < 0)
                    sum = 0;
                *(_outputImgData + x + (long)y * imgCols) = (byte)sum;
            }

        }
    }


    void LineDetector2D(byte[,] _inputImgData, byte[,] _outputImgData,
                      int imgCols, int imgRows, int[,] MASK)
    {
        int x, y, i, j, sum;

        for (y = 1; y < imgRows - 1; y++)
        {
            for (x = 1; x < imgCols - 1; x++)
            {
                sum = 0;
                for (i = -1; i <= 1; i++)
                {
                    for (j = -1; j <= 1; j++)
                    {
                        // 這是圖像目前的像素，改為直接使用二維陣列
                        sum = sum + _inputImgData[y + i, x + j] * MASK[i + 1, j + 1];
                    }
                }

                // 確保像素值在 [0, 255] 範圍內
                if (sum > 255)
                    sum = 255;
                if (sum < 0)
                    sum = 0;

                // 將結果儲存回輸出圖像
                _outputImgData[y, x] = (byte)sum;
            }
        }
    }


    void byteArrayTo2D(byte* buffer, byte[,] outBuffer)
    {
        for (int y = 0; y < 512; y++)
        {
            for (int x = 0; x < 512; x++)
            {
                outBuffer[y, x] = buffer[y * 512 + x];
            }
        }
    }



    int imgWidth;
    int imgHeight;
    int imgBitDepth;
    byte[] imgHeader = new byte[BMP_HEADER_SIZE];
    byte[] imgColorTable = new byte[BMP_COLOR_TABLE_SIZE];
    byte[] imgBuffer = new byte[CUSTOM_IMG_SIZE];
    byte[] imgBuffer2 = new byte[CUSTOM_IMG_SIZE];


    byte[,] imgBufferTwoD = new byte[512, 512];
    byte[,] imgBuffer2TwoD = new byte[512, 512];

    string imgName = "lena512.bmp";
    string newImgName = "lena_rdia_2d.bmp";



    int[,] VER = {
        { -1,2,-1},
        { -1,2,-1},
        { -1,2,-1}
    };
    int[,] HOR = {
        { -1,-1,-1},
        { 2,2,2},
        { -1,-1,-1}
    };
    int[,] LDIA = {
        { 2,-1,-1},
        { -1,2,-1},
        { -1,-1,2}
    };
    int[,] RDIA = {
        { -1,-1,2},
        { -1,2,-1},
        { 2,-1,-1}
    };

    ImageReader(imgName, &imgHeight, &imgWidth, &imgBitDepth, imgHeader, imgColorTable, imgBuffer);
    fixed (byte* ptrImgBuffer = &imgBuffer[0])
        byteArrayTo2D(ptrImgBuffer, imgBufferTwoD);

    LineDetector2D(imgBufferTwoD, imgBuffer2TwoD, imgWidth, imgHeight, RDIA);


    //fixed (byte* ptrImgBuffer = &imgBuffer[0], ptrImgBuffer2 = &imgBuffer2[0])
    //    LineDetector(ptrImgBuffer, ptrImgBuffer2, imgWidth, imgHeight, RDIA);

    fixed (byte* ptrImgHeader = imgHeader, ptrImgColorTable = imgColorTable, ptrImgBuffer2 = imgBuffer2TwoD)
        ImageWriter(newImgName, ptrImgHeader, ptrImgColorTable, ptrImgBuffer2, imgBitDepth);

    Console.WriteLine("Success!\n");
}
```

## 加鹽

這裡可以用以下方法來加料
這裡他一樣用 `*(inputImgData + x + (long)y * imgCols)` 讀起來比較噁心

假如 width = 5, height = 2

0 1 2 3 4
5 6* 7 8 9

如果 6 是目前選到的格子就看得很清楚, 因為他最後要被拆成 1d

0 1 2 3 4 5 6* 7 8 9

5 + 2 = 7

索引由 0 開始, 必須減一所以得到 6 這個索引位置

```
void SaltPepper(byte* inputImgData, int imgCols, int imgRows, float prob)
{
	int x, y, data, data1, data2;
	data = (int)(prob * 32768 / 2);
	data1 = data + 16384;
	data2 = 16384 - data;

	Random rnd = new Random();

	for (y = 0; y < imgRows; y++)
	{
		for (x = 0; x < imgCols; x++)
		{
			data = rnd.Next(0, 32768);
			if (data >= 16384 && data < data1)
				*(inputImgData + x + (long)y * imgCols) = 0;
			if (data >= data2 && data < 16384)
				*(inputImgData + x + (long)y * imgCols) = 255;
		}
	}
}

void SaltPepper2D(byte[,] inputImgData, int imgCols, int imgRows, float prob)
{
	int x, y, data, data1, data2;
	data = (int)(prob * 32768 / 2);
	data1 = data + 16384;
	data2 = 16384 - data;

	Random rnd = new Random();

	for (y = 0; y < imgRows; y++)
	{
		for (x = 0; x < imgCols; x++)
		{
			data = rnd.Next(0, 32768);
			if (data >= 16384 && data < data1)
				inputImgData[y, x] = 0;
				//*(inputImgData + x + (long)y * imgCols) = 0;

			if (data >= data2 && data < 16384) 
				inputImgData[y, x] = 255;
				//*(inputImgData + x + (long)y * imgCols) = 255;
		}
	}
}
```

## High Pass Filter

這裡比較簡單, 一樣就是跑個卷積就搞定了, code 就不列惹

-1 -1 -1
-1 9 -1
-1 -1 -1

## 高斯雜訊

希望沒寫錯 LOL

```
void Gussian(byte* _inputImgData, int imgCols, int imgRows, float var, float mean)
{
	int x, y;
	double noise, theta;
	Random rnd = new Random();
	for (y = 0; y < imgRows; y++)
	{
		for (x = 0; x < imgCols; x++)
		{
			noise = Math.Sqrt(-2 * var * Math.Log(1.0 - rnd.Next(0, 32767) / 32767.1));
			theta = rnd.Next(0, 32767) * 1.9175345e-4 - Math.PI;
			noise = noise * Math.Cos(theta);
			noise = noise + mean;
			if (noise > 255) noise = 255;
			if (noise < 0) noise = 0;
			*(_inputImgData + x + (long)y * imgCols) = (byte)(noise + 0.5);
		}
	}
}
```

## js 版本

js 的話要注意影像是由 rgb 為順序, 另外他好像都會有 alpha 透明度通道

搞這個還要記順序整個詭異 LOL

還有他 img canva 等比例縮放也比較難寫

以下是我實作部分的網址 https://codepen.io/weber87na/pen/OJKqXXL

## RIP 風格的 asp.net core middleware

搞這也是搞滿久的, 本來以為直接修改 Response 就好了, 沒想到還要先 `new MemoryStream`
這裡如果要禁止 Cache 可以加上

`context.Context.Response.Headers.Add("Cache-Control", "no-cache, no-store");`

`context.Context.Response.Headers.Add("Expires", "-1");`

```
app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponseAsync = async context =>
    {
        context.Context.Response.Headers.Add("Cache-Control", "no-cache, no-store");
        context.Context.Response.Headers.Add("Expires", "-1");
	
        if (context.File.Name.EndsWith(".bmp", StringComparison.OrdinalIgnoreCase))
            await BmpToGrayAsync(context);
    }
});


async Task BmpToGrayAsync(StaticFileResponseContext context)
{
    var filePath = context.File.PhysicalPath;
    byte[] imgData = await File.ReadAllBytesAsync(filePath);

    using (var bmpStream = new MemoryStream(imgData))
    {
        //read header
        byte[] imgHeader = new byte[54];
        await bmpStream.ReadAsync(imgHeader, 0, imgHeader.Length);

        int height = BitConverter.ToInt32(imgHeader, 22);
        int width = BitConverter.ToInt32(imgHeader, 18);
        int bitDepth = BitConverter.ToInt16(imgHeader, 28);

        Console.WriteLine($"height: {height}");
        Console.WriteLine($"width: {width}");
        Console.WriteLine($"bitDepth: {bitDepth}");

        //read color table
        byte[] colorTable = new byte[1024];
        if (bitDepth <= 8)
        {
            await bmpStream.ReadAsync(colorTable, 0, colorTable.Length);
        }

        //圖片大小
        int imgSize = height * width;
        using (var output = new MemoryStream())
        {
            //write header
            await output.WriteAsync(imgHeader, 0, imgHeader.Length);
            if (bitDepth <= 8)
            {
                await output.WriteAsync(colorTable, 0, colorTable.Length);
            }

            for (int i = 0; i < imgSize; i++)
            {
                var blue = (byte)bmpStream.ReadByte(); 
                var green = (byte)bmpStream.ReadByte();
                var red = (byte)bmpStream.ReadByte();

                // 使用灰階公式：R * 0.299 + G * 0.587 + B * 0.114
                int gray = (int)(red * 0.299 + green * 0.587 + blue * 0.114);
                output.WriteByte((byte)gray);
                output.WriteByte((byte)gray);
                output.WriteByte((byte)gray);
            }

            //設定
            context.Context.Response.ContentType = "image/bmp";
            output.Seek(0, SeekOrigin.Begin);
            await output.CopyToAsync(context.Context.Response.Body);
        }
    }
}
```

## 粗糙的馬賽克
這裡 c# 就懶得寫了, 不過有 js
假設馬賽克範圍是 3 * 3
他原理就是拿 3 * 3 的左上角當點位
除了 loop 圖片的迴圈, 再跑一個巢狀迴圈, 並且讓這 9 格內設定為左上角的點即可

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    FILE *fIn = fopen("images/lena_color.bmp", "rb");
    FILE *fOut = fopen("images/lena_mosaic.bmp", "wb");

    unsigned char imgHeader[54];
    unsigned char colorTable[1024];

    if (fIn == NULL)
    {
        printf("Unable to open image\n");
    }

    for (int i = 0; i < 54; i++)
        imgHeader[i] = getc(fIn);

    fwrite(imgHeader, sizeof(unsigned char), 54, fOut);

    int height = *(int *)&imgHeader[22];
    int width = *(int *)&imgHeader[18];
    int bitDepth = *(int *)&imgHeader[28];

    if (bitDepth <= 8)
    {
        fread(colorTable, sizeof(unsigned char), 1024, fIn);
        fwrite(colorTable, sizeof(unsigned char), 1024, fOut);
    }

    int imgSize = height * width;
    unsigned char buffer[imgSize][3];
    int mosaicSize = 5;

    // 複製圖片 pixel 到最後要 out 的 buffer
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            int current = x + y * width;
            buffer[current][0] = getc(fIn);
            buffer[current][1] = getc(fIn);
            buffer[current][2] = getc(fIn);
        }
    }

    //loop pixel 步進值用 3 * 3 大小
    for (int y = 0; y < height; y += mosaicSize)
    {
        for (int x = 0; x < width; x += mosaicSize)
        {
            //取得目前 pixel
            int current = x + y * width;
            int blue = buffer[current][0];
            int green = buffer[current][1];
            int red = buffer[current][2];

            //跑一個 3 * 3 大小的馬賽克
            //把目前的設定這 3 * 3 都是用目前這個 pixel
            for (int my = 0; my < mosaicSize && (y + my) < height; my++)
            {
                for (int mx = 0; mx < mosaicSize && (x + mx) < width; mx++)
                {
                    int current = (y + my) * width + (x + mx);
                    buffer[current][0] = blue;
                    buffer[current][1] = green;
                    buffer[current][2] = red;

                }
            }
        }
    }

    //輸出最終 buffer
    for (int i = 0; i < imgSize; i++)
    {
        putc(buffer[i][0], fOut);
        putc(buffer[i][1], fOut);
        putc(buffer[i][2], fOut);
    }

    printf("Success!\n");
    fclose(fIn);
    fclose(fOut);

    return 0;
}
```

## 平滑馬賽克
平滑的話需要先對 3 * 3 的馬賽克色格子彩計算平均值
接著跟粗暴版本的一樣, 把平均值給 3 * 3 內的每個 pixel 即可

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    FILE *fIn = fopen("images/lena_color.bmp", "rb");
    FILE *fOut = fopen("images/lena_mosaic_smooth.bmp", "wb");

    unsigned char imgHeader[54];
    unsigned char colorTable[1024];

    if (fIn == NULL)
    {
        printf("Unable to open image\n");
    }

    for (int i = 0; i < 54; i++)
        imgHeader[i] = getc(fIn);

    fwrite(imgHeader, sizeof(unsigned char), 54, fOut);

    int height = *(int *)&imgHeader[22];
    int width = *(int *)&imgHeader[18];
    int bitDepth = *(int *)&imgHeader[28];

    if (bitDepth <= 8)
    {
        fread(colorTable, sizeof(unsigned char), 1024, fIn);
        fwrite(colorTable, sizeof(unsigned char), 1024, fOut);
    }

    int imgSize = height * width;
    unsigned char buffer[imgSize][3];
    int mosaicSize = 10;

    // 複製圖片 pixel 到最後要 out 的 buffer
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            int current = x + y * width;
            buffer[current][0] = getc(fIn);
            buffer[current][1] = getc(fIn);
            buffer[current][2] = getc(fIn);
        }
    }

    // loop pixel 步進值用 3 * 3 大小
    for (int y = 0; y < height; y += mosaicSize)
    {
        for (int x = 0; x < width; x += mosaicSize)
        {
            int sumBlue = 0;
            int sumGreen = 0;
            int sumRed = 0;
            int count = 0;

            for (int my = 0; my < mosaicSize && (y + my) < height; my++)
            {
                for (int mx = 0; mx < mosaicSize && (x + mx) < width; mx++)
                {
                    int current = (y + my) * width + (x + mx);
                    sumBlue += buffer[current][0];
                    sumGreen += buffer[current][1];
                    sumRed += buffer[current][2];
                    count++;
                }
            }

            int avgBlue = sumBlue / count;
            int avgGreen = sumGreen / count;
            int avgRed = sumRed / count;

            // 跑一個 3 * 3 大小的馬賽克
            // 把目前的設定這 3 * 3 都是用目前這個 pixel
            for (int my = 0; my < mosaicSize && (y + my) < height; my++)
            {
                for (int mx = 0; mx < mosaicSize && (x + mx) < width; mx++)
                {
                    int current = (y + my) * width + (x + mx);
                    buffer[current][0] = avgBlue;
                    buffer[current][1] = avgGreen;
                    buffer[current][2] = avgRed;
                }
            }
        }
    }

    // 輸出最終 buffer
    for (int i = 0; i < imgSize; i++)
    {
        putc(buffer[i][0], fOut);
        putc(buffer[i][1], fOut);
        putc(buffer[i][2], fOut);
    }

    printf("Success!\n");
    fclose(fIn);
    fclose(fOut);

    return 0;
}
```

## Ascii Art js

記得很多年前稍微玩過線上 AsciiArt 產生器覺得很有意思, 不過也不曉得怎麼做的, 今天就順便寫看看
參考這篇

他原理就是把圖片灰階化, 然後用一個 array 定義若干數量的字符
他這邊用這樣, 我自己定義其他符號, 不過效果不太好
$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^‘. `

因為灰階是 `0 ~ 255` 所以這裡用 `ceil(灰色 / 10)` 算出字符索引位置即可
然後讓取得的字符瘋狂相加, 最後就得到結果

這裡 css 的字要設定 `1px` 不然畫面會走鐘

如果想要彩色的話跟灰階的寫法差不多, 不過要把 return 的字變成 span 並設定顏色, 詳細可以看 code
取得結果以後, 則是要設定元素的 `innerHtml` 而非灰階的 `innerText`

https://codepen.io/weber87na/full/OJKqXXL

## 水平 垂直翻轉 js

這裡也是懶得搞 c# 了, 在 js 上水平翻轉的話需要先得到 beginIndex 及 endIndex
然後把 copiedPixels[beginIndex] 的 RGB 設定為 pixels[endIndex] 的 RGB 就搞定了

```
//起始
let beginIndex = (y * imageData.width + x) * 4;

//結束
let endIndex = (y * imageData.width + imageData.width - x) * 4;
```

垂直翻轉的話也差不多, 只是 `endIndex` 算法不同, 關鍵為 `imageData.height - y` 取得結束位置的垂直高度

```
//起始
let beginIndex = (y * imageData.width + x) * 4;

//結束
let endIndex = ((imageData.height - y) * imageData.width + x) * 4;
```
