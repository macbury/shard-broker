class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :partner, class_name: "User"

  scope :isAccepted, -> { where(accepted: true) }
  scope :isNotAccepted, -> { where(accepted: false) }

  def accepted?
    accepted
  end
end