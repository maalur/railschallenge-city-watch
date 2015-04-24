class Responder < ActiveRecord::Base
  self.inheritance_column = :type_of

	validates :capacity, presence: true, inclusion: { in: (1..5) }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :type, presence: true

  RESPONDER_TYPES = ['Fire', 'Police', 'Medical']

  scope :all_by_type, -> (type) { where type: type }
  scope :unassigned, -> { where emergency_code: nil }
  scope :on_duty, -> { where on_duty: true }
  scope :available, -> { on_duty.unassigned }
  scope :capacity_under, -> (amount) { where "capacity <= ?", amount }
  scope :capable, -> { on_duty.unassigned.order(capacity: :asc) }


  def self.responder_capacities
  	capacities = {}
  	RESPONDER_TYPES.each do |type|
  		responders = all_by_type(type)
  		capacities[type] = []
      capacities[type] << capacities_of(responders)
      capacities[type] << capacities_of(responders.unassigned)
      capacities[type] << capacities_of(responders.on_duty)
      capacities[type] << capacities_of(responders.available)
  	end
  	capacities
  end

  def self.capacities_of(responders)
    responders.pluck(:capacity).reduce(0,:+)
  end

  def self.dispatch_for(emergency)
    full_response = true

    RESPONDER_TYPES.each do |type|
      severity = emergency.send("#{type.downcase}_severity")
      responders = all_by_type(type).available.capacity_under(severity).order(capacity: :desc)
      capacity_levels = responders.pluck(:capacity)

      capacity_levels.each do |capacity|
        if severity - capacity >= 0
          severity -= capacity
          responders.find_by(capacity: capacity).assign_to(emergency)
        end
      end

      if severity > 0 && responder = all_by_type(type).capable.first
        severity -= responder.capacity
        responder.assign_to(emergency)
      end

      full_response = false if severity > 0
    end

    emergency.response_met! if full_response
  end

  def assign_to(emergency)
    update_attributes(emergency_code: emergency.code)
  end

  def unassign
    update_attributes(emergency_code: nil)
  end
end