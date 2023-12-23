---
title: pyautogui 筆記
date: 2023-11-15 19:11:53
tags: python
---
&nbsp;
<!-- more -->

因為每天都要瞎掰工作日誌 , 覺得好麻煩 , 所以乾脆搞自動化 XD

最關鍵應該就是 locateCenterOnScreen 這噁爛函數 , 他可以找圖 , 所以就能定位按鈕之類的
我的想法就是如果沒找到圖就讓他 retry , 然後找到了就搞定 , 超過次數就跳出
還有他沒找到好像會噴 ImageNotFoundException 所以也要 retry
本來我之前有個環境卻沒這個問題 , python 就是靈異 XD

另外就是沒辦法直接輸入中文 , 要用複製貼上 , 還有就算輸入數字也是要丟 string

後來因為太懶惰了 , 我連每日進去點都懶 , 所以搞個先掃描 outlook 信箱
如果有要寫工作日誌的信件就自動幫我開 notes 去寫
然後搭配 `schedule` 定時執行任務 , 還有用 `pytesseract` OCR 功能來當眼
另外使用 `pytesseract` 需要先安裝 [tesseract](https://github.com/tesseract-ocr/tesseract) python 特色肥大 XD

大概一年沒寫 python 啦 , 寫得很沙雕 , 偷懶就這樣吧 XD

相關套件如下
```
conda create --name auto
conda activate auto
conda install pip
pip install pyautogui
pip install opencv-python
pip install pypiwin32
pip install schedule
pip install pytesseract
pip install subprocess_maximize
```

### subprocess
這裡我試了一堆方法 , 但是好像用 subprocess 的 kill 都只能關閉 command 的 process , 所以最後只好手關 notes
而且一開始開啟 notes 沒辦法視窗最大化 , 可以用 `subprocess_maximize` 這個來最大化 , 比較好讀些

``` py
def open_notes():
    print('open notes')
    # notes = subprocess.Popen(['notes.exe'], stdout=subprocess.PIPE,shell=True)  
    # notes.wait()  
    # notes.stdout.read()
    # subprocess.call(["cmd", "/c", "start", "/max", "notes.exe"])
    notes = Popen('notes.exe',show='maximize', priority=0, stdout=subprocess.PIPE)
```

### 掃描 outlook 特定信件
首先先找 outlook 看看有沒有日報的信件 , 這裡需要用 `pypiwin32`
這邊就塞一天當期限然後呼叫 `Restrict` 可以過濾時間
注意他會 return 一個 array 而使用 `Sort` 函數則不會

``` py
# 找 outlook 的信
def find_outlook_report():
    outlook_namespace = win32.Dispatch('Outlook.Application').GetNameSpace('MAPI')
    # 等價這個 c#
    # inboxFolder = outlookNamespace.GetDefaultFolder( OlDefaultFolders.olFolderInbox );
    inbox_folder = outlook_namespace.GetDefaultFolder(6)
    mails = inbox_folder.Items

    today = datetime.datetime.now() - datetime.timedelta(days=1)
    today = today.strftime('%m/%d/%Y %H:%M %p')
    today_mails = mails.Restrict("[ReceivedTime] >= '" + today + "'")
    today_mails = today_mails.Restrict("[SenderEmailAddress] = 'oxox@ladisai.com'")
    today_mails.Sort("[ReceivedTime]", True)

    result = False
    for mail in today_mails:
        if (mail.Body.find('OX工作報告') > 0):
            result = True
            print('找到日報')
            print(mail.Body.find('OX工作報告'))
            print(mail.CreationTime)
            print(mail.Subject)
            print(mail.Body)
            return result

    return result
```

### tesseract 當眼睛
這個函數他會去看工作日報那列 `item` 如果有字的話 `return False`
`pyautogui.screenshot(region=(410,140, 1290, 156)` 這段可以得到螢幕上的那塊區域的圖片
接著要用 `pytesseract` 當眼去看裡面是否有文字
特別注意 `pytesseract.pytesseract.tesseract_cmd` 路徑不要設定錯誤 `C:\Program Files\Tesseract-OCR\tesseract`
最後就用 `image_to_string` 得到文字 , 這裡不求辨識率只要看有沒有文字即可

``` py
# 找日報的 item 是否有文字
def is_find_daily_report_item():
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract'
    temp_img = pyautogui.screenshot(region=(410,140, 1290, 156))
    text = pytesseract.image_to_string(temp_img, lang='chi_tra')
    result = False
    if text:
        print('辨識內容為空')
        return result
    
    return result
```


### 中文輸入問題

這裡如果直接用 pyautogui 是沒辦法輸入中文內容低可以看[這篇](https://blog.51cto.com/lilongsy/6236256)

``` py
    lorem = get_lorem()
    print(lorem)
    pyperclip.copy(lorem)
    time.sleep(1)
    pyautogui.hotkey('Ctrl' , 'V')
```


### schedule 定時執行任務

最後可以觀察下 outlook 都啥時寄信 , 然後無腦用 schedule , 本來說那如果在 server 執行怎辦 , 不過沒遇到就放生 XD
``` py
def main():
    print('main')
    # schedule.every(1).minutes.do(job)
    auto_run_time = '00:00'
    schedule.every().monday.at(auto_run_time).do(job)
    schedule.every().thursday.at(auto_run_time).do(job)
    schedule.every().wednesday.atauto_run_time().do(job)
    schedule.every().thursday.at(auto_run_time).do(job)
    schedule.every().friday.at(auto_run_time).do(job)	

    while True:
        schedule.run_pending()
        time.sleep(1)
```



full code
``` py
import win32com.client as win32
import datetime
import random
import time
import pyautogui
import subprocess
import pyperclip
import getpass
import pytesseract

import schedule

from subprocess_maximize import Popen


pwd = getpass.getpass('Password:')

# 錯誤處理
pyautogui.useImageNotFoundException()

# 找日報的 item 是否有文字
def is_find_daily_report_item():
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract'
    temp_img = pyautogui.screenshot(region=(410,140, 1290, 156))
    text = pytesseract.image_to_string(temp_img, lang='chi_tra')
    result = False
    if text:
        print('辨識內容為空')
        return result
    
    return result

# 找圖
def find_img(filename: str):
    find_count = 0
    x  = None
    y = None
    while find_count < 30:
        print('find img:' + filename)
        time.sleep(1)
        try:
            coords = pyautogui.locateCenterOnScreen(filename, confidence = 0.9)
            print(coords)
            if coords is not None:
                x , y  = coords
                break
            else:
                find_count += 1
        except pyautogui.ImageNotFoundException:
            find_count +=1

    return x , y

# 是否找到
def is_find(x , y):
    if x is not None and y is not None:
        return True
    return False

# 登入
def login():
    print('login')
    pyautogui.typewrite(pwd)
    pyautogui.press('enter')

# 開啟 notes
def open_notes():
    print('open notes')
    # notes = subprocess.Popen(['notes.exe'], stdout=subprocess.PIPE,shell=True)  
    # notes.wait()  
    # notes.stdout.read()
    # subprocess.call(["cmd", "/c", "start", "/max", "notes.exe"])
    notes = Popen('notes.exe',show='maximize', priority=0, stdout=subprocess.PIPE)
    


# 取得廢話
def get_lorem():
    lorems = [
        'ladisai' , 
        'ladisai' ,
        'ladisai' , 
        'ladisai' , 
        'ladisai' , 
    ]

    lorem_num = random.randint(0, 4)
    lorem = lorems[lorem_num]
    return lorem

# 找 outlook 的信
def find_outlook_report():
    outlook_namespace = win32.Dispatch('Outlook.Application').GetNameSpace('MAPI')
    # 等價這個 c#
    # inboxFolder = outlookNamespace.GetDefaultFolder( OlDefaultFolders.olFolderInbox );
    inbox_folder = outlook_namespace.GetDefaultFolder(6)
    mails = inbox_folder.Items

    today = datetime.datetime.now() - datetime.timedelta(days=1)
    today = today.strftime('%m/%d/%Y %H:%M %p')
    today_mails = mails.Restrict("[ReceivedTime] >= '" + today + "'")
    today_mails = today_mails.Restrict("[SenderEmailAddress] = 'oxox@ladisai.com'")
    today_mails.Sort("[ReceivedTime]", True)

    result = False
    for mail in today_mails:
        if (mail.Body.find('工作報告') > 0):
            result = True
            print('找到日報')
            print(mail.Body.find('工作報告'))
            print(mail.CreationTime)
            print(mail.Subject)
            print(mail.Body)
            return result

    return result

# 移動到中心
def move_to_center_of_screen():
    screenWidth, screenHeight = pyautogui.size()
    x , y = pyautogui.center((0 , 0 , screenWidth , screenHeight))
    pyautogui.moveTo(x , y)

# 主要流程
def job():
    # 先看看有無找到日報
    if find_outlook_report() == False:
        print('尚未發現日報')
        return

    screenWidth, screenHeight = pyautogui.size()
    print(screenWidth)
    print(screenHeight)
    open_notes()

    # 登入 notes
    login_x , login_y = find_img('notes_login.png')
    if is_find(login_x , login_y):
        login()
    else:
        return

    # 進入 main
    main_x , main_y = find_img('main.png')
    if is_find(main_x , main_y):
        print('click main 按鈕')
        pyautogui.click(x=main_x , y=main_y, duration=1)
    else:
        return

    # 工作報告
    work_x , work_y = find_img('work.png')
    if is_find(work_x , work_y):
        print('click 工作報告按鈕')
        pyautogui.click(x=work_x , y=work_y, duration=1)
    else:
        return

    # 這裡應該要 OCR 看看有沒有文字
    # 點日報
    if is_find_daily_report_item():
        print('click 日報')
        pyautogui.doubleClick(x=555 ,y=152 , duration=1)
    else:
        # 關閉 notes
        pyautogui.click(x=1900 , y=15, duration=2)
        move_to_center_of_screen()
        return

    # 點共用專案新增後編輯
    add_new_x , add_new_y = find_img('addNew.png')
    if is_find(add_new_x , add_new_y):
        print('click 專案新增後編輯')
        pyautogui.click(x=add_new_x , y=add_new_y, duration=1)
    else:
        return

    # 點系統資料處理
    new_item_x , new_item_y = find_img('new_item.png')
    if is_find(new_item_x , new_item_y):
        print('click 系統資料處理')
        pyautogui.doubleClick(x=new_item_x , y=new_item_y, duration=1)
    else:
        return
    
    # 工作時數
    print('輸入工作時數')
    pyautogui.click(x=782,y=459, duration=1)
    pyautogui.press('backspace')
    pyautogui.typewrite('8')

    # 工作內容
    # 不能直接敲中文要用複製貼上的
    # https://blog.51cto.com/lilongsy/6236256
    print('輸入工作內容')
    pyautogui.click(x=774,y=434, duration=1)
    lorem = get_lorem()
    print(lorem)
    pyperclip.copy(lorem)
    time.sleep(1)
    pyautogui.hotkey('Ctrl' , 'V')
    # pyautogui.typewrite(lorem, interval=0.1)

    # 存檔
    save_x , save_y = find_img('save.png')
    if is_find(save_x , save_y):
        print('click 存檔')
        pyautogui.click(x=save_x , y=save_y, duration=1)
    else:
        return

    # 送出
    send_x , send_y = find_img('send.png')
    if is_find(send_x , send_y):
        print('click 送出')
        pyautogui.click(x=send_x , y=send_y, duration=1)
        print('done ~')

        # 關閉 notes
        pyautogui.click(x=1900 , y=15, duration=2)

        # 回中心點
        move_to_center_of_screen()
    else:
        return


def main():
    print('main')
    # schedule.every(1).minutes.do(job)
    auto_run_time = '00:00'
    schedule.every().monday.at(auto_run_time).do(job)
    schedule.every().thursday.at(auto_run_time).do(job)
    schedule.every().wednesday.at.(auto_run_time).do(job)
    schedule.every().thursday.at(auto_run_time).do(job)
    schedule.every().friday.at(auto_run_time).do(job)	

    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == '__main__':
    main()


```
