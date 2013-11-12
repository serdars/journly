 require 'net/http'

class GooglePlace
  def self.suggest(term)
    suggestions = [ ]
    response = nil

    response = self.autocomplete({:input => term})
    response["predictions"].each do |s|
      suggestions << {
        :type => "location",
        :value => s["description"],
        :reference => s["reference"]
      }
    end

    suggestions
  end

  def self.info(reference)
    response = nil

    response = self.place_detail({:reference => reference})
    {
      :name => response['result']['name'],
      :address => response['result']['formatted_address'],
      :url => response['result']['url'],
      :geometry => response['result']['geometry']['location'],
      :phone_number => response['result']['formatted_phone_number']
    }
  end

  #
  # Internal methods
  #
  def self.autocomplete(parameters)
    # Add google api key
    Rails.logger.debug "Google Autocomplete Call with: #{parameters}"

    parameters[:key] = APP_CONFIG[:GOOGLE_PLACES_API_KEY]
    parameters[:sensor] = false

    # Make autocomplete request to GooglePlaces
    uri = URI("https://maps.googleapis.com/maps/api/place/autocomplete/json")
    uri.query = URI.encode_www_form(parameters)

    result, response = self.fetch_rest(uri)

    Rails.logger.debug "GAC Result: #{result}"
    Rails.logger.debug "Response: #{response}"

    response
  end

  def self.place_detail(parameters)
    # Add google api key
    Rails.logger.debug "Google Place Detail Call with: #{parameters}"

    parameters[:key] = APP_CONFIG[:GOOGLE_PLACES_API_KEY]
    parameters[:sensor] = false

    # Make place_detail request to GooglePlaces
    uri = URI("https://maps.googleapis.com/maps/api/place/details/json")
    uri.query = URI.encode_www_form(parameters)

    result, response = self.fetch_rest(uri)

    Rails.logger.debug "GPD Result: #{result}"
    Rails.logger.debug "Response: #{response}"

    response
  end


  def self.fetch_rest(uri)
    if APP_CONFIG[:LOCAL_MODE]
      return 200, fetch_local(uri)
    end

    http_client = Net::HTTP.new(uri.host, uri.port)
    http_client.use_ssl = true if uri.scheme == "https"

    response = http_client.get(uri.request_uri)
    case response
    when Net::HTTPSuccess then
      result = JSON.parse(response.body)
      return response.code.to_i, result
    when Net::HTTPRedirection then
      raise ArgumentError, "HTTP Request Redirected: #{response.value}"
    else
      Rails.logger.error "HTTP REQUEST FAILURE: #{response.body}"
      raise ArgumentError, "HTTP Request Failed: #{response.value}"
    end
  end

  def self.fetch_local(uri)
    if uri.path.include? "autocomplete"
      local_autocomplete
    elsif uri.path.include? "details"
      local_place_detail
    else
      raise "Unknown path '#{uri.path}' to fetch local..."
    end
  end

  def self.local_autocomplete
    {"predictions"=>[{"description"=>"Opscode, Western Avenue, Seattle, WA, United States", "id"=>"ee545b1c665fe07a74be66858c48674b1c95f5e0", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"ClRCAAAAziP8w9xxrsslVXeXyx_wNNBfRMJrN08eN_e4cSG8m3bOH6dq4AaEUVGM0t-zUALBhRuphFocwUkgFDjyteGtUAl1Xc5gy0jT4Km4LTITOwsSEDf5U9x-fDWpqvJGtrkOqxAaFF8xJA1mdYztxY4cCN5cqqRVL9u9", "terms"=>[{"offset"=>0, "value"=>"Opscode"}, {"offset"=>9, "value"=>"Western Avenue"}, {"offset"=>25, "value"=>"Seattle"}, {"offset"=>34, "value"=>"WA"}, {"offset"=>38, "value"=>"United States"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries Ltd, Calgary, AB, Canada", "id"=>"601c7958932fdf49290690215390445c1590c215", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"CkQ_AAAAtaOABRMiH-pCIQA3rKfX1PzRGI9UXVp-SLXQKl6ZRGAvymlRlgNC_mPd6jt6gZbUfJ3kVTxo0zDqjxqzd24bsxIQigEtTbqljiRvwntCdf1q_BoULCz6qPGyGrScK6B2YcoWaJNAuSE", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries Ltd"}, {"offset"=>29, "value"=>"Calgary"}, {"offset"=>38, "value"=>"AB"}, {"offset"=>42, "value"=>"Canada"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries, Canal Street, Pinedale, WY, United States", "id"=>"a580015c84cf4df6d3352734a2170f8fb2655889", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"CmRRAAAAq-0AGj-R_WH9fcF6RfztJ5Fl7LeukzKDcp1AczVoDX7bOJmoqjcj_CJYtGReFs4h691mmoQOLHvUU7hkEe6K6EdY63N69jglUWoMFbjgEkQxgJcBfVfG_QpiWw3TEnb7EhBJKs41ANLS3wQbJo_dhq7fGhRoy3uPgfLXMHt0uzd0OcWmBFT2Og", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries"}, {"offset"=>25, "value"=>"Canal Street"}, {"offset"=>39, "value"=>"Pinedale"}, {"offset"=>49, "value"=>"WY"}, {"offset"=>53, "value"=>"United States"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries, Boulder, WY, United States", "id"=>"0283066d4edda4752ccfb1521446640fd11b6fb4", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"ClRCAAAAGRzCvBYyAd_JOPTpF2YIqeNEdGambAykSXJAZsHDvz2ZLt3pmPW6HdWumRxm92lLdaupxxXTCc1PJLt8ieCGaB1GDyVfwL3lsQ3pJOwjIhESEH6saMT8SK5oCJxvvWPzkZMaFHHIRAug5oebsy1aTbBGMN5mJTcx", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries"}, {"offset"=>25, "value"=>"Boulder"}, {"offset"=>34, "value"=>"WY"}, {"offset"=>38, "value"=>"United States"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries USA, Texas 97, Pleasanton, TX, United States", "id"=>"4e1b97340a8ab3c4f1654290328f16c3fb49b78e", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"CmRTAAAAbW3q6r4i4l57ymERnDhHnS-RfvPfhIGH5QMDAoV4TfDoTU_Ej5veoTWICAPV4dfsoTW_t0SfDQUJJ8bdzmR-4KcqMZACktxgPukVFdqdPXVdzYoTI2FH7m22YY08RlDaEhDL4O_vHh_iqJz_26EbxXqXGhR7bmKLo-E4aHjM8E2ZTEtg4pFnDQ", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries USA"}, {"offset"=>29, "value"=>"Texas 97"}, {"offset"=>39, "value"=>"Pleasanton"}, {"offset"=>51, "value"=>"TX"}, {"offset"=>55, "value"=>"United States"}], "types"=>["establishment"]}], "status"=>"OK"}
  end

  def self.local_place_detail
{"debug_info"=>[], "html_attributions"=>[], "result"=>{"address_components"=>[{"long_name"=>"1008", "short_name"=>"1008", "types"=>["street_number"]}, {"long_name"=>"Western Avenue", "short_name"=>"Western Avenue", "types"=>["route"]}, {"long_name"=>"Seattle", "short_name"=>"Seattle", "types"=>["locality", "political"]}, {"long_name"=>"King", "short_name"=>"King", "types"=>["administrative_area_level_2", "political"]}, {"long_name"=>"WA", "short_name"=>"WA", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"US", "short_name"=>"US", "types"=>["country", "political"]}, {"long_name"=>"98104", "short_name"=>"98104", "types"=>["postal_code"]}], "formatted_address"=>"1008 Western Avenue #600, Seattle, WA, United States", "formatted_phone_number"=>"(206) 508-4799", "geometry"=>{"location"=>{"lat"=>47.604658, "lng"=>-122.33759}}, "icon"=>"http://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png", "id"=>"ee545b1c665fe07a74be66858c48674b1c95f5e0", "international_phone_number"=>"+1 206-508-4799", "name"=>"Opscode", "photos"=>[{"height"=>818, "html_attributions"=>["<a href=\"https://plus.google.com/107720175715710094444\">Jason McDonald</a>"], "photo_reference"=>"CoQBdwAAAFMrz1Dre-Kn9w-Msm0B2G8VX4gg8FE0ERa4VfrBCAqzJS8puIpZRuIr7_LCLYDw_bPmNemEBI-7r93SP7q6-6TryxGF7J3VivZJ6eQ-YBkg7V4pOL7s0hK9-efaRhM9k1P7aoRTa5tLFv-t5moFRiRL0A1kziJOQ5qyXyq7FzXCEhBhah2R5EzJPVat-vUYP383GhQf3_Ax4pmz2whoag6S5egatuJ-sg", "width"=>600}], "reference"=>"CnRhAAAA-Ek2t-T_Xgi6MmZqBfcj1otE9Q_NZb3GbP0HkFOtq2XXxeoXr-3GlHsnVHLn6bCiRPQTEMk5eVSOwhnspJNjKZXs2C15EyYHBLcuVhTHbj8-fTQOPuHsuDQIEspt_RZRzvDKcAPzXVcWDqCvzTtLgBIQ4doyizsPV18f3Yyl6-AW4hoUbs5zFMq8lZ8trbSSt76q8ifCxzI", "types"=>["establishment"], "url"=>"https://plus.google.com/115609223567096118613/about?hl=en-US", "utc_offset"=>-480, "vicinity"=>"1008 Western Avenue #600, Seattle", "website"=>"http://www.opscode.com/"}, "status"=>"OK"}
  end
end
