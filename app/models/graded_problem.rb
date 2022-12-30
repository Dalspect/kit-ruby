class GradedProblem < ApplicationRecord
  belongs_to :problem
  belongs_to :submission
  
  references :grader, class_name: "User", foreign_key: :grader_id, optional: true
  
  has_many :checked_rubric_items, dependent: :destroy
  
  validates :problem, uniqueness: {scope: :submission}
  
  validate :validate_correct_assignment!
  
  after_save :clear_grade_cache
  after_destroy :clear_grade_cache
  
  def graded?
    if self.checked_rubric_items.to_a.empty? && self.problem.rubric_items.to_a.any?
	  return false
	else
	  return true
	end
  end
  
  def get_grade_points
    sum = self.point_adjustment
	sum ||= 0
	self.checked_rubric_items.each do |i|
	  sum += i.rubric_item.points
	end
	return sum
  end
  
  def grader
    User.find(self.grader_id)
  end

  def clear_grade_cache
    self.submission.clear_grade_cache
  end  
  
  private
  
  def validate_correct_assignment!
    unless self.submission.assigned.assignment == self.problem.assignment
	  self.errors.add(:base, "Assignment references do not match!")
	end
  end
end
