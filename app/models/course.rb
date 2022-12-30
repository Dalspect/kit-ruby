class Course < ApplicationRecord
  belongs_to :repo, dependent: :destroy
  belongs_to :department
  
  has_many :klass, dependent: :destroy
  has_many :assignment, dependent: :destroy
  has_many :grade_category, dependent: :destroy
end
