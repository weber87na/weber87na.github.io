---
title: asp.net core 佈署至 IIS 筆記
date: 2024-10-22 12:04:09
tags: c#
---
&nbsp;
<!-- more -->

今天想要把 .net core `Debug` 的 web api 佈署到自己 Local IIS 測試
結果馬上 IIS 就噴 `IIS HTTP 錯誤 403.14 - Forbidden` 雷了好一陣子, 果然久沒用就忘了, 筆記下幾個遇到的問題

## 確認 IIS 是否安裝 hosting bundle

如果要確定自己的機器有無安裝 hosting bundle 可以到這裡查 regedit
需要依照自己版本去安裝, 可以到[官網下載](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)

```
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Updates\.NET\Microsoft .NET 8.0.10 - Windows Server Hosting (x86)
```

## Visual Studio Publish

Publish 之前最好先把 IIS 上面的 ApplicationPool 建好, 建議一個 ApplicationPool 對應一隻程式, 這樣萬一有問題時, 關閉 ApplicationPool 即可

先在 `專案` 按下右鍵 => `Publish` => `Folder` 然後設定你的路徑
搞定後他會生設定檔在 `Properties` => `PublishProfiles` => `FolderProfile.pubxml`
然後切換 config 檔案就可以正常 publish, 他會在佈署的資料夾底下生出 `web.config`

## 手動佈署
如果是自己直接複製 Debug 資料夾的方式它不會產出 web.config 這樣會一直噴出 404, 須自己手動加入

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" arguments=".\你的專案.dll" stdoutLogEnabled="false" stdoutLogFile=".\logs\stdout" hostingModel="inprocess" />
    </system.webServer>
  </location>
</configuration>
```

## COM 元件存取問題

後來因為專案有使用到 COM 元件, 結果噴這串, 最後調整 Application Pool 權限為 LocalSystem 才搞定

```
UnauthorizedAccessException: Retrieving the COM class factory for component with CLSID {3624XXX0-XE5X-12D3-AX96-XXC04F324E22} failed due to the following error: 80070005 存取被拒
```
