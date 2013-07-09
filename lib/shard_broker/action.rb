module ShardBroker
  class Action < Node
    LOGIN_TAG                 = "login"
    PASSWORD_TAG              = "password"
    TAG                       = "action"
    ACTION_INVITE_PENDING     = "invite-pending"
    ACTION_INVITE             = "invite"
    ACTION_INVITE_ACCEPT      = "invite-accept"
    ACTION_AUTH               = "auth"
    ACTION_CAPTCHA            = "captcha"
    ACTION_REGISTRATION       = "register-or-login"
    ELEMENT_TOKEN             = "token"
    DEVICE_TAG                = "device"
    SIGN_KEY_TAG              = "signing-key"
    ENCRYPTION_KEY_TAG        = "encryption-key"

    def initialize
      super(TAG)
    end

    def type?(typ)
      getType == typ.to_s
    end

    def getType
      attribute("type").to_s
    end

    def setType(type)
      self.add_attribute("type", type)
    end

    def getResponse
      response = Response.new
      response.setId(getId)
      response.setFor(getType)
      return response
    end
  end
end