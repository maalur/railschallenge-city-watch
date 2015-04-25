class Responder < ActiveRecord::Base
  self.inheritance_column = :type_of

  validates :capacity, presence: true, inclusion: { in: (1..5) }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :type, presence: true

  RESPONDER_TYPES = %w(Fire Medical Police)

  scope :all_by_type, -> (type) { where type: type }
  scope :unassigned, -> { where emergency_code: nil }
  scope :on_duty, -> { where on_duty: true }
  scope :available, -> { on_duty.unassigned }

  def self.responder_capacities
    capacities = {}
    RESPONDER_TYPES.each do |type|
      responders = all_by_type(type)
      capacities[type] = retreive_capacities_of(responders)
    end
    capacities
  end

  def self.retreive_capacities_of(responders)
    [
      capacity_of(responders),
      capacity_of(responders.unassigned),
      capacity_of(responders.on_duty),
      capacity_of(responders.available)
    ]
  end

  def self.dispatch_for(emergency)
    full_response = true

    RESPONDER_TYPES.each do |type|
      responders = all_by_type(type).available.order(capacity: :desc)
      severity = emergency.send("#{type.downcase}_severity")
      best_available, response_size = emergency.find_best_available(responders, severity)
      best_available.each { |responder| responder.assign_to(emergency) }
      full_response = false if severity > response_size
    end

    emergency.full_response! if full_response
  end

  def assign_to(emergency)
    update_attributes(emergency_code: emergency.code)
  end

  def unassign
    update_attributes(emergency_code: nil)
  end

  def self.capacity_of(responders)
    responders.pluck(:capacity).reduce(0, :+)
  end
end
