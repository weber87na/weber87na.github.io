<!DOCTYPE html>
<html lang="{{ config.language }}">
<head>
  {{ partial('_partials/head/head.swig', {}, {cache: theme.cache.enable}) }}
  {% include '_partials/head/head-unique.swig' %}
  {{- next_inject('head') }}
  <title>{% block title %}{% endblock %}</title>
  {{ partial('_third-party/analytics/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
  <!-- google ad -->
  <!--
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-1069539516107706"
     crossorigin="anonymous"></script>
  -->
</head>

<body itemscope itemtype="http://schema.org/WebPage">
  <!--
  <div class="spell" ></div>
  <div class="ghost" style="display: none;"></div>
  <div class="noise"></div>
  <div class="noise2"></div>
  -->


  <div class="container{%- if theme.motion.enable %} use-motion{%- endif %}">
    <div class="headband"></div>

    <header class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner">{% include '_partials/header/index.swig' %}</div>
    </header>

    {{ partial('_partials/widgets.swig', {}, {cache: theme.cache.enable}) }}

    <main class="main">
      <div class="main-inner">
        <div class="content-wrap">
          {% include '_partials/header/sub-menu.swig' %}
          <div class="content {% block class %}{% endblock %}">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/comments.swig' %}
        </div>
        {%- if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {%- endif %}
      </div>
    </main>

    <footer class="footer">
      <div class="footer-inner">
        {% include '_partials/languages.swig' %}
        {{ partial('_partials/footer.swig', {}, {cache: theme.cache.enable}) }}
        {{ partial('_third-party/statistics/index.swig', {}, {cache: theme.cache.enable}) }}
      </div>
    </footer>
  </div>

  {{ partial('_scripts/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_third-party/index.swig', {}, {cache: theme.cache.enable}) }}

  {%- if theme.pjax %}
    <div id="pjax">
  {%- endif %}
  {% include '_third-party/math/index.swig' %}
  {% include '_third-party/quicklink.swig' %}

  {{- next_inject('bodyEnd') }}
  {%- if theme.pjax %}
    </div>
  {%- endif %}

  <!-- <div class="snow1" style="position:fixed !important"></div> -->
  <div class="cobweb" style="position:fixed !important"></div>
  <div class="spider" style="position:fixed !important"></div>
<div class="fswitch">關閉</div>
<div class="snowflakes" aria-hidden="true">
  <div class="snowflake">
 🌹
  </div>
  <div class="snowflake">
 💩
  </div>
  <div class="snowflake">
 🌹
  </div>
  <div class="snowflake">
 💩
  </div>
    <div class="snowflake">
 🌹
  </div>
  <div class="snowflake">
 💩
  </div>
    <div class="snowflake">
 🌹
  </div>
  <div class="snowflake">
 💩
  </div>
</div>

<!--
<script>
	function toggleSpell() {
		let spell = document.getElementsByClassName('spell')[0];
		let ghost = document.getElementsByClassName('ghost')[0];
		let noise = document.getElementsByClassName('noise')[0];
		let noise2 = document.getElementsByClassName('noise2')[0];
		if (spell.style.display === 'none') {
			spell.style.display = 'block';
			noise.style.display = '';
			noise2.style.display = '';
			ghost.style.display = 'none';
		} else {
			spell.style.display = 'none';
			noise.style.display = 'none';
			noise2.style.display = 'none';
			ghost.style.display = 'block';
		}
	}

	//訂閱內容
	let spell = document.getElementsByClassName('spell')[0];
	let ghost = document.getElementsByClassName('ghost')[0];
	spell.addEventListener('click',toggleSpell);
	ghost.addEventListener('click',toggleSpell);
</script>
-->

<script>

let cobweb = document.querySelector('.cobweb');
let spider = document.querySelector('.spider');
let back = document.querySelector('.back-to-top');
let fswitch = document.querySelector('.fswitch');

document.addEventListener('keydown', function(event) {
	if (event.key === 'f') {
		console.log('press f key');
		ftoggle();
	}
});

fswitch.addEventListener('click' , function(){ 
	ftoggle();
});

function ftoggle(){
	if(cobweb.style.display === ''){
		cobweb.style.display = 'none';
	}else{
		cobweb.style.display = '';
	}
	if(spider.style.display === ''){
		spider.style.display = 'none';
	}else{
		spider.style.display = '';
	}
	if(back.style.display === ''){
		back.style.display = 'none';
	}else{
		back.style.display = '';
	}

	if(fswitch.innerText === '關閉') fswitch.innerText = '乖乖'
	else fswitch.innerText = '關閉'
}



</script>

<script>
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

const viNavigation = new ViNavigation();
viNavigation.init();
</script>



</body>
</html>
