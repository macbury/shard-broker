module ShardBroker
  class Server

    def initialize
      @connections = []
    end

    def push(connection)
      @connections << connection
    end

    def pop(connection)
      @connections.delete(connection)
    end

  end
end