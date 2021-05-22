---
title: visual studio 製作類似 vim 的 GoToFile 功能外掛
date: 2021-01-31 23:38:12
tags:
- visual studio
- extension
- 外掛
---
&nbsp;
<!-- more -->

### 幹話
用了 vsvim 開發一陣子了, 大致上來說功能都有, 但是好像沒 `gf` ~~女友(誤)~~ Go To File 這個功能
由於目前遇到的 mvc 不太照著標準的 mvc 架構進行資料夾或是檔案的擺放, 所以常常找不到檔案.. 檔案數量又非常眾多, 沒有這類功能很困擾
萬事起頭難上網查一下最主要核心物件就是 DTE 這玩意 , 他可以控制 visual studio 一堆亂七八糟操作都有 , 看官方 [example](https://docs.microsoft.com/en-us/dotnet/api/envdte.itemoperations.openfile?view=visualstudiosdk-2019#EnvDTE_ItemOperations_OpenFile_System_String_System_String_) 操作開啟檔案十分簡單
目前的寫法比較陽春也還沒驗證過 , 簡單試了幾個檔案還算是堪用 , 主要就是讓選取起來路徑去查看看有無規則內的路徑 , 有就開啟在視窗內 , 美中不足是在 vim 裡面不用選取吧!? 就可以直接找到路徑 這樣的作法可能要在多設定 key binding 感覺操作才會順 , 不曉得 vscode 裡面有沒有這功能 , 印象中 emacs 大師上課有狂婊一頓 哈!

### 關鍵開啟檔案
``` csharp
        public void GoToFile(IWpfTextView wpfTextView , DTE dte)
        {
            var spans = wpfTextView.Selection.SelectedSpans;
            foreach (var span in wpfTextView.Selection.SelectedSpans)
            {
                string path = span.GetText( );

                //打開目前絕對路徑的檔案
                if(File.Exists(path) == true) dte.ItemOperations.OpenFile( path , Constants.vsViewKindAny );

                //mvc root
                if(path.StartsWith( "~/" ))
                {
                    var slnDir = Path.GetDirectoryName(dte.Solution.FullName);
                    string currentDocumentPath = dte.ActiveDocument.FullName;
                    string substractPath = currentDocumentPath.Replace( slnDir, "" );
                    var match = Regex.Match(substractPath, @"^(\\)(?<first>[\w\-]+)");
                    var first = match.Groups["first"];
                    string dirName = Path.GetDirectoryName( currentDocumentPath );
                    path = path.Replace( "~/", "" );
                    path = path.Replace( @"/", @"\" );
                    var result = Path.Combine(slnDir, first.Value, path);

                    if(File.Exists(result) == true) 
                        dte.ItemOperations.OpenFile( result , Constants.vsViewKindAny );
                }

                //取得目前資料夾位置
                if(path.StartsWith( "./" ))
                {
                    string currentDocumentPath = dte.ActiveDocument.FullName;
                    string dirName = Path.GetDirectoryName( currentDocumentPath );
                    path = path.Replace( "./", "" );
                    path = path.Replace( @"/", @"\" );
                    var result = Path.Combine( dirName, path);

                    if(File.Exists(result) == true) 
                        dte.ItemOperations.OpenFile( result , Constants.vsViewKindAny );
                }

                //相對
                if (path.StartsWith( "../" ))
                {
                    string currentDocumentPath = dte.ActiveDocument.FullName;
                    string dirName = Path.GetDirectoryName( currentDocumentPath );
                    var result = Path.Combine( dirName, path);

                    if(File.Exists(result) == true) 
                        dte.ItemOperations.OpenFile( result , Constants.vsViewKindAny );
                }
            }
        }

```

### 切換 true false
做完以後順手把覺得很煩人的 toggle 順便一起做一做 , 把選到的文字驗證是 true or false 相對的結果進行切換 , 應該還可以用這類方法做更多操作

``` csharp
        public void Toggle(IWpfTextView wpfTextView)
        {
            var spans = wpfTextView.Selection.SelectedSpans;
            foreach (var span in wpfTextView.Selection.SelectedSpans)
            {
                Debug.WriteLine( span.GetText( ) );
                if (span.GetText( ) == "0")
                {
                    var textEdit = wpfTextView.TextBuffer.CreateEdit( );
                    textEdit.Replace( span, "1" );
                    textEdit.Apply( );
                    continue;
                }

                if (span.GetText( ) == "1")
                {
                    var textEdit = wpfTextView.TextBuffer.CreateEdit( );
                    textEdit.Replace( span, "0" );
                    textEdit.Apply( );
                    continue;
                }


                if (span.GetText( ) == "public")
                {
                    var textEdit = wpfTextView.TextBuffer.CreateEdit( );
                    textEdit.Replace( span, "private" );
                    textEdit.Apply( );
                    continue;
                }

                if (span.GetText( ) == "private")
                {
                    var textEdit = wpfTextView.TextBuffer.CreateEdit( );
                    textEdit.Replace( span, "public" );
                    textEdit.Apply( );
                    continue;
                }

                if (span.GetText( ) == "true")
                {
                    var textEdit = wpfTextView.TextBuffer.CreateEdit( );
                    textEdit.Replace( span, "false" );
                    textEdit.Apply( );
                    continue;
                }

                if (span.GetText( ) == "false")
                {
                    var textEdit = wpfTextView.TextBuffer.CreateEdit( );
                    textEdit.Replace( span, "true" );
                    textEdit.Apply( );
                    continue;
                }
            }
        }

```

### 半殘 fullcode
``` csharp
using EnvDTE;
using Microsoft;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.ComponentModelHost;
using Microsoft.VisualStudio.Editor;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Text.Editor;
using Microsoft.VisualStudio.TextManager.Interop;
using System;
using System.ComponentModel.Design;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using Task = System.Threading.Tasks.Task;

namespace VSIXProjectMultiLang
{
    /// <summary>
    /// Command handler
    /// </summary>
    internal sealed class CommandGoToFile
    {
        private static DTE dte;

        private IWpfTextView wpfTextView;
        /// <summary>
        /// Command ID.
        /// </summary>
        public const int CommandId = 4139;

        /// <summary>
        /// Command menu group (command set GUID).
        /// </summary>
        public static readonly Guid CommandSet = new Guid( "d7d69c46-e99c-4a3c-95b8-9ac3a1e45289" );

        /// <summary>
        /// VS Package that provides this command, not null.
        /// </summary>
        private readonly AsyncPackage package;

        /// <summary>
        /// Initializes a new instance of the <see cref="CommandGoToFile"/> class.
        /// Adds our command handlers for menu (commands must exist in the command table file)
        /// </summary>
        /// <param name="package">Owner package, not null.</param>
        /// <param name="commandService">Command service to add command to, not null.</param>
        private CommandGoToFile(AsyncPackage package, OleMenuCommandService commandService)
        {
            this.package = package ?? throw new ArgumentNullException( nameof( package ) );
            commandService = commandService ?? throw new ArgumentNullException( nameof( commandService ) );

            var menuCommandID = new CommandID( CommandSet, CommandId );
            var menuItem = new MenuCommand( this.Execute, menuCommandID );
            commandService.AddCommand( menuItem );
        }

        /// <summary>
        /// Gets the instance of the command.
        /// </summary>
        public static CommandGoToFile Instance
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets the service provider from the owner package.
        /// </summary>
        private IServiceProvider ServiceProvider
        {
            get
            {
                return this.package;
            }
        }

        /// <summary>
        /// Initializes the singleton instance of the command.
        /// </summary>
        /// <param name="package">Owner package, not null.</param>
        public static async Task InitializeAsync(AsyncPackage package)
        {
            // Switch to the main thread - the call to AddCommand in CommandGoToFile's constructor requires
            // the UI thread.
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync( package.DisposalToken );
            dte = (DTE)await package.GetServiceAsync(typeof(DTE));
            OleMenuCommandService commandService = await package.GetServiceAsync( typeof( IMenuCommandService ) ) as OleMenuCommandService;
            Assumes.Present(dte);
            Instance = new CommandGoToFile( package, commandService );
        }

        /// <summary>
        /// This function is the callback used to execute the command when the menu item is clicked.
        /// See the constructor to see how the menu item is associated with this function using
        /// OleMenuCommandService service and MenuCommand class.
        /// </summary>
        /// <param name="sender">Event sender.</param>
        /// <param name="e">Event args.</param>
        private void Execute(object sender, EventArgs e)
        {
            ThreadHelper.ThrowIfNotOnUIThread( );
            Exec( );
        }

        private void Exec()
        {
            this.wpfTextView = GetCurrentTextView( );
            MethodLogic methodLogic = new MethodLogic( );
            methodLogic.GoToFile( wpfTextView , dte);

        }
        public IWpfTextView GetCurrentTextView()
        {
            return GetTextView();
        }

        public IWpfTextView GetTextView()
        {
            var compService = ServiceProvider.GetService(typeof(SComponentModel)) as IComponentModel;
            Assumes.Present(compService);
            IVsEditorAdaptersFactoryService editorAdapter = compService.GetService<IVsEditorAdaptersFactoryService>();
            return editorAdapter.GetWpfTextView(GetCurrentNativeTextView());
        }

        public IVsTextView GetCurrentNativeTextView()
        {
            var textManager = (IVsTextManager)ServiceProvider.GetService(typeof(SVsTextManager));
            Assumes.Present(textManager);
            IVsTextView activeView;
            ErrorHandler.ThrowOnFailure(textManager.GetActiveView(1, null, out activeView));
            return activeView;
        }

    }
}

```

### vsvim key binding
實際上開發會用 vsvim 呼叫這些 command 唯一缺點就是這些 command 操作必須要先選到文字才能呼叫所以 binding 變得很攏長必須在開頭加上這樣 `viw:vsc` 反而自己用模擬的 binding 撰寫還比呼叫這些 command 快速 , 不過有的功能像是 toogle vim 好像就沒法實現 , 撰寫這些 extension 還算是有點價值 , 尤其是在大量類別需要修改上面方便很多!
```
"to string
"nmap <Leader>2s viwxistring<Esc>

"to string use extension
nmap <Leader>2s viw:vsc Tools.ToString<CR>

"to int use extension
nmap <Leader>2i viw:vsc Tools.ToInt<CR>

"to bool
"nmap <Leader>2b viwxibool<Esc>

"to bool use extension
nmap <Leader>2b viw:vsc Tools.ToBool<CR>

"to float
"nmap <Leader>2f viwxifloat<Esc>

"to decimal
"nmap <Leader>2d viwxidecimal<Esc>

"to var
"nmap <Leader>2v viwxivar<Esc>

"to var use extension
nmap <Leader>2v viw:vsc Tools.ToVar<CR>

"to double use extension
nmap <Leader>2f viw:vsc Tools.ToDouble<CR>

"toogle true
"nmap <Leader>tt viwxitrue<Esc>

"toogle false
"nmap <Leader>tf viwxifalse<Esc>

"toogle use extension
nmap <Leader>tt

"go to file 必須先選中路徑
map <Leader>gf :vsc Tools.GoToFile<CR>

"select current method
map <Leader>vim :vsc Tools.SelectCurrentMethod<CR>

"Move To Method Begin
map <Leader>gmb :vsc Tools.MoveToMethodBegin<CR>

"Move To Method End
map <Leader>gme :vsc Tools.MoveToMethodEnd<CR>
```

### 後記
上網看到 SSMS 也可以用類似的方式製作外掛 , 不過我實驗失敗就是了 , 可以參考這[老外](https://www.codeproject.com/Articles/1377559/How-to-Create-SQL-Server-Management-Studio-18-SSMS)
[很多DTE Example](https://vlasovstudio.com/visual-commander/commands.html)
