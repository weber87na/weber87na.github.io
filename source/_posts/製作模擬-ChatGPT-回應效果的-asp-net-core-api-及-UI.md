---
title: 製作模擬 ChatGPT 回應效果的 asp.net core api 及 UI
date: 2024-06-10 18:02:00
tags: c#
---
&nbsp;
<!-- more -->

上課學到的東東, 順手寫下筆記
依稀記得很多年前做爬蟲的時候無意間有做過類似的效果, 當時不曉得這個叫做 `streaming`
首先 api 的部分要回傳 `IAsyncEnumerable<string>` 然後用 `await Task.Delay` 來控制語速

```c#
[Route("api/[controller]")]
[ApiController]
public class LoremController : ControllerBase
{
    private List<List<string>> textDict = new List<List<string>>() {
        new List<string>() {
                "好啊",
                "歡迎",
                "鳩咪",
        },

        new List<string>() {
                "歸剛ㄟ",
                "社畜",
                "煩不煩",
        },
        new List<string>() {
                "你好",
                "心靜自然涼",
                "長輩語錄",
        },
        new List<string>() {
                "開心每一天",
                "與世無爭",
                "長輩語錄",
        },
    };

    [HttpGet("GetText")]
    public async IAsyncEnumerable<string> GetText(int speed = 2)
    {
        var rnd = new Random();
        var current = rnd.Next(0, textDict.Count);

        foreach (var item in textDict[current])
        {
            await Task.Delay(speed * 100);
            yield return item;
        }
    }
}
```

前端 js 則是可以參考 [mdn](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API/Using_readable_streams)
```js
async function readData(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  while (true) {
    const { done, value } = await reader.read();
    if (done) {
      // Do something with last chunk of data then exit reader
      return;
    }
    // Otherwise do something here to process current chunk
  }
}
```

他這個拿回來實際上會是一個 `uint8array` 還需要經過 `TextDecoder` 處理

```js
const arr = new Uint8Array([104, 101, 108, 108, 111]);
const decoder = new TextDecoder();
const str = decoder.decode(arr);
// => "hello"
```

經過 decode 以後因為是 string array 的關係會變這樣
```
["aaa",
"bbb",
"ccc",
"ddd"]
```

我沒找到更好的方法來解, 發現 老外 也是用 regex 處理, 搭配 GPT 問起來就是這樣

```js
async function getText(url) {
	// 將 URL 替換為你的 API 端點
	const response = await fetch(url);
	const reader = response.body.getReader();

	// 定義一個 async generator function 來處理非同步流
	async function* generateText() {
		while (true) {
			const { done, value } = await reader.read();
			if (done) return;
			yield value;
		}
	}

	// 使用 for await...of 來遍歷非同步迭代器
	for await (const chunk of generateText()) {
		//第一個可以把 [] 替換掉
		//第二個可以把開頭 , 替換掉
		//第三個可以把 "" 替換掉
		const text = new TextDecoder().decode(chunk)
			.replace(/\[|]/g, '')
			.replace(/^,/, '')
			.replace(/^"|"$/g, '');
		
		console.log(text)
	}
}
```

想看完整效果的話可以到我的 codepen 然後把 url 改成你的網址並且開啟 CORS 即可 ~

<p class="codepen" data-height="730" data-default-tab="result" data-slug-hash="qBLVQmJ" data-pen-title="SkypeGPT" data-user="weber87na" style="height: 730px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/qBLVQmJ">
  SkypeGPT</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
