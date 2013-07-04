module ShardBroker
  class Node < REXML::Element
    def is?(check_type)
      self.name == check_type.to_s
    end
    
    def haveValidId?
      return false if getId.nil?
      return true
    end

    def getId
      attribute("id")
    end

    def setId(id)
      self.add_attribute("id", id)
    end

    def have?(have_type)
      self.elements[have_type.to_s].present?
    end

    def params
      elements.to_a.inject({}) { |out, element| out[element.name] = element.text; out;  }
    end

    def addParam(key, value)
      p      = REXML::Element.new(key)
      p.text = value
      self << p
    end
  end
end