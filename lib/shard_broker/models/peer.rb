class Peer < ActiveRecord::Base
  belongs_to :user

  validates :device_id, presence: true, uniqueness: true, length: { minimum: 3, maximum: 32 }
  validates :encryption_key, :signing_key, presence: true

  before_create :generate_token

  def generate_token
    while true
      new_token = SecureRandom.hex(16)
      if Peer.where(token: new_token).count == 0
        self.token = new_token
        break
      end
    end
  end
end