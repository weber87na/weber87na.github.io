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
  <div class="spell" ></div>
  <div class="ghost" style="display: none;"></div>
  <div class="noise"></div>
  <div class="noise2"></div>


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



</body>
</html>
