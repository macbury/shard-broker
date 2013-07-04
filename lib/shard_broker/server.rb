module ShardBroker
  class Server

    def findConnectionByUser(user)
      @connections.select { |connection| connection.havePeer? && connection.peer.user_id == user.id }
    end

    def findConnectionByPeer(peer)
      @connections.select { |connection| connection.havePeer? && connection.peer.id == peer.id }
    end

    def closeConnectionForUser(user)
      findConnectionByUser(user).each do |connection|
        connection.close
      end
    end

    def closeConnectionForPeer(peer)
      findConnectionByPeer(peer).each do |connection|
        connection.close
      end
    end

    def sendActionToUser(msg, user)
      findConnectionByUser(user).each do |connection|
        connection.write(msg)
      end
    end

    def initialize
      @connections = []
    end

    def broadcastToUser()
      
    end

    def push(connection)
      @connections << connection
    end

    def pop(connection)
      @connections.delete(connection)
    end
  end
end