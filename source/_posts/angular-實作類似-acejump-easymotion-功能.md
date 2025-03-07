---
title: angular 實作類似 acejump easymotion 功能
date: 2025-01-13 12:54:51
tags: angular
---
&nbsp;
<!-- more -->

最近因為要離職的關係, 才發現離上一篇已經快兩個月, 好久沒更新 blog 了!
想當初是因為長官的知遇之恩才續留, 沒想到最後還是這種結果, 整個心情超難過的 哀~
要是能重來, 去年錄取保哥時就該直接過去, 錯失保哥還真的滿可惜的! 也不會有後續這些遲早引爆的事件發生

離開前把一直想在 `angular` 上面做類似 `acejump` or `easymotion` 的功能給完成下, 不過我覺得用 `slickback` 這個詞更貼切
之前有用純 js 在自己 blog 搞過一把, 這次就獻給 `angular` 說不定這是職涯最後一把用 `angular` 了, 就當最後的致敬吧!

html 的部分大概長這樣, 需要注意的是 span 這個部分
他應該要每一個字使用一個 span, 這樣才可以每敲一個字下去變成紅字, 否則會整坨都紅字

```
<div
	#dtags
	class="slickback-tag"
	[ngStyle]="{display: isFirstCharInCmdArray('d') ? '' : 'none'}">
	<span
	  *ngFor="
		let text of indexToSpan(i, 'd');
		let textIndex = index
	  "
	  [ngStyle]="{
		color: textInCmdArray(
		  indexToSpan(i, 'd').join(''),
		  textIndex
		)
		  ? 'red'
		  : 'black'
	  }"
	  >{{ text }}</span>
</div>
```

css 則是用絕對定位這老朋友即可搞定

```
.slickback-tag {
  position: absolute;
  left: 0;
  top: 0;
  background-color: #89cf07;
  font-weight: bold;
  font-size: 10px;
  color: black;
  padding: 2px;
  border-radius: 2px;
}
```


當使用者敲擊第一個字如果是以下列表時表示會觸發執行跳躍的事件, 將這些字 `push` 進去 `cmdArray` 裡面

`e` => `edit`
`a` => `add`
`d` => `delete`

接著如果命令的字大於一個時則判斷是否敲入 `0123456789`
如果正確的話一樣 `push` 該 `key`, 反之則設定 `cmdArray = []` 清除

`isNeedAnotherKeyTyping` 這個函數則是用來判斷 `a1 ... a10 a11` 這類兩個字開頭一樣的情況, 如果不需要的話就執行跳躍

回頭看到 `防禦式` 的部分, 如果使用者敲 `e1 a1 d1` 這類有可能兩個字相同的部分, 並且明確敲下 Enter 則直接執行

```
//防禦式, 如果需要執行第二個 key 時直接按下 Enter 則直接執行 ex: e1 a1 d1
if (keyPressed === 'Enter' && this.needAnotherKey) {
  if (this.typingTimeout) {
	clearTimeout(this.typingTimeout);
  }
  console.log('needAnotherKey', this.needAnotherKey);

  this.slickbackClick();
  return;
}
```

最後看到 `setTimeout` 時間如果在 2.5 秒內都沒動作的話, 就執行 `slickbackClick` 讓貼在 span 上的按鈕觸發 click 即可

full code


