class Professor < ApplicationRecord
  belongs_to :user
  belongs_to :klass
  
  after_create {Repo.refresh_repo_authorizations}
  after_destroy {Repo.refresh_repo_authorizations}
  after_destroy {self.user.check_submission_notifications}
  
  validates :user, uniqueness: {scope: :klass}
end
