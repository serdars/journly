class Item < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :item_elements

  def as_json(options = { })
    options[:include] = :tags
    super(options).merge({:item_elements => item_elements})
  end
end
