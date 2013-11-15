require 'pry'

class ItemElement < ActiveRecord::Base
  belongs_to :item

  def self.create_google_place(google_place_data)
    self.create({
                  :element_type => "google_place",
                  :name => google_place_data["name"],
                  :data => google_place_data.to_json
                })
  end
  
  def as_json(options = { })
    # For item elements we are not sending the full data.
    # We are crafting the item element objects here.
    item_data = JSON.parse(self.data)
    
    item_object = case self.element_type
                  when "google_place"
                    {
        :name => item_data['name'],
        :address => item_data['formatted_address'],
        :url => item_data['website'] || item_data['url'],
        :geometry => item_data['geometry']['location'],
        :phone_number => item_data['formatted_phone_number']
      }
                  else
                    raise "Unknown element type: #{self.element_type}"
                  end

    item_object[:element_type] = self.element_type
    item_object[:id] = self.id if self.id

    item_object.as_json(options)
  end
end
