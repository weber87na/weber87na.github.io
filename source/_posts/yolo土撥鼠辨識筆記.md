---
title: yolo土撥鼠辨識筆記
date: 2025-06-01 23:57:16
tags:
- yolo
- python
---
&nbsp;
<!-- more -->

首先用 `yt-dlp` 下載老鼠廢片存成 `marmot.mp4`

https://github.com/yt-dlp/yt-dlp
```
yt-dlp https://www.youtube.com/shorts/sTezq-GOTY4
```

安裝 yolo 跟 pytouch, 這邊因為 gpu 設定有點複雜之後才補

https://docs.ultralytics.com/zh/quickstart/
https://pytorch.org/get-started/locally/

```
conda create --name ultralytics-env python=3.11 -y
conda activate ultralytics-env
pip3 install torch torchvision torchaudio
pip install ultralytics
pip install supervision
```

然後就可以辨識看看, 預設他把土撥鼠辨識成鳥是怎樣, 一臉鳥樣嗎 XD?
```
from ultralytics import YOLO
import torch
import torchvision

print(torch.__version__)
print(torchvision.__version__)
print(torch.cuda.is_available())

model = YOLO("yolo11n.pt")

results = model(source="marmot.mp4", show=True)
```

開啟 colab
```
!pip install ultralytics
!pip install roboflow
```

```
import torch
print(torch.cuda.is_available())
```

先到 roboflow 下載土撥鼠(marmot) dataset, 他會給你這串 code 貼在 colab 上即執行可下載
```
from roboflow import Roboflow
rf = Roboflow(api_key="yourkey")
project = rf.workspace("science-education-uwqay").project("marmot-iq9f5")
version = project.version(1)
dataset = version.download("yolov11")
```

如果資料集目錄有問題的話, 調整目錄檔案, `marmot 這個目錄不用調整`
```
import shutil
shutil.move(
    '/content/marmot-1/test',
    '/content/marmot-1/marmot-1/test')
shutil.move(
    '/content/marmot-1/train',
    '/content/marmot-1/marmot-1/train')
shutil.move(
    '/content/marmot-1/valid',
    '/content/marmot-1/marmot-1/valid')
```

執行訓練土撥鼠, 搞定後會在 `runs/detect/train1` 底下出現 `weights/best.pt` 下載回本地電腦的 `models` 資料夾底下即可
```
from ultralytics import YOLO
model = YOLO("yolo11n.pt")
results = model.train(data=f"/content/marmot-1/data.yaml", epochs=100, imgsz=640, device="cuda")
```

改下 code 然後跑看看就可以獲得襲鼠目標辨識 XD
影片會出現在 `runs\detect\predict\marmot.avi`
這裡要特別注意 `save=True` 這個選項, 很容易就忘了寫, 然後找不到東西雷半天

```
from ultralytics import YOLO
import torch
import torchvision

print(torch.__version__)
print(torchvision.__version__)
print(torch.cuda.is_available())

model = YOLO("models/best.pt")

results = model(source="marmot.mp4", show=True, save=True, conf=0.25)
```

新增 `utils` 資料夾, 並且加入 `video_utility.py` `__init__.py` 在 `utils` 底下
```
import cv2

def read_video(file_path):
        vidoe_capture = cv2.VideoCapture(file_path)

        frames = []

        while True:
            isReturn, frame = vidoe_capture.read()
            if not isReturn:
                break

            frames.append(frame)

        vidoe_capture.release()

        return frames

        
def save_video(frames, save_path):
    if not frames:
        raise ValueError("Frames is empty. Please ensure frames are added before writing the video")
    
	fourcc = cv2.VideoWriter_fourcc(*'avc1')
    output_video= cv2.VideoWriter(save_path, fourcc, 24, (frames[0].shape[1], frames[0].shape[0]))

    for frame in frames:
        output_video.write(frame)

    output_video.release()


```

```
from .video_utility import read_video, save_video
```

調整 `main.py`, 然後執行

```
from utils import read_video, save_video

def main():
    video_frames = read_video("marmot.mp4")
    output_video = save_video(video_frames, 'output_marmot.mp4')

if __name__ == "__main__":
    main()
```

這裡會出現編碼錯誤 `OpenCV: FFMPEG: fallback to use tag 0x31637661/'avc1'` 只要改編碼為 `avc1` 即可

```
def save_video(frames, save_path):
    if not frames:
        raise ValueError("Frames is empty. Please ensure frames are added before writing the video")
    
    # fourcc = cv2.VideoWriter_fourcc(*'H264')
	fourcc = cv2.VideoWriter_fourcc(*'avc1')
    output_video= cv2.VideoWriter(save_path, fourcc, 24, (frames[0].shape[1], frames[0].shape[0]))

    for frame in frames:
        output_video.write(frame)

    output_video.release()
```

或是用以下方法應該也能搞定
如果有跳這個錯誤 `Failed to load OpenH264 library: openh264-1.8.0-win64.dll Please check environment and/or download library`
只需要到 https://github.com/cisco/openh264/releases?page=2 找到對應的檔案 `openh264-1.8.0-win64.dll` 下載
並且放在 python 環境底下, 我這邊用 conda 所以放在 `C:\Users\yourname\anaconda3\envs\ultralytics-env` 即可
