class Destination
  def self.suggest(term)
    GooglePlace.suggest(term, {:types => "(regions)"})
  end

  def self.create(reference)
    response = GooglePlace.place_detail({:reference => reference})
    {
      :name => response["result"]["name"],
      :geometry => response["result"]["geometry"]["location"]
    }
  end
end
