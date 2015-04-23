class Responder < ActiveRecord::Base
  self.inheritance_column = :type_of

	validates :capacity, presence: true,
                       inclusion: { in: (1..5) }
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :type, presence: true
end