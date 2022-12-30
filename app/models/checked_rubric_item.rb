class CheckedRubricItem < ApplicationRecord
  belongs_to :rubric_item
  belongs_to :graded_problem
  
  validates :graded_problem, uniqueness: {scope: :rubric_item}
  
  validate :validate_correct_problem!
  
  after_create :clear_grade_cache
  after_destroy :clear_grade_cache

  def clear_grade_cache
    self.graded_problem.clear_grade_cache
  end  
  
  private
  
  def validate_correct_problem!
    unless self.rubric_item.problem == self.graded_problem.problem
	  self.errors.add(:base,"Mismatched problem!")
	end
  end
end
