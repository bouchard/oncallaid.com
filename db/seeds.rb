start_time = Time.now

u1 = User.where(:email => 'brady@thewellinspired.com').first_or_create!(:username => 'brady')

PaperTrail.whodunnit = u1.id

require 'nokogiri'

xml_files = Dir.glob(File.join(Rails.root,'db','seeds','*.xml'))

xml_files.each do |xml|

  doc = Nokogiri::XML(File.new(xml))

  total = doc.css('chapters chapter').count
  puts "===== PROCESSING CHAPTERS (#{total}) =====\n"

  doc.css('chapters chapter').each do |chapter|
    c = Chapter.new(
      :title => chapter.at_css('title').try(:content).strip.gsub("\n",'\n').gsub('\n',"\n")
    )
    c.save!
    total = chapter.css('articles article').count
    puts "===== PROCESSING ARTICLES (#{total}) =====\n"
    chapter.css('articles article').each do |article|
      a = c.articles.new(
        :title => article.at_css('title').try(:content).strip.gsub("\n",'\n').gsub('\n',"\n"),
        :body => (article.at_css('body').try(:content) || '').strip.gsub("\n",'\n').gsub('\n',"\n")
      )
      a.save!
    end
  end
  puts "Done."

end

Rails.cache.clear

puts "\n\nDone! Took #{(Time.now - start_time).seconds} seconds.\n\n"