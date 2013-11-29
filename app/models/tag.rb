class Tag < ActiveRecord::Base
  has_and_belongs_to_many :items

  def self.suggest(term)
    suggestions = self.where("name like ?", "#{term}%")
    if term != "" && !(suggestions.length == 1 && suggestions[0][:name] == term)
      suggestions << { :name => term }
    end

    suggestions
  end
end
