class Responder < ActiveRecord::Base
  self.inheritance_column = :type_of

	validates :capacity, presence: true,
                       inclusion: { in: (1..5) }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true

  RESPONDER_TYPES = ['Fire', 'Police', 'Medical']

  scope :all_by_type, -> (type) { where type: type }
  scope :available, -> { where emergency_code: nil }
  scope :on_duty, -> { where on_duty: true }

  def self.responder_capacities
  	capacities = {}
  	RESPONDER_TYPES.each do |type|
  		responders = Responder.all_by_type(type)
  		capacities[type] = []
      capacities[type] << count_of(responders)
      capacities[type] << count_of(responders.available)
      capacities[type] << count_of(responders.on_duty)
      capacities[type] << count_of(responders.available.on_duty)
  	end
  	capacities
  end

  def self.count_of(responders)
    responders.map(&:capacity).reduce(0,:+)
  end
end