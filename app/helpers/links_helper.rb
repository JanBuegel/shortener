module LinksHelper
  def short_url_for(link)
    "#{request.base_url}/#{link.short_token}"
  end
end
