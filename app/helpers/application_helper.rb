module ApplicationHelper

  def page_title(title = nil)
    title ||= @article && @article.title
    title.blank? ? "OnCallAid" : "#{title} &mdash; OnCallAid".html_safe
  end

  def google(ua_code = 'UA-3289741-36')
    raw(%Q[<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');ga('create', '#{ua_code}', 'auto');ga('send', 'pageview');</script>])
  end

end
