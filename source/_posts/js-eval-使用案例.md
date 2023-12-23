---
title: js eval 使用案例
date: 2023-11-28 18:30:19
tags: js
---
&nbsp;
<!-- more -->
最近遇到後端用 nestjs 想傳 echarts 的 options 給前端用 , 傳了半天前端的圖表只 work 一半
後來發現傳過去的屬性裡面有 function , 預設不會把 function 傳過去 , 而且傳了也沒用
其實可以在 `JSON.stringify` 加工讓他變成 string 傳過去
```
let option = {
	visualMap: [
		{
			show: false,
			type: 'continuous',
			seriesIndex: 0,
			min: Math.min(...valueArray),
			max: Math.max(...valueArray)
		}
	],
	toolbox: {
		show: true
	},

	tooltip: {
		trigger: 'axis',
		axisPointer: {
			type: 'cross'
		},
		formatter: function (params: any) {
			return `${params[0].name}<br />${params[0].marker}${params[0].data.toFixed(
				2
			)}`
		}
	},

	xAxis: {
		name: 'time',
		type: 'category',
		data: timeArray,
		axisLabel: {
			formatter: function (value: string) {
				console.log('x', value)
				let theDate = new Date(value)
				let formatResult = formatDateWithOutYear(theDate)
				console.log('formatResult', formatResult)
				return formatResult
			}
		}
	},
	yAxis: {
		name: 'value',
		type: 'value',
		axisLabel: {
			formatter: function (value: number) {
				// console.log(Math.max(...valueArray))
				// return value.toFixed(4)
				return value.toFixed(0)
			}
		},
		max: Math.max(...valueArray),
		min: Math.min(...valueArray)
	},
	series: [
		{
			data: valueArray,
			type: 'line',
			smooth: true,
			markPoint: {
				label: {
					//https://echarts.apache.org/zh/option.html#series-line.markPoint.label
					formatter: function (params: any) {
						console.log(params)
						let val = params.data.coord[1].toFixed(2)
						return val.toString()
					}
				},
				data: [
					{ type: 'max', name: 'Max' },
					{ type: 'min', name: 'Min' }
				]
			},
			markLine: {
				data: [{ type: 'average', name: 'Avg' }]
			}
		}
	]
}

let str = JSON.stringify(option, function (key, value) {
	if (typeof value === 'function') {
		return value.toString()
	} else {
		return value
	}
})
console.log(str)
return str
```


然後會長大概這樣
```
{
    "visualMap": [{
            "show": false,
            "type": "continuous",
            "seriesIndex": 0,
            "min": 753.1195596415225,
            "max": 799.2967914834596
        }
    ],
    "toolbox": {
        "show": true
    },
    "tooltip": {
        "trigger": "axis",
        "axisPointer": {
            "type": "cross"
        },
        "formatter": "function (params) {\n return `${params[0].name}
        ${params[0].marker}${params[0].data.toFixed(2)}`;\n }"
    },
    "xAxis": {
        "name": "time",
        "type": "category",
        "data": ["2023-09-30T23:00:00.000Z", "2023-10-01T00:00:00.000Z", "2023-10-01T01:00:00.000Z", "2023-10-01T02:00:00.000Z", "2023-10-01T03:00:00.000Z", "2023-10-01T04:00:00.000Z", "2023-10-01T05:00:00.000Z", "2023-10-01T06:00:00.000Z", "2023-10-01T07:00:00.000Z", "2023-10-01T08:00:00.000Z", "2023-10-01T09:00:00.000Z", "2023-10-01T10:00:00.000Z", "2023-10-01T11:00:00.000Z", "2023-10-01T12:00:00.000Z", "2023-10-01T13:00:00.000Z", "2023-10-01T14:00:00.000Z", "2023-10-01T15:00:00.000Z", "2023-10-01T16:00:00.000Z", "2023-09-30T16:00:00.000Z", "2023-09-30T17:00:00.000Z", "2023-09-30T18:00:00.000Z", "2023-09-30T19:00:00.000Z", "2023-09-30T20:00:00.000Z", "2023-09-30T21:00:00.000Z"],
        "axisLabel": {
            "formatter": "function (value) {\n console.log('x', value);\n let theDate = new Date(value);\n let formatResult = formatDateWithOutYear(theDate);\n console.log('formatResult', formatResult);\n return formatResult;\n }"
        }
    },
    "yAxis": {
        "name": "value",
        "type": "value",
        "axisLabel": {
            "formatter": "function (value) {\n return value.toFixed(0);\n }"
        },
        "max": 799.2967914834596,
        "min": 753.1195596415225
    },
    "series": [{
            "data": [786.2406686892617, 775.351119116916, 799.2967914834596, 790.5960817959443, 783.6805454571232, 758.6840079816668, 790.3245296380129, 765.9456069157624, 796.968419345223, 778.2591762916247, 789.6245539701669, 759.8650377260842, 754.1071947394639, 791.2912269423003, 790.0196448088915, 777.3533484777939, 785.9742945288351, 757.6758327929319, 754.5333806345333, 794.8477019479826, 757.7808310071706, 758.9203808298035, 780.6047889965498, 753.1195596415225],
            "type": "line",
            "smooth": true,
            "markPoint": {
                "label": {
                    "formatter": "function (params) {\n console.log(params);\n let val = params.data.coord[1].toFixed(2);\n return val.toString();\n }"
                },
                "data": [{
                        "type": "max",
                        "name": "Max"
                    }, {
                        "type": "min",
                        "name": "Min"
                    }
                ]
            },
            "markLine": {
                "data": [{
                        "type": "average",
                        "name": "Avg"
                    }
                ]
            }
        }
    ]
}

```


接著用前端的 `JSON.parse` 把 string 然後開頭為 `function` 結尾是 `}` 的用 `eval` 喚醒他 , 就能動了!
難得遇到可以用 `eval` 的情景 XD
雖然不好 , but 要快速交差 demo 也只有先這樣
```
let option = JSON.parse(this.response, function (key, value) {
	if (
		typeof value === 'string' &&
		value.startsWith('function') &&
		value.endsWith('}')
	) {
		console.log(value)
		return eval(`(${value})`)
	}
	return value
})
```
