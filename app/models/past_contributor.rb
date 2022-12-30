class PastContributor < ApplicationRecord
  belongs_to :user
  belongs_to :submission
  
  # Needs an on destroy trigger in case last user on a submission is destroyed
  after_destroy :destroy_submission_if_unowned!
  
  private
  
  def destroy_submission_if_unowned!
    if self.submission.contributors.empty? && self.submission.past_contributors.empty?
	  self.submission.destroy
	end
  end
end
