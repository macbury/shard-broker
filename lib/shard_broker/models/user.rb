require 'digest/sha1'
class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, format: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/i
  validates :salt, :encrypted_password, presence: true
  validates :password, presence: true, length: { minimum: 3, maximum: 12 }, on: :create

  has_many   :peers, dependent: :destroy
  
  has_many    :relationships, dependent: :delete_all
  has_one     :relationship,  class_name: "Relationship", foreign_key: "partner_id"
  has_many    :invitations,   class_name: "Relationship", foreign_key: "partner_id"
  attr_accessor   :password

  def self.authOrCreateByEmailAndPassword(email, password)
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

  def addPeer(device_id, encryption_key, signing_key)
    peer                = self.peers.find_or_initialize_by(device_id: device_id)
    peer.encryption_key = encryption_key
    peer.signing_key    = signing_key
    peer.save
    peer
  end

  def inRelationship?
    relationship = self.relationships.isAccepted.first || self.relationship
    (!relationship.nil? && relationship.accepted?)
  end

  def invite!(user)
    partner = relationships.find_or_initialize_by(partner_id: user.id)
    partner.save
  end

  def accept!(user)
    partner           = relationships.find_by(partner_id: user.id)
    partner.accepted  = true
    result            = partner.save

    self.relationships.isNotAccepted.delete_all
    self.invitations.isNotAccepted.delete_all

    return result
  end
end