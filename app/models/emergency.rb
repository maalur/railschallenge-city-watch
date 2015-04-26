class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :fire_severity, :police_severity, :medical_severity,
            presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :responders, primary_key: :code, foreign_key: :emergency_code

  #
  # Dismisses assigned responders if the emergency is resolved.
  # Can be improved to dismiss or assign responders if a severity is updated
  # but the emergency is still unresolved.
  #
  def adjust_response!
    responders.update_all(emergency_code: nil) if resolved_at
  end

  #
  # Requests a dispatch if a response is needed, then updates full_response.
  #
  def dispatch!
    full_response! if !response_required? || Responder.dispatch_for(self)
  end

  #
  # Returns an array of:
  #   - array of integers
  #   - boolean
  #
  # This is an implementation of the coin change algorithm that only
  # looks for exact matches. If an exact match is not found, it increases
  # the match value by 1 and tries again until a match is found. This
  # returns the collection of capacities that can provide the lowest full
  # response, if a full response can be met.
  #
  # available: array of integers
  # severity: integer
  #
  # emergency.find_best([5, 4, 2, 1], 8) => [[5, 2, 1], true]
  #
  def find_best(available, severity)
    max_capacity = available.reduce(0, :+)
    i = 0
    response = 0
    best_available = []

    until [severity, max_capacity].include?(response)
      best_available = []
      response = 0 - i

      available.each do |capacity|
        if response <= severity - capacity
          response += capacity
          best_available << capacity
        end
      end

      i += 1
    end

    [best_available, severity <= response + i]
  end

  #
  # Wrapper method for updating full_response to true.
  #
  def full_response!
    update_attributes(full_response: true)
  end

  #
  # Returns an array of the names of responders assigned to the emergency.
  #
  def responders_names
    responders.map(&:name)
  end

  #
  # Returns a boolean value of response necessity.
  #
  def response_required?
    fire_severity + police_severity + medical_severity > 0
  end
end
