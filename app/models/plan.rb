class Plan < ActiveRecord::Base
  has_many :items
  belongs_to :user

  def as_json(options = { })
    options[:exclude] = :destination
    super(options).merge({:destination => JSON.parse(self.destination)})
  end
end