```
cmdArray = new Array<string>();
@ViewChildren('etags')
etags?: QueryList<ElementRef>;

@ViewChildren('atags')
atags?: QueryList<ElementRef>;

@ViewChildren('dtags')
dtags?: QueryList<ElementRef>;

typingTimeout: any;
typingKeyDelayTime = 2500;
needAnotherKey = false;
@HostListener('document:keydown', ['$event'])
onKeyDown(event: KeyboardEvent): void {
  // console.log(`KeyDown: ${event.key}`);

  let keyPressed = event.key;

  //防禦式, 如果需要執行第二個 key 時直接按下 Enter 則直接執行 ex: e1 a1 d1
  if (keyPressed === 'Enter' && this.needAnotherKey) {
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout);
    }
    console.log('needAnotherKey', this.needAnotherKey);

    this.slickbackClick();
    return;
  }


  //正常情況
  if (this.cmdArray.length > 0) {
    if ('0123456789'.includes(keyPressed)) {
      this.cmdArray.push(keyPressed);
    } else {
      //萬一中間按下其他 key 則終止執行動作
      this.cmdArray = [];
    }
  } else {

    if (this.isViewMode) {
      //編輯
      if (keyPressed === 'e') this.cmdArray.push('e');

      if (keyPressed === 'a') this.cmdArray.push('a');

      if (keyPressed === 'd') this.cmdArray.push('d');
    } else {
      //新增
      if (keyPressed === 'a') this.cmdArray.push('a');

      //刪除
      if (keyPressed === 'd') this.cmdArray.push('d');
    }
  }

  this.needAnotherKey = this.isNeedAnotherKeyTyping();
  if (this.needAnotherKey) return;

  if (this.typingTimeout) {
    clearTimeout(this.typingTimeout);
  }

  //3 秒內按下的話就執行 slickback
  this.typingTimeout = setTimeout(() => {
    this.slickbackClick();
  }, this.typingKeyDelayTime);
}

//快捷跳躍
slickbackClick() {
  if (this.cmdArray.length > 1) {
    console.log('於 1 秒按下');
    console.log('exe', this.cmdArray);
    let str = this.cmdArray.join('');
    console.log('str', str);
    let index = parseInt(str.substring(1));

    let arr;

    if (this.isViewMode) {
      if (str[0] === 'e') arr = this.etags?.toArray();
    } else {
      if (str[0] === 'a') arr = this.atags?.toArray();
      if (str[0] === 'd') arr = this.dtags?.toArray();
    }

    if (arr && arr.length > 0 && index < arr.length)
      arr![index].nativeElement.parentElement.click();

    //已經執行命令所以清空
    this.cmdArray = [];
  }
}

//判斷是否需要輸入其他 key, ex:a1 ... a10 a11 這時就需要
isNeedAnotherKeyTyping() {
  if (this.cmdArray.length > 1) {
    console.log('於 1 秒按下');
    console.log('exe', this.cmdArray);
    let str = this.cmdArray.join('');
    console.log('str', str);
    let index = parseInt(str.substring(1));
    let sindex = str.substring(1);

    let arr;

    if (this.isViewMode) {
      if (str[0] === 'e') arr = this.etags?.toArray();
    } else {
      if (str[0] === 'a') arr = this.atags?.toArray();
      if (str[0] === 'd') arr = this.dtags?.toArray();
    }

    if (!arr || arr.length === 0) return false;
    let indexAsStrings = arr?.map((_, index) => index.toString());

    console.log('sindex', sindex);
    let needDelay = indexAsStrings?.some(
      (value) => value.startsWith(sindex) && value !== sindex
    );

    // console.log('indexAsStrings', indexAsStrings);

    // console.log('needDelay', needDelay);

    if (!needDelay) {
      // console.log('arr', arr);
      if (arr && arr?.length > 0 && index < arr.length)
        arr![index].nativeElement.parentElement.click();

      //已經執行命令所以清空
      this.cmdArray = [];
      return false;
    }

    return true;
  }

  return false;
}

//把 index 轉為一個一個的 span
indexToSpan(index: number, key: string) {
  let arr = key + index.toString();
  let result = arr.split('');
  return result;
}

textInCmdArray(arr: string, index: number) {
  if (this.cmdArray.length === 0) return false;

  for (let i = 0; i < index + 1; i++) {
    if (arr[i] !== this.cmdArray[i]) return false;
  }
  return true;
}

isFirstCharInCmdArray(key: string) {
  if (this.cmdArray.length >= 1) {
    if (this.cmdArray[0] === key) return true;
  }

  return false;
}

//global 當點選按鈕時, 取消 slickback
@HostListener('document:click', ['$event'])
onClick(event: MouseEvent) {
  const target = event.target as HTMLElement;
  if (target && target.tagName.toLowerCase() === 'button') {
    // 如果點擊的是按鈕，觸發事件
    console.log('button click cancel slickback cmd');
    this.cmdArray = [];
    this.needAnotherKey = false;
  }
}
```
