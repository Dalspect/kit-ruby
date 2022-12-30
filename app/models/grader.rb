class Grader < ApplicationRecord
  belongs_to :user
  belongs_to :klass
  
  validates :user, uniqueness: {scope: :klass}
  
  after_destroy :removed_assigned_graders
  
  after_create {Repo.refresh_repo_authorizations}
  after_destroy {Repo.refresh_repo_authorizations}
  after_destroy {self.user.check_submission_notifications}
  
  private
  def removed_assigned_graders
    #Remove any assigned_grader entries for this class & user
	self.user.assigned_graders.each do |ag|
	  if ag.assigned.klass == self.klass
	    ag.destroy
	  end
	end
  end
end
