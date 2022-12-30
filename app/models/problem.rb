class Problem < ApplicationRecord
  belongs_to :assignment
  has_many :rubric_items, dependent: :destroy
  
  has_many :graded_problems, dependent: :destroy
  
  has_many :reusable_comments, dependent: :destroy
  
  validates :title, presence: true
  validates :points, presence: true
  
  before_create :set_starting_location
  after_destroy :remove_from_order
  
  after_save :clear_grade_cache
  after_destroy :clear_grade_cache
  
  #Set this problem to be the last one in order
  def set_starting_location
    # NOTE: Re-queries database for assignment so that multiple problems can be added per transaction without getting same locations
    self.location = Assignment.find(self.assignment.id).problems.map{|p| p.location}.max
	if self.location
	  self.location += 1
	else
	  self.location = 0
	end
  end
  
  #Move all problems below this one up to fill in the gap
  def remove_from_order
    unless self.destroyed_by_association
      self.assignment.problems.each do |p|
        if p.location > self.location
	      p.location-=1
		  p.save!
	    end
	  end
	end
  end
  
  def clear_grade_cache
    unless self.destroyed_by_association
      self.assignment.clear_grade_cache
	end
  end
  
  def copy_problem(to_assignment)
    self.with_lock do |s|
      newProb = Problem.new(title: self.title, points: self.points)
	
	  newProb.assignment = to_assignment

	  newProb.save!

	  # Copy rubric items
	  self.rubric_items.order(location: :asc).each do |r|
		newItem = RubricItem.new(title: r.title, points: r.points)
		newItem.problem = newProb
		
		newItem.save!
	  end
	end
  end
end
