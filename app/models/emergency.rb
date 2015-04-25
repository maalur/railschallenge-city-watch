class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :fire_severity, :police_severity, :medical_severity,
            presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :responders, primary_key: :code, foreign_key: :emergency_code

  #
  # Returns an array of Responder names from responders assigned to the emergency.
  #
  def responders_names
    responders.map(&:name)
  end

  #
  # Wrapper method for updating full_response to true.
  #
  def full_response!
    update_attributes(full_response: true)
  end

  #
  # Returns a boolean value of response necessity.
  #
  def response_required?
    fire_severity + police_severity + medical_severity > 0
  end

  #
  # Requests a dispatch if a response is needed then updates full_response.
  #
  def dispatch!
    full_response! if !response_required? || Responder.dispatch_for(self)
  end

  #
  # Dismisses assigned responders if the emergency is resolved.
  # Can be improved to only dismiss some responders if a severity is updated
  # but the emergency is still unresolved.
  #
  def adjust_response!
    responders.each(&:dismiss!) if resolved_at
  end

  #
  # Returns the 'best' selection of responders and the total capacity.
  #
  # This is an implementation of the coin change algorithm that only
  # looks for exact matches. If an exact match is not found, it increases
  # the match value by 1 and tries again until a match is found. This
  # returns the collection of responders that can provide the lowest full
  # response.
  #
  # responders: ActiveRecord::Relation
  # severity: integer
  #
  def find_best_available(responders, severity)
    max_capacity = responders.pluck(:capacity).reduce(0, :+)
    i = 0
    response = 0
    best_available = []

    until [severity, max_capacity].include?(response)
      best_available = []
      response = 0 - i

      responders.each do |responder|
        capacity = responder.capacity
        if response <= severity - capacity
          response += capacity
          best_available << responder
        end
      end

      i += 1
    end

    [best_available, response + i]
  end
end
