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

### Outlook
```
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Runtime.InteropServices;
using Microsoft.Office.Interop.Outlook;
using System.Diagnostics;
using System.Text.RegularExpressions;

namespace LazyHelper
{
    public partial class FormLog : Form
    {

        Microsoft.Office.Interop.Outlook.Application outlookApplication = null;
        NameSpace outlookNamespace = null;
        MAPIFolder inboxFolder = null;

        public FormLog()
        {
            InitializeComponent();

            this.Load += FormLog_Load;
            this.buttonLog.Click += ButtonLog_Click;
            this.FormClosing += FormLog_FormClosing;

            richTextBoxLog.ReadOnly = true;
            richTextBoxLog.BackColor = Color.White;
        }

        private void FormLog_FormClosing( object sender, FormClosingEventArgs e )
        {
            if (e.CloseReason == CloseReason.UserClosing)
            {
                e.Cancel = true;
                this.Hide();
            }

        }

        protected override void OnFormClosed( FormClosedEventArgs e )
        {
            //ReleaseComObject( mailItems );
            ReleaseComObject( inboxFolder );
            ReleaseComObject( outlookNamespace );
            ReleaseComObject( outlookApplication );
            base.OnFormClosed( e );
        }

        string FetchLog( string folder, string keyword)
        {
            var sb = new StringBuilder();
            var develop = inboxFolder.Folders[folder];
            var filter = develop.Items.Cast<MailItem>()
                .Where( x => x.Subject.Contains( keyword ) )
                .OrderByDescending( x => x.CreationTime )
                .Take( 20 )
                .ToList();

            filter.ForEach( item =>
            {
                sb.AppendLine( "Time: " + item.CreationTime );
                sb.AppendLine( "From: " + item.SenderEmailAddress );
                sb.AppendLine( "To: " + item.To );
                sb.AppendLine( "" );
                sb.AppendLine( "Subject: " + item.Subject );
                sb.AppendLine( item.Body );
                Marshal.ReleaseComObject( item );
            } );

            return sb.ToString();
        }

        async Task<string> FetchLogAsync()
        {
            return await Task.Run( () =>
            {
                try
                {
                    return FetchLog(textBoxFolder.Text , textBoxSubjectFilter.Text);
                }
                catch (System.Exception ex)
                {
                    Console.WriteLine( "{0} Exception caught: ", ex );
                    throw ex;
                }
            } );
        }

        private async void ButtonLog_Click( object sender, EventArgs e )
        {
            buttonLog.Enabled = false;
            labelStatus.Text = "Loading...";
            richTextBoxLog.Text = string.Empty;
            richTextBoxLog.Text = await FetchLogAsync();

            //設定顏色
            //注意會被覆蓋掉
            setColor( "Error" );
            setColor( "([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])" );

            buttonLog.Enabled = true;
            labelStatus.Text = "Ready";
        }

        void setColor(string pattern)
        {
            //這樣選不 ok
            richTextBoxLog.SelectAll();
            richTextBoxLog.SelectionColor = Color.Black;
            richTextBoxLog.SelectionBackColor = Color.White;
            Regex regex = new Regex( pattern );
            MatchCollection matches = regex.Matches( richTextBoxLog.Text );

            if (matches.Count > 0)
            {
                foreach (Match m in matches)
                {
                    richTextBoxLog.Select( m.Index, m.Length );
                    richTextBoxLog.SelectionColor = Color.Red;
                    richTextBoxLog.SelectionBackColor = Color.Black;
                }
            }
        }


        private void FormLog_Load( object sender, EventArgs e )
        {
            var existing = Process.GetProcessesByName( "OUTLOOK" ).Any();
            outlookApplication =
            existing ?
            Marshal.GetActiveObject( "Outlook.Application" ) as Microsoft.Office.Interop.Outlook.Application :
            new Microsoft.Office.Interop.Outlook.Application();
            outlookNamespace = outlookApplication.GetNamespace( "MAPI" );
            inboxFolder = outlookNamespace.GetDefaultFolder( OlDefaultFolders.olFolderInbox );
            var develop = inboxFolder.Folders["Develop"];
            develop.Items.ItemAdd += Items_ItemAdd;
            //develop.Items.ItemRemove += Items_ItemRemove;
        }

        private void Items_ItemAdd( object Item )
        {
            MailItem item = (MailItem)Item;
            var sb = new StringBuilder();
            sb.AppendLine( "Time: " + item.CreationTime );
            sb.AppendLine( "From: " + item.SenderEmailAddress );
            sb.AppendLine( "To: " + item.To );
            sb.AppendLine( "" );
            sb.AppendLine( "Subject: " + item.Subject );
            sb.AppendLine( item.Body );
            richTextBoxLog.BeginInvoke( new System.Action( ()=> {
                richTextBoxLog.Text += sb.ToString();
            } ));
            Marshal.ReleaseComObject( item );

        }

        private void Items_ItemRemove()
        {
            Console.WriteLine("remove");
            richTextBoxLog.BeginInvoke( new System.Action( ()=> {
                richTextBoxLog.Text = "remove";
            } ));
        }

        private static void ReleaseComObject( object obj )
        {
            if (obj != null)
            {
                Marshal.ReleaseComObject( obj );
                obj = null;
            }
        }

    }
}

```

