module ShardBroker
  class Connection < EM::Connection
    include ShardBroker::State
    include ShardBroker::ProtocolTags
    include ShardBroker::Parser

    def post_init
      prepare_parser
      ShardBroker.server.push(self)
      @connectionSecret = SecureRandom.hex
      @port, @ip        = Socket.unpack_sockaddr_in(get_peername)
      ShardBroker.logger.info "New connection #{@ip}:#{@port}"
      go ShardBroker::State::Init
    end

    def getConnectionSecret
      @connectionSecret
    end

    def receive_data(data)
      read(data)
    end

    def timeout!
      write_error(ShardBroker::Status::TIMEOUT_ERROR)
      close
    end

    def writeActionError(action, status, msg=nil)
      response = action.getResponse
      response.setStatus(status)
      response.addError(msg.to_s) if msg
      write(response)
    end

    def write_error(status, msg=nil,id=nil)
      response = Response.new
      response.setStatus(status)
      response.setId(id)
      response.addError(msg.to_s) if msg
      write(response)
    end

    def close
      send_end_stream_tag
      close_connection_after_writing
    end

    def unbind
      ShardBroker.server.pop(self)
      ShardBroker.logger.info "Client disconnected #{@ip}:#{@port}"
    end
  end
end