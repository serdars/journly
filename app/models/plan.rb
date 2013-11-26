class Plan < ActiveRecord::Base
  def as_json(options = { })
    options[:exclude] = :destination
    super(options).merge({:destination => JSON.parse(self.destination)})
  end
end
