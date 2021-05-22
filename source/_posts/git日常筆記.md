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

### 其他資源
[git 練習](https://learngitbranching.js.org/?locale=zh_TW)
