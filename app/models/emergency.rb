class Emergency < ActiveRecord::Base
	validates :code, presence: true,
	          uniqueness: { case_sensitive: false }
	validates :fire_severity, :police_severity, :medical_severity,
	          presence: true, numericality: { greater_than_or_equal_to: 0 }

	has_many :responders, primary_key: :code, foreign_key: :emergency_code

	scope :with_full_response, -> { where full_response: true }

  def responders_names
  	responders.pluck(:name)
  end

  def response_met!
	  update_attributes(full_response: true)
	end

	def response_required?
		if fire_severity + police_severity + medical_severity > 0
			true
		else
			response_met!
			false
		end
	end

end