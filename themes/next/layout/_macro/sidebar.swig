{% macro render(display_toc) %}
  <div class="toggle sidebar-toggle">
    <span class="toggle-line toggle-line-first"></span>
    <span class="toggle-line toggle-line-middle"></span>
    <span class="toggle-line toggle-line-last"></span>
  </div>

  <aside class="sidebar">
    <div class="sidebar-inner">

      {%- set display_toc = page.toc.enable and display_toc %}
      {%- if display_toc %}
        {%- set toc = toc(page.content, { class: "nav", list_number: page.toc.number, max_depth: page.toc.max_depth }) %}
        {%- set display_toc = toc.length > 1 and display_toc %}
      {%- endif %}

      <ul class="sidebar-nav motion-element">
        <li class="sidebar-nav-toc">
          {{ __('sidebar.toc') }}
        </li>
        <li class="sidebar-nav-overview">
          {{ __('sidebar.overview') }}
        </li>
      </ul>

      <!--noindex-->
      <div class="post-toc-wrap sidebar-panel">
        {%- if display_toc %}
          <div class="post-toc motion-element">{{ toc }}</div>
        {%- endif %}
      </div>
      <!--/noindex-->

      <div class="site-overview-wrap sidebar-panel">
        {{ partial('_partials/sidebar/site-overview.swig', {}, {cache: theme.cache.enable}) }}

        {{- next_inject('sidebar') }}
      </div>

      {%- if theme.back2top.enable and theme.back2top.sidebar %}
        <div class="back-to-top motion-element">
          <i class="fa fa-arrow-up"></i>
          <span>0%</span>
        </div>
      {%- endif %}

	  <!-- skilltree 廣告 -->
	  <div id="myadblock" style="margin-top:25px;position:relative">
	  <div id="myadblock-title" style="position:absolute;left:-10px;top:-10px;width:100px;background-color:rgba(0,0,0,.75);color:white;">偷放工商</div>
	  <script src="https://skilltree.my/promotion/cec9b4b0-be5e-4727-85c6-f7af5445124a?w=350"></script>
	  </div>

	  <!-- google 廣告 -->
	  <ins class="adsbygoogle"
		  style="display:inline-block;width:220px;height:120px;margin-top:50px;position:relative;border-bottom-left-radius: 15px 255px;border-bottom-right-radius: 225px 15px;border-top-left-radius: 255px 15px;border-top-right-radius: 15px 225px;border: 2px solid #41403e;"
		  data-ad-client="ca-pub-1069539516107706"
		  data-ad-slot="6588270137">
	  <div id="myadblock-title2" style="z-index:999999;position:absolute;left:-10px;top:-10px;width:100px;background-color:rgba(0,0,0,.75);color:white;">偷放工商</div>
	  </ins>
	  <script>
		  (adsbygoogle = window.adsbygoogle || []).push({});
	  </script>

    </div>
  </aside>
  <div id="sidebar-dimmer"></div>
{% endmacro %}
