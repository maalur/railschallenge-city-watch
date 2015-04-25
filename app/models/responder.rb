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

  def self.dispatch_for(emergency)
    full_response = true

    RESPONDER_TYPES.each do |type|
      severity = emergency.send("#{type.downcase}_severity")
      responders = all_by_type(type).available.order(capacity: :desc)
      available_capacities = responders.pluck(:capacity)

      best_available, response_size = best_available_from( available_capacities, severity )

      best_available.each do |capacity|
        responders.find_by_capacity(capacity).assign_to(emergency)
      end

      full_response = false if severity > response_size
    end

    emergency.response_met! if full_response
  end

  def assign_to(emergency)
    update_attributes(emergency_code: emergency.code)
  end

  def unassign
    update_attributes(emergency_code: nil)
  end

  private

    def self.best_available_from(collection, value)
      i = 0
      sum = 0
      sub_set = []
      until sum == value || collection == sub_set
        sum = 0 - i
        sub_set = []
        collection.each do |n|
          if sum <= value - n
            sum += n
            sub_set << n
          end
        end
        i += 1
      end
      [sub_set, sum + i]
    end

    def self.capacities_of(responders)
      responders.pluck(:capacity).reduce(0,:+)
    end

end