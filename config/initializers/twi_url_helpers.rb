module InspiredUrlHelpers

  if Rails.env.production?
    SITE_URL = 'https://network.thewellinspired.com'
  else
    SITE_URL = 'http://network.thewellinspired.com.dev'
  end

  def profile_url(arg)
    arg = arg[:id] if arg[:id]
    id = arg.respond_to?(:id) ? arg.id.to_i : arg.to_i
    raise ArgumentError if id.blank?
    "#{SITE_URL}/users/#{id}"
  end
end

ActionView::Base.send(:include, InspiredUrlHelpers)