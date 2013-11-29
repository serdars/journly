require 'uri'

class Bookmark
  def self.test
    test_data = ["http://www.yelp.com/biz/odd-fellows-building-san-francisco?sort_by=useful_desc",
                 "http://www.yelp.com/biz/odd-fellows-building-san-francisco",
                 "http://www.yelp.com/user_details?userid=8htH0KByrQ9nGXWCs2AN-Q",
                 "www.yelp.com/biz/odd-fellows-building-san-francisco?sort_by=useful_desc",
                 "yelp.com/biz/odd-fellows-building-san-francisco",
                 "www.google.com"]

    test_data.each do |test|
      puts self.info(test)
    end
  end

  def self.info(url)
    info = [ ]
    yelp_biz_id = self.extract_yelp_biz_id(url)
    if yelp_biz_id
      return Yelp.info(yelp_biz_id)
    end

    title = self.get_title_from_url(url)
    info << {
      :element_type => "title",
      :name => title
    } if title

    info
  end

  # Extract Yelp info from the url
  def self.extract_yelp_biz_id(url)
    business_id = nil
    uri = URI(url)

    if uri.host == "www.yelp.com"
      parameters = uri.path.split("/")

      # parameters[0] is equal to ""
      if parameters[1] == "biz"
        if parameters[2]
          if !parameters[2].include?("?")
            business_id = parameters[2]
          else
            # TODO: if the url is like yelp.com/biz/? this would fail.
            business_id = parameters[2].split("?")[0]
          end
        end
      end
    end

    business_id
  end

  def self.get_title_from_url(url)
    title = nil

    begin
      source = Net::HTTP.get(URI(url))
    rescue Exception => e
      Rails.logger.error "Can not get information from #{url}. Error: #{e.inspect}"
      return title
    end

    if source
      title_match = source.match(/<title>(.*)<\/title>/)
      if title_match
        title_match[1]
      else
        nil
      end
    end

    nil
  end

end
