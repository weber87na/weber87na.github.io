---
title: png to svg 筆記
date: 2022-10-30 18:57:23
tags: python
---
&nbsp;
<!-- more -->

工作上遇到的需求 , user 給的檔案解析度不太好 , 導致東西印出來時看起來沒那麼完美
嘗試了一些線上工具發現效果都不太滿意 , 所以找看看淫蕩的 python 有無法子轉 png or jpg 為 svg
最後看到 [這篇討論](https://stackoverflow.com/questions/31427903/convert-png-to-svg-using-python)
老外說有 [potrace](https://pypi.org/project/pypotrace/) 不過在 windows 上面好像很難裝
然後推薦一個 [PngToSvg](https://github.com/IngJavierR/PngToSvg) 效果意外的好 , 不過速度有點慢就是
另外自己也試了 [svgtrace](https://github.com/FHPythonUtils/SvgTrace) 不過效果不優

只要這樣就完事了 , 會把 example 裡面的 `angular.png` 轉為 `angular.svg`
```
git clone https://github.com/IngJavierR/PngToSvg.git
cd .\PngToSvg\
pip install -r .\requirements.txt
python init.py
```

所以如果要啥檔案就自己進去 `init.py` 改下檔名即可 , 老外把 `main` 放在最底端 , 我這裡改成 `logo.png`

`init.py`
```
def main():
    image = Image.open('examples/logo.png').convert('RGBA')
    svg_image = rgba_image_to_svg_contiguous(image)
    #svg_image = rgba_image_to_svg_pixels(image)
    with open("examples/logo.svg", "w") as text_file:
        text_file.write(svg_image)

if __name__ == '__main__':
    main()

```
