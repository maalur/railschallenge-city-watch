class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :fire_severity, :police_severity, :medical_severity,
            presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :responders, primary_key: :code, foreign_key: :emergency_code

  scope :with_full_response, -> { where full_response: true }

  def responders_names
    responders.pluck(:name)
  end

  def full_response!
    update_attributes(full_response: true)
  end

  def response_required?
    if fire_severity + police_severity + medical_severity > 0
      true
    else
      full_response!
      false
    end
  end

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
