---
title: asp.net core 加入 git commit 資訊
date: 2024-10-17 11:58:12
tags: c#
---
&nbsp;
<!-- more -->

## api

印象中以前實驗 docker or k8s 看過一個功能, 他的版本是用 git commit 的 hash 來做為版號
而不是自己去編號, 自己編最後通常就是荒廢, 不然就是有啥 final final final … 這種版本
用 git commit hash 有個好處就是可以很完整確定線上的版本到底是啥, 防止腦子不清醒用分支佈署跳出預期外的結果, 或是忘了切 commit 之類的情況
這兩天發現有這套 [GitInfo](https://github.com/devlooped/GitInfo) 及 [gitversion](https://gitversion.net/docs/) 這套
因為 GitInfo 比較簡單, 就決定用他 XD

安裝完要注意這句, `先關閉 Visual Studio` 不然會偵測不到, 鬼打牆半天 LOL

```
NOTE: you may need to close and reopen the solution in order for Visual Studio to refresh intellisense and show the ThisAssembly type the first time after installing the package.
```

我目前專案大概長這樣, 有一個 api, 他引用了 kernel 這個咚咚, 它們分別用兩個 git 來管理

```
LaSaiApi
	LaSaiApi (34567qq)
	LaSaiApiKernel (gg12345)
```

所以要分別在 api 及 kernel 撰寫撈版本的函數
不然只會列出頂層, 也就是 api 的 `34567qq` 資訊
而不會撈出 kernel `gg12345` 的資訊
最後就是上線之前 `兩個都要編譯` `兩個都要編譯` `兩個都要編譯` 才會動 ~

程式碼大概長這樣 `LaSaiApi` 這邊會是 `34567qq`
而 `LaSaiApiKernelGitInfo` 裡面的則會取得 `gg12345`


```csharp
[ApiController]
[Route( "[controller]" )]
public class VersionController : ControllerBase
{
	[HttpGet( "version" )]
	public IActionResult Version()
	{
		//這裡會得到 34567qq 這個 commit
		var api = new
		{
			ThisAssembly.Git.Branch,
			ThisAssembly.Git.Commits,
			ThisAssembly.Git.Commit,
			ThisAssembly.Git.CommitDate,
			ThisAssembly.Git.RepositoryUrl,
			ThisAssembly.Git.Sha,
			ThisAssembly.Git.Tag,
		};
		
		//這邊會得到 gg12345 這個 commit
		var kernel = new LaSaiApiKernelGitInfo().Version();

		return Ok( new
		{
			Api = api,
			Kernel = kernel
		} );
	}
}
```

LaSaiApiKernel 裡面的類別長這樣

```csharp
   public class LaSaiApiKernelGitInfoDto
   {
       public string Branch { get; set; }
       public string Commits { get; set; }
       public string Commit { get; set; }
       public string CommitDate { get; set; }
       public string RepositoryUrl { get; set; }

       public string Sha { get; set; }

       public string Tag { get; set; }

/// <summary>
/// 跳到 branch 頁面
/// </summary>
public string BranchUrl
{
	get
	{
		var url = RepositoryUrl.Replace(".git", "");
		//這裡是 commits 注意有加 s
		//才會跳到 branch ex:main master 分支..
		string result = $@"{url}/commits/{Branch}";
		return result;
	}
}

/// <summary>
/// 跳到這個 commit
/// </summary>
public string CommitUrl
{
	get
	{
		var url = RepositoryUrl.Replace(".git", "");
		//這裡要串 commit 沒有 s
		//他會直接跳到 commit 內容
		string result = $@"{url}/commit/{Sha}";
		return result;
	}
}
   }

   public class LaSaiApiKernelGitInfo
   {
       public LaSaiApiKernelGitInfoDto Version()
       {
           return new LaSaiApiKernelGitInfoDto
           {
               Branch = ThisAssembly.Git.Branch,
               Commits = ThisAssembly.Git.Commits,
               Commit = ThisAssembly.Git.Commit,
               CommitDate = ThisAssembly.Git.CommitDate,
               RepositoryUrl = ThisAssembly.Git.RepositoryUrl,
               Sha = ThisAssembly.Git.Sha,
               Tag = ThisAssembly.Git.Tag,
           };

       }
   }
```

## 自訂 chrome extension

後來覺得每次還要點那個 version 還是有點麻煩, 所以自幹一個 chrome extension 來輔助自己 XD

```
mkdir gitlab-online-commit-tag
cd gitlab-online-commit-tag
npm init --yes
npm install --save @types/chrome
mkdir scripts
touch scripts/content.js
touch manifest.json
```

注意現在 manifest_version 要選 `3`
`manifest.json` 設定如下

```
{
    "manifest_version": 3,
    "name": "gitlab-online-commit-tag",
    "description": "標示目前線上 api commit",
    "version": "1.0",
    "content_scripts": [
        {
            "js": [
                "scripts/content.js"
            ],
            "matches": [
                "https://yourgitlab/*"
            ]
        }
    ]
}
```

這裡注意自己的站台是否都是 `https` , 如果有混合 `https` `http` 會噴 chrome `Blocked Mixed Content`
可以參考 [Adobe 這個說明](https://experienceleague.adobe.com/en/docs/target/using/experiences/vec/troubleshoot-composer/mixed-content) 把 chrome 的 `gitlab` 相關設定關閉
讓 gitlab 暫時允許 https http 混用
中文版的話應該是 `網站設定` => `不安全的內容`

另外一個重點就是後端 asp.net core 的 cors 要開啟, 不然撈不到

```
console.log("gitlab-online-commit-tag is work");
(function () {
  addCss();

  const libList = ["Api", "Lib"];

  const gitlabUrls = [
    {
      name: "本地",
      url: "https://localhost:3001/version",
    },
    {
      name: "遠端",
      url: "http://xxxooo/version",
    },
  ];

  const fetchPromises = gitlabUrls.map((urlObj) =>
    fetch(urlObj.url)
      .then((response) => {
        if (!response.ok) {
          throw new Error("error" + response.status);
        }
        var result = response.json();
        console.log(result);
        return result;
      })
      .then((result) => {
        //展開運算子展開後, 追加原本定義 url 的物件
        const modifiedResult = { ...result, urlObj: urlObj };
        return modifiedResult;
      })
  );

  Promise.all(fetchPromises)
    .then((versionArray) => {
      //console.log('versionArray' , versionArray);

      for (let version of versionArray) {
        for (let lib of libList) {
          //console.log('lib' , lib);
          if (
            version[lib] &&
            (window.location.href.includes(lib) ||
              window.location.href.includes(lib.toLowerCase()))
          ) {
            // console.log("version[lib]", version[lib]);
            var sha = version[lib].Sha;
            //gitlab 使用八碼 sha
            var commitSha8 = sha.substring(0, 8);
            addCurrentCommitTag(commitSha8, version.urlObj);
          }
        }
      }
    })
    .catch((error) => {
      console.error("error:", error);
    });
})();

function addCss() {
  //加入 css
  const style = document.createElement("style");
  style.type = "text/css";
  style.appendChild(
    document.createTextNode(`
	.online-version {
		line-height: 35px;
		border-radius: 3px;
		border: 1px #bfbfc3 solid;
		margin-left: 3px;
		padding : 3px;
		background-color : YellowGreen;
	}
	`)
  );
  document.head.appendChild(style);
}

function addCurrentCommitTag(commitSha8, urlObj) {
  //commit-25dfdfox
  var commitDiv = document.querySelector(`#commit-${commitSha8}`);
  var btnGroup = commitDiv.querySelector(".btn-group");
  var targetAnchor = btnGroup.querySelector('a[title="Browse Files"]');
  var newDiv = document.createElement("div");

  newDiv.innerHTML = `<div class="online-version">${urlObj.name}</div>`;

  if (targetAnchor) {
    targetAnchor.parentNode.insertBefore(newDiv, targetAnchor.nextSibling);
  }
}
```

最後開啟 chrome 打入以下網址 chrome://extensions/
開啟開發人員模式 => 載入未封裝項目 => 選擇資料夾 gitlab-online-commit-tag 即可搞定

