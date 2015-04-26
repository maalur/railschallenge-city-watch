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
  # Returns a hash of responder types with an array of available capacities.
  #
  # => { 'Fire' => [1, 2], 'Police' => [3, 4], 'Medical', [5, 6] }
  #
  def self.available_capacities_map
    responders = available.order(capacity: :desc)
    capacities_map = Hash.new([])

    responders.each do |responder|
      capacities_map[responder.type] += [responder.capacity]
    end

    capacities_map
  end

  #
  # Assigns responders to an emergency by type.
  # Returns true if a full response for the emergency is met.
  #
  # emergency: Emergency instance
  # type: string
  # available_capacities: array of integers
  #
  def self.dispatch_by_type(emergency, type, available_capacities)
    severity = emergency.send("#{type.downcase}_severity")
    best_capacities, response_met = emergency.find_best(available_capacities, severity)

    all_by_type(type)
      .available
      .where(capacity: best_capacities)
      .update_all(emergency_code: emergency.code)

    response_met
  end

  #
  # Calls for assignment of responders to an emergency by type.
  # Returns true if a full response for the emergency is met.
  #
  # emergency: Emergency instance
  #
  def self.dispatch_for(emergency)
    full_response = true
    capacities_map = available_capacities_map

    RESPONDER_TYPES.each do |type|
      full_response = false unless dispatch_by_type(emergency, type, capacities_map[type])
    end

    full_response
  end

  #
  # Returns a hash of the total capacity levels for all responder types.
  #
  # => { 'Fire' => [1, 1, 1, 1], 'Police' => [3, 3, 3, 3], 'Medical', [0, 0, 0, 0] }
  #
  def self.total_capacities_map
    capacities_hash = Hash.new { |hash, key| hash[key] = [0, 0, 0, 0] }

    find_each do |responder|
      responder.add_capacity_to(capacities_hash[responder.type])
    end

    capacities_hash
  end

  #
  # Adds responder capacity to appropriate categories.
  #
  # capacity_array: [int, int, int, int]
  #
  def add_capacity_to(capacity_array)
    capacity_array[0] += capacity
    capacity_array[1] += capacity unless emergency_code?
    capacity_array[2] += capacity if on_duty?
    capacity_array[3] += capacity if available?
  end

  #
  # Returns boolean of responder availability.
  #
  def available?
    on_duty? && !emergency_code
  end
end
