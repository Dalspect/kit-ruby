class ReusableComment < ApplicationRecord
  belongs_to :problem
  
  validates :comment, length: { minimum: 1 }, uniqueness: true
end
