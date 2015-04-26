class Responder < ActiveRecord::Base
  self.inheritance_column = :type_of

  validates :capacity, presence: true, inclusion: { in: (1..5) }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :type, presence: true

  RESPONDER_TYPES = %w(Fire Medical Police)

  scope :all_by_type, -> (type) { where(type: type) }
  scope :unassigned, -> { where(emergency_code: nil) }
  scope :on_duty, -> { where(on_duty: true) }
  scope :available, -> { on_duty.unassigned }

  #
  # Returns a hash of the capacity levels for all responder types.
  #
  def self.responder_capacities
    capacities = {}
    RESPONDER_TYPES.each do |type|
      capacities[type] = capacities_for(type)
    end
    capacities
  end

  #
  # Resturns an array of capacity levels for a set of responders.
  #
  # type: string
  #
  def self.capacities_for(type)
    responders = all_by_type(type)
    [
      capacity_of(responders),
      capacity_of(responders.unassigned),
      capacity_of(responders.on_duty),
      capacity_of(responders.available)
    ]
  end

  #
  # Calls for assignment of responders to an emergency by type.
  # Returns true if a full response for the emergency is met.
  #
  # emergency: Emergency instance
  #
  def self.dispatch_for(emergency)
    full_response = true
    capacities_map = map_of_available_capacities
    RESPONDER_TYPES.each do |type|
      full_response = false unless dispatch_by_type(emergency, type, capacities_map[type])
    end
    full_response
  end

  #
  # Returns a hash of responder types with an array of available capacities.
  #
  # => { 'Fire' => [1, 2], 'Police' => [3, 4], 'Medical', [5, 6] }
  #
  def self.map_of_available_capacities
    responders = Responder.available.order(capacity: :desc)
    capacities_map = Hash.new([])
    responders.each { |responder| capacities_map[responder.type] += [responder.capacity] }
    capacities_map
  end

  #
  # Assigns responders to an emergency by type.
  # Returns true if a full response for the emergency is met.
  #
  # emergency: Emergency instance
  # type: string
  # available_capacities: array[integer]
  #
  def self.dispatch_by_type(emergency, type, available_capacities)
    severity = emergency.send("#{type.downcase}_severity")
    best_capacities, response_met = emergency.find_best(available_capacities, severity)
    best_responders = all_by_type(type).available.where(capacity: best_capacities)
    group_assign_to(best_responders, emergency)
    response_met
  end

  #
  # Wrapper method for updating emergency_code
  #
  # responders: ActiveRecord::Relation
  # emergency: Emergency instance
  #
  def self.group_assign_to(responders, emergency)
    responders.update_all(emergency_code: emergency.code)
  end

  #
  # Wrapper method for updating emergency_code to nil.
  #
  def dismiss!
    update_attributes(emergency_code: nil)
  end

  #
  # Returns the sum of capacities from a collection of responders.
  #
  # responders: ActiveRecord::Relation
  #
  def self.capacity_of(responders)
    responders.pluck(:capacity).reduce(0, :+)
  end
end
