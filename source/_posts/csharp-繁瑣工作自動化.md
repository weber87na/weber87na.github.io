---
title: csharp 繁瑣工作自動化
date: 2021-06-06 00:39:29
tags: csharp
---
&nbsp;
<!-- more -->

無意中看到 Python 有 PyAutoGUI 這東東可以做些自動化操作 , 手癢也來用 c# 玩玩 , 沒很認真找不曉得有無比較完整的 Lib 能用 , 只好半土炮來兜
這類東東做法跟爬蟲類似 , 不外乎就是抓取按鈕在螢幕上的座標位置然後點選 or 輸入文字
開工第一步想要抓 Global 的滑鼠位置馬上就陣亡了 , 所以參考這個 [Lib](https://github.com/gmamaladze/globalmousekeyhook) 來達成目的

### 撈滑鼠座標
```
private IKeyboardMouseEvents m_GlobalHook;
public void Subscribe()
{
	// Note: for the application hook, use the Hook.AppEvents() instead
	m_GlobalHook = Hook.GlobalEvents();

	m_GlobalHook.MouseMove += M_GlobalHook_MouseMove;
}

private void M_GlobalHook_MouseMove( object sender, MouseEventArgs e )
{
	Color c = GetPixel( e.Location );
	lblThumbnail.BackColor = c;

	int x = e.Location.X;
	int y = e.Location.Y;

	lblMousePos.Text = $"目前位置 (x:{x},y:{y})";
	lblColor.Text = $"RGBA ({c.R},{c.G},{c.B},{c.A})";
}
```

### 撈目前座標顏色
```
//https://rosettacode.org/wiki/Color_of_a_screen_pixel#C.23
Color GetPixel( Point position )
{
	using (var bitmap = new Bitmap( 1, 1 ))
	{
		using (var graphics = Graphics.FromImage( bitmap ))
		{
			graphics.CopyFromScreen( position, new Point( 0, 0 ), new Size( 1, 1 ) );
		}
		return bitmap.GetPixel( 0, 0 );
	}
}
```

### trigger 滑鼠動作
用 `mouse_event` 執行滑鼠 click or double click
```
//This is a replacement for Cursor.Position in WinForms
[System.Runtime.InteropServices.DllImport("user32.dll")]
static extern bool SetCursorPos(int x, int y);

[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);

public const int MOUSEEVENTF_LEFTDOWN = 0x02;
public const int MOUSEEVENTF_LEFTUP = 0x04;

//This simulates a left mouse click
public static void LeftMouseClick(int xpos, int ypos)
{
    SetCursorPos(xpos, ypos);
    mouse_event(MOUSEEVENTF_LEFTDOWN, xpos, ypos, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, xpos, ypos, 0, 0);
}

public static void MouseDoubleClick(int xpos, int ypos)
{
    mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, xpos, ypos, 0, 0);

	Thread.Sleep(150);

    mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, xpos, ypos, 0, 0);
}

```

### trigger 鍵盤輸入
用 `SendKeys.Send` 送出需要輸入的文字 , 注意要用 Thread 睡一下
```
Cursor.Position = new Point( 441, 371 );
LeftMouseClick( 441, 371 );
SendKeys.Send( textBoxId.Text );
Thread.Sleep( 200 );

```

### 開啟程式
開啟 IE or 其他 Application 用 return Process 方便執行完就 kill
```
Process OpenIE()
{
	Process ps = new Process();
	string url = "http://xxx.xxx.xxx";
	ps.StartInfo.FileName = "iexplore.exe";
	ps.StartInfo.Arguments = url;
	ps.Start();
	return ps;
}

```
