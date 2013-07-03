require 'digest/sha1'
class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, format: /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/i
  validates :salt, :encrypted_password, presence: true
  validates :password, presence: true, length: { minimum: 3, maximum: 12 }, on: :create

  has_many :peers, dependent: :destroy

  attr_accessor :password

  def self.auth_or_create_by_params(email, password)
    user = User.find_or_initialize_by(email: email)
    if user.new_record?
      user.password           = password
      user.salt               = SecureRandom.hex(32)
      user.encrypted_password = user.hashPassword(password)
      user.save
      return user
    elsif user.validPassword?(password)
      return user
    else
      return false
    end
  end

  def validPassword?(password)
    self.encrypted_password == hashPassword(password)
  end

  def hashPassword(password)
    Digest::SHA1.hexdigest([self.salt, password].join("-"))
  end

  def add_peer(device_id, public_key)
    peer            = self.peers.find_or_initialize_by(device_id: device_id)
    peer.public_key = public_key
    peer.save
    peer
  end
end