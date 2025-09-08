---
title: socket server 開發筆記
date: 2025-06-21 20:36:07
tags: c#
---

&nbsp;
<!-- more -->

最近幫朋友開發 socket server 來接收 IOT 設備的資料, 以前比較少碰觸這麼底層, 順便筆記下

### 接收資料函數
猜測 client 應該是 c 語言之類寫的, 所以傳來資料型態為 byte array 裡面存的則是 hex 16 進位, 並且還有 checksum 才能把資料解出來
還好有 chatgpt 可以快速搞定這些常用的功能 XD

```
    public byte[] HexStringToByteArray(string hex)
    {
        int numberChars = hex.Length;
        byte[] bytes = new byte[numberChars / 2];
        for (int i = 0; i < numberChars; i += 2)
        {
            bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);
        }
        return bytes;
    }

    public float HexToFloat(string hex)
    {
        if (hex.Length != 8)
            throw new ArgumentException("Hex 字串長度必須為 8（32-bit）");

        // 1. 將 hex 轉為 byte[]
        byte[] bytes = Enumerable.Range(0, hex.Length / 2)
            .Select(i => Convert.ToByte(hex.Substring(i * 2, 2), 16))
            .ToArray();

        // 2. 注意:IEEE 754 是小端序 (little-endian)，要 reverse（依實際情況決定）
        if (BitConverter.IsLittleEndian)
            Array.Reverse(bytes);

        // 3. 轉成 float
        return BitConverter.ToSingle(bytes, 0);
    }

    public short HexStringToShort(string hex)
    {
        if (string.IsNullOrWhiteSpace(hex))
            throw new ArgumentException("輸入字串不可為空");

        hex = hex.Replace(" ", "");

        if (hex.Length != 4)
            throw new ArgumentException("輸入字串長度必須是 4 (2 bytes)");

        byte[] bytes = new byte[2];
        for (int i = 0; i < 2; i++)
        {
            bytes[i] = Convert.ToByte(hex.Substring(i * 2, 2), 16);
        }

        if (BitConverter.IsLittleEndian)
            Array.Reverse(bytes);

        return BitConverter.ToInt16(bytes, 0);
    }


    public byte HexStringToByte(string hex)
    {
        if (string.IsNullOrWhiteSpace(hex))
            throw new ArgumentException("輸入字串不可為空");

        hex = hex.Replace(" ", "");

        if (hex.Length != 2)
            throw new ArgumentException("輸入字串長度必須是 2 (1 byte)");

        return Convert.ToByte(hex, 16);
    }

    public byte CalculateChecksum(string hexString)
    {
        // Remove any spaces just in case
        hexString = hexString.Replace(" ", "");

        int sum = 0;
        for (int i = 0; i < hexString.Length; i += 2)
        {
            string byteStr = hexString.Substring(i, 2);
            byte value = Convert.ToByte(byteStr, 16);
            sum += value;
        }

        // Return only the lowest 8 bits
        return (byte)(sum % 256);
    }

```

### port 監測
如果有 client 連上來的話就會出現一個以上的訊息, 否則只會出現 0.0.0.0
```
Get-NetTCPConnection -LocalPort 5987

LocalAddress                        LocalPort RemoteAddress                       RemotePort State       AppliedSetting OwningProcess
------------                        --------- -------------                       ---------- -----       -------------- -------------
10.1.2.3                            5987      123.45.67.89                        12345      Established Datacenter     7916
0.0.0.0                             5987      0.0.0.0                             0          Listen                     7916
```

