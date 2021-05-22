---
title: 製作窮人的 ini to csharp 外掛
date: 2021-01-23 18:55:16
tags:
- visualstudio
- ini
- csharp
---
&nbsp;
<!-- more -->

一個人假日發呆找不到人陪我看海，剛好看到[老外開掛](https://github.com/Apress/visual-studio-extensibility-development/tree/master/Chapter%205/JsonToCSharpCodeGeneration) 這老外還真是猛，可以寫出這麼變態的東西
剛好案子在做 ini 有類似的情景就順應天命做一個窮人的 ini to c# 外掛，徹底當條掛狗
首先要安裝 `vsix 專案範本` 之前就裝過了詳情可以靠 google
新增專案 `VSIX Project` 注意!腦子已經在空白，不要選成空白的
接著新增 `Extensibility` => `command`
然後新增類別 INIIoCSharpCodeGenerator 繼承 BaseCodeGeneratorWithSite
這個類別會用正則表達式簡單的驗證 ini 檔案，然後產生 csharp 類別，不支援陣列及註解還有其他特別狀況
## 核心轉換 INIToCSharpCodeGenerator
``` csharp
    public class INIToCSharpCodeGenerator : BaseCodeGeneratorWithSite
    {
        public const string Name = nameof(INIToCSharpCodeGenerator);

        public const string Description = "Generates the C# class from INI file";

        public override string GetDefaultExtension()
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            var item = (ProjectItem)GetService(typeof(ProjectItem));
            var ext = Path.GetExtension(item?.FileNames[1]);
            return $".cs";
        }


        public string PoorManINIToCS(string path)
        {
            var lines = File.ReadAllLines( path );

            Dictionary<string, Dictionary<string, string>> dict = new Dictionary<string, Dictionary<string, string>>( );

            //類別區塊
            var classSection = new Regex( @"\[\w+\]" );
            //屬性區塊
            var propSection = new Regex( @"(?<prop>\w+) (=) (?<val>.*)" );
            bool isClass = false;

            string holdClass = "";
            foreach (var line in lines)
            {
                //如果是的話進入到下個階段辨識
                isClass = classSection.IsMatch( line );
                if (isClass == true)
                {
                    dict.Add( line, null );
                    holdClass = line;
                    dict[holdClass] = new Dictionary<string, string>( );
                }

                //如果完全符合規則取得屬性與數值
                var isProp = propSection.IsMatch( line );
                if (isProp)
                {
                    var match = propSection.Match( line );
                    var prop = match.Groups["prop"].Value;
                    var val = match.Groups["val"].Value;
                    dict[holdClass].Add( prop, val );
                }
            }
            StringBuilder sb = new StringBuilder( );
            foreach (var d in dict)
            {
                sb.AppendLine(
                    $@"public class {d.Key.Replace( "[", "" ).Replace( "]", "" )} " );
                sb.AppendLine( "{" );
                foreach (var item in d.Value)
                {
                    bool boolVal = false;
                    var isBool = bool.TryParse( item.Value, out boolVal );

                    int intVal = 0;
                    var isInt = int.TryParse( item.Value, out intVal );

                    double doubleVal = 0.0;
                    var isDouble = double.TryParse( item.Value, out doubleVal );

                    if (isBool)
                    {
                        sb.AppendLine( "\t" + $@"public bool {item.Key} = {item.Value}" + ";" );
                        continue;
                    }

                    if (isInt)
                    {
                        sb.AppendLine( "\t" + $@"public int {item.Key} = {item.Value}" + ";" );
                        continue;
                    }

                    if (isDouble)
                    {
                        sb.AppendLine( "\t" + $@"public double {item.Key} = {item.Value}" + ";" );
                        continue;
                    }

                    sb.AppendLine( "\t" + $@"public string {item.Key} =  ""{item.Value}"";" );
                }
                sb.AppendLine( "}" );
            }
            return sb.ToString( );
        }


        protected override byte[] GenerateCode(string inputFileName, string inputFileContent)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            string document = string.Empty;
            try
            {
                document = ThreadHelper.JoinableTaskFactory.Run(async () =>
               {
                   var text  = PoorManINIToCS( inputFileName );
                   //var text = File.ReadAllText(inputFileName); // Alternatively, you can also use inputFileContent directly.
                   //var schema = NJsonSchema.JsonSchema.FromSampleJson(text);
                   //var generator = new CSharpGenerator(schema);
                   return await System.Threading.Tasks.Task.FromResult(text);
               });
            }
            catch (Exception exception)
            {
                // Write in output window
                var outputWindowPane = this.GetService(typeof(SVsGeneralOutputWindowPane)) as IVsOutputWindowPane;
                if (outputWindowPane != null)
                {
                    outputWindowPane.OutputString($"An exception occurred while generating code {exception.ToString()}");
                }

                // Show in error list
                this.GeneratorErrorCallback(false, 1, $"An exception occurred while generating code {exception.ToString()}", 1, 1);
                this.ErrorList.ForceShowErrors();
            }

            return Encoding.UTF8.GetBytes(document);
        }
    }

```

## 命令部分 CodeGenCommand
接著修改 `CodeGenCommand`
``` csharp
    internal sealed class CodeGenCommand
    {
        /// <summary>
        /// Command ID.
        /// </summary>
        public const int CommandId = 0x0100;

        /// <summary>
        /// Command menu group (command set GUID).
        /// </summary>
        public static readonly Guid CommandSet = new Guid( "9623d4ed-6401-4963-b5aa-fc850be96b6e" );

        /// <summary>
        /// VS Package that provides this command, not null.
        /// </summary>
        private readonly AsyncPackage package;

        private CodeGenCommand(AsyncPackage package, IMenuCommandService commandService)
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
        public static CodeGenCommand Instance
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets the service provider from the owner package.
        /// </summary>
        private Microsoft.VisualStudio.Shell.IAsyncServiceProvider ServiceProvider
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
            // Switch to the main thread - the call to AddCommand in CodeGenCommand's constructor requires
            // the UI thread.
            //await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync( package.DisposalToken );

            //OleMenuCommandService commandService = await package.GetServiceAsync( typeof( IMenuCommandService ) ) as OleMenuCommandService;
            //Instance = new CodeGenCommand( package, commandService );


            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync(package.DisposalToken);
            dte = (DTE)await package.GetServiceAsync(typeof(DTE));
            Assumes.Present(dte);
            IMenuCommandService commandService = await package.GetServiceAsync(typeof(IMenuCommandService)) as IMenuCommandService;
            Instance = new CodeGenCommand(package, commandService);
        }
        private static DTE dte;
        /// <summary>
        /// This function is the callback used to execute the command when the menu item is clicked.
        /// See the constructor to see how the menu item is associated with this function using
        /// OleMenuCommandService service and MenuCommand class.
        /// </summary>
        /// <param name="sender">Event sender.</param>
        /// <param name="e">Event args.</param>
        private void Execute(object sender, EventArgs e)
        {
            //ThreadHelper.ThrowIfNotOnUIThread( );
            //string message = string.Format( CultureInfo.CurrentCulture, "Inside {0}.MenuItemCallback()", this.GetType( ).FullName );
            //string title = "CodeGenCommand";

            // Show a message box to prove we were here
            //VsShellUtilities.ShowMessageBox(
            //    this.package,
            //    message,
            //    title,
            //    OLEMSGICON.OLEMSGICON_INFO,
            //    OLEMSGBUTTON.OLEMSGBUTTON_OK,
            //    OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST );

            ThreadHelper.ThrowIfNotOnUIThread();
            ProjectItem item = dte.SelectedItems.Item(1).ProjectItem;

            if (item != null)
            {
                item.Properties.Item("CustomTool").Value = INIToCSharpCodeGenerator.Name;
            }


        }
    }

```

## 命令部分 PoorManINIToCSharpVSIXPackage
最後修改 `PoorManINIToCSharpVSIXPackage`
這個步驟會在 visual studio 的 UI 上加一些訊息
像是這個屬性 ProvideUIContextRule
```
    [PackageRegistration( UseManagedResourcesOnly = true, AllowsBackgroundLoading = true )]
    [Guid( PoorManINIToCSharpVSIXPackage.PackageGuidString )]
    //[ProvideMenuResource("Menus.ctmenu", 1)]
    [ProvideCodeGenerator(typeof(INIToCSharpCodeGenerator), INIToCSharpCodeGenerator.Name, INIToCSharpCodeGenerator.Description, true)]
    [ProvideCodeGeneratorExtension(INIToCSharpCodeGenerator.Name, PoorManINIToCSharpVSIXPackage.IniExt)]
    [ProvideUIContextRule(PackageGuids.guidPoorManINIToCSharpVSIXPackageString,
        name: "Context",
        expression: PoorManINIToCSharpVSIXPackage.IniExt,
        termNames: new[] { PoorManINIToCSharpVSIXPackage.IniExt },
        termValues: new[] { "HierSingleSelectionName:." + PoorManINIToCSharpVSIXPackage.IniExt + "$" })]
    public sealed class PoorManINIToCSharpVSIXPackage : AsyncPackage
    {
        /// <summary>
        /// PoorManINIToCSharpVSIXPackage GUID string.
        /// </summary>
        public const string PackageGuidString = "2c67d035-a33c-4d5a-a354-e99aa615100c";
        public const string IniExt = "ini";
        #region Package Members

        /// <summary>
        /// Initialization of the package; this method is called right after the package is sited, so this is the place
        /// where you can put all the initialization code that rely on services provided by VisualStudio.
        /// </summary>
        /// <param name="cancellationToken">A cancellation token to monitor for initialization cancellation, which can occur when VS is shutting down.</param>
        /// <param name="progress">A provider for progress updates.</param>
        /// <returns>A task representing the async work of package initialization, or an already completed task if there is none. Do not return null from this method.</returns>
        protected override async Task InitializeAsync(CancellationToken cancellationToken, IProgress<ServiceProgressData> progress)
        {
            // When initialized asynchronously, the current thread may be a background thread at this point.
            // Do any initialization that requires the UI thread after switching to the UI thread.
            await this.JoinableTaskFactory.SwitchToMainThreadAsync( cancellationToken );
            await CodeGenCommand.InitializeAsync(this);
        }

        #endregion
    }

```

## Debug 設定
在 csproj 把這幾個都給設定為 true 不然不能 debug
```
    <IncludeAssemblyInVSIXContainer>true</IncludeAssemblyInVSIXContainer>
    <IncludeDebugSymbolsInVSIXContainer>true</IncludeDebugSymbolsInVSIXContainer>
    <IncludeDebugSymbolsInLocalVSIXDeployment>true</IncludeDebugSymbolsInLocalVSIXDeployment>
    <CopyBuildOutputToOutputDirectory>true</CopyBuildOutputToOutputDirectory>
    <CopyOutputSymbolsToOutputDirectory>true</CopyOutputSymbolsToOutputDirectory>
```

此外要在 Debug Properties 內設定以下兩個進階命令
`Start external program` => `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe`
`Command line arguments` => `/rootsuffix Exp`
最後就可以把 ini 檔放進來點選右鍵 `Run Custom Command` 以後就可以順利產生類別了

``` ini
[Test]
SomeString = Hello World!
SomeInteger = 10
SomeFloat = 20.05
SomeBoolean = true
Day = Monday

[Person]
Name = Peter
Age = 50
```
結論要當個開掛仔還是非常辛苦低!

## 附贈 console 版本
```
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace ConvINIToCSharp
{
    class Program
    {
        static void Main(string[] args)
        {
            PoorManINIToCS( "d:\\test.ini" );
        }
        public static void PoorManINIToCS(string path)
        {
            var lines = File.ReadAllLines( path );

            Dictionary<string, Dictionary<string, string>> dict = new Dictionary<string, Dictionary<string, string>>( );

            //類別區塊
            var classSection = new Regex( @"\[\w+\]" );
            //屬性區塊
            var propSection = new Regex( @"(?<prop>\w+) (=) (?<val>.*)" );
            bool isClass = false;

            string holdClass = "";
            foreach (var line in lines)
            {
                //如果是的話進入到下個階段辨識
                isClass = classSection.IsMatch( line );
                if (isClass == true)
                {
                    dict.Add( line, null );
                    holdClass = line;
                    dict[holdClass] = new Dictionary<string, string>( );
                }

                //如果完全符合規則取得屬性與數值
                var isProp = propSection.IsMatch( line );
                if (isProp)
                {
                    var match = propSection.Match( line );
                    var prop = match.Groups["prop"].Value;
                    var val = match.Groups["val"].Value;
                    dict[holdClass].Add( prop, val );
                }
            }

            foreach (var d in dict)
            {
                Console.WriteLine(
                    $@"public class {d.Key.Replace( "[", "" ).Replace( "]", "" )} " );
                Console.WriteLine( "{" );
                foreach (var item in d.Value)
                {
                    bool boolVal = false;
                    var isBool = bool.TryParse( item.Value, out boolVal );

                    int intVal = 0;
                    var isInt = int.TryParse( item.Value, out intVal );

                    double doubleVal = 0.0;
                    var isDouble = double.TryParse( item.Value, out doubleVal );

                    if (isBool)
                    {
                        Console.WriteLine( "\t" + $@"public bool {item.Key} = {item.Value}" + ";" );
                        continue;
                    }

                    if (isInt)
                    {
                        Console.WriteLine( "\t" + $@"public int {item.Key} = {item.Value}" + ";" );
                        continue;
                    }

                    if (isDouble)
                    {
                        Console.WriteLine( "\t" + $@"public double {item.Key} = {item.Value}" + ";" );
                        continue;
                    }

                    Console.WriteLine( "\t" + $@"public string {item.Key} =  ""{item.Value}"";" );
                }
                Console.WriteLine( "}" );
            }
        }

    }
}

```
## 其他資源
[官方範例](https://github.com/Microsoft/VSSDK-Extensibility-Samples)
