class RegradeRequest < ApplicationRecord
  belongs_to :submission
  
  belongs_to :requested_by, class_name: "User", foreign_key: :requested_by_id
  belongs_to :closed_by, class_name: "User", foreign_key: :closed_by_id, optional: true
  
  validates :reason, presence: true
  
  validate :validate_only_active_request!
  
  
  
  def validate_only_active_request!
    reqs = self.submission.regrade_requests.where(closed: false)
    if reqs.any? && reqs.first!=self
      self.errors.add(:base, "Submission already has an active regrade request")
	end
  end
  
end
