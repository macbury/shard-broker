module ShardBroker
  class User
    include Mongoid::Document

    field :email,               type: String
    field :salt,                type: String
    filed :encrypted_password,  type: String
  end
end