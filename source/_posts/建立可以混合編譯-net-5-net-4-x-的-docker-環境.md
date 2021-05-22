---
title: 建立可以混合編譯 .net 5 & .net 4.x 的 docker 環境
date: 2021-05-19 19:26:09
tags: docker
---
&nbsp;
<!-- more -->

### hello world
[最小的 nanoserver](https://hub.docker.com/_/microsoft-windows-nanoserver) , 注意預設的 nanoserver 只有 cmd
這個 example 會安裝 powershell core 在 nanoserver 上面
另外要注意的是 .net framework 沒辦法在 nano server 上執行 , 必須用 windows server core (很肥 10GB+)

注意使用 nanoserver 因為沒有 latest 所以會炸這個 error , 要自己指定版本
```
manifest for mcr.microsoft.com/windows/nanoserver:latest not found: manifest unknown: manifest unknown
```

```
#因為 windows 會用 slash 所以設定為 ` 作為 dockerfile 的換行
# escape=`

#這個是只有 cmd 版本的
#FROM mcr.microsoft.com/windows/nanoserver:1809

#有 powershell 版本的
FROM mcr.microsoft.com/powershell:nanoserver-1809

COPY print-env-details.ps1 C:\\print-env.ps1

#注意舊版才有 powershell
#CMD ["powershell.exe" , "c:\\print-env.ps1"]

#新版都用 powershell core
CMD ["pwsh.exe" , "c:\\print-env.ps1"]
```

補充 ,萬一需要 pull or push 內部的 private registry 需要在 `%programdata%\docker\config\daemon.json` 自己加上 ip
```
	"insecure-registries" : [
		"registry.local:5000"
	]
```


### 建立一個 .net core & .net framework 混用的
特別注意這個很雷 , 一定要照官方的這個 [example](https://docs.microsoft.com/zh-tw/visualstudio/install/build-tools-container?view=vs-2019) 去改 , 不然直接用 windows-servercore 會 build 不起來
安裝完會有 nuget , msbuild tool
```
# escape=`

# Use the latest Windows Server Core image with .NET Framework 4.8.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.AzureBuildTools `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest -UseBasicParsing https://chocolatey.org/install.ps1 | Invoke-Expression;
RUN choco install -y git
RUN choco install -y vim
RUN choco install -y firacode

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
RUN Install-PackageProvider -Name NuGet -Force
RUN Install-Module posh-git -Force
RUN Install-Module oh-my-posh -Force
#RUN Install-Module DockerCompletion -Force
RUN Install-Module PSReadLine -RequiredVersion 2.1.0 -Force


#設定 git 環境變數 , 預設沒有設定
ENV GIT_PATH="C:\Program Files\Git\bin"

#追加到 PATH 裡面
RUN $env:PATH = $env:GIT_PATH + ';' +  $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

#複製現在機器上的設定到 image 裡面
COPY Microsoft.PowerShell_profile.ps1 .

#搬 profile 到 image 內
RUN cp Microsoft.PowerShell_profile.ps1 $profile

#讓 image 內的 profile 生效
RUN & $profile

#設定 git ssl
RUN git config --global http.sslVerify false

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

```

`Microsoft.PowerShell_profile` `$profile`
```
#使用 bash 的 emacs 鍵盤設定
Set-PSReadLineOption -EditMode Emacs

#美化 powershell
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt darkblood

#Docker 提示
#Import-Module DockerCompletion

#k8s 提示
#Import-Module -Name PSKubectlCompletion
#Register-KubectlCompletion

#dotnet 提示
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

#開啟歷史提示
#Set-PSReadLineOption -PredictionSource History

#alias
Set-Alias -Name d -Value docker
#Set-Alias -Name k -Value kubectl
Set-Alias gsudo sudo
Set-Alias -Name touch -Value New-Item

```

蓋完以後可以用 Get-Command 去找看看 msbuild , nuget , dotnet 或其他工具的位置在哪裡 , 因為在 powershell 裡面 where 有其他意思 , 如果是 cmd 則是用 where
```
Get-Command msbuild
#C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe

Get-Command nuget
#C:\Program Files\NuGet\nuget.exe

Get-Command dotnet
C:\Program Files\dotnet\dotnet.exe
```
