require 'oauth'

class Yelp
  def self.info(business_id)
    biz_info = self.get_business_info(business_id)

    {
      :element_type => "yelp",
      :name => biz_info["name"],
      :rating => biz_info["rating"],
      :review_count => biz_info["review_count"],
      :url => biz_info["url"],
      :phone => biz_info["display_phone"],
      :rating_img_url => biz_info["rating_img_url"]
    }
  end

  def self.get_business_info(business_id)
    local_mode = false
    if local_mode
      return self.fetch_local_business_info
    end

    consumer_key = ENV["YELP_CONSUMER_KEY"]
    consumer_secret = ENV["YELP_CONSUMER_SECRET"]
    token = ENV["YELP_TOKEN"]
    token_secret = ENV["YELP_TOKEN_SECRET"]

    api_host = 'api.yelp.com'
    path = "http://api.yelp.com/v2/business/#{business_id}"

    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)

    answer = access_token.get(path)
    Rails.logger.debug "Yelp API call result: #{answer.code_type}"

    response = JSON.parse(answer.body)
    Rails.logger.debug "Yelp API call response: #{response}"

    response
  end

  def self.fetch_local_business_info
    {
      "is_claimed"=>false, "rating"=>4.0, "mobile_url"=>"http://m.yelp.com/biz/uptown-nails-issaquah", "rating_img_url"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/c2f3dd9799a5/ico/stars/v1/stars_4.png", "review_count"=>47, "name"=>"Uptown Nails", "snippet_image_url"=>"http://s3-media4.ak.yelpcdn.com/photo/7G6fkFiCYu79aIO8Wd_oSQ/ms.jpg", "rating_img_url_small"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/f62a5be2f902/ico/stars/v1/stars_small_4.png", "url"=>"http://www.yelp.com/biz/uptown-nails-issaquah", "reviews"=>[{"rating"=>2, "excerpt"=>"**This is for a waxing review.**\n\nOut of desperation I went here for a brow wax. I have sensitive skin, it is true, so when I saw a very stale and crusted...", "time_created"=>1383967943, "rating_image_url"=>"http://s3-media2.ak.yelpcdn.com/assets/2/www/img/b561c24f8341/ico/stars/v1/stars_2.png", "rating_image_small_url"=>"http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a6210baec261/ico/stars/v1/stars_small_2.png", "user"=>{"image_url"=>"http://s3-media4.ak.yelpcdn.com/photo/cMJWEI0pYI9wi58Bk5aJFA/ms.jpg", "id"=>"ZJofh3rrsXQYnz35CYOYSg", "name"=>"Tanya J."}, "rating_image_large_url"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/c00926ee5dcb/ico/stars/v1/stars_large_2.png", "id"=>"KD-KpF3lqNF7NlSl6VDuTA"}, {"rating"=>4, "excerpt"=>"This place is great. They're always busy, so it's hard to be a walk in, but whatever, make an appointment! I walked in on Father's Day and it being a Sunday...", "time_created"=>1372315428, "rating_image_url"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/c2f3dd9799a5/ico/stars/v1/stars_4.png", "rating_image_small_url"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/f62a5be2f902/ico/stars/v1/stars_small_4.png", "user"=>{"image_url"=>"http://s3-media4.ak.yelpcdn.com/photo/7G6fkFiCYu79aIO8Wd_oSQ/ms.jpg", "id"=>"ehCW9jTA3H4dOXrp8ZIpyw", "name"=>"Amanda T."}, "rating_image_large_url"=>"http://s3-media2.ak.yelpcdn.com/assets/2/www/img/ccf2b76faa2c/ico/stars/v1/stars_large_4.png", "id"=>"pmoNbuBL-EbDkr1vMKvY1Q"}, {"rating"=>4, "excerpt"=>"My mom in law and I made an appointment. We got there and there were 3 employees working on 3 customers, but it looked like they were finishing up. We got...", "time_created"=>1370438945, "rating_image_url"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/c2f3dd9799a5/ico/stars/v1/stars_4.png", "rating_image_small_url"=>"http://s3-media4.ak.yelpcdn.com/assets/2/www/img/f62a5be2f902/ico/stars/v1/stars_small_4.png", "user"=>{"image_url"=>"http://s3-media3.ak.yelpcdn.com/photo/wbIWcOAVj7AKatD64LxfaQ/ms.jpg", "id"=>"FGokZSEVPDrCHQGWFkei9A", "name"=>"Marina T."}, "rating_image_large_url"=>"http://s3-media2.ak.yelpcdn.com/assets/2/www/img/ccf2b76faa2c/ico/stars/v1/stars_large_4.png", "id"=>"pFEGCT5VftWeEFJLhMrVZw"}], "phone"=>"4253928363", "snippet_text"=>"This place is great. They're always busy, so it's hard to be a walk in, but whatever, make an appointment! I walked in on Father's Day and it being a Sunday...", "image_url"=>"http://s3-media1.ak.yelpcdn.com/bphoto/gNjQQlx5GJOnfRcLRke84g/ms.jpg", "categories"=>[["Nail Salons", "othersalons"]], "display_phone"=>"+1-425-392-8363", "rating_img_url_large"=>"http://s3-media2.ak.yelpcdn.com/assets/2/www/img/ccf2b76faa2c/ico/stars/v1/stars_large_4.png", "id"=>"uptown-nails-issaquah", "is_closed"=>false, "location"=>{"cross_streets"=>"N 3rd Ave & Bike Path", "city"=>"Issaquah", "display_address"=>["375 NW Gilman Blvd", "(b/t N 3rd Ave & Bike Path)", "Issaquah, WA 98027"], "postal_code"=>"98027", "country_code"=>"US", "address"=>["375 NW Gilman Blvd"], "state_code"=>"WA"}}
  end
end
