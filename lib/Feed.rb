require 'rss/2.0'

class Feed
  def self.parse_feed (url, regExp)
    feed_url = url
    myArray = Array.new
    
    open(feed_url) do |http|
      response = http.read
      result = RSS::Parser.parse(response, false)
      result.items.each do |item|
        myArray += item.title.split(regExp)
      end
    end

    myArray
  end
end