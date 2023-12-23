---
title: 以 JSchema 對 JObject 進行容錯驗證
date: 2023-02-19 20:38:49
tags: csharp
---
&nbsp;
<!-- more -->

### 日常操作
工作上遇到的問題 , 花了點時間研究 , 我有一包 legacy 的 code , 他的 api post 傳進來 `JObject` 這個該死的弱類型物件 , 然後他會呼叫 `ToObject` 轉換為類似這樣的物件
這個物件裡面又有巢狀的 `JObject` , 每次傳進來的巢狀子物件又有不同屬性
``` c#
class MyArgs{
	public int Num {get;set;}
	public string Color {get;set;}
	public JObject Data {get;set;}
}
```

然後他的驗證就是一一驗證各個子屬性 , 如果少個屬性丟 Exception 上去 , 覺得不太好維護 , 複雜度有點高
由於 api 已經用好陣子 , 前端又有串 js 的網站 , 考量到容錯率 , 希望可以讓參數以 `string` 傳進來的也可以過關 , 特別研究看看有無法子 , 問了 chatgpt 也是答非所問
不過從 chatgpt 給的解答裡面發現一個關鍵方向 , 就是 `JSchemaType` 是 `enum` 可以用 `|` 運算子來進行組合 , 所以我腦洞大開 , 就得到以下方法搞定收工
可以看到就算傳進 `string` 給 `Age` or `Money` 一樣也可以通過驗證

``` c#
JSchemaGenerator generator = new JSchemaGenerator();
JSchema schema = generator.Generate(typeof(Person));
foreach (var item in schema.Properties)
{
    if(item.Value.Type != JSchemaType.String)
        item.Value.Type = item.Value.Type | JSchemaType.String;
}

Console.WriteLine(schema);

JObject j = new JObject();
j["Age"] = "18";
j["Name"] = "Haha";
j["Money"] = "199";

bool isValid = JToken.FromObject(j).IsValid(schema);

//true
Console.WriteLine(isValid);




public class Person
{
    public string Name { get; set; }
    public int Age { get; set; }
	public double Money {get;set;}
}
```

後來發現如果你跟我一樣遇到巢狀 `JObject` 的話 , 他產的 type 會長這樣 `{}`
就算你傳 null 進去也不會觸發驗證
所以要手動去設定才會有辦法驗證 , 設定完長這樣 `{ "type" : "object" }`
請參以下 code
``` c#
//假設 Key 為 data 也就是子物件時設定 object 給他
//否則預設是 "data" : {} 裡面沒 type
//設定後變這樣 "data" : { "type" : "object" }
if( item.Key == "data" )
	item.Value.Type = JSchemaType.Object;
```

