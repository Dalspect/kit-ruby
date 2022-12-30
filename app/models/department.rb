class Department < ApplicationRecord
  belongs_to :repo, dependent: :destroy
  
  has_many :department_professors, dependent: :destroy
  has_many :courses, dependent: :destroy
  
  validates :title, presence: true
  
  
  def is_department_admin?(user)
    if self.department_professors.find_by(user: user, admin: true) || user.admin?
	  return true
	else
	  return false
	end
  end
  
  def is_department_professor?(user)
    if self.department_professors.find_by(user: user) || user.admin?
	  return true
	else
	  return false
	end
  end
  
end
