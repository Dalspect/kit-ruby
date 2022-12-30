class RubricItem < ApplicationRecord
  belongs_to :problem
  
  has_many :checked_rubric_items, dependent: :destroy
  
  validates :problem, presence: true
  validates :title, presence: true
  validates :points, presence: true
  
  
  before_create :set_starting_location
  after_destroy :remove_from_order
  
  after_save :clear_grade_cache
  after_destroy :clear_grade_cache
  
  #Set this problem to be the last one in order
  def set_starting_location
    unless self.location
	  #NOTE: Re-gets the problem from database in case other rubric items were added in this same transaction
	  self.location = Problem.find(self.problem.id).rubric_items.map{|p| p.location}.max
	  if self.location
	    self.location += 1
	  else
	    self.location = 0
	  end
	end
  end
  
  #Move all problems below this one up to fill in the gap
  def remove_from_order
    unless self.destroyed_by_association
      self.problem.rubric_items.each do |p|
        if p.location > self.location
	      p.location-=1
		  p.save!
	    end
	  end
	end
  end
  
  def clear_grade_cache
    unless self.destroyed_by_association
      self.problem.clear_grade_cache
	end
  end
end
