---
title: Entity Framework Core JSON Path 筆記
date: 2023-05-30 23:45:18
tags:
- sql
- c#
---
&nbsp;
<!-- more -->

工作上遇到的實際問題 , 也是老生常談 , 至少遇過 5 次以上
這個例子是個階層選擇 code , 通常會有 2 - 3 階 , 然後給你類似的 view 把資料攤平
假設今天有 `主菜` 然後可以選擇 `口味` 通常 sql 會長下面這樣
```
;with Main as (
	select 'A' Code , N'魚' MName union
	select 'B' , N'牛' union
	select 'C' , N'雞'
) , Flavor as (
	select 'A' Code , 'X01' ChildCode , N'芥末' FName union
	select 'A' Code , 'X02' , N'起司' union
	select 'A' Code , 'X03' , N'日式' union
	select 'B' , 'X01' , N'芥末' union
	select 'B' , 'Y01' , N'川辣' union
	select 'C' , 'X02' , N'麻辣' union
	select 'C' , 'Y01' , N'川辣' union
	select 'C' , 'Z01' , N'菠菜' union
	select 'C' , 'Z02' , N'巧克力'
) , Flat as (
	select M.* , F.ChildCode , F.FName
	from Main M
	join Flavor F
	on M.Code = F.Code
)
select *
from Flat
```

因為要給前端點選 , 所以通常會有個 Active 屬性 , 在後端實際上需要的是一個類似這樣的類別
```
class Main {
	public string Code {get;set;}
	public string MName {get;set;}
	public bool Active {get;set;}
	public List<Flavor> Flavors {get;set}
}

class Flavor {
	public string Code {get;set;}
	public string ChildCode {get;set;}
	public string FName {get;set;}
	public bool Active {get;set;}
}
```

如果不用 JSON PATH 的話 , 這時候你大概會在後端寫一堆 loop 之類的去設定狀態 , 然後把 Flavor 掛在他對應的主餐上
不過 JSON PATH 可以很輕鬆的搞定這件事 , 所以修改稍早的 cte 追加兩個 distinct 去除重複的結果
然後在子查詢塞 for json path 就可以把對應的口味轉為 json array 放進去
```
) , MainDistinct as (
	select distinct Code , MName
	from Flat
) , FlavorDistinct as (
	select distinct Code , ChildCode , FName
	from Flat
)
select * , 0 as Active , (
	select * , 0 as Active 
	from FlavorDistinct FD
	where FD.Code = MD.Code
	for json path
) as Flavors
from MainDistinct MD
```

大概長這樣
```
A	魚	0	[{"Code":"A","ChildCode":"X01","FName":"芥末","Active":0},{"Code":"A","ChildCode":"X02","FName":"起司","Active":0},{"Code":"A","ChildCode":"X03","FName":"日式","Active":0}]
B	牛	0	[{"Code":"B","ChildCode":"X01","FName":"芥末","Active":0},{"Code":"B","ChildCode":"Y01","FName":"川辣","Active":0}]
C	雞	0	[{"Code":"C","ChildCode":"X02","FName":"麻辣","Active":0},{"Code":"C","ChildCode":"Y01","FName":"川辣","Active":0},{"Code":"C","ChildCode":"Z01","FName":"菠菜","Active":0},{"Code":"C","ChildCode":"Z02","FName":"巧克力","Active":0}]
```

最後只要讓最終結果也轉為 json 即可 , 另外預設的欄位名稱會很醜類似這樣 JSON_FFWFW-F1234-1234-2424-AGWE-1232 , 所以要多包子查詢給 alias
```
;with Main as (
	select 'A' Code , N'魚' MName union
	select 'B' , N'牛' union
	select 'C' , N'雞'
) , Flavor as (
	select 'A' Code , 'X01' ChildCode , N'芥末' FName union
	select 'A' Code , 'X02' , N'起司' union
	select 'A' Code , 'X03' , N'日式' union
	select 'B' , 'X01' , N'芥末' union
	select 'B' , 'Y01' , N'川辣' union
	select 'C' , 'X02' , N'麻辣' union
	select 'C' , 'Y01' , N'川辣' union
	select 'C' , 'Z01' , N'菠菜' union
	select 'C' , 'Z02' , N'巧克力'
) , Flat as (
	select M.* , F.ChildCode , F.FName
	from Main M
	join Flavor F
	on M.Code = F.Code
) , MainDistinct as (
	select distinct Code , MName
	from Flat
) , FlavorDistinct as (
	select distinct Code , ChildCode , FName
	from Flat
)
select (
	select * , 0 as Active , (
		select * , 0 as Active 
		from FlavorDistinct FD
		where FD.Code = MD.Code
		for json path
	) as Flavors
	from MainDistinct MD
	for json path
) as Tree
```

接著在 ef core 裡面先定義轉換 boolean 用的類別
https://stackoverflow.com/questions/68682450/automatic-conversion-of-numbers-to-bools-migrating-from-newtonsoft-to-system-t
```
    public class BoolConverter : JsonConverter<bool>
    {
        public override void Write(Utf8JsonWriter writer, bool value, JsonSerializerOptions options) =>
            writer.WriteBooleanValue(value);

        public override bool Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options) =>
            reader.TokenType switch
            {
                JsonTokenType.True => true,
                JsonTokenType.False => false,
                JsonTokenType.String => bool.TryParse(reader.GetString(), out var b) ? b : throw new JsonException(),
                JsonTokenType.Number => reader.TryGetInt64(out long l) ? Convert.ToBoolean(l) : reader.TryGetDouble(out double d) ? Convert.ToBoolean(d) : false,
                _ => throw new JsonException(),
            };
    }
```

然後定義一個 `MyTree` 類別
```
    public class MyTree { 
        public string Tree { get; set; }
    }

```

然後在 `OnModelCreating` 針對 `MyTree` 設定 `HasNoKey`

```
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
	modelBuilder.Entity<MyTree>(entity =>
	{
		entity.HasNoKey();
	});
}
```

最後只要這樣寫 , 就可以輕鬆去把 sql server 傳來的 json string 轉換為你要的類別 , 而且是一顆完好的樹
```
var result = await _dbContext.MyTree.FromSqlRaw(sql).ToListAsync();
var serializeOptions = new JsonSerializerOptions();
serializeOptions.Converters.Add(new BoolConverter());
var tree = JsonSerializer.Deserialize<IEnumerable<Main>>(
	result.FirstOrDefault().Tree,
	serializeOptions
	);

return tree;
```
