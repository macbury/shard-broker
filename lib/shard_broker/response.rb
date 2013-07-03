module ShardBroker
  class Response < Node 
    TAG = "response"
    
    def initialize
      super(TAG)
    end

    def setStatus(status)
      self.add_attribute("status", status)
    end

    def addError(body)
      error      = REXML::Element.new('error')
      error.text = body
      self << error
    end
  end
end