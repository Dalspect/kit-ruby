class Contributor < ApplicationRecord
  belongs_to :user
  belongs_to :submission
  
  # Needs an on destroy trigger in case last user on a submission is destroyed
  after_destroy :destroy_submission_if_unowned!
  
  # If user becomes a contributor but already had a submission, convert that contributor to a past contributor
  after_create :replace_previous_submission
  
  private
  
  def destroy_submission_if_unowned!
    if self.submission.contributors.empty? && self.submission.past_contributors.empty?
	  self.submission.destroy
	end
  end
  
  def replace_previous_submission
    self.user.contributors.select{|c| c.submission.assigned == self.submission.assigned && c!=self}.each do |c|
	  pc = PastContributor.new
	  pc.user = c.user
	  pc.submission = c.submission
	  pc.save!
	  c.destroy!
	end
	
	# If user was a past contributor to this submission already, remove that
	pcs = self.submission.past_contributors & self.user.past_contributors
	
	pcs.each do |pc|
	  pc.destroy!
	end
  end
end
