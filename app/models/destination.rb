require 'net/http'

class Destination
  def self.suggest(term)
    GooglePlace.suggest(term, {:types => "(regions)"})
  end
end