### Singleton 的 WPF 程式
複寫 `OnStartup` 的內容 , 並且把 `app.xaml` 的 startup 拿掉
使用 Shutdown 的原因是會關閉這個準備要開啟的 Thread (Instance)
```
public partial class App : Application
{
	protected override void OnStartup(StartupEventArgs e)
	{
		base.OnStartup(e);

		Mutex m = new Mutex(true , "Singleton" , out bool isExists);
		if (isExists != true)
		{
			var findWindow = FindWindow( null, "Singleton" );
			if (findWindow!=IntPtr.Zero)
			{
				SetForegroundWindow( findWindow );
			}
			Shutdown();
		}

		var window1 = new Window1();
		window1.Show();

	}

	[DllImport("User32" , CharSet = CharSet.Unicode)]
	static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

	[DllImport("User32" , CharSet = CharSet.Unicode)]
	static extern IntPtr SetForegroundWindow(IntPtr hWnd);
}
```

### Singleton 的 WinForm 程式
這個 case 比較特別 , 主要是有做縮到右下角 icon 的功能 , 如果沒加上 `ShowWindowAsync` 會 show 不出來
```
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault( false );

            Mutex m = new Mutex(true, "Singleton", out bool created);

            //程式的沒開的話才跑進來
            if (created != true)
            {
                //找這個 window 的指標 (instance)
                var findWindow = FindWindow(null, "Singleton");
                if (findWindow != IntPtr.Zero)
                {
                    //這邊要加上 ShowWindowAsync 這樣子如果縮小成右下角的 Notify Icon 才會有顯示的效果
                    //https://dotblogs.com.tw/chou/2009/06/30/9049
                    ShowWindowAsync( findWindow, WS_SHOWNORMAL );

                    //設定到前景
                    SetForegroundWindow(findWindow);
                }
                Environment.Exit(0);
            }

            Application.Run( new Form1() );
        }

        [DllImport( "user32.dll", CharSet = CharSet.Unicode)]
        static extern IntPtr FindWindow( string lpClassName, string lpWindowName );

        [DllImport("User32.dll" , CharSet = CharSet.Unicode)]
        private static extern bool ShowWindowAsync(IntPtr hWnd, int cmdShow);

        [DllImport("User32.dll" , CharSet = CharSet.Unicode)]
        private static extern bool SetForegroundWindow(IntPtr hWnd);
        private const int WS_SHOWNORMAL = 1;
    }

```
### 錯誤處理
WPF
```
public partial class App : Application
{
	protected override void OnStartup(StartupEventArgs e)
	{
		base.OnStartup(e);
		Dispatcher.UnhandledException += Dispatcher_UnhandledException;
	}

	private void Dispatcher_UnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
	{
		//Log Here
		Debug.Write($"{e.Exception.ToString()}");
		e.Handled = true;
	}
}
```

### 在 WPF Button 的 Tooltip 裡面加些不三不四的東東
```
<Button Content="AAA" Width="50" Height="50" >
	<Button.ToolTip>
		<Grid>
			<Image Width="200" Height="200">
				<Image.Source>
					<BitmapImage UriSource="nono.jpg"></BitmapImage>
				</Image.Source>
			</Image>
		</Grid>
	</Button.ToolTip>
</Button>
```
