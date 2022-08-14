---
title: powershell 佈署 asp.net core 到 iis sub application
date: 2020-07-14 12:01:44
tags:
- iis
- asp.net core
- sub application
- powershell
---
&nbsp;
![terminal](https://raw.githubusercontent.com/weber87na/flowers/master/terminal.png)
<!-- more -->
上線前為了方便讓前端可以去做畫面的調整建議把 csproj 內的 RazorCompileOnPublish 設定為 true

編譯之前建議先看這 [黑暗執行緒的文章](https://blog.darkthread.net/blog/razor-runtime-compilation/) 很受用

有時需要切換環境測試所以直接使用 self-contained 命令
```
dotnet publish --self-contained true -r win10-x64
```

注意以下操作需要使用系統管理員 , 可以安裝 [sudo](https://github.com/gerardog/gsudo) 簡化流程

下載 NTFSSecurity 模組 , 並且引入 IIS 模組及 NTFSSecurity
``` powershell
Import-Module WebAdministration
Install-Module -Name NTFSSecurity -RequiredVersion 4.2.4
Import-Module NTFSSecurity
```

佈署 asp.net core 網站之前記得要下載 [aspnetcore-windows-hosting-bundle](https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-aspnetcore-3.1.5-windows-hosting-bundle-installer)

接著在 APpPool 建立 .net core 專屬的 AppPool

注意 AppPool 我測不出自動建立的方法 , 只好手動建立一個 no managed code 名為 NetCore 的 AppPool , 如果有人有找到方法歡迎告訴我感謝!

最後佈署 Asp.net Core 網站為 Default Web Site 的 Sub Application (這很無奈... 但就是很多地方只能讓你用 80 port 又不給你 domain name)
```
New-WebApplication -Name VideoExample -Site 'Default Web Site' -PhysicalPath D:\TestWebSite -ApplicationPool NetCore
```

給予權限 (以前都要按好多步驟 , 現在一行就搞定)
```
Add-NTFSAccess -Path 'D:\TestWebSite ' -Account IIS_IUSRS -AccessRights FullControl
```

最後切換到 IIS 目錄底下看看狀況
```
cd IIS:\Sites\Default Web Site\
ls
```
如果要移除 sub application 或是其他物件也很方便直接下 rm 就好了
