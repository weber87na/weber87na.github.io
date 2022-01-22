---
title: git日常筆記
date: 2020-07-09 00:06:28
tags:
- git
---
&nbsp;
<!-- more -->
隨手紀錄一下日常遇到的git問題

### 中文亂碼
參考以下文章
powershell
https://www.cnblogs.com/Laggage/p/12301495.html 

git bash
https://dotblogs.com.tw/H20/2018/06/22/111411

### 遠端切換分支
參考
https://stackoverflow.com/questions/67699/how-to-clone-all-remote-branches-in-git

自己的 git 太廢學了又忘筆記一下常用的多人開發狀況
A 開發者
```
列出所有分支
git branch -a

remotes/origin/develop
remotes/origin/master

從遠端追蹤分支建立連結
git checkout develop

建立新的 new1 本地分支
git checkout -b new1

將本地分支上傳到遠端(-u origin 是設定上游)
git push -u origin
```

B 開發者
```
下載遠端追蹤分支
git fetch

remotes/origin/develop
remotes/origin/master
remotes/origin/new1

git checkout new1
```

### 救援
腦子不清楚寫錯 code 時放棄目前所有檔案變更
```
git reset --hard HEAD

上一個版本
git reset --hard HEAD~1

回到 reset 以前的版本
git reset --hard ORIG_HEAD

軟男小幅改動程式 , 不想又多 commit 時使用
git reset --soft HEAD~1
```

將自己的分支上傳前被遠端 reject 以後 pull 時用
只更新索引不強制復原檔案(預設就是 --mixed)
```
git reset --mixed
```

修正之前寫錯的 commit (會自動帶出之前 commit 的 message 內容)
或是追加檔案在最後一個 commit 注意只在 local 使用
```
git commit -amend

or
追加的檔案
git add index.html
git commit -amend
```

還原誤刪的檔案
```
rm test.html
git checkout -- test.html

還原某個 commit 裡面的 test.html
git checkout ab1234afsb -- test.html

拿三個版本以前的
git checkout HEAD~3 test.html

救全部
git checkout .
```

### log
log 近三次的
```
git log -3
```

log 單一檔案
```
git log gy.html
```

log 詳細單一檔案
```
git log -p gy.html
```

log 作者名稱 gy
```
git log --oneline --author="gy"
```

log 找罵客戶的
```
git log --oneline --grep="gy"
```

找內容有髒話的
```
git log -S "gy"
```

參考自遺留系統重建實戰
找 10 天內最常修改的 source code
`"[^\s]"` => 去除空白行
特別要注意排序部分有可能有相同數量的檔案 , 所以依照 count 接著 name 進行排序

`bash`
```
git log --since="10 days ago" --pretty=format:"" --name-only | grep "[^\s]" | sort | uniq -c | sort -nr | head -10
```

`powershell`
```
git log --since="10 days ago" --pretty=format:"" --name-only | Select-String -Pattern "[^\s]" | Group-Object | sort count , name -desc | select Count , Name -first 10
```

### 刪檔
讓 git 刪除檔案
```
git rm index.html
```

讓檔案變成 untrack 狀態
```
git rm --cached index.html
```