### License
後來發現 JSchema 會噴 license 問題 , 到他官網發現其實有免費仔 [open source](https://github.com/JamesNK/Newtonsoft.Json.Schema/releases) 版本
每小時可以 validation 1000 次 呼叫 (IncrementAndCheckValidationCount)
每小時可以 generation 10 次 呼叫 (IncrementAndCheckGenerationCount)
我主要需要測試 generation , 因為太多物件開發上 10 次有點不夠用 , 所以研究看看有無法子開發時暫時超過 10 次
```
Newtonsoft.Json.Schema.JSchemaException: The free-quota limit of 10 schema generations per hour has been reached. Please visit http://www.newtonsoft.com/jsonschema to upgrade to a commercial license.
   at Newtonsoft.Json.Schema.Infrastructure.Licensing.LicenseHelpers.IncrementAndCheckGenerationCount()
   at Newtonsoft.Json.Schema.Generation.JSchemaGenerator.Generate(Type type, Boolean rootSchemaNullable)
   at Newtonsoft.Json.Schema.Generation.JSchemaGenerator.Generate(Type type)
```

就順便爬看看原始碼 , 發現他有個 `LicenseHelpers` 類別裡面控制有無註冊 license , 存取級別為 `internal` 自己平常沒再用 `internal` , 所以爬[大神](https://blog.poychang.net/c-sharp-unit-testing-with-internal-access-modifier/)文複習下
使用 `internal` 的話就只能讓這個 project 看到 function , 其他引用專案則無法
又發現他單元測試裡面也可以訪問 `LicenseHelpers` 原來他有在專案加上 `AssemblyInfo` 然後開放讓測試專案可以呼叫 `internal`
``` csharp
[assembly: InternalsVisibleTo("Newtonsoft.Json.Schema.Tests")]
```

接著發現他在 `JSchemaGenerator` 裡面 `Generate` 會呼叫這個函數 `LicenseHelpers.IncrementAndCheckGenerationCount`
``` csharp
public virtual JSchema Generate(Type type, bool rootSchemaNullable)
{
	ValidationUtils.ArgumentNotNull(type, nameof(type));

	LicenseHelpers.IncrementAndCheckGenerationCount();

	Required required = rootSchemaNullable ? Required.AllowNull : Required.Always;

	JSchemaGeneratorInternal generator = new JSchemaGeneratorInternal(this);
	return generator.Generate(type, required);
}
```

而 `Validator` 裡面會呼叫 `ValidateCurrentToken`
``` csharp
public void ValidateCurrentToken(JsonToken token, object? value, int depth)
{
	if (depth == 0)
	{
		// Handle validating multiple content
		RemoveCompletedScopes();
	}

	if (_scopes.Count == 0)
	{
		if (Schema == null)
		{
			throw new JSchemaException("No schema has been set for the validator.");
		}

		if (!_hasValidatedLicense)
		{
			LicenseHelpers.IncrementAndCheckValidationCount();
			_hasValidatedLicense = true;
		}

		SchemaScope.CreateTokenScope(token, Schema, _context, null, depth);
	}

	if (TokenWriter != null)
	{
		// JTokenReader can return JsonToken.String with a null value which WriteToken doesn't like.
		// Hacky - change token to JsonToken.Null. Can be removed when fixed Newtonsoft.Json is public.
		JsonToken fixedToken = (token == JsonToken.String && value == null) ? JsonToken.Null : token;

		TokenWriter.WriteToken(fixedToken, value);
	}

	for (int i = _scopes.Count - 1; i >= 0; i--)
	{
		Scope scope = _scopes[i];

		if (!scope.Complete)
		{
			scope.EvaluateToken(token, value, depth);
		}
		else
		{
			_scopes.RemoveAt(i);
			_scopesCache.Add(scope);
		}
	}

	if (TokenWriter != null && (TokenWriter.WriteState == WriteState.Start || TokenWriter.WriteState == WriteState.Closed))
	{
		TokenWriter = null;
	}
}
```

然後又爬到 `ExtensionsTests` 類別有個 `GenerateSchemaAndSerializeFromType` 呼叫到 `LicenseHelpers.ResetCounts(null)`
```
private void GenerateSchemaAndSerializeFromType<T>(T value)
{
	LicenseHelpers.ResetCounts(null);

	JSchemaGenerator generator = new JSchemaGenerator();
	generator.SchemaIdGenerationHandling = SchemaIdGenerationHandling.AssemblyQualifiedName;
	JSchema typeSchema = generator.Generate(typeof(T));
	string schema = typeSchema.ToString();

	string json = JsonConvert.SerializeObject(value, Formatting.Indented);
	JToken token = JToken.ReadFrom(new JsonTextReader(new StringReader(json)));

	List<string> errors = new List<string>();

	token.Validate(typeSchema, (sender, args) => { errors.Add(args.Message); });

	if (errors.Count > 0)
	{
		Assert.Fail("Schema generated for type '{0}' is not valid." + Environment.NewLine + string.Join(Environment.NewLine, errors.ToArray()), typeof(T));
	}
}
```

所以 `LicenseHelpers.ResetCounts(null)` 這個其實就是關鍵所在 , 它裡面有兩個變數 `_validationCount` `_generationCount` 控制驗證次數
```
internal static void ResetCounts(object state)
{
	lock (Lock)
	{
		_validationCount = 0;
		_generationCount = 0;
	}
}
```


接著我用 `Reflection` 來測試看看怎麼呼叫 `LicenseHelpers.ResetCounts` 並且印出 `_validationCount` `_generationCount`
本來我是用 `AppDomain.CurrentDomain.GetAssemblies` 來載入 `Newtonsoft.Json.Schema` 後來發現會噴 null , 因為是底層判斷有用到時才載入元件
後來我又 try 以下這段 , 東西是 load 進來了可是他的 context 好像不同 , 所以沒辦法正常觸發 `ResetCounts`
```
List<Assembly> assemblies = new List<Assembly>();
string path = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

foreach (string dll in Directory.GetFiles(path, "*.dll"))
	assemblies.Add(Assembly.LoadFile(dll));

var assembly = assemblies.FirstOrDefault(x => x.GetName().Name == "Newtonsoft.Json.Schema");
```

最後查了下應該是要使用 `Assembly.Load("Newtonsoft.Json.Schema")` 測法大致如下

``` csharp
    var assembly = Assembly.Load("Newtonsoft.Json.Schema");
    var licenseHelpers = assembly.GetType("Newtonsoft.Json.Schema.Infrastructure.Licensing.LicenseHelpers");

    FieldInfo generationCount = licenseHelpers.GetField("_generationCount", BindingFlags.NonPublic | BindingFlags.Static);
    object generationCountVal = generationCount.GetValue(null);
    Console.WriteLine("before gen:" + generationCountVal);

    FieldInfo validationCount = licenseHelpers.GetField("_validationCount", BindingFlags.NonPublic | BindingFlags.Static);
    object validationCountVal = validationCount.GetValue(null);
    Console.WriteLine("before valid:" + validationCountVal);

    JObject input = new JObject();
    input["XXX"] = "";
    input["OOO"] = 1;
	
    for (int i = 0; i < 200; i++)
    {
		JSchemaGenerator generator = new JSchemaGenerator();
		JSchema schema = generator.Generate(typeof(YourObject));
		IList<string> errorMessages = new List<string>();
		bool isValid = JToken.FromObject(json).IsValid(schema, out errorMessages);

        generationCount = licenseHelpers.GetField("_generationCount", BindingFlags.NonPublic | BindingFlags.Static);
        generationCountVal = generationCount.GetValue(null);
        Console.WriteLine("after gen:" + generationCountVal);

        validationCount = licenseHelpers.GetField("_validationCount", BindingFlags.NonPublic | BindingFlags.Static);
        validationCountVal = validationCount.GetValue(null);
        Console.WriteLine("after valid:" + validationCountVal);
    }
	
    //呼叫 reset
    MethodInfo minfo = licenseHelpers.GetMethod("ResetCounts", BindingFlags.Static | BindingFlags.NonPublic);
    minfo.Invoke(null, new object[] { 0 });


    generationCount = licenseHelpers.GetField("_generationCount", BindingFlags.NonPublic | BindingFlags.Static);
    generationCountVal = generationCount.GetValue(null);
    Console.WriteLine("reset gen:" + generationCountVal);

    validationCount = licenseHelpers.GetField("_validationCount", BindingFlags.NonPublic | BindingFlags.Static);
    validationCountVal = validationCount.GetValue(null);
    Console.WriteLine("reset valid:" + validationCountVal);


```
