---
title: flask 的低能兒筆記
date: 2021-04-18 13:23:46
tags:
---
&nbsp;
<!-- more -->

### 安裝 pycharm
[pycharm](https://www.jetbrains.com/pycharm/)
老樣子還是要安裝一下 vim 的 plugin , 設定方法跟以前 android studio 一模一樣就懶得寫了 , [直接偷看以前寫得比較快](https://weber87na.github.io/2021/02/21/Android-Studio-vim-mode/)

### 安裝 anaconda 整合環境
chocolate 直接安裝 anaconda3
```
choco install anaconda3
```

需要加入 `condabin` 環境變數
```
C:\tools\Anaconda3\condabin
```

[操作參考自](https://medium.com/python4u/%E7%94%A8conda%E5%BB%BA%E7%AB%8B%E5%8F%8A%E7%AE%A1%E7%90%86python%E8%99%9B%E6%93%AC%E7%92%B0%E5%A2%83-b61fd2a76566)

```
#查 conda 環境
conda env list

#安裝一個 python3.9 的環境在 conda 上
conda create --name flaskenv python=3.7

#啟動 conda 環境
activate flaskenv

#安裝 flask 在目前環境上
conda install flask -y
conda install flask-restful -y
conda install Flask-SQLAlchemy -y
conda install pymssql -y

#看目前環境的 python 裝了什麼套件
conda list

#離開目前環境
deactivate

#
conda env remove --name flaskenv
```

整合 pycharm [參考老外](https://medium.com/infinity-aka-aseem/how-to-setup-pycharm-with-an-anaconda-virtual-environment-already-created-fb927bacbe61)

隨便開個空資料夾 , 接著依照下列設定去 config 
`File` => `Settings` => `Project` => `Python Interpreter` => `Conda Environment` => `Existing environment` => 
`C:\tools\Anaconda3\envs\flaskenv\python.exe` =>  => `C:\tools\Anaconda3\Scripts\conda.exe` => `Make available to all projects`
搞定後再 pycharm 開啟 terminal 看看是否長這樣 , 是的話就搞定了
```
(flaskenv) C:\Users\GG\test_flask>
```

### 傳統安裝 python
[載點](https://www.python.org/downloads/)


### chocolate 安裝 python
懶得設定環境變數跟阿撒布魯的話直接偷懶用 [chocolate](https://community.chocolatey.org/packages?q=python) 也是個不錯的選擇
```
choco install python
```

### 建立虛擬環境
以前寫 python 2.7 時都沒使用虛擬環境 , 每次都搞得整台電腦亂七八糟的 , 現在乖乖用吧
```
python -m venv .env
```

### 安裝 flask 常用的 lib
```
pip install flask
pip install flask-restful
pip install Flask-SQLAlchemy
pip install pymssql
#萬一炸了可以到此找看看 https://www.lfd.uci.edu/~gohlke/pythonlibs/#pymssql
#將下載的 whl 丟到專案內這樣安裝 pip install pymssql-2.1.5-cp36-cp36m-win_amd64.whl
```

### 檢查 dependency
在資料夾底下新增 `requirements.txt` 執行以下命令
```
python -m pip freeze
```

### helloworld
感覺每次都要寫 jsonify 還滿麻煩的 , 不過因為是弱類型的語言 , 寫起來真的好快 , 7 行就做完了 , 特別適合我這種低能兒 , 感動!
```
from flask import Flask , jsonify , request

app = Flask(__name__)

@app.route('/', methods=['GET'])
def helloworld():
    return jsonify({'helloworld' : 'helloworld'})

if __name__ == "__main__":
    app.run()

```

### pymssql helloworld
隨便蓋張表
``` sql
CREATE TABLE [dbo].[Card](
	[Id] [int] NOT NULL,
	[Num] [int] NULL,
 CONSTRAINT [PK_Customer_Card] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```
新增 `card` 類別 , 這邊也雷很久 , 因為預設不能直接輸出成 json , 從一個生態系換到其他生態系明明很多很簡單的問題 , 實際上卻很低能 , 所以[參考邢烽朔解答](https://stackoverflow.com/questions/5022066/how-to-serialize-sqlalchemy-result-to-json)
注意這邊最重要就是 `as_dict` 這句 , 用他才可以轉成 json , 結果雷了兩小時後面課程也用一樣的解法 , 天下文章一大抄就對了
注意這邊的類別最好補上 `__tablename__` 防止 mapping 的時候發生錯誤
```
from test import db

class Card(db.Model):
	__tablename__ = 'Card'
    id = db.Column(db.Integer, primary_key=True)
    Num = db.Column(db.Integer)

    def as_dict(self):
        return {item.name: getattr(self, item.name) for item in self.__table__.columns}

    def __repr__(self):
        return "id={}, Num={}".format(
            self.id,
            self.Num
        )
```
設定撈資料的類別
```
from flask import  Flask , jsonify , request
from flask_restful import Resource

from test.model.card import Card
from test import db
import json


class Helloworld(Resource):

    def get(self):
        list = []
        cards = db.session.query(Card).all()
        for x in cards :
            list.append(x.as_dict())
        return jsonify(list)

```

後來看課程才發現有這種淫蕩的寫法
```
return [x.as_dict() in cards]
```

設定 `__init__.py`
```
from flask import Flask
from flask_restful import Api
from flask_sqlalchemy import SQLAlchemy
import pymssql
# from flask_migrate import Migrate


db = SQLAlchemy()


from demo.resource.helloworld import Helloworld
from demo.model.card import Card

def create_app():

    app = Flask(__name__)
    api = Api(app)
    # app.config['SQLALCHEMY_DATABASE_URI'] = "sqlite:///demo.db"
    # app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:root@localhost:3306/demo'
	
    app.config['SQLALCHEMY_DATABASE_URI'] = "mssql+pymssql://sa:yourpassword@localhost/test"
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)

    api.add_resource(Helloworld, '/')


    return app
```

### 模組化 __init__.py
python 的模組化還滿奇怪的要先建個資料夾接著加入 `__init__.py` 的空文件
然後引用方法大概長這樣
```
from test.resource.gg import Helloworld
```
gg.py => 被引用的檔案
test.resource => 資料夾名稱 , 有點像 java 的 package or c# namespace , 但是又不倫不類
Helloworld => 類別名稱

### flask run
這個雷超久 , 看 udemy 上面是用 mac , 自己在 windows 跑雷暴 , 原來只要在 cmd 下這樣就好
``` cmd
set FLASK_APP=test:create_app()
flask run
```

### flask shell
這鬼東西可以直接跑一些有的沒的 , 想先測試程式就靠他
```
flask shell
```
### 用 windows 開 python 會自動開啟 Microsoft Store
只需要把環境變數的 python 調整到 WindowsApps 之前即可
C:\Python36
C:\Users\YourName\AppData\Local\Microsoft\WindowsApps
