---
title: vue3 openlayers ts 筆記
date: 2023-11-27 18:19:47
tags:
- vue
---
&nbsp;
<!-- more -->
最近看看 openlayers , 發現好像 vue3 支援度比較友善 , 不然 angular 太殘了 XD
之前做些小東東都用 js , 這次想說玩看看 ts 結果馬上陣亡 XD

### volar
vue3 要搞 ts 的話要先安裝 [Vue Language Features Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
並且還要裝 [TypeScript Vue Plugin Volar](https://marketplace.visualstudio.com/items?itemName=Vue.vscode-typescript-vue-plugin)

然後輸入 `@builtin typescript` 也要 `disable (Workspace)`

可以看參考下這個[影片](https://vueschool.io/lessons/volar-the-official-language-feature-extension-for-vs-code)
或是[這個說明](https://vuejs.org/guide/typescript/overview.html)

可以順便在 `settings.json` 設定讓當輸入 `ref` 以後 `.value` 自動跳
```
"vue.autoInsert.dotValue": true
```

### eslint
先安裝 [eslint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
還有 [Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

增加 `overrides` 那段 , 不然 html 會噴 error

`.eslintrc.cjs`
```
/* eslint-env node */
require('@rushstack/eslint-patch/modern-module-resolution')

module.exports = {
	root: true,
	extends: [
		'plugin:vue/vue3-essential',
		'eslint:recommended',
		'@vue/eslint-config-typescript',
		'@vue/eslint-config-prettier/skip-formatting'
	],
	parserOptions: {
		ecmaVersion: 'latest'
	},
	overrides: [
		{
			files: ['*.html'],
			rules: {
				'vue/comment-directive': 'off'
			}
		}
	]
}


```

設定 `.prettierrc.json`
```
{
    "$schema": "https://json.schemastore.org/prettierrc",
    "semi": false,
    "useTabs": true,
    "tabWidth": 4,
    "singleQuote": true,
    "printWidth": 100,
    "trailingComma": "none"
    "singleAttributePerLine" : true
}
```


開啟 `settings.json` 加入以下設定
```
    "eslint.enable": true,
    "eslint.validate": [
        // "html",
        // "javascript",
        "vue"
    ],
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "[vue]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[html]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
```


### openlayers

```
npm create vue@latest
cd .\demomap-vue\
npm install
npm run format
npm run dev
```

[vue3openlayers](https://vue3openlayers.netlify.app/get-started.html)
[openlayers 文件](https://openlayers.org/en/latest/apidoc/module-ol_View.html)
```
npm install
npm install ol ol-ext ol-contextmenu
npm install vue3-openlayers
npm run dev
```

`MapDemo.vue`
```
<template>
	<ol-map style="height: 400px">
		<ol-view
			ref="view"
			:center="center"
			:rotation="rotation"
			:zoom="zoom"
			:projection="projection"
			@change:center="centerChanged"
			@change:resolution="resolutionChanged"
			@change:rotation="rotationChanged"
		/>

		<ol-tile-layer>
			<ol-source-osm />
		</ol-tile-layer>

		<ol-rotate-control></ol-rotate-control>
	</ol-map>

	<ul>
		<li>center : {{ currentCenter }}</li>
		<li>resolution : {{ currentResolution }}</li>
		<li>zoom : {{ currentZoom }}</li>
		<li>rotation : {{ currentRotation }}</li>
	</ul>
</template>

<script setup lang="ts">
import type { ObjectEvent } from 'ol/Object'
import { ref } from 'vue'

const center = ref([40, 40])
const projection = ref('EPSG:4326')
const zoom = ref(8)
const rotation = ref(0)

const currentCenter = ref(center.value)
const currentZoom = ref(zoom.value)
const currentRotation = ref(rotation.value)
const currentResolution = ref(0)

function resolutionChanged(event: ObjectEvent) {
	currentResolution.value = event.target.getResolution()
	currentZoom.value = event.target.getZoom()
}
function centerChanged(event: ObjectEvent) {
	currentCenter.value = event.target.getCenter()
}
function rotationChanged(event: ObjectEvent) {
	currentRotation.value = event.target.getRotation()
}
</script>
```

`App.vue`
```
<script setup lang="ts">
import MapDemo from './components/MapDemo.vue'
</script>

<template>
	<MapDemo id="map" />
</template>

<style scoped>
#map {
	height: 400px;
}
</style>
```



### vite.config.ts
因為要讓他可以對外 , 所以補下 `server` 那段

```
import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
	plugins: [vue()],
	resolve: {
		alias: {
			'@': fileURLToPath(new URL('./src', import.meta.url))
		}
	},
	server: {
		host: '0.0.0.0',
		port: 4000
	}
})
```
