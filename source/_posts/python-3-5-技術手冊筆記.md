---
title: python 3.5 技術手冊筆記
date: 2025-04-19 03:17:34
tags: python
---

&nbsp;

<!-- more -->
龜家天天看老鼠[廢片](https://www.youtube.com/shorts/sTezq-GOTY4), 大概老天覺得太廢的關係, 突然發現家裡有一本良葛格 (RIP) python3.5 技術手冊, 就順便讀一讀複習下, 那個時空連 vscode 都沒有 ROFL ~

## ch1 ch2
### 環境變數關鍵字
安裝完以後重要資料夾 `Lib` `Scripts` `Tools`
如果選加入環境變數則 `Scripts` 也會被包含進去
我自己用 anaconda3 列出來會長這樣, 原版不曉得長怎樣 @. @

```
import sys
sys.path

[
'', 
'C:\\Users\\lasai\\anaconda3\\python312.zip',
'C:\\Users\\lasai\\anaconda3\\DLLs',
'C:\\Users\\lasai\\anaconda3\\Lib',
'C:\\Users\\lasai\\anaconda3',
'C:\\Users\\lasai\\anaconda3\\Lib\\site-packages',

//書上沒列
'C:\\Users\\lasai\\anaconda3\\Lib\\site-packages\\win32', 
'C:\\Users\\lasai\\anaconda3\\Lib\\site-packages\\win32\\lib', 
'C:\\Users\\lasai\\anaconda3\\Lib\\site-packages\\Pythonwin'
]
```


用 help() 函數以後輸入 `keywords` 可以列出關鍵字
```
help> keywords

Here is a list of the Python keywords.  Enter any keyword to get more help.

False               class               from                or
None                continue            global              pass
True                def                 if                  raise
and                 del                 import              return
as                  elif                in                  try
assert              else                is                  while
async               except              lambda              with
await               finally             nonlocal            yield
break               for                 not
```

可以用 `dir(__builtins__)` 取得常用函數跟類別

```
dir(__builtins__)
['ArithmeticError', 'AssertionError', 'AttributeError', 'BaseException', 'BaseExceptionGroup', 'BlockingIOError', 'BrokenPipeError', 'BufferError', 'BytesWarning', 'ChildProcessError', 'ConnectionAbortedError', 'ConnectionError', 'ConnectionRefusedError', 'ConnectionResetError', 'DeprecationWarning', 'EOFError', 'Ellipsis', 'EncodingWarning', 'EnvironmentError', 'Exception', 'ExceptionGroup', 'False', 'FileExistsError', 'FileNotFoundError', 'FloatingPointError', 'FutureWarning', 'GeneratorExit', 'IOError', 'ImportError', 'ImportWarning', 'IndentationError', 'IndexError', 'InterruptedError', 'IsADirectoryError', 'KeyError', 'KeyboardInterrupt', 'LookupError', 'MemoryError', 'ModuleNotFoundError', 'NameError', 'None', 'NotADirectoryError', 'NotImplemented', 'NotImplementedError', 'OSError', 'OverflowError', 'PendingDeprecationWarning', 'PermissionError', 'ProcessLookupError', 'RecursionError', 'ReferenceError', 'ResourceWarning', 'RuntimeError', 'RuntimeWarning', 'StopAsyncIteration', 'StopIteration', 'SyntaxError', 'SyntaxWarning', 'SystemError', 'SystemExit', 'TabError', 'TimeoutError', 'True', 'TypeError', 'UnboundLocalError', 'UnicodeDecodeError', 'UnicodeEncodeError', 'UnicodeError', 'UnicodeTranslateError', 'UnicodeWarning', 'UserWarning', 'ValueError', 'Warning', 'WindowsError', 'ZeroDivisionError', '__build_class__', '__debug__', '__doc__', '__import__', '__loader__', '__name__', '__package__', '__spec__', 'abs', 'aiter', 'all', 'anext', 'any', 'ascii', 'bin', 'bool', 'breakpoint', 'bytearray', 'bytes', 'callable', 'chr', 'classmethod', 'compile', 'complex', 'copyright', 'credits', 'delattr', 'dict', 'dir', 'divmod', 'enumerate', 'eval', 'exec', 'exit', 'filter', 'float', 'format', 'frozenset', 'getattr', 'globals', 'hasattr', 'hash', 'help', 'hex', 'id', 'input', 'int', 'isinstance', 'issubclass', 'iter', 'len', 'license', 'list', 'locals', 'map', 'max', 'memoryview', 'min', 'next', 'object', 'oct', 'open', 'ord', 'pow', 'print', 'property', 'quit', 'range', 'repr', 'reversed', 'round', 'set', 'setattr', 'slice', 'sorted', 'staticmethod', 'str', 'sum', 'super', 'tuple', 'type', 'vars', 'zip']
```

配合 loop 又可以做出 [打字練習](https://www.blog.lasai.com.tw/2023/01/31/%E6%89%93%E5%AD%97%E7%B7%B4%E7%BF%92/) 的殭屍字典 XD
```
for word in dir(__builtins__):
	print(word)
```

最後新建 python 檔案用 UTF8 檔首無 BOM 就對了! 不然會噴亂碼, 其他一律 ban ~

### 套件
資料夾中一定要有一個 `__init__.py` 才會被視為一個套件, 套件名稱為資料夾名稱

```
cow
	__init__.py
	xx.py
lasai
	__init__.py
	oo.py
```

假如要從 lasai 呼叫 cow 裡面的 `xx.py` 要這樣用

```
import cow.xx
```

### import

as 這最常看到的用法應該是 numpy 這類的東東
```
import numpy as np
np.array([1,2,3])
```

也可以用 from 這種懶人用法
```
from sys import argv
print('qq' , argv[1])
```

用逗點隔開可以一次處理多個, 也可以用 `*` 不過不建議會有名稱衝突的問題

```
from sys import argv, path
```

也可以從套件匯入模組

```
from lasai import gg
```

## ch3
數值均為 `int` 沒有 `long`

複數, 希望不要用到 XD
```
>>> type(3.14)
<class 'float'>
>>> a = 3 + 2j
>>> b = 5 + 3j
>>> a + b
(8+5j)
>>> type(a)
<class 'complex'>
```

字串會有 escape 的問題, 如果不要 escape 可以在前面加上 `r`
```
print('c:\xx')
c: xx

print(r'c:\xx')
c:\xx
```

跟 c# 一樣要換行需要用三個引號
```
print("""ooooooo
xxxxxxxxx""")
ooooooo
xxxxxxxxx
```

可以用 `str` 來做到 c# 的 `Convert.ToString` 功能

```
str(123)
```

可以用 `{}` 做出 c# template string 效果
```
print('name={} , age={}'.format('qq', 18))
name=qq , age=18
```

後來發現 3.6 也可以跟 js c# 一樣直接把變數放裡面就好了,不過要多加個 `f` 在前面就是, 不用多搞個 `format`
```
age = 18
name = 'qq'
print(f'name:{name} age:{age}')

name:qq age:18
```

可以用 `[]` 來當作索引取得某個 char, 並且可以用 `in` 來判斷是否這個 char 在 string 裡, 搭配切片可以取感興趣的區塊 ROI
```
>>> name = '曹休蔣幹華雄曹爽'
>>> name[2]
'蔣'
>>> name[3]
'幹'
>>> name[4]
'華'
>>> '曹' in name
True
>>> name[2:5]
'蔣幹華'
```

另外他的步進值也可以用負的, 所以可以拿來反轉 array
```
text = '12345'
text[::-1]
```

Tuple
只要在數值後面加上逗號就可以做出來
```
>>> 10,
(10,)
```

可以用 Tuple 拿來做這種噁心的交換

```
>>> x = 10
>>> y = 20
>>> x, y = y, x
>>> x
20
>>> y
10
```

Set 可以用這種噁心的符號做出 sql 常用的效果 `& 可以交集 intersect` `| 聯集 union` `- 則可以做出 except minus` `^ 互斥` 

```
a = {1,2,3}
b = {2,3,4}

a & b
{2, 3}

a | b
{1, 2, 3, 4}

a - b
{1}

b - a
{4}

a ^ b
{1, 4}
```

練習1 做出下面效果
```
python .\exercisel.py qq gg no go yy
有 5 個不重複字串 {'gg', 'go', 'yy', 'qq', 'no'}
```

sys.argv[0] 為檔案名稱

```
import sys
words = set(sys.argv[1:])
print('有 {} 個不重複字串 {}'.format(len(words), words))
```

練習2 做出下面效果

```
python .\excercise2.py gg oo gg gg
gg 出現了 2 次
```

書上提示用 count 可以算出次數

```
import sys
from collections import Counter
words = sys.argv[1:]
search = words[0]
# 需要排除自己 1 次, 或是從 sys.argv[2:] 開始
num = words.count(search) - 1
text = '{} 出現了 {} 次'.format(search, num)
print(text)
```

問 AI 還可以用 Counter 這咚咚
```
import sys
from collections import Counter
words = sys.argv[1:]
counter = Counter(words)
search = words[0]
text = '{} 出現了 {} 次'.format(search, counter[search] - 1)
print(text)

```

## ch4

### while
while 迴圈有 else 這啥鬼語法, 而且非用 `break` 跳出的話都會執行 `else`

```
while False:
	print('while')
else:
	print('else')
```

這邊因為是用 break 跳出, 所以不會直營 `else` 書上建議直接把 while else ban 了 XD
```
num = 0
while num <= 5:
	print(f'before :{num}')
	num += 1
	print(f'after :{num}')
	if num == 5:
		break
else:
	print('else 在這邊永遠不會執行')
```

### for
一般常見程式語言如 js for 迴圈會長這樣

```
var list = [1,2,3]
for (let i = 0; i < list.length; i++)
	console.log(`index:${i}, value:${list[i]}`)
```

python 卻特別噁心要搞個 range, 如果想要輸出 index 的話需要這樣操作, 而且 for 也有 for in else 語法不過一樣被 ban


```
my_list = [1,2,3]
for i in range(len(my_list)):
	print(i,my_list[i])
```

不然就要用 `enumerate`

```
my_list = [1,2,3]
for index , value in enumerate(my_list):
	print(index, value)
```

並且注意到 `range` 的第二個參數為終止條件, 所以輸出 0 ~ 9 要這樣寫

```
for i in range(0,10):
	print(i)
```

另外 python 還有噁心的 `for comprehension` 而且只要給他相應的符號他就會建立想要的東東
* [] list 
* {} dict 
* () generator

```
nums = [1, 2, 3, 4]
squared = [x**2 for x in nums]
print(squared)  # [1, 4, 9, 16]
```

### def 定義函數

python 也有 local function, 這個在 js 最常用應該是有遞迴呼叫這種情況希望裡面多包一層, 不過要注意需要先定義才呼叫, 像這樣寫會掛點

```
def qq():
	text = localqq()
	print(text)
	
	def localqq():
		return 'qq'


qq()
```

這樣寫就過了 ooxx.. 被 js 荼毒的下場

```
def qq():	
	def localqq():
		return 'qq'
		
	text = localqq()
	print(text)

qq()
```

python 沒有 overload (到底什麼垃圾語言 怒 ~), 這樣寫第二函數個會覆蓋第一個函數

```
def greet(name):
    print(f"Hello, {name}")

def greet(name, age):
    print(f"Hello, {name}. You are {age} years old.")
```

常用的替代方案是加上 `* or **`

`*` 表示 `tuple`

```
def sum(*numbers):
	result = 0
	for number in numbers:
		result += number
	return result
	
	
sum(1,2,3,4,5)
```

`**` 表示 `字典 dict`
```
def show_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key} = {value}")
		
show_info(name="Alice", age=25, city="Taipei")

p = {'name':'qq','age':18}
show_info(**p)

```

他們也可以搭配一起用, 好噁心
```
def some(*arg1, **arg2):
	print(arg1)
	print(arg2)


>>> some(1,2,3)
(1, 2, 3)
{}

>>> some(name = '丁ava')
()
{'name': '丁ava'}


>>> some('fq' , 'qq', name = '丁ava')
('fq', 'qq')
{'name': '丁ava'}
```

## ch5
### import
一個 `.py` 就是一個模組, 可以用 `dir` 來看模組裡面的東東

```
import numpy
import math
dir(numpy)
dir(numpy.version)
dir(math)
```

可以定義模組然後 import 來用

`mygame.py`
```
def gg():
	print('gg')
```

```
import mygame

mygame.gg()
```

也可以用懶人用法法呼叫 mygame 裡面的 gg
```
from mygame import gg

gg()
```

也可以用 `from xxx import *` 不過會發生命名衝突, 所以就忘了它吧! 他會把所有不含底線公開的內容都給匯入

### 類別
可以用以下這種方法定義類別, `__init__` 是建構子, 第一個參數約定俗成為 `self`, `__str__` 則跟 c# 的 ToString 差不多, 兩個底線表示魔術方法
```
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def introduce(self):
        return f"Hi, I'm {self.name} and I'm {self.age} years old."

    def __str__(self):
        return self.introduce()
		
import person
p = person.Person("gg", 30)
print(p)
```

如果需要把參數設定為私有要這樣寫, 不過還是可以訪問他的私有變數只不過要改寫這樣 `p._Person__name`

```
class Person:
    def __init__(self, name, age):
        self.__name = name
        self.__age = age

    def introduce(self):
        return f"Hi, I'm {self.__name} and I'm {self.__age} years old."

    def __str__(self):
        return self.introduce()
		
import person
p = person.Person("gg", 30)
print(p)
```

如果想搞出 c# getter 需要加上 `@property` 標註即可

```
class Person:
    def __init__(self, name, age):
        self.__name = name
        self.__age = age

    def introduce(self):
        return f"Hi, I'm {self.__name} and I'm {self.__age} years old."

    def __str__(self):
        return self.introduce()

    @property
    def name(self):
        return self.__name

    @property
    def age(self):
        return self.__age


import person
p = person.Person("gg", 30)
p.name
```

如果想要 getter 與 setter 則這樣寫, 怎麼覺得 getter setter 在 python 變得好囉嗦

```
class Person:
    def __init__(self, name, age):
        self.__name = name
        self.__age = age

    @property
    def name(self):
        return self.__name

    @name.setter
    def name(self, value):
        if not value:
            raise ValueError("Name cannot be empty.")
        self.__name = value

    @property
    def age(self):
        return self.__age

    @age.setter
    def age(self, value):
        if value < 0:
            raise ValueError("Age cannot be negative.")
        self.__age = value

    def introduce(self):
        return f"Hi, I'm {self.__name} and I'm {self.__age} years old."

    def __str__(self):
        return self.introduce()

```

## ch6
繼承的時候只要把父類別放在子類別的建構子即可 `class Groundhog(Marmot)`
```
# 土撥鼠
class Marmot:
    def __init__(self, name, hp):
        self.name = name
        self.hp = hp
        
    def __str__(self):
            return f"name:{self.name},hp:{self.hp}"

# 美洲土撥鼠
class Groundhog(Marmot):
    def dig(self):
        print('美洲土撥鼠挖洞')

class Machine:
	pass
```

這裡一樣不管型別是啥, 只要方法對了就可以用傳遞函數的方式呼叫
```
import marmot
groundhog = marmot.Groundhog('美洲土撥鼠',33)
groundhog.dig()

m = marmot.Marmot('土撥鼠' ,10)
print(m)

def dig(x):
	x.dig()

machine = marmot.Machine()
machine.dig = lambda: print('機器挖土')
dig(machine)
```

可以用 isinstance 來判斷型別
```
def dig(x):
	if isinstance(x, marmot.Machine):
		print('機器挖土')
	elif isinstance(x, marmot.Groundhog):
		print('美洲土撥鼠挖土')
	
```

如果想要基於父類的功能來使用 function 的話, 可以用 `super()`

```
class Groundhog(Marmot):
    def dig(self):
        print('美洲土撥鼠挖洞')

	def __str__(self):
		return f"超古錐的美洲土撥鼠" + super().__str__()
```

```
import marmot
g = marmot.Groundhog('qq',123)
print(g)
```

抽象方法需要加入 abc 模組, 剛開始看到還以為在寫幹話 XD, 不過書上是用 `ABCMeta` 好像比較舊版的用法
只需要標示 `@abstractmethod` 就可以搞出抽象方法

```
from abc import ABC, abstractmethod

# 土撥鼠（抽象類別）
class Marmot(ABC):
    def __init__(self, name, hp):
        self.name = name
        self.hp = hp

    def __str__(self):
        return f"name:{self.name},hp:{self.hp}"

    @abstractmethod
    def fight(self):
        pass  # 子類別必須實作這個方法


# 美洲土撥鼠
class Groundhog(Marmot):
    def dig(self):
        print('美洲土撥鼠挖洞')

    def fight(self):
        print(f"{self.name} 用爪子攻擊！")

    def __str__(self):
        return f"超古錐的美洲土撥鼠" + super().__str__()


# 機器
class Machine:
    def dig(self):
        print('機器挖土')

```

想要用 enum 則是需要用以下這種方式

```
from enum import IntEnum
class WebOp(IntEnum):
	get = 1
	post = 2
	put = 3
	delete = 4
	
op = WebOp(1)

op.name #'get'
op.value #1

for op in WebOp:
	print(op.name , op.value)
```

另外 python 竟然支援多重繼承 -. -"
印象以前學 c++ 這個功能不是臭掉了嗎 XD
這裡就利用多重繼承來建立一隻機甲土撥鼠
這裡一樣可以在建構子這樣寫 `super().__init__` 省略一些麻煩
這裡萬一方法名稱重複的話需要注意下, 會先找子類, 接著由左往右找父類

```
# 機器土撥鼠
class MechaMarmot(Marmot, Machine):
    def __init__(self, name, hp, serial_number):
        super().__init__(name, hp)
        self.serial_number = serial_number

    def fight(self):
        print(f"{self.name}（編號 {self.serial_number}）發射雷射光！")

    def __str__(self):
        return f"未來戰鬥型機器土撥鼠 {super().__str__()}，序號:{self.serial_number}"
```

用法也沒兩樣
```
m = marmot.MechaMarmot('qq',120,'abc')
m.fight() # qq（編號 abc）發射雷射光！
m.dig() # 機器挖土

```

最後還有 Rich comparison 方法, 有 `__lt__()` `__le__()` `__eq__()` `__ne__()` `__gt__()` `__ge__()` 等, 用到再說 XD

## ch7

可以用 `try except` 來做出例外處理的效果

```
total = 0
count = 0

while True:
    number_str = ''
    try:
        number_str = input('輸入數字:')
        number = int(number_str)
        if number == 0:
            break
        else:
            total += number
            count += 1
    except ValueError as err:
        print('非整數的輸入', number_str)
        
print('avg', total / count)
```

要小心以下寫法, 會跳不出迴圈, 所有例外都是 BaseException 的子類, 當使用 except 沒指定例外型態時, 就是比對 BaseException
```
while True:
	try:
		print('run..')
	except:
		print('shit happens!')
		
```

如果指定了 Exception 就可以透過 ctrl + c 跳出

```
while True:
	try:
		print('run..')
	except Exception:
		print('shit happens!')
```

python 的 raise 等同於 c# 的 throw

```
def health(hp):
	if hp <= 0:
		raise ValueError('土撥鼠 hp 不能是負數:' + str(hp))
```

另外還有這樣的語法可以使用, 如果沒錯就跑 else 那段, 最後則一定跑 finally
```
try:
	hp = 10
except ValueError as err:
	print(err)
else:
	print('hp:', hp)
finally:
	print('gg')
```

此外還有類似 c# using 的語法, with as 會自己在 finally 幫你關閉釋放資源
```
import sys

for arg in sys.argv[1:]:
    try:
        with open(arg, 'r') as f:
            print(arg, '有' , len(f.readlines()), '行')
    except FileNotFoundError:
        print('找不到檔案', arg)
```

在 fastapi 也可以看到這樣的寫法

```
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```