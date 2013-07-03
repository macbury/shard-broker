module ShardBroker
  module ProtocolTags
    SESSION_TAG = "session"

    def getSessionHeaderXML
      "<?xml version='1.0'?>\n" + 
      "<#{SESSION_TAG} secret='#{getConnectionSecret}'>"
    end

    def send_start_stream_tag
      send_data(getSessionHeaderXML)
    end

    def send_end_stream_tag
      send_data("</#{SESSION_TAG}>")
    end
  end
end