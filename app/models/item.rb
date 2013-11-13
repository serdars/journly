class Item < ActiveRecord::Base
  has_and_belongs_to_many :tags

  def as_json(options = { })
    options[:include] = :tags
    super(options)
  end
end
