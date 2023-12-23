---
title: privateGPT 筆記
date: 2023-06-02 18:48:57
tags: python
---
&nbsp;
<!-- more -->

今天發現 [privateGPT](https://github.com/imartinez/privateGPT) 筆記下用法
速度有點慢 , 不過確實可以得到些屬於自己內部的答案
```
conda create --name gpt
conda activate gpt
conda install pip


git clone https://github.com/imartinez/privateGPT.git
cd privateGPT
pip install -r requirements.txt
mkdir models
cd models
# 下載搬進去 models
# https://gpt4all.io/models/ggml-gpt4all-j-v1.3-groovy.bin

mv example.env .env
# 丟你的 pdf or txt or 其他文件到 source_documents
# 我丟台灣小吃 taiwan_food.txt
# https://zh.wikipedia.org/zh-tw/%E5%8F%B0%E7%81%A3%E5%B0%8F%E5%90%83

python ingest.py
python privateGPT.py
> Enter a query: 台灣小吃
```
