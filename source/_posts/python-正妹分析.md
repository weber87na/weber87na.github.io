---
title: python 正妹分析
date: 2023-12-18 21:28:08
tags: python
---
&nbsp;
<!-- more -->

無聊看到這個[人臉分數專案](https://github.com/ustcqidi/BeautyPredict) 自己想說也抓來玩看看 , 折磨了一翻

我用的 `python` 環境 `3.9.18`
```
conda create --name face3 python=3.9
conda conda activate face3
```

```
git clone https://github.com/ustcqidi/BeautyPredict.git
```

安裝以下套件 
```
pip install -r requirements.txt
```

`requirements.txt`
```
absl-py==2.0.0
astunparse==1.6.3
cachetools==5.3.2
certifi==2023.11.17
charset-normalizer==3.3.2
contourpy==1.2.0
cycler==0.12.1
dlib==19.24.2
flatbuffers==23.5.26
fonttools==4.46.0
gast==0.5.4
google-auth==2.25.2
google-auth-oauthlib==1.2.0
google-pasta==0.2.0
grpcio==1.60.0
h5py==3.10.0
idna==3.6
importlib-metadata==7.0.0
importlib-resources==6.1.1
keras==2.15.0
kiwisolver==1.4.5
libclang==16.0.6
Markdown==3.5.1
MarkupSafe==2.1.3
matplotlib==3.8.2
ml-dtypes==0.2.0
numpy==1.26.2
oauthlib==3.2.2
opencv-python==4.8.1.78
opt-einsum==3.3.0
packaging==23.2
Pillow==10.1.0
protobuf==4.23.4
pyasn1==0.5.1
pyasn1-modules==0.3.0
pyparsing==3.1.1
python-dateutil==2.8.2
requests==2.31.0
requests-oauthlib==1.3.1
rsa==4.9
scipy==1.11.4
six==1.16.0
tensorboard==2.15.1
tensorboard-data-server==0.7.2
tensorflow==2.15.0
tensorflow-estimator==2.15.0
tensorflow-intel==2.15.0
tensorflow-io-gcs-filesystem==0.31.0
termcolor==2.4.0
typing_extensions==4.9.0
urllib3==2.1.0
Werkzeug==3.0.1
wrapt==1.14.1
zipp==3.17.0
```

因為不想下載啥百度 , 所以找到這個[資料集 SCUT-FBP5500-Database-Release](https://github.com/HCIILAB/SCUT-FBP5500-Database-Release)
下載解壓後建一個資料夾 `dataset\SCUT-FBP5500` 把東西都往裡面丟
接著建立 `dataset\SCUT-FBP5500\All_Ratings` 資料夾
```
md "dataset\SCUT-FBP5500\All_Ratings"
```


然後把 `All_Ratings.xlsx` 裡面的亞洲女人 sheet 另存成 csv 取名為 `female_yellow_images.csv`
然後用 [csvq](https://mithrandie.github.io/csvq/) 篩選想要的即可 , 好像只要前三個欄位
我這裡電腦比較爛就搞個五萬筆
```
csvq -o female_white_images.csv --write-delimiter ',' 'select Rater,Filename,Rating from `female_yellow_images.csv` limit 50000'
```

接著找到 `prepare_data.py` 只留下亞洲女人的 `female_yellow_images.csv` 即可
```
rating_files = ['female_yellow_images.csv']
```

然後 cd 到 `train/ldl+resnet` 執行 `prepare_data.py` 標記
```
cd .\train\ldl+resnet\
python prepare_data.py
```

這個時候會噴 `AttributeError: scipy.misc is deprecated and has no attribute toimage`
找到這句
```
img = scipy.misc.toimage(img)
```

修改為
```
img = Image.fromarray(img.astype('uint8'), 'RGB')
```

然後會出現 `test_lable_distribution.dat` `train_lable_distribution.dat`

接著執行訓練模型 `train_model.py`
會噴 `ImportError: cannot import name 'Dense' from 'keras.applications.resnet50'`

將原本的
```
from keras.applications.resnet50 import Dense
```

改成引用

```
from tensorflow.python.keras.layers.core import Dense
```

這時會噴 `ValueError: decay is deprecated in the new Keras optimizer, please check the docstring for valid arguments, or use the legacy optimizer, e.g., tf.keras.optimizers.legacy.SGD.`


加入引用
```
import tensorflow as tf
```

然後修改
```
sgd = SGD(lr=0.001, decay=1e-6, momentum=0.9, nesterov=True)
```

變這樣
```
sgd = tf.keras.optimizers.legacy.SGD(lr=0.001, decay=1e-6, momentum=0.9, nesterov=True)
```

然後這裡有個 `暴雷` 的點要在 `train/ldl+resnet` 底下建立 `model-dropout` 這個資料夾 , 不然他的 model 沒辦法放超無言 , 都跑老半天才搞這錯誤

最後會產出 `model-ldl-resnet.h5` 這個檔案

接著執行 `python test_model.py` 他會噴 `cannot import name 'Dense' from 'keras.applications.resnet50'` 修改成以下這樣即可
```
# from keras.applications.resnet50 import Dense
from tensorflow.python.keras.layers.core import Dense
```


最後複製模型 `model-ldl-resnet.h5` 並切到 `inference\ldl+resnet` 資料夾底下 , 執行 `beauty_predict.py`
```
cd inference\ldl+resnet
python beauty_predict.py
```

他會喷這個錯 `cannot import name 'adam' from 'keras.optimizers'`
只要註解以下即可修正
```
# from keras.optimizers import adam
```

然後又會噴一次 `cannot import name 'Dense' from 'keras.applications.resnet50'`
依照先前的方法修正即可
```
# from keras.applications.resnet50 import Dense
from tensorflow.python.keras.layers.core import Dense
```

最後跑之前把圖片丟到 `samples/image` 記得修正下你要的檔案名稱 `test7` 林志玲
```
beauty_predict(parent_path+"/samples/image",'test7.jpg')
```
