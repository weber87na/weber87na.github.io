---
title: js 土炮自己的 chrome vim
date: 2024-06-12 18:17:53
tags: js
---

![img](https://github.com/weber87na/RespectVimium/blob/main/RespectVimium.gif?raw=true)

<!-- more -->

自己用 vim 來 coding 不知不覺也有幾年的時間了, 在 chrome 上通常都用這個套件 [vimium](https://chromewebstore.google.com/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?pli=1)
可是其他人電腦不見得有裝, 導致每次要在別人電腦 debug 又剛好要找自己 blog 資料時總是少了點 fu ~
今天就來自己致敬下 vim, 大致上分為兩部分, 普通移動跟 easymotion
後來發現有些網站 bug bug 的 XD 有空再修
因為放 codepen 怪小怪小的, 難得要放 [github repo](https://github.com/weber87na/RespectVimium)

### 普通移動
普通移動相當簡單, 只需要呼叫 `window.scrollTo` 這個函數就可以搞定
可以設定下 `behavior` 讓移動起來比較絲滑
這裡如果是在 youtube 上面會發生 `document.body.scrollHeight` 為零的詭異狀況
所以要用 `Math.max` 讓取回最大的數值才會正確

```js
viGoTop(keyPressed) {
  if (keyPressed === "g") {
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
}

viGoBottom(keyPressed) {
  if (keyPressed === "G") {
    console.log("document.body.scrollHeight", document.body.scrollHeight);
    let h = Math.max(
      Math.max(
        document.body.scrollHeight,
        document.documentElement.scrollHeight
      ),
      Math.max(
        document.body.offsetHeight,
        document.documentElement.offsetHeight
      ),
      Math.max(
        document.body.clientHeight,
        document.documentElement.clientHeight
      )
    );
    window.scrollTo({ top: h, behavior: "smooth" });
  }
}



viFastDown(keyPressed) {
  if (keyPressed === "d") {
    this.move(350);
  }
}

viDown(keyPressed) {
  if (keyPressed === "j") {
    this.move(100);
  }
}

viFastUp(keyPressed) {
  if (keyPressed === "u") {
    this.move(-350);
  }
}

viUp(keyPressed) {
  if (keyPressed === "k") {
    this.move(-100);
  }
}

move(val) {
  var currentPosition =
    window.pageYOffset || document.documentElement.scrollTop;
  window.scrollTo({
    top: currentPosition + val,
    behavior: "smooth",
  });
}
```

`gg` 比較特別要按兩下, 所以可以在事件裡面撰寫以下 code

```
if (
  keyPressed === this.lastKeyPressed &&
  currentTime - this.lastKeyPressTime < 300
) {
  this.viGoTop(keyPressed);
}
```

最後因為包成物件, 所以要 `bind(this)` 才能正確呼叫函數

```js
init() {
	document.addEventListener("keydown", this.handleKeyDown.bind(this));
}
```

### Easymotion

`Easymotion` 比較複雜, 他先用 `ABCEILNOPQRSTVWXYZ` 排除掉 `jkgdu` 等特殊字防止出錯
接著將 `ABCEILNOPQRSTVWXYZ` 進行雙重迴圈配對出兩個字的組合, 大概快 `400` 個, 超過就放生 XD
`holdTags` 這個變數則是保存目前塞進去的配對 `tag`

```js
//可使用移動的字碼
//共 18 個字 排除 vi 會用到的字
this.tagChars = "ABCEILNOPQRSTVWXYZ";
// this.tagChars = "abc";

//目前的 vim 標示字標籤 array
this.holdTags = new Array();

//預先建立兩字組合的字典
this.dict = new Array();
//雙層迴圈灌入所有兩字組合
for (var i = 0; i < this.tagChars.length; i++) {
  for (var j = 0; j < this.tagChars.length; j++) {
    this.dict.push(this.tagChars[i] + this.tagChars[j]);
  }
}
```

接著看到核心的 `createViTags`, 當進入 `motion` 模式時, 這裡因為 `f` 這個 `key` 有 `保哥條款`, 所以改用 `F` , 需要找到所有 `a` 標籤
接著跑個迴圈, 當 `a` 標籤少於 `ABCEILNOPQRSTVWXYZ` 的話直接放一個 `char`, 反之就從 `dict` 找出兩個 `char` 來放
另外 `getBoundingClientRect` 這個函數撈出來的值, 還需要加上卷軸數值 `window.scrollY window.scrollX` 才會對

```js
createViTag(text, href, top, left) {
  let newDiv = document.createElement("div");
  newDiv.classList.add("vim-tag");
  newDiv.style.fontFamily = "Arial, sans-serif";
  newDiv.style.fontSize = "12px";
  newDiv.style.position = "absolute";
  newDiv.style.backgroundColor = "#89CF07";
  newDiv.style.color = "black";
  newDiv.style.padding = "2px";
  newDiv.style.borderRadius = "2px";
  newDiv.style.zIndex = "999999";

  newDiv.textContent = text;
  newDiv.dataset.href = href;
  newDiv.style.top = top;
  newDiv.style.left = left;
  return newDiv;
}

createViTags() {
  let allTags = document.querySelectorAll("a");
  let counter = 0;
  for (let tag of allTags) {
    let rect = tag.getBoundingClientRect();
    let href = tag.href;
    //這個距離需要加入卷軸距離才會正確
    let top = window.scrollY + rect.top + "px";
    let left = window.scrollX + rect.left + "px";
    let text = "";
    if (allTags.length <= this.tagChars.length) {
      text = this.tagChars[counter];
      this.holdTags.push(text);
    } else {
      text = this.dict[counter];
      this.holdTags.push(text);
    }
    let newDiv = this.createViTag(text, href, top, left);
    document.body.appendChild(newDiv);
    counter++;
  }
}
```

再來是判斷是否一個 char, 若是的話很簡單的讓 `window.location.href = tag.dataset.href` 即可
這裡要注意到由於 `ABCEILNOPQRSTVWXYZ` 為大寫所以要呼叫 `toLowerCase`

```js
if (
  this.currentMode === this.Mode.Motion &&
  document.querySelectorAll("a").length <= this.tagChars.length &&
  this.tagChars.toLowerCase().includes(keyPressed)
) {
  console.log("one char mode");
  let allTags = document.querySelectorAll(".vim-tag");

  allTags.forEach(function (tag) {
	if (tag.textContent.toLowerCase() === keyPressed) {
	  window.location.href = tag.dataset.href;
	}
  });

  this.toggleNormal();
  return;
}
```

接著是 `兩個 char` 的狀況, 如果 `lastKeyPressed` 為空字串的話, 表示敲入第一個字
此時利用 `firstCharArray` 判斷是否開頭有符合我們 `array` 保存的第一個字
當有符合的話, 將第一個字以外的內容排除, 並且讓第一個字變成紅色

若 `lastKeyPressed` 有東西的話, 則表示已經輸入一個字, 所以判斷第二個字是否正確, ok 的話就跳到該 `href` 的網址上

```js
//當 motion 兩個字才走這個模式
if (
  this.currentMode === this.Mode.Motion &&
  document.querySelectorAll("a").length > this.tagChars.length
) {
  console.log("motion lastKeyPressed", this.lastKeyPressed);
  console.log("motion current", keyPressed);

  if (!this.lastKeyPressed) {
    //如果出現字表以外的字則回到 normal
    //console.log("firstCharArray", this.firstCharArray());
    if (this.firstCharArray().includes(keyPressed) === false) {
      this.toggleNormal();
      return;
    } else {
      let allTags = document.querySelectorAll(".vim-tag");
      allTags.forEach(function (tag) {
        if (tag.textContent[0].toLowerCase() !== keyPressed) {
          tag.parentNode.removeChild(tag);
        }

        //將第一個字變為紅色
        if (tag.textContent[0].toLowerCase() === keyPressed) {
          tag.innerHTML =
            '<span style="color: red;">' +
            tag.textContent.charAt(0) +
            "</span>" +
            tag.textContent.substring(1);
        }
      });
    }
  }

  //如果有字的話才執行
  if (this.lastKeyPressed) {
    let chars = this.lastKeyPressed + keyPressed;
    console.log("chars", chars);
    let allTags = document.querySelectorAll(".vim-tag");
    allTags.forEach(function (tag) {
      if (tag.textContent.toLowerCase() === chars) {
        window.location.href = tag.dataset.href;
      }
    });
    //萬一沒找到切回 Normal
    this.toggleNormal();
    return;
  }
}
```

### fullcode

```
class ViNavigation {
  constructor() {
    this.Mode = {
      Normal: "normal",
      Motion: "motion",
    };

    this.lastKeyPressTime = 0;
    this.lastKeyPressed = "";
    this.currentMode = this.Mode.Normal;

    //可使用移動的字碼
    //共 18 個字 排除 vi 會用到的字
    this.tagChars = "ABCEILNOPQRSTVWXYZ";

    //目前的 vim 標示字標籤 array
    this.holdTags = new Array();

    //預先建立兩字組合的字典
    this.dict = new Array();
    //雙層迴圈灌入所有兩字組合
    for (var i = 0; i < this.tagChars.length; i++) {
      for (var j = 0; j < this.tagChars.length; j++) {
        this.dict.push(this.tagChars[i] + this.tagChars[j]);
      }
    }
  }

  viGoTop(keyPressed) {
    if (keyPressed === "g") {
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  }

  viGoBottom(keyPressed) {
    if (keyPressed === "G") {
      console.log("document.body.scrollHeight", document.body.scrollHeight);
      let h = Math.max(
        Math.max(
          document.body.scrollHeight,
          document.documentElement.scrollHeight
        ),
        Math.max(
          document.body.offsetHeight,
          document.documentElement.offsetHeight
        ),
        Math.max(
          document.body.clientHeight,
          document.documentElement.clientHeight
        )
      );
      window.scrollTo({ top: h, behavior: "smooth" });
    }
  }

  viFastDown(keyPressed) {
    if (keyPressed === "d") {
      this.move(350);
    }
  }

  viDown(keyPressed) {
    if (keyPressed === "j") {
      this.move(100);
    }
  }

  viFastUp(keyPressed) {
    if (keyPressed === "u") {
      this.move(-350);
    }
  }

  viUp(keyPressed) {
    if (keyPressed === "k") {
      this.move(-100);
    }
  }

  move(val) {
    var currentPosition =
      window.pageYOffset || document.documentElement.scrollTop;
    window.scrollTo({
      top: currentPosition + val,
      behavior: "smooth",
    });
  }

  removeViTags() {
    let allTags = document.querySelectorAll(".vim-tag");
    allTags.forEach(function (tag) {
      tag.parentNode.removeChild(tag);
    });
  }

  createViTag(text, href, top, left) {
    let newDiv = document.createElement("div");
    newDiv.classList.add("vim-tag");
    newDiv.style.fontFamily = "Arial, sans-serif";
    newDiv.style.fontSize = "12px";
    newDiv.style.position = "absolute";
    newDiv.style.backgroundColor = "#89CF07";
    newDiv.style.color = "black";
    newDiv.style.padding = "2px";
    newDiv.style.borderRadius = "2px";
    newDiv.style.zIndex = "999999";

    newDiv.textContent = text;
    newDiv.dataset.href = href;
    newDiv.style.top = top;
    newDiv.style.left = left;
    return newDiv;
  }

  createViTags() {
    let allTags = document.querySelectorAll("a");
    let counter = 0;
    for (let tag of allTags) {
      let rect = tag.getBoundingClientRect();
      let href = tag.href;
      //這個距離需要加入卷軸距離才會正確
      let top = window.scrollY + rect.top + "px";
      let left = window.scrollX + rect.left + "px";
      let text = "";
      if (allTags.length <= this.tagChars.length) {
        text = this.tagChars[counter];
        this.holdTags.push(text);
      } else {
        text = this.dict[counter];
        this.holdTags.push(text);
      }
      let newDiv = this.createViTag(text, href, top, left);
      document.body.appendChild(newDiv);
      counter++;
    }
  }

  //找出目前的首字 array
  firstCharArray() {
    let result = [];
    for (let i = 0; i < this.holdTags.length; i++) {
      let text = this.holdTags[i];
      if (text) {
        let theChar = text[0].toLowerCase();
        if (result.includes(theChar) === false) {
          result.push(theChar);
        }
      }
    }

    return result;
  }

  toggleMotion() {
    this.currentMode = this.Mode.Motion;
    this.lastKeyPressed = "";
    console.log("mode", this.currentMode);
    this.createViTags();
  }

  toggleNormal() {
    this.currentMode = this.Mode.Normal;
    console.log("mode", this.currentMode);
    this.removeViTags();
    this.holdTags = [];
    this.lastKeyPressed = "";
  }

  handleKeyDown(event) {
    let currentTime = new Date().getTime();
    let keyPressed = event.key;

    //按下 F 時進入 motion 模式
    if (this.currentMode === this.Mode.Normal && keyPressed === "F") {
      this.toggleMotion();
      return;
    }

    //按下 esc 跳離 motion 模式回到 normal 模式
    if (this.currentMode === this.Mode.Motion && keyPressed === "Escape") {
      this.toggleNormal();
      return;
    }

    //當 motion 一個字時才走這模式
    if (
      this.currentMode === this.Mode.Motion &&
      document.querySelectorAll("a").length <= this.tagChars.length &&
      this.tagChars.toLowerCase().includes(keyPressed)
    ) {
      console.log("one char mode");
      let allTags = document.querySelectorAll(".vim-tag");

      allTags.forEach(function (tag) {
        if (tag.textContent.toLowerCase() === keyPressed) {
          window.location.href = tag.dataset.href;
        }
      });

      this.toggleNormal();
      return;
    }

    //當 motion 兩個字才走這個模式
    if (
      this.currentMode === this.Mode.Motion &&
      document.querySelectorAll("a").length > this.tagChars.length
    ) {
      console.log("motion lastKeyPressed", this.lastKeyPressed);
      console.log("motion current", keyPressed);

      if (!this.lastKeyPressed) {
        //如果出現字表以外的字則回到 normal
        //console.log("firstCharArray", this.firstCharArray());
        if (this.firstCharArray().includes(keyPressed) === false) {
          this.toggleNormal();
          return;
        } else {
          let allTags = document.querySelectorAll(".vim-tag");
          allTags.forEach(function (tag) {
            if (tag.textContent[0].toLowerCase() !== keyPressed) {
              tag.parentNode.removeChild(tag);
            }

            //將第一個字變為紅色
            if (tag.textContent[0].toLowerCase() === keyPressed) {
              tag.innerHTML =
                '<span style="color: red;">' +
                tag.textContent.charAt(0) +
                "</span>" +
                tag.textContent.substring(1);
            }
          });
        }
      }

      //如果有字的話才執行
      if (this.lastKeyPressed) {
        let chars = this.lastKeyPressed + keyPressed;
        console.log("chars", chars);
        let allTags = document.querySelectorAll(".vim-tag");
        allTags.forEach(function (tag) {
          if (tag.textContent.toLowerCase() === chars) {
            window.location.href = tag.dataset.href;
          }
        });
        //萬一沒找到切回 Normal
        this.toggleNormal();
        return;
      }
    }

    // 任何模式按兩下的區域
    if (
      keyPressed === this.lastKeyPressed &&
      currentTime - this.lastKeyPressTime < 300
    ) {
      this.viGoTop(keyPressed);
    }

    // 按一下的區域
    this.viGoBottom(keyPressed);
    this.viDown(keyPressed);
    this.viFastDown(keyPressed);
    this.viUp(keyPressed);
    this.viFastUp(keyPressed);

    this.lastKeyPressTime = currentTime;
    this.lastKeyPressed = keyPressed;
  }

  init() {
    document.addEventListener("keydown", this.handleKeyDown.bind(this));
  }
}
```
