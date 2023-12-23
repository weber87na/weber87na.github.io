---
title: asp.net core 發佈 m3u8
date: 2020-07-05 08:58:07
tags:
- asp.net core
- c#
- video
---
&nbsp;
<!-- more -->

有個賣迷片的朋友影片一直無法發佈影片,佛心幫忙看看.

### 發佈 m3u8
開個 .net core 的 mvc 專案
修改 Startup.cs 的 Configure
預設 .ts 檔會吃到 typescript 所以將它移除
並且加上 .m3u8 , .key , .ts 相對應的 mime 型別
```csharp
var provider = new FileExtensionContentTypeProvider();
provider.Mappings.Remove(".ts");
provider.Mappings.Add(".key", "text/plain");
provider.Mappings.Add(".m3u8", "application/x-mpegURL");
provider.Mappings.Add(".ts", "video/MP2T");

app.UseStaticFiles(new StaticFileOptions
{
	ContentTypeProvider = provider
});
```

由於切割 .ts 檔案並且製作加密需要符合 Aes-128 加密演算法 , 之前用 openssl 產生不曉得是否因為是在 windows 上 , 造成有的 key 無法使用 , 故手動用 .net 自己刻 Aes-128? 好吧偷懶[參考大神比較快](https://www.cnblogs.com/xyz0835/p/5775850.html)

建立一個KeyController的ApiController
``` c#
[Route("api/[controller]")]
[ApiController]
public class KeyController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        var str = Aes128Helper.AesEncrypt("你要加密的內容");
        return Content(str, "text/plain" );
    }
}

```

接著新增一個 key.enc 的文字檔把從API取得的值寫進去
接著用 openssl 產生 VI 亂數
```bash
$ openssl rand -hex 16
```

接著新增 enc.keyinfo 的文字檔加入以下內容
```
http://localhost:5000/api/key
enc.key
631a942d1e82f749467743256fcecaaa
```
631a942d1e82f749467743256fcecaaa => VI 亂數

將剛剛做好的 enc.key 跟 enc.keyinfo 丟到 ffmpeg 要執行的目錄下 like this:
```
enc.key
enc.keyinfo
ffplay.exe
ffmpeg.exe
```
接著執行以下命令
```
$ ffmpeg -y  -i yourvideo.mp4 -hls_time 12 -hls_key_info_file enc.keyinfo -hls_playlist_type vod -hls_segment_filename "file%d.ts" playlist.m3u8
```
都搞定以後會產生 playlist.m3u8 跟一堆 fileXX.ts
```
playlist.m3u8
file0.ts
file1.ts
file2.ts
file3.ts
```
回到 mvc 的專案在 wwwroot 底下建立一個 videos 的資料夾將剛剛產生的 .ts playlist.m3u8 都丟到裡面 , 怕 enc.key enc.keyinfo 最好也一起丟進去 , 特別注意在 mvc 專案中 .ts 代表是 typescript 所以先把 .ts 全部選起來 Exclude From Project 否則會造成專案錯誤編譯失敗!

最後在 View/Home/Index.cshtml 補上以下程式碼大概就可以動了!
```
@{
    ViewData["Title"] = "Home Page";
}

<div class="text-center">
    <h1 class="display-4">Welcome</h1>
    <p>Learn about <a href="https://docs.microsoft.com/aspnet/core">building Web apps with ASP.NET Core</a>.</p>
</div>


<video id="video" class="" style="width:100%;height:500px;" controls src=""></video>


@section scripts{
    <script>
        var video = document.getElementById('video');
        //var videoSrc = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
        var videoSrc = 'http://localhost:5000/videos/playlist.m3u8';
        if (Hls.isSupported()) {
            var hls = new Hls();
            hls.loadSource(videoSrc);
            hls.attachMedia(video);
            hls.on(Hls.Events.MANIFEST_PARSED, function () {
                //video.play();
            });
        }
    </script>
}
```

### 上字幕
這是後來遇到的 , 因為謎片都是沒字幕的 , 朋友想加上字幕又懶得花錢 , 所以只好找了免費仔的方法 [`pyTranscriber`](https://github.com/raryelcostasouza/pyTranscriber/releases/tag/v1.5-stable)
基本上只要下載以後選擇要的檔案就是無腦用 google api 去產生字幕 , 不過翻譯出來還是需要有人去校正 , 還是滿方便低 ~

另外如果想要把字幕燒在影片上的話可以用 ffmpeg 然後用 powershell 執行像是這樣就可以搞定 , [參考這篇](https://stackoverflow.com/questions/8672809/use-ffmpeg-to-add-text-subtitles)
``` powershell
.\ffmpeg.exe -i "40cm 黑人大戰金剛.mp4" -vf subtitles="40cm 黑人大戰金剛.srt" "40cm 黑人大戰金剛.mp4"
```
[`順帶一提剪片子`](https://stackoverflow.com/questions/18444194/cutting-the-videos-based-on-start-and-end-time-using-ffmpeg)
這邊有個雷包參數 `-t` 跟 `-to` 如果用 `-t` 的話指的是剪幾秒 , 而 `-to` 則是剪到那個位置
假設我下面是用 `-t` 的話會剪從剪 `00:30:00` 開始然後往後加上 40 分鐘 , 還好這個速度很快 , 不然做迷片的朋友又要欲哭無淚 ~
```
./ffmpeg -i "40cm 黑人大戰金剛.mp4" -ss 00:30:00 -to 00:40:00 -async 1 -c copy cut.mp4
```

所以如果我想從 `00:30:00` 開始剪到 `00:40:00` 這十分鐘的最後精華片段應該這樣下才對 ~
```
./ffmpeg -i "40cm 黑人大戰金剛.mp4" -ss 00:30:00 -to 00:40:00 -async 1 -c copy cut.mp4
```
