---
title: js 排序筆記
date: 2024-08-11 01:30:40
tags: js
---

&nbsp;
<!-- more -->

最近看到排序, 順手紀錄下, 以前上課印象中就是白板寫一些概念, 也沒給你真的 code 就沒了… 鬼才搞得起來 XD

## 氣泡排序

老朋友了, 唯一特別就是用 es6 [arr[i], arr[j]] = [arr[j], arr[i]] 可以取得交換的值

```js
function bubbleSort(arr) {
	for (let j = 0; j < arr.length - 1; j++) {
		for (let i = j + 1; i < arr.length ; i++) {
			if (arr[j] > arr[i]) [arr[i], arr[j]] = [arr[j], arr[i]]
		}
	}
	return arr
}

let res = bubbleSort([5, 4, 1, 26, 99, 78, 33, 2])
console.log(res)
```

## 選擇排序

選擇排序還算好理解, 就是把最小的丟到最前面, 與第一個尚未排序元素交換, 然後進行下一輪找最小的

```js
function selectionSort(arr) {
	for (let j = 0; j < arr.length; j++) {
		let minIndex = j
		//找到最小值
		for (let i = j; i < arr.length; i++) {
			if (arr[minIndex] > arr[i]) {
				minIndex = i
			}
		}
		//跟最左邊的值互換
		[arr[j], arr[minIndex]] = [arr[minIndex], arr[j]]
	}

	return arr
}

let res = selectionSort([5, 1, 3, 2, 7, 4])
console.log(res)
```


## 插入排序

課程的邏輯我自己覺得有點難懂, 我用我自己的方式去實作, 不過這樣不曉得還算不算是插入排序?

```js
function insertionSort(arr) {
	for (let i = 1; i < arr.length; i++) {
		let rightIndex = i
		let leftIndex = i - 1
		while (leftIndex >= 0 && arr[rightIndex] < arr[leftIndex]) {
			[arr[rightIndex], arr[leftIndex]] = [arr[leftIndex], arr[rightIndex]]
			leftIndex--
			rightIndex--
		}
	}

	return arr
}
```

課程

```js
function insertionSort(arr) {
	for (let j = 1; j <= arr.length - 1; j++) {
		let key = arr[j];
		i = j - 1;
		while (i >= 0 && arr[i] > key) {
			arr[i + 1] = arr[i];
			i -= 1;
		}
		arr[i + 1] = key;

		// console.log(arr);
	}

	// console.log(arr);
	return arr;
}
```

## merge sort

```js
function merge(arr1, arr2) {
    let result = [];

    let leftIndex = 0;
    let rightIndex = 0;
    while (leftIndex < arr1.length && rightIndex < arr2.length) {
        if (arr1[leftIndex] < arr2[rightIndex]) {
            result.push(arr1[leftIndex]);
            leftIndex++;
        } else {
            result.push(arr2[rightIndex]);
            rightIndex++;
        }
    }
    while (leftIndex < arr1.length) {
        // console.log('leftIndex', leftIndex);
        result.push(arr1[leftIndex]);
        leftIndex++;
    }
    while (rightIndex < arr2.length) {
        // console.log('rightIndex', rightIndex);
        result.push(arr2[rightIndex]);
        rightIndex++;
    }

    return result;
}

function mergeSort(arr) {
    if (arr.length === 0 || arr.length === 1)
        return arr;

    let midIndex = Math.floor(arr.length / 2);
    let left = [];
    let right = [];

    for (let i = 0; i < midIndex; i++) {
        let leftValue = arr[i];
        left.push(leftValue);
    }

    for (let i = midIndex; i < arr.length; i++) {
        let rightValue = arr[i];
        right.push(rightValue);
    }

    console.log('left', left);
    console.log('right', right);

    console.log('----------------------');
    let result = merge(mergeSort(left), mergeSort(right));

    return result;
}

let ans = mergeSort([33, 1, 99]);
console.log(ans);
```