### windows service
socket server 通常會需要在背景跑, 所以要辛苦寫 windows service, 不過也可以用偷懶的方法, 直接靠 [nssm](https://nssm.cc/) 把 console 變成 windows service 即可
用法可以參考[保哥](https://blog.miniasp.com/post/2021/09/15/Useful-tools-the-Non-Sucking-Service-Manager)

另外有可能會想要看到即時的 log, 所以可以在 Serilog 加上一個 `NamedPipeServerStream` 的 `PipeSink`, 每當 server 有印出東西來時就可以送給想要接收的即時 log 的 winform or wpf 之類的程式
可以在 chrome 打上這個網址 `file://.//pipe//` 就可以瀏覽到很多程式也是用 `NamedPipeServerStream` 這種方式來做程式之間的溝通
```
public static class NamedPipeSinkExtensions
{
    public static LoggerConfiguration NamedPipe(
        this LoggerSinkConfiguration loggerConfiguration,
        string pipeName = "LogPipe",
        ITextFormatter? textFormatter = null) // 改成 ITextFormatter
    {
        return loggerConfiguration.Sink(new NamedPipeSink(pipeName, textFormatter));
    }
}


public class NamedPipeSink : ILogEventSink
{
    private readonly string _pipeName;
    private readonly ITextFormatter _textFormatter;
    private NamedPipeServerStream? _client;
    private StreamWriter? _writer;

    public NamedPipeSink(string pipeName, ITextFormatter? textFormatter = null)
    {
        _pipeName = pipeName;
        _textFormatter = textFormatter ?? new MessageTemplateTextFormatter(
            "[{Timestamp:yyyy-MM-dd HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}", null);

        Task.Run(ListenForClient); // background task
    }

    public void Emit(LogEvent logEvent)
    {
        if (_client == null || !_client.IsConnected || _writer == null)
            return;

        try
        {
            _textFormatter.Format(logEvent, _writer);
            _writer.WriteLine(); // 保證 log 換行
        }
        catch (IOException)
        {
            // 客戶端中斷或寫入錯誤
            _client.Dispose();
            _client = null;
            _writer = null;
        }
    }

    private async Task ListenForClient()
    {
        while (true)
        {
            _client = new NamedPipeServerStream(
                _pipeName,
                PipeDirection.InOut,
                1, //永遠只有 1 個 client
                PipeTransmissionMode.Byte,
                PipeOptions.Asynchronous);

            await _client.WaitForConnectionAsync();

            _writer = new StreamWriter(_client, leaveOpen: true) { AutoFlush = true };
            var reader = new StreamReader(_client);

            try
            {
                while (_client.IsConnected)
                {
                    string? line = await reader.ReadLineAsync();
                    if (line == null) break;

                    Log.Information($"收到 Manager Client 訊息: {line}");

                    // 回應 client（可選）
                    //await _writer.WriteLineAsync("Server 收到: " + line);
                }
            }
            catch (IOException ex)
            {
                Log.Warning("Manager Client Pipe 發生錯誤: " + ex.Message);
            }
            finally
            {
                _client.Dispose();
                _client = null;
                _writer = null;
            }
        }
    }
}


```

然後這樣設定 serilog

```
Log.Logger = new LoggerConfiguration()
	.ReadFrom.Configuration(configuration)
	.Enrich.FromLogContext()
	.WriteTo.NamedPipe("YourLogPipe")
	.CreateLogger();
```

這裡有個很容易暴雷的低能問題, 就是 appsettings.json 已經設定了, 但又多補上 Console 跟 File 然後導致輸出兩次 log -. -

```
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("Logs/log-.txt", rollingInterval: RollingInterval.Day)
	.WriteTo.NamedPipe("YourLogPipe")
    .CreateLogger();

```



### websocket
因為希望能在 web 發送命令給 client, 所以可以用 websocket 來當作 proxy 發給 socket server, server 會再轉發給 client 設備

```
app.Use(async (context, next) =>
{
    if (context.Request.Path == "/ws")
    {
        if (context.WebSockets.IsWebSocketRequest)
        {
            using var webSocket = await context.WebSockets.AcceptWebSocketAsync();
            using var tcpClient = new TcpClient(ip, port); // 每個 Client 一條 TCP 連線
            using var tcpStream = tcpClient.GetStream();

            string guid = Guid.NewGuid().ToString();
            byte[] guidBytes = Encoding.UTF8.GetBytes(guid);
            await tcpStream.WriteAsync(guidBytes, 0, guidBytes.Length);

            var cts = new CancellationTokenSource();

            var receiveFromWebSocket = Task.Run(async () =>
            {
                var buffer = new byte[1024];
                while (!cts.Token.IsCancellationRequested)
                {
                    try
                    {
                        var result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), cts.Token);
                        if (result.MessageType == WebSocketMessageType.Close)
                        {
                            cts.Cancel();
                            break;
                        }

                        string message = Encoding.UTF8.GetString(buffer, 0, result.Count);
                        byte[] data = Encoding.UTF8.GetBytes(message);
                        await tcpStream.WriteAsync(data, 0, data.Length, cts.Token);
                    }
                    catch
                    {
                        cts.Cancel();
                    }
                }
            });

            var receiveFromTcp = Task.Run(async () =>
            {
                var buffer = new byte[1024];
                while (!cts.Token.IsCancellationRequested)
                {
                    try
                    {
                        int bytesRead = await tcpStream.ReadAsync(buffer, 0, buffer.Length, cts.Token);
                        if (bytesRead == 0)
                        {
                            cts.Cancel();
                            break;
                        }

                        string response = Encoding.UTF8.GetString(buffer, 0, bytesRead);
                        await webSocket.SendAsync(
                            new ArraySegment<byte>(Encoding.UTF8.GetBytes(response)),
                            WebSocketMessageType.Text,
                            true,
                            cts.Token);
                    }
                    catch
                    {
                        cts.Cancel();
                    }
                }
            });

            await Task.WhenAny(receiveFromWebSocket, receiveFromTcp);
            cts.Cancel(); // 雙向斷開
        }
        else
        {
            context.Response.StatusCode = 400;
        }
    }
    else
    {
        await next();
    }
});

```

前端則需要設定 wss,並實作自己需要的 `onopen` `onclose` `onerror` 等功能即可, 其他就問 gpt 大概就無腦使用

```
const socket = new WebSocket("wss://localhost:1234/ws");
```
