---
title: python 操作 netcdf 筆記
date: 2022-08-13 04:18:02
tags:
- GIS
- netcdf
- python
---
&nbsp;
![netcdf](https://raw.githubusercontent.com/weber87na/flowers/master/weather.jpg)
<!-- more -->

礙於某年接觸到這個該死的檔案格式 , 後來三不五時就會有人來煩我 , 不過以前是用 ncl 這個鬼語言去搞這些東西
那個環境實在太麻煩了 , 剛好有人找我就把這些方法換成 python 筆記下 , 不然這個鬼玩意實在有夠冷門 , 每次做每次忘
下次有空再把以前 ncl 的挖出來寫一寫好了

## 環境準備
### 下載 Panpoly
先到 NASA 下載最新版本 5.1.1
https://www.giss.nasa.gov/tools/panoply/download/
`特別注意電腦一定要有 java 11 才能跑!`

### 安裝及設定 OpenJDK11
這裡用微軟的 [OpenJdk 11](https://docs.microsoft.com/zh-tw/java/openjdk/download)
接著在環境變數 `Path` 加上這樣 `C:\Program Files\OpenJDK\jdk-11.0.15+10\bin`
然後新增 `JAVA_HOME` 設定這樣 `C:\Program Files\OpenJDK\jdk-11.0.15+10\bin`

### Panpoly 操作說明
礙於 Panpoly 操作與之前不太一樣 , 這邊順便帶一下
點選 `File` => `Open` => `YOURNETCDF.nc` => `點選變數` => `右鍵` => `Create Plot` =>
`接著點選 Georeferenced Longitude-Latitude color contour plot` => `Create`
建立地圖後 , 會發現以前可以選時間的選項不見了 , 他現在被藏在 `Window` => `Arrays` 裡面 , 想關閉的話點選左上角的叉叉
選完之後時間的小視窗就會跳出來 , 有任何需要修改 view 的地方就找看看 `Window`

### conda 準備
`注意要用 Anaconda Prompt 這個 shell 開啟!!` 開啟後會長下面這樣
```
(base) ┏[lasai]
┖[~]>
```

接著準備 [conda](https://www.anaconda.com/products/distribution) 需要的環境 , 這邊用 [xarray](https://docs.xarray.dev/en/stable/) 這個 lib 來操作 netcdf 應該可以省不少事
如果需要合併 netcdf 要多安裝 `dask`
```
conda env list
conda create --name netcdf
conda install netcdf4
conda install xarray
conda install pandas
conda install numpy
conda install dask
conda install jupyter notebook
conda install psycopg2
conda install matplotlib
conda activate netcdf
```
最後會長這樣
```
(netcdf) ┏[lasai]
┖[~]>
```

## example
### 匯出為 csv
本來以為會很麻煩 , 沒想到很無腦
比較需要注意的是萬一不要有 NaN 的資料可以用 [`dropna`](https://stackoverflow.com/questions/39695606/querying-panda-df-to-filter-rows-where-a-column-is-not-nan)
```
import xarray as xr
import numpy as np

nc = xr.open_dataset('YOURFILE.nc')

list(nc.keys())

# 可以直接這樣撈
nc.yourvariable.to_dataframe().to_csv('YOURFILE.csv')


# 或是這樣撈
nc['yourvariable'].to_dataframe().to_csv('YOURFILE.csv')

# 過濾 nan
nc.yourvariable.to_dataframe().dropna(subset=['yourvariable']).to_csv('YOURFILE.csv')

# 一次撈多個
df = nc.to_dataframe()
df.dropna(subset=['var1','var2']).to_csv('test.csv')
```

### 合併 netcdf
我有數個月的 netcdf 資料類似這樣的結構 `YOURNETCDF\2020` , 希望可以合成一個單檔
```
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
------      2021/7/19  下午 05:22       12883288   YOURNETCDF_202001.nc
------      2021/7/19  下午 05:22       14316965   YOURNETCDF_202002.nc
------      2021/7/19  下午 05:22       15383188   YOURNETCDF_202003.nc
------      2021/7/19  下午 05:22       11371512   YOURNETCDF_202004.nc
```

在 `Anaconda Prompt` 底下輸入指令開啟 vscode
```
cd YOURNETCDF\2020
code .
```

接著合併看看 , 一樣在 `YOURNETCDF\2020` 資料夾新增一隻 `merge_netcdf.py`
這裡最大的雷應該就是沒安裝 `dask` , 只要安裝了就是無腦合併
```
import xarray as xr
import os

# 取得目前資料夾名稱
year_name = os.path.basename(os.getcwd())

# 取得上層目錄的絕對路徑
prev_dir_name = os.path.abspath(os.path.join(os.getcwd(), os.path.pardir))

# 過濾出變數名稱
variable_name = os.path.basename(prev_dir_name)

# 合成完整名稱
full_name = f"{variable_name}_{year_name}.nc"
# print(full_name)

# 需先安裝 dask 模組
# conda install dask
ds = xr.open_mfdataset('*.nc', parallel=True)

ds.to_netcdf(full_name)
```

最後執行 `merge_netcdf_demo.py` 看看應該會得到以下結果
```
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----       2022/7/31  上午 11:19      186940159   YOURNETCDF_2020.nc
```

接著開啟 `Panpoly` 來驗證是否正確合併了
點選 `File` => `Open` => `YOURNETCDF_2020.nc` => `點選變數` => `右鍵` => `Create Plot`
接著點選 `Georeferenced Longitude-Latitude color contour plot` => `Create`
接著點選 `Window` => `Arrays` 可以看到現在有 365 天了


### 修復時間 Coordinates
今天拿到一份檔案 , 本來之前的資料都正常 work , 偏偏這份出了問題 , 拿 jupyter 跟 Panpoly debug 看看 , 發現是時間的 Coordinates 有問題
這個在轉資料或是製作資料時 , 應該要把 `date` 這個變數放在 `Coordinates` 裡面才對
神奇的是 , 用 Panpoly 也是可以選擇時間這個維度 , 只不過顯示的是 1 - 31 , 並非正常的時間
我陸續看了幾個 api `expand_dims` , `assign_coords` 下去 try , 不過都沒成功 , 所以用以下比較蠢的方法去做
```
# 讀取 netcdf
nc = xr.open_dataset('XXX.nc')
nc
```
輸出如下結果
```
Dimensions:
	time: 31 latitude: 409 longitude: 313
Coordinates:
	latitude (latitude) float32 ...
	longitude (longitude) float32 ...
Data variables:
	date (time) float32 ...
	othervar (time, latitude, longitude) float32 ...
	othervar2 (time, latitude, longitude) float32 ...
```

如果要變成正常格式應該會長這樣 , 特別注意 `xarray` 時間通常都是 `datetime64[ns]`
```
Dimensions:
	time: 31 latitude: 409 longitude: 313
Coordinates:
	time (time) datetime64[ns] ...
	latitude (latitude) float32 ...
	longitude (longitude) float32 ...
Data variables:
	othervar (time, latitude, longitude) float32 ...
	othervar2 (time, latitude, longitude) float32 ...
```

首先建立時間這個 dataframe , 可以參考[這裡](https://pandas.pydata.org/docs/reference/api/pandas.to_datetime.html)
我這裡方法可能比較蠢 , python 寫得斷斷續續 , 所以就直接 for loop
假設時間是 `2008-01-01` 至 `2008-01-31` 可以這樣寫
```
import xarray as xr
import numpy as np
import pandas as pd
import pandas.io.sql as sqlio

# 讀取 netcdf
nc = xr.open_dataset('BADFILE.nc')
# nc

# 手動加入時間
newyear = []
newmonth = []
newdate = []
newminute = []

# 31 天
print(len(nc.date))

for x in nc.date:
    newyear.append(2008)
    newmonth.append(1)
    newdate.append(int(x))
    # 這裡沒小時可以設定 , 所以要這樣寫
    # format like this 2008-01-01 12:00:00
    newminute.append(int(60 * 12))

df = pd.DataFrame({'year': newyear, 'month': newmonth, 'day': newdate , 'minute': newminute})
newfulltime = pd.to_datetime(df)
```

接著撈出 `變數` 與 `global 屬性` 及 `經緯度`
```
# 取得經緯度
lat = nc['latitude'].values
lon = nc['longitude'].values

# 撈變數
othervar = nc.othervar.values
othervar2 = nc.othervar2.values

# 取得 global 屬性
att = nc.attrs
```

針對每個變數建立 DataArray
```
# 建立 DataArray
new_othervar = xr.DataArray(
othervar,
coords={
	'time': newfulltime,
	'latitude': lat,
	'longitude': lon
},
dims=['time', 'latitude', 'longitude'],
)

# 建立 DataArray
new_othervar2 = xr.DataArray(
othervar2,
coords={
	'time': newfulltime,
	'latitude': lat,
	'longitude': lon
},
dims=['time', 'latitude', 'longitude'],
)
```

最後重建檔案
```
# 重建 netcdf 檔案
newds = xr.Dataset(
    data_vars=dict(
        othervar = new_othervar,
        othervar2 = new_othervar2
    ),
    attrs=att,
)

# 他這個有指定用 NETCDF4 去存檔
newds.to_netcdf('FIXFILE.nc',format='NETCDF4')


# 讀取新搞出來的檔案
newnc = xr.open_dataset('FIXFILE.nc')
# newnc
```

### 修復時間 Coordinates part2
這次遇到一批資料格式為 `yymmddHH` , 本來沒詳細看 , 也不曉得問題在哪 , 處理老半天 , 圖資 server 偏偏免錢只吃標準 format 狂噴紅字
後來才發現他的日期格式怪怪 , 因為一時也想不出啥好法子 , 就直接擷取 string 去逐一處理 , 還好最後屎運搞定

```
import xarray as xr
import numpy as np
import pandas as pd

# 建立 DataArray
def createDataArray(var, newfulltime, lat , lon):
    new_var = xr.DataArray(
        var,
        coords={
            'time': newfulltime,
            'latitude': lat,
            'longitude': lon
        },
        dims=['time', 'latitude', 'longitude'],
    )
    return new_var


# 讀檔
nc = xr.open_dataset('xxx.nc')


# 修正時間 yymmddHH 轉為正式的時間格式
time = nc['Time']
# print(time)
new_years = []
new_months = []
new_days = []
new_times = []

for x in time:
    val = x.values
    s = str(int(val))
    new_year = int(f'20{s[0:2]}')
    new_month = int(s[2:4])
    new_day = int(s[4:6])
    new_time = int(s[6:8])
    new_years.append(new_year)
    new_months.append(new_month)
    new_days.append(new_day)
    new_times.append(int(60 * new_time))

df = pd.DataFrame({'year': new_years, 'month': new_months,
                  'day': new_days, 'minute': new_times})
# 正確的時間格式
newfulltime = pd.to_datetime(df)

# 取得經緯度
lat = nc['latitude'].values
lon = nc['longitude'].values

# 撈變數
xxx = nc['xxx']

# 取得 global 屬性
att = nc.attrs

# 建立變數
new_xxx = createDataArray(xxx, newfulltime , lat , lon)



# 重建 netcdf 檔案
newds = xr.Dataset(
    data_vars=dict(
        xxx = new_xxx,
    ),
    attrs=att,
)

# 他這個有指定用 NETCDF4 去存檔
newds.to_netcdf('FIXFILE.nc',format='NETCDF4')


# 讀取新搞出來的檔案
newnc = xr.open_dataset('FIXFILE.nc')
print(newnc)
```

### 修復 Coordinate 並降維
今天又遇到個問題 , 檔案在 geoserver 上面沒法發佈 
先讀看看資料發現又暴雷 , 他的變數指定到 `lon` , `lat` 的 coordinates , 可是實際上變數又命為 `longitude` , `latitude`
這樣會造成錯誤需要修復
```
Dimensions:    (depth: 1, lon: 157, lat: 205, time: 31)
Coordinates:
  * depth      (depth) float64 0.494
  * time       (time) datetime64[ns] 1998-01-01T12:00:00 ... 1998-01-31T12:00:00
Dimensions without coordinates: lon, lat
Data variables:
    longitude  (lon) float64 ...
    latitude   (lat) float64 ...
    vo         (time, depth, lat, lon) float64 ...
```

修好了以後發現還是沒法在 geoserver 上面發佈 , 因為這次有多個 `depth` 的維度就認為是他搞的鬼
反正他的資料也只有一個深度 , 基本上沒啥意義 , 所以跑個迴圈把需要的擷取出來即可

實作 code
```
import xarray as xr

# 讀取檔案
nc = xr.open_dataset('xxx.nc')

# 撈變數
lat = nc['latitude']
lon = nc['longitude']
time = nc['time']
uo = nc['uo']
vo = nc['vo']

# 保存修改後的變數
vos = []
uos = []

# 猜測這裡的 depth 有問題導致 geoserver 發生錯誤
# 以時間 loop 重新取出數值
for i , ele in enumerate(time):
    uo_val = uo[i][0][:][:]
    vo_val = vo[i][0][:][:]
    uos.append(uo_val)
    vos.append(vo_val)


# 合併每天的資料
# https://docs.xarray.dev/en/stable/generated/xarray.concat.html
new_uo = xr.concat(uos , dim='time')

# 他這裡的 latitude longitude 寫在變數上面 coord 實際上是用 lon lat , 所以重新分配就可以正常
new_uo = new_uo.assign_coords({
    "lon" : lon,
    "lat" : lat
})

# 合併每天的資料
# https://docs.xarray.dev/en/stable/generated/xarray.concat.html
new_vo = xr.concat(vos , dim='time')

# 他這裡的 latitude longitude 寫在變數上面 coord 實際上是用 lon lat , 所以重新分配就可以正常
new_vo = new_vo.assign_coords({
    "lon" : lon,
    "lat" : lat
})

# 製作 dataset
newds = xr.Dataset(
    data_vars=dict(
        uo = new_uo,
        vo = new_vo,
    ),
)

# 刪除沒用到的變數
# https://docs.xarray.dev/en/stable/generated/xarray.Dataset.drop_vars.html
newds = newds.drop_vars('depth')
newds.to_netcdf('xxx_fix.nc')
```

### 修復 Coordinate 並且補上 units 
延續上個 example 後來覺得不該鴕鳥心態 , 這樣以後遇到類似問題不就爆炸 , 仔細看看資料發現沒有 units 猜 geoserver 認不得 , 補上去看看就搞定了 
最關鍵的一句 `depth.attrs['units'] = 'm'`
每次處理別人的資料還真是痛苦萬分 , 一堆問題要靠自己通靈的 ...

```
import xarray as xr

# 讀取檔案
nc = xr.open_dataset('XXX.nc')

# 撈變數
lat = nc['latitude']
lon = nc['longitude']
time = nc['time']
depth = nc['depth']
uo = nc['uo']
vo = nc['vo']

# 關鍵要設定深度單位不然 geoserver 認不得他
depth.attrs['units'] = 'm'

# 他這裡的 latitude longitude 寫在變數上面 coord 實際上是用 lon lat , 所以重新分配就可以正常
new_uo = uo.assign_coords({
    "lon" : lon,
    "lat" : lat,
    "depth" : depth
})

# 他這裡的 latitude longitude 寫在變數上面 coord 實際上是用 lon lat , 所以重新分配就可以正常
new_vo = vo.assign_coords({
    "lon" : lon,
    "lat" : lat,
    "depth" : depth
})

# 製作 dataset
newds = xr.Dataset(
    data_vars=dict(
        depth = depth,
        uo = new_uo,
        vo = new_vo,
    ),
)

# 保存檔案
newds.to_netcdf('XXXFIX.nc')
```


### 匯入 netcdf 資料到 postgresql
這個看起來好像很困難的作業 , 其實骨子裡就是把資料先弄成 csv 然後匯進去
如果是用 postgres 有個無腦的資料型別 `precision` 可以使用
如果是 sql server 就要考慮欄位其精度通常 `lon` 會設定為 `decimal(11,8)` , `lat` 則是 `decimal(10,8)`
另外私心推薦個好用工具 [pgcli](https://www.pgcli.com/) , 當只有 cli 時很好用 , 他也有 sql server & mysql 的版本

建立資料表
```
create database mydb;
create table test(
	id bigserial primary key,
	time timestamp,
	lon double precision,
	lat double precision,
	yourvariable double precision
);
```

沒記錯的話 , 這裡要注意只有一點就是使用 `COPY` 指令 `只能在那台電腦上 run!!!`
當然也可以一筆一筆 insert , 但是 netcdf 資料量很大 , 沒人這樣搞的 , 很蠢
```
import psycopg2
import xarray as xr
import numpy as np

# Update connection string information
host = "localhost"
dbname = "mydb"
user = "postgres"
password = "postgres"
sslmode = "allow"

# Construct connection string
conn_string = "host={0} user={1} dbname={2} password={3} sslmode={4}".format(host, user, dbname, password, sslmode)
conn = psycopg2.connect(conn_string)
print("Connection established")

cursor = conn.cursor()

nc = xr.open_dataset('YOURFILE.nc')
# 這步會把 nan 過濾掉
nc.yourvariable.to_dataframe().dropna(subset=['yourvariable']).to_csv('YOURFILE.csv')

csv_file_name = 'C:\\test\\YOURFILE.csv'
sql = "COPY test(time, lat, lon, yourvariable) FROM 'C:\\test\\YOURFILE.csv' DELIMITER ',' CSV HEADER;"
cursor.copy_expert(sql, open(csv_file_name, "r"))
conn.commit()

cursor.close()
conn.close()
```

### 繪圖
以往都是發成 wms 事情就結束了 , 繪圖基本上沒太多研究 , 暫時簡單記錄下 , 有空研究看看能否加上 Georeferencing
```
# 最基本畫法
nc.chl[0].plot()

# 可以這樣關閉 lon lat 格線
plt.axis("off")

# 找進階參數
# https://docs.xarray.dev/en/stable/generated/xarray.plot.pcolormesh.html

# 找 colormap
# https://matplotlib.org/stable/gallery/color/colormap_reference.html
nc.chl[0].plot(robust=True , add_colorbar=False ,cmap='rainbow', add_labels = False)

# 保存圖片不帶邊框滿版
plt.savefig('save.png', bbox_inches='tight',pad_inches = 0, transparent=True)
```