刪除火大的 Untrack file Thumbs.db [參考](https://koukia.ca/how-to-remove-local-untracked-files-from-the-current-git-branch-571c6ce9b6b1)
```
git clean -f
```

### 忽略檔案
git 通靈目錄
```
mkdir test
touch .keep
```

git 忽略檔案
```
建立忽略文件列表
.gitignore

踢掉建立 gitignore 以前的所有檔案
git clean -fX
```

[.gitignore template](https://github.com/github/gitignore)
[visual studio 底下建 .gitignore 的方法](https://elanderson.net/2016/09/add-git-ignore-to-existing-visual-studio-project/)


git you give love a bad name
```
git blame bonjovi.html
```

萬一被 cache 鎖住更新不了可以參考[這篇](https://stackoverflow.com/questions/6030530/git-ignore-not-working-in-a-directory)
```
git rm -r --cached .
git add .
git commit -m "Gitignore issue fixed"
```

### fatal: fsync error on '.git/objects/pack/tmp_pack_DZTfQ3': Bad file descriptor
今天遇到這個問題 , 我是用 visual studio 開啟專案 , 然後開 git bash 執行 pull 發生的 , 怎麼樣都沒法正確 pull 下來
後來參考[老外](https://stackoverflow.com/questions/47929881/git-fatal-fsync-error-on-sha1-file-bad-file-descriptor)
搞了半天最後把 visual studio 關閉 , 然後用 git bash pull 就成功了 , 不曉得是不是 lock 什麼檔案
```
fatal: fsync error on '.git/objects/pack/tmp_pack_DZTfQ3': Bad file descriptor
```

### repository 改名
今天在用 git 遇到的問題 , 原本的 repository 被改名了 , 這樣比較好運的意思
只要設定下面這個就搞定 `git remote set-url origin https://xxx.com.tw/oxapi.git`
```
remote: To create a merge request for xxxapi, visit:
remote:   https://xxx.com.tw/api/-/merge_requests/new?merge_request%5Bsource_branch%5D=api
remote: Project 'XXX/api' was moved to 'OOO/oxapi'.
remote: Please update your Git remote:
remote:   git remote set-url origin https://xxx.com.tw/oxapi.git
```

### 排除 web.config 裡面的敏感資訊
最近遇到一個問題 , 業主要求要給 git 版控紀錄 , 老實說還真不想給 , 這樣內部密碼等敏感資訊不就裸奔 , 所以研究一下怎麼搞 , 主要[參考老外](https://stackoverflow.com/questions/45677569/how-do-i-keep-asp-net-connection-string-passwords-secure-on-a-git-repository/45706222) 及[這篇](http://johnatten.com/2014/04/06/asp-net-mvc-keep-private-settings-out-of-source-control/) 也可以參考[微軟](https://docs.microsoft.com/zh-tw/aspnet/identity/overview/features-api/best-practices-for-deploying-passwords-and-other-sensitive-data-to-aspnet-and-azure)
新增一個連線字串的檔案 `ConnectionStrings.config` 然後把原本的連線字串都丟進來 , 這裡用 LocalDb
```
<connectionStrings>
	<add name="WorldCities" 
	   connectionString="Data Source=(LocalDb)\MSSQLLocalDB;Initial Catalog=WorldCities;Integrated Security=SSPI;"
	   providerName="System.Data.SqlClient" 
	/>
</connectionStrings>
```


接著修改 `web.config` 的內容 , 找到原本連線字串的地方 , 改為這樣
```
<configuration>
	<connectionStrings configSource="ConnectionStrings.config" />
</configuration>
```

在 `.gitignore` 裡面加上排除條件
```
# 排除 web.config 裡面的敏感資訊
ConnectionStrings.config
```

執行 `git status` 大概會長這樣 , 這樣就排除了
```
git status

On branch master
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   ../.gitignore
        modified:   Web.config
        deleted:    connections.config
```

接著隨便寫段 code 連看看應該就沒事了
```
public class DapperBaseRepository
{
	public List<T> Query<T>(string query, object parameters = null)
	{
		try
		{

			using (SqlConnection conn 
				   = new SqlConnection(ConfigurationManager.ConnectionStrings["WorldCities"].ToString()))
			{
				return conn.Query<T>(query, parameters).ToList();
			}
		}
		catch (Exception ex)
		{
			//Handle the exception
			return new List<T>();
		}
	}
}
```

`appSettings` 詳細可以看[官方](https://docs.microsoft.com/zh-tw/aspnet/identity/overview/features-api/best-practices-for-deploying-passwords-and-other-sensitive-data-to-aspnet-and-azure)跟[這篇](https://stackoverflow.com/questions/19596233/mvc-3-getting-values-from-appsettings-in-web-config)
```
<appSettings file="AppSettingsSecrets.config">
	<add key="webpages:Version" value="3.0.0.0" />
	<add key="webpages:Enabled" value="false" />
	<add key="ClientValidationEnabled" value="true" />
	<add key="UnobtrusiveJavaScriptEnabled" value="true" />
</appSettings>
```

接著新增 `AppSettingsSecrets.config` 注意要在 gitignore 裡面先設定
```
<appSettings>
   <!-- SendGrid-->
   <add key="mailAccount" value="My mail account." />
   <add key="mailPassword" value="My mail password." />
   <!-- Twilio-->
   <add key="TwilioSid" value="My Twilio SID." />
   <add key="TwilioToken" value="My Twilio Token." />
   <add key="TwilioFromPhone" value="+12065551234" />

   <add key="GoogClientID" value="1.apps.googleusercontent.com" />
   <add key="GoogClientSecret" value="My Google client secret." />
</appSettings>

```

撈資料
```
var x = System.Configuration.ConfigurationManager.AppSettings["mailAccount"];
```


### 其他資源
[git 練習](https://learngitbranching.js.org/?locale=zh_TW)
