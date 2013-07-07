module ShardBroker
  module ProtocolTags
    SESSION_TAG = "session"
    PING_TAG = "p"
    def getSessionHeaderXML
      "<?xml version='1.0'?>\n" + 
      "<#{SESSION_TAG}>\n"
    end

    def send_start_stream_tag
      read(getSessionHeaderXML)
      send_data(getSessionHeaderXML)
    end

    def send_end_stream_tag
      send_data("</#{SESSION_TAG}>\n")
    end
  end
end