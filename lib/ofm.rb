# OnCallAid-Flavoured Markdown
# Ideas from Github-Flavoured Markdown, with modifications.
# Using RedCarpet to process.

module OCAMarkdown

  def self.included(klass)
    klass.try(:helper_method, :markdown)
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    # include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::UrlHelper
  end

  def markdown(*args)

    options = args.extract_options!
    options[:allowed_tags] ||= %w(abbr sub sup)
    text = args.first || ''
    md_options = {
      :autolink => true,
      :space_after_headers => true,
      :no_intra_emphasis => true,
      :tables => true,
      :strikethrough => true
    }
    renderer_options = {
      :safe_links_only => true
    }

    @_markdown ||= Redcarpet::Markdown.new(MarkdownRenderer.new(renderer_options), md_options)
    @_preprocessor = Preprocessor.new
    text = @_markdown.render(@_preprocessor.process(text, options)).html_safe

  end

  class Preprocessor

    def process(*args)
      preprocess_text(*args)
    end

    private

    def preprocess_text(text, options = {})

      # Swap out arrows.
      text.gsub!(/[-<>]*/) do |x|
        x = x.sub(/<-+>/, '&#8596;').sub(/-+>/, '&#8594;').sub(/<-+/, '&#8592;')
      end

      # Process references.
      references = []
      text.gsub!(/<ref>(.+?)<\/ref>/) do |x|
        references << $1
        x = %|<sup class="ref">#{references.length}</sup>|
      end
      references = references.each_with_index.map{ |r, i| "#{i + 1}. #{r}" }.join("\n")

      unless text.match("\n\# References") || references.length == 0
        text = text.strip + "\n\n\# References"
      end
      text.gsub!("\n\# References") do |x|
        x += "\n\n#{references}\n"
      end

      # Allow the use of angle brackets that clearly are not meant to be HTML tags.
      # We determine that using these rules:
      # 1. if either start or end bracket is next to anything but a single or double quote, forward slash, or an alpha character.
      # 2. We also allow closing brackets next to newlines or spaces, as we can have blockquotes for Markdown either nested or on a newline by themselves.
      text.gsub!(/<([^[[:alpha:]]"'\/])/, '&lt;\1')
      text.gsub!(/([^[[:alpha:]]"'\n\s])>/, '\1&gt;')

      # We can't sanitize anymore. The Rails 4.2 helper takes out our single angle brackets, which we otherwise want to keep...
      # text = help.sanitize(text, :tags => options[:allowed_tags])

      # Process internal links.
      text.gsub!(/\[\[.+?\]\]/) do |x|
        slug = x.gsub(/[\[\]]/,'')
        title, slug = slug.split('|') if slug.match(/\|/)
        if a = Article.where(:slug => slug.parameterize).first
          x = help.link_to(title || slug, url.slug_path(:slug => a.slug, :chapter_slug => a.chapter.slug))
        else
          x = help.link_to(title || slug, url.new_article_path(:title => slug), :class => 'non-existent')
        end
      end

      # Fixes for Windows linebreaks.
      text.gsub!(/\r\n?/, "\n")

      # in very clear cases, let newlines become <br> tags.
      text.gsub!(/^[\w\<][^\n]*\n+/) do |x|
        x =~ /\n{2}/ ? x : (x.strip!; x << "  \n")
      end

      # Swap out increased/decreased.
      text.gsub!(/increased|decreased/i) do |x|
        x = x.sub(/increased/i,'<i class="icon-arrow-up"></i>').sub(/decreased/i,'<i class="icon-arrow-down"></i>')
      end

      text
    end

    def help
      ::OCAMarkdown::Helper.instance
    end

    def url
      OnCallAid::Application.routes.url_helpers
    end


  end

  class MarkdownRenderer < Redcarpet::Render::SmartyHTML
    def autolink(l, link_type)
      if l.match(/^https?:\/\//)
        link(l, '', l)
      elsif l.match(/^mailto:\/\//)
          %|<a href="#{l}">#{l.gsub('mailto:','')}</a>|
      end
    end

    def link(l, title, content)
      if l.match(/^https?:\/\//)
        %|<a href="#{l}" title="#{title}">#{content} <i class="icon-external-link"></i></a>|
      elsif l.match(/\.(jpg|png|gif)$/)
        %|<a href="#{l}" title="#{title}">#{content} <i class="icon-image"></i></a>|
      # else
      #   %|<a href="#{l}" title="#{title}">#{content}</a>|
      end
    end
  end

end