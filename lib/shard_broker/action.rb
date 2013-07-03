module ShardBroker
  class Action < Node
    LOGIN_TAG           = "login"
    PASSWORD_TAG        = "password"
    TAG                 = "action"
    ACTION_AUTH         = "auth"
    ACTION_REGISTRATION = "register-or-login"
    ELEMENT_TOKEN       = "token"
    DEVICE_TAG          = "device"
    SIGN_KEY_TAG        = "signing-key"
    ENCRYPTION_KEY_TAG  = "encryption-key"

    def initialize
      super(TAG)
    end

    def type?(typ)
      attribute("type").to_s == typ.to_s
    end
  end
end