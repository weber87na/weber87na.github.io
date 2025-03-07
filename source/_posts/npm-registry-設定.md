---
title: npm registry 設定
date: 2024-11-01 12:24:22
tags: npm
---
&nbsp;
<!-- more -->

同事遇到的問題, 在安裝 npm angular 套件時噴出以下錯誤

```
npm ERR! 404 Not Found - GET http://xxxx:8801/@angular-devkit%2fbuild-angular
npm ERR! 404
npm ERR! 404  '@angular-devkit/build-angular@^16.2.16' is not in this registry.
npm ERR! 404
npm ERR! 404 Note that you can also install from a
npm ERR! 404 tarball, folder, http url, or git url.

npm ERR! A complete log of this run can be found in:
npm ERR!     C:\Users\username\AppData\Local\npm-cache\_logs\2024-10-26T03_45_30_217Z-debug-0.log
✖ Package install failed, see above.
The Schematic workflow failed. See above.
```

解法如下輸入 `npm config get registry` 看目前使用的 registry 正常會是 `https://registry.npmjs.org/`
這邊因為同事設定了壞掉的 registry 所以會是這樣 `http://xxxx:8801`

```
npm config get registry
https://registry.npmjs.org/
```

如果之前有用自己的 registry 或其他 3rd registry 發生錯誤之類的則需要將他改回來就搞定了

```
npm config set registry https://registry.npmjs.org/
```

如果想自己蓋私有的 registry 可以用這個無腦套件 [verdaccio](https://verdaccio.org/)

```
npm install --global verdaccio
```

不過要記得調整 `config.yaml` 裡面的 `listen` 不然會連不到
他在位置在 `%username%\AppData\Roaming\verdaccio\config.yaml`

```
listen:
- 0.0.0.0:4873              # listen on all addresses (INADDR_ANY)
```
