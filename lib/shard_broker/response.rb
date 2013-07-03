module ShardBroker
  class Response < Node 
    TAG = "response"
    
    def initialize
      super(TAG)
    end

    def setStatus(status)
      self.add_attribute("status", status)
    end

    def addParam(key, value)
      p      = REXML::Element.new(key)
      p.text = value
      self << p
    end

    def addError(body)
      error      = REXML::Element.new('error')
      error.text = body
      self << error
    end

    def setFor(status)
      self.add_attribute("for", status)
    end
  end
end