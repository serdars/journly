class Tag < ActiveRecord::Base
  has_and_belongs_to_many :items

  def self.suggest(term)
    (self.where("name like ?", "#{term}%") + [ { :name => term } ]).uniq
  end
end
