---
title: excel to sql
date: 2022-10-27 20:53:36
tags:
- python
- sql
---
&nbsp;
<!-- more -->

今天遇到 user 搞個刁蠻需求 , 反正就要建立一堆資料表 , 然後他給 4x 個檔案 , 每個檔案大概有 100 個 column 真的變態 , 也沒註明哪些是複製改出來的 , 而且我又要遵守 coding style , 本來以為可以半自動完成 , 最後還是趁著半夜沒人煩搞成整個自動 , 一開始我還是想用 c# 解決 , 不過以前就搞過類似的問題 , 老實說用 c# 搞這種 batch 整個速度下降很多 , 最後還是搞 python XD

### 表格長相
我的表格長相大概類似下面這樣 , 其他還有些雜訊 , 就不一一列啦

| PK | fieldName | chinese | dbdatatype   | nullable | default   | comment |
|----|-----------|---------|--------------|----------|-----------|---------|
| V  | qq1       | qq      | int          | N        |           |         |
|    | qq2       | qq      | varchar(50)  | Y        |           |         |
|    | qq3       | qq      | datetime2(7) | Y        | getdate() |         |

### 環境準備
環境準備 , 首先需要有 `conda` , 接著切換到 `OOXX` 這個資料夾 , 並且安裝以下套件
如果懶得裝 excel 的話 vscode 有這個套件可以用 [Excel Viewer](https://marketplace.visualstudio.com/items?itemName=GrapeCity.gc-excelviewer)
```
cd OOXX

conda create --name excel
conda activate excel
conda install pandas -y
pip install stringcase
conda install openpyxl
```

### 主要 code
其中比較特別的部分就是 `lambda` , python 的這個部份真的做得不太好 , 其他語言頂多個 `->` `=>` 就搞定了 , 偏偏 python 這種講求簡潔的語言這個地方特別噁心 XD
``` python
import pandas as pd
import stringcase
import os
import sys

print(sys.argv)

if len (sys.argv) != 3 :
    print('Usage: python excel_to_sql.py file_name.xlsx sheet_name')
    sys.exit (1)

# input 傳進來的參數
xlsx_name = sys.argv[1]
sheet_name = sys.argv[2]

df = pd.read_excel(
    # 'XXOO.xlsx',
    # sheet_name="XXOO",
    xlsx_name,
    sheet_name=sheet_name,
    usecols="B:G",
)


# PK,fieldName,中文,db datatype,Nullable,default
# https://stackoverflow.com/questions/11346283/renaming-column-names-in-pandas
# 先轉換 column
original_col = ['PK', 'fieldName', 'chinese', 'dbdatatype', 'nullable', 'default']
df = df.set_axis(original_col, axis='columns', inplace=False)
print(df.columns)


# 擷取需要的部分
df = df[4:]

# 將 col 位置換到 sql 語法正確的地方
reindex_col = ['fieldName', 'chinese', 'dbdatatype', 'nullable', 'default' , 'PK' ]
df = df.reindex(columns=reindex_col)

# 轉換 Naming 符合 sql server
result_pascalcase = df['fieldName'].apply(lambda x: stringcase.pascalcase(x))
df['fieldName'] = result_pascalcase.apply(lambda x: x.replace('_', ''))

# 將 data type 轉換為小寫 , 並且將 datetime2 轉為 datetime
df['dbdatatype'] = df['dbdatatype'].apply(lambda x: stringcase.lowercase(x))
df['dbdatatype'] = df['dbdatatype'].apply(lambda x: x.replace('datetime2(7)' , 'datetime'))

# 轉換 Y or N 為 null or not null
df['nullable'] = df['nullable'].apply(lambda x: x.replace('Y', 'null'))
df['nullable'] = df['nullable'].apply(lambda x: x.replace('N', 'not null'))

# 萬一有預設值將 default 加上去
df['default'] = df['default'].apply(lambda x: x if pd.isnull(x) else 'default ' + x)

# 追加 pk
df['PK'] = df['PK'].apply(lambda x: x if pd.isnull(x) else str(x).replace('V', 'primary key identity'))

# https://stackoverflow.com/questions/13411544/delete-a-column-from-a-pandas-dataframe
# 刪除中文的 col
df.drop('chinese', axis=1, inplace=True)


print(df)

df.to_csv('tmp.csv', index=False, header=False, sep='\t')


# 取得 table 名稱
df_table_name = pd.read_excel(
    xlsx_name,
    sheet_name=sheet_name,
    nrows=1
)
table_name = df_table_name.columns[1]
table_name = table_name.replace('_','')
table_name = str(table_name).strip()

# 保存新的結果用
newlines = []
with open('tmp.csv') as f:
    # lines = f.readlines()
    lines = f.read().splitlines()
    last = lines[-1]

    newlines.append(f'create table {table_name} (' + '\n')
    for line in lines:
        if line is last:
            newlines.append(line)
            newlines.append('\n')
            newlines.append(')')
        else:
            newlines.append(line + ',' + '\n')
        


with open(f'{table_name}_sql.txt' , 'w') as f:
    f.writelines(newlines)


os.remove('tmp.csv')
```

### merge
因為最後會產生一堆 sql 檔案 , 懶得逐一執行的話可以合成一個然後去 run
``` python
import glob
filenames = glob.glob("*.txt")

print(filenames)


with open('final_sql.txt', 'w') as outfile:
    # Iterate through list
    for names in filenames:
        # Open each file in read mode
        with open(names) as infile:
            # read the data from file1 and
            # file2 and write it in file3
            outfile.write(infile.read())
        # Add '\n' to enter data of file2
        # from next line
        outfile.write("\n")
```

### 驗證 table
驗證建立資料表數量是否正確請參考以下語法 , 確保與需要建立之檔案數量相符
``` sql
select *
from INFORMATION_SCHEMA.TABLES
```

### 產生批次刪除 table
萬一中間有搞錯可以用這樣的 sql 生 sql
```
select 'DROP TABLE IF EXISTS ' + TABLE_NAME
from INFORMATION_SCHEMA.TABLES
```

### 修正 excel
後來又被要求要把一坨 excel 給全部修正 , 想到手敲這些就崩潰 
本來以為 pandas 可以馬上搞定這問題 , 不過轉 dataframe 後不曉得怎麼保持有 colspan 的格式 , 研究下好像還是要靠 `openpyxl` 才能處理
最後研究下怎麼操作 , 還好問題有解決
```
import string
import pandas as pd
import stringcase
import os
import sys
from openpyxl import load_workbook
import copy

print(sys.argv)

if len (sys.argv) != 4 :
    print('Usage: python fix_excel_naming.py path_name file_name.xlsx sheet_name')
    sys.exit (1)


path_name = sys.argv[1]
file_name = sys.argv[2]

xlsx_name = f'{path_name}/{file_name}.xlsx'

sheet_name = sys.argv[3]

wb = load_workbook(xlsx_name)

sheet = wb[sheet_name]

# 讀取 fieldName 的 column
field_name = sheet['C']
old_field_name = copy.deepcopy(field_name)

# 讀取 db_datatype 的 column
db_datatype = sheet['E']
old_db_datatype = copy.deepcopy(db_datatype)

# 範圍
start = 5

# end = 107
end = sheet.max_row

# loop fieldName 修正大小寫並移除底線
for x in range(start , end):
    old_val = field_name[x].value
    # 轉換大寫駝峰
    new_val_pascalcase = stringcase.pascalcase(field_name[x].value)

    # 移除底線
    new_val_remove_dash =  new_val_pascalcase.replace('_' , '')

    # 賦予值
    field_name[x].value = new_val_remove_dash


# loop db datatye 修正 datetime2 為 datetime
for x in range(start , end):
    old_val = db_datatype[x].value
    fix_datetime = db_datatype[x].value.replace('datetime2(7)' , 'datetime')
    db_datatype[x].value = fix_datetime


# 修正 table name
table_name = sheet['B']
table_name[0].value = stringcase.pascalcase(table_name[0].value)
table_name[0].value = table_name[0].value.replace('_','')

# 保留原本名稱
old_table_name = copy.deepcopy(table_name[0].value)

# 處理差異 log
lines = []
lines.append('TableName')
lines.append(f'{old_table_name} => {table_name[0].value}')
lines.append('-' * 100)

# loop 差異輸出結果
for x in range(start , end):
    if old_field_name[x].value != field_name[x].value or old_db_datatype[x].value != db_datatype[x].value:
        lines.append(f'{old_field_name[x].value} {old_db_datatype[x].value} => {field_name[x].value} {db_datatype[x].value}')
    else:
        lines.append(f'{old_field_name[x].value} {old_db_datatype[x].value}')

# 存檔差異 log
with open(f'{file_name}_change_log.txt' , 'w', encoding='utf-8') as f:
    for x in lines:
        f.write(x)
        f.write('\n')

# 另存新檔 excel
wb.save(f'{file_name}_fix.xlsx')
```

### 產生批次執行的 python script
如果數量少的話 , 還可以慢慢用手打指令 , 但是 user 一次給你 5x 個檔案 , 而且 sheetname 也不一樣 , 光打指令就崩潰 , 只好用 python 去產生批次指令來跑

```
import string
import pandas as pd
import stringcase
import os
import glob
import sys
from openpyxl import load_workbook
import copy

print(sys.argv)

if len (sys.argv) != 2 :
    print('Usage: python gen_script.py opt')
    print('opt: fix or sql')
    sys.exit (1)

for name in os.listdir(os.getcwd()):
    if os.path.isdir(os.path.join(os.getcwd(), name)):
        print('#' * 100)
        print('# ' + name)
        for myfile in os.listdir(os.getcwd() +  f'\{name}'):
            if myfile.endswith('.xlsx'):
                str = f"python excel_to_sql.py '{name}\'{myfile} ''"
                xlsx_name = os.getcwd() +  f'\{name}\{myfile}'
                wb = load_workbook(xlsx_name)

                if sys.argv[1] == 'sql':
                    print(f"python excel_to_sql.py '{name}\{myfile}' '{wb.sheetnames[0]}'")
                
                if sys.argv[1] == 'fix':
                    print(f"python fix_excel_naming.py '{name}' '{myfile.strip('.xlsx')}' '{wb.sheetnames[0]}'")
```

### ChatGPT 產 csharp

後續工作又遇到類似需求 , 這次玩看看 ChatGPT , 產了很多種不過還是要拿來自己修 , 不能算 100% 完美
以下是我的問法
```
幫我用 c# 語法 , 產生符合 sql server 的 create table 指令檔 , 資料表名稱為 Test
PK 這個 column 表示要加上 identity
欄位則是在 excel 的 fieldName 這一個 column
資料型態在 db datatype
是否允許 Nullable 如果是 Y 表示允許 , 如果是 N 表示不允許
default 這個 column 則表示預設值 , 如果有看到也幫我加預設值
```

這是他產的 , 可以看到相差不遠 , 但也是要 debug 下 , 可能我還不太會問 XD
```
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using ExcelDataReader;

namespace CreateTable
{
    class Program
    {
        static void Main(string[] args)
        {
            // 讀取 Excel 檔案
            var filePath = "C:\\path\\to\\TestExcelChatGPT.xlsx";
            using (var stream = File.Open(filePath, FileMode.Open, FileAccess.Read))
            {
                using (var reader = ExcelReaderFactory.CreateReader(stream))
                {
                    // 取得第一個 Sheet
                    reader.Read();
                    
                    // 資料表名稱
                    var tableName = "Test";
                    
                    // SQL 指令
                    var sql = $"CREATE TABLE {tableName} (";

                    // 逐行讀取欄位資訊
                    while (reader.Read())
                    {
                        // 欄位名稱
                        var fieldName = reader.GetValue(0).ToString();
                        
                        // 資料型態
                        var dataType = reader.GetValue(1).ToString();
                        
                        // 是否允許 Nullable
                        var nullable = reader.GetValue(2).ToString().ToUpper() == "Y" ? "NULL" : "NOT NULL";

                        // Default 值
                        var defaultValue = reader.GetValue(3).ToString() == "" ? "" : $"DEFAULT {reader.GetValue(3)}";
                        
                        // PK 欄位需要加上 IDENTITY
                        var identity = reader.GetValue(4).ToString().ToUpper() == "PK" ? "IDENTITY(1,1)" : "";
                        
                        // 產生 SQL 指令
                        sql += $"{fieldName} {dataType} {identity} {nullable} {defaultValue}, ";
                    }
                    
                    // 移除最後一個 , 符號
                    sql = sql.Remove(sql.Length - 2);

                    // 加上 Primary Key
                    sql += $", PRIMARY KEY (ID))";

                    Console.WriteLine(sql);

                    // 執行 SQL 指令
                    var connectionString = "Data Source=myServerAddress;Initial Catalog=myDataBase;User ID=myUsername;Password=myPassword;";
                    using (var conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (var command = new SqlCommand(sql, conn))
                        {
                            command.ExecuteNonQuery();
                        }
                    }
                }
            }
        }
    }
}

```

修飾
```
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using ExcelDataReader;

namespace CreateTable
{
    class Program
    {
        static void Main(string[] args)
        {

            System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);
            // 讀取 Excel 檔案
            var filePath = "D:\\TestExcelChatGPT.xlsx";
            using (var stream = File.Open(filePath, FileMode.Open, FileAccess.Read))
            {
                using (var reader = ExcelReaderFactory.CreateReader(stream))
                {
                    // 取得第一個 Sheet
                    reader.Read();

                    // 資料表名稱
                    var tableName = "Test";

                    // SQL 指令
                    var sql = $"CREATE TABLE {tableName} (" + Environment.NewLine;

                    // 要跳過的行數
                    var skip = 0;

                    // 逐行讀取欄位資訊
                    while (reader.Read())
                    {
                        //跳過的行數
                        skip++;
                        if (skip <= 4) continue;

                        // 欄位名稱
                        var fieldName = reader.GetValue(2).ToString();

                        // 資料型態
                        var dataType = reader.GetValue(4).ToString();
                        if (dataType == "datetime2(7)")
                            dataType = "datetime";

                        // 是否允許 Nullable
                        var nullable = reader.GetValue(5).ToString().ToUpper() == "Y" ? "NULL" : "NOT NULL";

                        // Default 值
                        var defaultValue = "";
                        if (reader.GetValue(6) != null)
                        {
                            defaultValue = reader.GetValue(6).ToString() == "" ? "" : $"DEFAULT {reader.GetValue(6)}";
                        }

                        // PK 欄位需要加上 IDENTITY
                        var identity = "";
                        if (reader.GetValue(1) != null)
                        {
                            identity = reader.GetValue(1).ToString().ToUpper() == "V" ? "IDENTITY(1,1)" : "";
                        }

                        // 產生 SQL 指令
                        sql += $"{fieldName} {dataType} {identity} {nullable} {defaultValue}, " + Environment.NewLine;
                    }

                    // 移除最後一個 , 符號
                    sql = sql.Trim().TrimEnd(',');
                    sql += ")";

                    Console.WriteLine(sql);
                    File.WriteAllText("sql.txt", sql);
                }
            }
        }
    }
}

```
