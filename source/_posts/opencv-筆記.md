---
title: opencv 筆記
date: 2025-04-24 03:44:37
tags: python
---
&nbsp;
<!-- more -->

最近看 [opencv 課程](https://www.youtube.com/watch?v=rn5OK18bTdI&list=PLaqioiYJMwvbpyOGhoyAYL1IuyAZDhK3n) 當個免費仔就筆記下練習內容

## helloworld
先在自己的 base 安裝 `nb_conda_kernels` 他會掃描全部的 conda 環境然後讓 jupyter kernel 加進去, 搞 python 裝環境真的超煩.. 整個心態炸裂
```
conda activate base
conda install nb_conda_kernels

# 切到 cv2 這個環境安裝 ipykernel
conda activate cv2
conda install ipykernel
conda install opencv
conda install matplotlib

```


接著用 jupyter 開啟, 看是喜歡 notebook or lab 都可以
```
jupyter notebook
jupyter-lab
```

helloworld 這裡的 `%matplotlib inline` 可以直接顯示圖片在 cell 上面
opencv 預設的顏色通道是 `bgr` 而 matplotlib 則是 `rgb`
所以需要呼叫 `cv2.cvtColor(marmot, cv2.COLOR_BGR2RGB)` 先轉為 `rgb`
```
import cv2
import matplotlib.pyplot as plt
%matplotlib inline
marmot = cv2.imread('marmot.jpg')
marmot = cv2.cvtColor(marmot, cv2.COLOR_BGR2RGB)
plt.imshow(marmot)
plt.show()
```

如果想讀成灰度的話需要補上 `cv2.IMREAD_GRAYSCALE`
接著 matplotlib 要加入 colormap 參數 `cmap`

可以到這邊來找喜歡的 [colormap](https://matplotlib.org/stable/users/explain/colors/colormaps.html)
以前最常用 `jet` 這樣就可以得到一隻彩色土撥鼠 XD

```
marmot = cv2.imread('marmot.jpg', cv2.IMREAD_GRAYSCALE)
plt.imshow(marmot, cmap='gray')
plt.show()

plt.imshow(marmot, cmap='jet')
plt.show()
```

另外讀圖還有這種方法, 不過要記得是按下任意的按鍵, 點關閉視窗是沒用低, jupyter 的格子會掛點
```
marmot = cv2.imread('marmot.jpg')
blur_marmot = cv2.blur(marmot, (3,3))
blur_marmot_rgb = cv2.cvtColor(blur_marmot, cv2.COLOR_BGR2RGB)
cv2.imshow('marmot' , marmot)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

### ROI (Region of Interest)
ROI (Region of Interest)
```
# 先 Y 後 X
y_start, y_end = 50, 250
x_start, x_end = 150, 500
roi_marmot = marmot[y_start:y_end,x_start:x_end]
plt.imshow(roi_marmot, cmap='jet')
plt.show()
```

可以用 split 分出三個通道的 array 然後調整數值就可以弄出一隻憂鬱的老鼠 LOL
```
marmot = cv2.imread('marmot.jpg')
b,g,r = cv2.split(marmot)
b[:] = 200

deep_blue = cv2.merge((b,g,r))
deep_blue = cv2.cvtColor(deep_blue, cv2.COLOR_BGR2RGB)
plt.imshow(deep_blue)
plt.show()

```

### 外框填充
跑 `convolution` 的時候邊框會損失一圈, 可以用 `copyMakeBorder` 來補
```
img = cv2.imread('marmot.jpg')
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
top_size, bottom_size, left_size , right_size = (50,50,50,50)

replicate = cv2.copyMakeBorder(img, top_size, bottom_size, left_size , right_size , borderType=cv2.BORDER_REPLICATE)
reflect = cv2.copyMakeBorder(img, top_size, bottom_size, left_size , right_size , borderType=cv2.BORDER_REFLECT)
reflect101 = cv2.copyMakeBorder(img, top_size, bottom_size, left_size , right_size , borderType=cv2.BORDER_REFLECT101)
wrap = cv2.copyMakeBorder(img, top_size, bottom_size, left_size , right_size , borderType=cv2.BORDER_WRAP)
constant = cv2.copyMakeBorder(img, top_size, bottom_size, left_size , right_size , borderType=cv2.BORDER_CONSTANT, value=0)

plt.subplot(231), plt.imshow(img,'gray'), plt.title('img')
plt.subplot(232), plt.imshow(replicate,'gray'), plt.title('replicate')
plt.subplot(233), plt.imshow(reflect,'gray'), plt.title('reflect')
plt.subplot(234), plt.imshow(reflect101,'gray'), plt.title('reflect101')
plt.subplot(235), plt.imshow(wrap,'gray'), plt.title('wrap')
plt.subplot(236), plt.imshow(constant,'gray'), plt.title('constant')
plt.show()
```

### 影像相加(融合)
融合需要調整把兩張圖大小先 resize 成一樣才可以
```
marmot = cv2.imread('marmot.jpg')
marmot.shape
# (360, 640, 3)
sweet_dumpling = cv2.imread('sweet_dumpling.jpg')
sweet_dumpling.shape
# (1398, 2484, 3)

sweet_dumpling_resize = cv2.resize(sweet_dumpling, (640, 360))
# plt.imshow(sweet_dumpling_resize)
# plt.show()

fusion = cv2.addWeighted(sweet_dumpling_resize, 0.8 , marmot, 0.5 , 0)
fusion = cv2.cvtColor(fusion, cv2.COLOR_BGR2RGB)
plt.imshow(fusion)
plt.show()
```

## threshold 與平滑處理

### threshold 門檻值(閾)

閾 (ㄩˋ) 但一堆人會念成 閥 (ㄈㄚˊ) LOL
```
marmot_gray = cv2.imread('marmot.jpg', cv2.IMREAD_GRAYSCALE)
ret, t1 = cv2.threshold(marmot_gray, 127, 255, cv2.THRESH_BINARY)
ret, t2 = cv2.threshold(marmot_gray, 127, 255, cv2.THRESH_BINARY_INV)
ret, t3 = cv2.threshold(marmot_gray, 127, 255, cv2.THRESH_TRUNC)
ret, t4 = cv2.threshold(marmot_gray, 127, 255, cv2.THRESH_TOZERO)
ret, t5 = cv2.threshold(marmot_gray, 127, 255, cv2.THRESH_TOZERO_INV)

titles = ['marmot' , 'THRESH_BINARY' , 'THRESH_BINARY_INV' , 'THRESH_TRUNC' , 'THRESH_TOZERO' , 'THRESH_TOZERO_INV']
images = [marmot_gray, t1, t2,t3,t4,t5]

for i in range(6):
    plt.subplot(2, 3 , i + 1)
    plt.imshow(images[i], 'gray')
    plt.title(titles[i])
    plt.xticks([])
    plt.yticks([])
plt.show()
```

### 平滑

產噪音點
```
# 讀取影像
img = cv2.imread('your_image.jpg')

# 取得影像的尺寸
height, width, channels = img.shape

# 設定噪點密度（0-100）
noise_density = 0.05  # 例如 5% 的噪點

# 生成隨機的噪點矩陣
noise = np.random.rand(height, width) < noise_density

# 將噪點設為白色（255）
img_with_noise = img.copy()
img_with_noise[noise] = 255  # 白色噪點

# 顯示結果
cv2.imshow('Image with White Noise', img_with_noise)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

blur (3,3) 為卷積大小, 一般都用奇數
```
marmot = cv2.imread('marmot.jpg')
blur_marmot = cv2.blur(marmot, (3,3))
blur_marmot_rgb = cv2.cvtColor(blur_marmot, cv2.COLOR_BGR2RGB)
cv2.imshow('marmot' , marmot)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

另一種寫法呼叫 boxFilter 函數
```
marmot = cv2.imread('marmot.jpg')
blur_marmot = cv2.boxFilter(marmot,-1, (3,3), normalize=True)
blur_marmot_rgb = cv2.cvtColor(blur_marmot, cv2.COLOR_BGR2RGB)
plt.imshow(blur_marmot_rgb)
plt.show()
```

高斯模糊

取鄰近的讓權重更大些, 大概長這樣
[
	[0.6,0.8,0.6],
	[0.8, 1 ,0.8],
	[0.6,0.8,0.6],
]


```
marmot = cv2.imread('marmot_noise.jpg')
blur_marmot = cv2.GaussianBlur(marmot,(5,5), 0)
blur_marmot_rgb = cv2.cvtColor(blur_marmot, cv2.COLOR_BGR2RGB)
plt.imshow(blur_marmot_rgb)
plt.show()
```

中值因為他取中間的數值, 所以可以有效消除噪音點
```
marmot_noise = cv2.imread('marmot_noise.jpg')
blur_marmot = cv2.medianBlur(marmot_noise, 3)
blur_marmot_rgb = cv2.cvtColor(blur_marmot, cv2.COLOR_BGR2RGB)
plt.imshow(blur_marmot_rgb)
plt.show()
```

他這裡教一個技巧可以用 numpy 的 `hstack` `vstack` 把圖拼成一張
```
marmot_noise = cv2.imread('marmot_noise.jpg')
blur_marmot = cv2.GaussianBlur(marmot_noise,(5,5), 0)
blur_marmot2 = cv2.medianBlur(marmot_noise, 3)
res = np.hstack((marmot_noise, blur_marmot, blur_marmot2))
res = cv2.cvtColor(res, cv2.COLOR_BGR2RGB)
plt.imshow(res)
plt.show()

# cv2.imshow('res', res)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
```

## 形態學 Morphological
### 腐蝕 Erosion
通常用在已經二值化的圖上, 先拿小畫家寫個黑底白字的土撥鼠, 然後字上面畫毛

```
marmot_text = cv2.imread('marmot_text.png')
kernel = np.ones((3,3), np.uint8)
# kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
print(kernel)
print(type(kernel))
marmot_text_erode = cv2.erode(marmot_text , kernel, iterations= 1)
res = np.hstack((marmot_text,marmot_text_erode))
plt.imshow(res)
plt.show()
```

### 膨脹 dilate
跟腐蝕相互為逆, 假如腐蝕過後線條變細可以用膨脹來讓它變粗

```
marmot_text = cv2.imread('marmot_text.png')
kernel = np.ones((3,3), np.uint8)
print(kernel)
print(type(kernel))
marmot_text_erode = cv2.erode(marmot_text , kernel, iterations= 1)
marmot_text_dilate = cv2.dilate(marmot_text_erode , kernel, iterations= 1)
res = np.hstack((marmot_text,marmot_text_erode,marmot_text_dilate))
plt.imshow(res)
plt.show()
```

### 開運算 Opening / 閉運算 Closing

開運算 => 先腐蝕再膨脹
閉運算 => 先膨脹再腐蝕

```
marmot_text = cv2.imread('marmot_text.png')
kernel = np.ones((3,3), np.uint8)
marmot_text_open = cv2.morphologyEx(marmot_text,cv2.MORPH_OPEN, kernel)
marmot_text_close = cv2.morphologyEx(marmot_text,cv2.MORPH_CLOSE, kernel)
res = np.hstack((marmot_text_open, marmot_text_close))
plt.imshow(res)
plt.show()
```

### 梯度運算 Gradient

Gradient = 膨脹 Dilation(image) - 腐蝕 Erosion(image)

```
marmot_text = cv2.imread('marmot_text.png')
marmot_text_open = cv2.morphologyEx(marmot_text,cv2.MORPH_OPEN, kernel)
plt.imshow(res)
plt.show()
```

### 禮帽 Top Hat / 黑帽 Black Hat

TopHat = 原圖 - 開運算結果
```
marmot_text = cv2.imread('marmot_text.png')
kernel = np.ones((3,3), np.uint8)
marmot_text_tophat = cv2.morphologyEx(marmot_text,cv2.MORPH_TOPHAT, kernel)
plt.imshow(marmot_text_tophat)
plt.show()
```

BlackHat = 閉運算結果 - 原圖
```
marmot_text = cv2.imread('marmot_text.png')
kernel = np.ones((3,3), np.uint8)
marmot_text_blackhat = cv2.morphologyEx(marmot_text,cv2.MORPH_BLACKHAT, kernel)
plt.imshow(marmot_text_blackhat)
plt.show()
```

## 圖像梯度
### Sobel
跟高斯有點像, 越近權重越高

kernelx = 
[
-1 0 +1
-2 0 +2
-1 0 +1
]

kernely = 
[
-1 -2 -1
 0  0  0
+1 +2 +1
]

Gx = kernelx * A and Gy = kernely * A

```
marmot = cv2.imread('marmot.jpg', cv2.IMREAD_GRAYSCALE)
marmotx = cv2.Sobel(marmot, cv2.CV_64F, 1, 0, ksize=3)
marmoty = cv2.Sobel(marmot, cv2.CV_64F, 0, 1, ksize=3)
marmotx = cv2.convertScaleAbs(marmotx)
marmoty = cv2.convertScaleAbs(marmoty)
marmotxy = cv2.addWeighted(marmotx, 0.5, marmoty, 0.5, 0)
plt.imshow(marmotxy, cmap='gray')
plt.show()
# cv2.imshow('marmotxy', marmotxy)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
```

### scharr / lapkacian

scharr 細節會比 Sobel 還更多

kernelx = 
[
 -3 0  3
-10 0 10
 -3 0  3
] 

kernely = 
[
-3 -10  3
 0   0  0
-3 -10 -3
] 

Gx = kernelx * A
Gy = kernely * A

```
marmot = cv2.imread('marmot.jpg', cv2.IMREAD_GRAYSCALE)
marmotx = cv2.Scharr(marmot, cv2.CV_64F, 1, 0)
marmoty = cv2.Scharr(marmot, cv2.CV_64F, 0, 1)
marmotx = cv2.convertScaleAbs(marmotx)
marmoty = cv2.convertScaleAbs(marmoty)
marmotxy = cv2.addWeighted(marmotx, 0.5, marmoty, 0.5, 0)
plt.imshow(marmotxy, cmap='gray')
plt.show()
```

lapkacian 不建議單獨使用, 需要搭配其他咚咚

G = 
[
0  1 0
1 -4 1
0  1 0
]

```
marmot = cv2.imread('marmot.jpg', cv2.IMREAD_GRAYSCALE)
marmot_laplacian = cv2.Laplacian(marmot, cv2.CV_64F)
marmot_laplacian = cv2.convertScaleAbs(marmot_laplacian)
plt.imshow(marmot_laplacian, cmap='gray')
plt.show()
```



## Retinex 視網膜

參考自這個 [repo](https://github.com/aravindskrishnan/Retinex-Image-Enhancement?tab=readme-ov-file)
還有另外一種 https://github.com/dongb5/Retinex


```
import cv2
import matplotlib.pyplot as plt
import numpy as np
%matplotlib inline

def singleScaleRetinex(img,variance):
    retinex = np.log10(img) - np.log10(cv2.GaussianBlur(img, (0, 0), variance))
    return retinex

def multiScaleRetinex(img, variance_list):
    retinex = np.zeros_like(img)
    for variance in variance_list:
        retinex += singleScaleRetinex(img, variance)
    retinex = retinex / len(variance_list)
    return retinex

   

def MSR(img, variance_list):
    img = np.float64(img) + 1.0
    img_retinex = multiScaleRetinex(img, variance_list)

    for i in range(img_retinex.shape[2]):
        unique, count = np.unique(np.int32(img_retinex[:, :, i] * 100), return_counts=True)
        for u, c in zip(unique, count):
            if u == 0:
                zero_count = c
                break            
        low_val = unique[0] / 100.0
        high_val = unique[-1] / 100.0
        for u, c in zip(unique, count):
            if u < 0 and c < zero_count * 0.1:
                low_val = u / 100.0
            if u > 0 and c < zero_count * 0.1:
                high_val = u / 100.0
                break            
        img_retinex[:, :, i] = np.maximum(np.minimum(img_retinex[:, :, i], high_val), low_val)
        
        img_retinex[:, :, i] = (img_retinex[:, :, i] - np.min(img_retinex[:, :, i])) / \
                               (np.max(img_retinex[:, :, i]) - np.min(img_retinex[:, :, i])) \
                               * 255
    img_retinex = np.uint8(img_retinex)        
    return img_retinex



def SSR(img, variance):
    img = np.float64(img) + 1.0
    img_retinex = singleScaleRetinex(img, variance)
    for i in range(img_retinex.shape[2]):
        unique, count = np.unique(np.int32(img_retinex[:, :, i] * 100), return_counts=True)
        for u, c in zip(unique, count):
            if u == 0:
                zero_count = c
                break            
        low_val = unique[0] / 100.0
        high_val = unique[-1] / 100.0
        for u, c in zip(unique, count):
            if u < 0 and c < zero_count * 0.1:
                low_val = u / 100.0
            if u > 0 and c < zero_count * 0.1:
                high_val = u / 100.0
                break            
        img_retinex[:, :, i] = np.maximum(np.minimum(img_retinex[:, :, i], high_val), low_val)
        
        img_retinex[:, :, i] = (img_retinex[:, :, i] - np.min(img_retinex[:, :, i])) / \
                               (np.max(img_retinex[:, :, i]) - np.min(img_retinex[:, :, i])) \
                               * 255
    img_retinex = np.uint8(img_retinex)        
    return img_retinex
```

呼叫法

MSR 需要吃一個 array AI 建議用這樣 variance_list = [15, 80, 200]
SSR 只需要單一數值

```
variance_list = [15, 80, 200]
variance = 300

# 原圖
img = cv2.imread('sweet_dumpling.jpg')
img_plt = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

plt.imshow(img_plt)
plt.show()

# MSR
img_msr = MSR(img,variance_list)
img_msr_plt = cv2.cvtColor(img_msr, cv2.COLOR_BGR2RGB)
plt.imshow(img_msr_plt)
plt.show()

# SSR
img_ssr = SSR(img, variance)
img_ssr_plt = cv2.cvtColor(img_ssr, cv2.COLOR_BGR2RGB)
plt.imshow(img_ssr_plt)
plt.show()
```