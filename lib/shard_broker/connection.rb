module ShardBroker
  class Connection < EM::Connection
    include ShardBroker::State
    include ShardBroker::ProtocolTags
    include ShardBroker::Parser

    attr_accessor :peer

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

    def ping!
      
    end

    def receive_data(data)
      read(data)
    end

    def havePeer?
      !peer.nil?
    end

    def timeout!
      ShardBroker.logger.info "Timeout for connection!"
      write_error(ShardBroker::Status::TIMEOUT_ERROR)
      close_connection
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