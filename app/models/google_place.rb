require 'net/http'

class GooglePlace
  def self.suggest(term)
    suggestions = [ ]
    response = nil
    local_mode = false
    
    if local_mode
      response = self.local_autocomplete
    else
      response = self.autocomplete({:input => term})
    end
    response["predictions"].each do |s|
      suggestions << {
        :type => "location",
        :value => s["description"]
      }
    end

    suggestions
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

  def self.fetch_rest(uri)
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

  def self.local_autocomplete
    {"predictions"=>[{"description"=>"Opscode, Western Avenue, Seattle, WA, United States", "id"=>"ee545b1c665fe07a74be66858c48674b1c95f5e0", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"ClRCAAAAziP8w9xxrsslVXeXyx_wNNBfRMJrN08eN_e4cSG8m3bOH6dq4AaEUVGM0t-zUALBhRuphFocwUkgFDjyteGtUAl1Xc5gy0jT4Km4LTITOwsSEDf5U9x-fDWpqvJGtrkOqxAaFF8xJA1mdYztxY4cCN5cqqRVL9u9", "terms"=>[{"offset"=>0, "value"=>"Opscode"}, {"offset"=>9, "value"=>"Western Avenue"}, {"offset"=>25, "value"=>"Seattle"}, {"offset"=>34, "value"=>"WA"}, {"offset"=>38, "value"=>"United States"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries Ltd, Calgary, AB, Canada", "id"=>"601c7958932fdf49290690215390445c1590c215", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"CkQ_AAAAtaOABRMiH-pCIQA3rKfX1PzRGI9UXVp-SLXQKl6ZRGAvymlRlgNC_mPd6jt6gZbUfJ3kVTxo0zDqjxqzd24bsxIQigEtTbqljiRvwntCdf1q_BoULCz6qPGyGrScK6B2YcoWaJNAuSE", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries Ltd"}, {"offset"=>29, "value"=>"Calgary"}, {"offset"=>38, "value"=>"AB"}, {"offset"=>42, "value"=>"Canada"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries, Canal Street, Pinedale, WY, United States", "id"=>"a580015c84cf4df6d3352734a2170f8fb2655889", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"CmRRAAAAq-0AGj-R_WH9fcF6RfztJ5Fl7LeukzKDcp1AczVoDX7bOJmoqjcj_CJYtGReFs4h691mmoQOLHvUU7hkEe6K6EdY63N69jglUWoMFbjgEkQxgJcBfVfG_QpiWw3TEnb7EhBJKs41ANLS3wQbJo_dhq7fGhRoy3uPgfLXMHt0uzd0OcWmBFT2Og", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries"}, {"offset"=>25, "value"=>"Canal Street"}, {"offset"=>39, "value"=>"Pinedale"}, {"offset"=>49, "value"=>"WY"}, {"offset"=>53, "value"=>"United States"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries, Boulder, WY, United States", "id"=>"0283066d4edda4752ccfb1521446640fd11b6fb4", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"ClRCAAAAGRzCvBYyAd_JOPTpF2YIqeNEdGambAykSXJAZsHDvz2ZLt3pmPW6HdWumRxm92lLdaupxxXTCc1PJLt8ieCGaB1GDyVfwL3lsQ3pJOwjIhESEH6saMT8SK5oCJxvvWPzkZMaFHHIRAug5oebsy1aTbBGMN5mJTcx", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries"}, {"offset"=>25, "value"=>"Boulder"}, {"offset"=>34, "value"=>"WY"}, {"offset"=>38, "value"=>"United States"}], "types"=>["establishment"]}, {"description"=>"Opsco Energy Industries USA, Texas 97, Pleasanton, TX, United States", "id"=>"4e1b97340a8ab3c4f1654290328f16c3fb49b78e", "matched_substrings"=>[{"length"=>5, "offset"=>0}], "reference"=>"CmRTAAAAbW3q6r4i4l57ymERnDhHnS-RfvPfhIGH5QMDAoV4TfDoTU_Ej5veoTWICAPV4dfsoTW_t0SfDQUJJ8bdzmR-4KcqMZACktxgPukVFdqdPXVdzYoTI2FH7m22YY08RlDaEhDL4O_vHh_iqJz_26EbxXqXGhR7bmKLo-E4aHjM8E2ZTEtg4pFnDQ", "terms"=>[{"offset"=>0, "value"=>"Opsco Energy Industries USA"}, {"offset"=>29, "value"=>"Texas 97"}, {"offset"=>39, "value"=>"Pleasanton"}, {"offset"=>51, "value"=>"TX"}, {"offset"=>55, "value"=>"United States"}], "types"=>["establishment"]}], "status"=>"OK"}
  end
end
