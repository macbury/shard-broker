module ShardBroker
  class Server

    def findConnectionByUser(user)
      @connections.select { |connection| connection.havePeer? && connection.peer.user_id == user.id }
    end

    def findConnectionByPeer(peer)
      @connections.select { |connection| connection.havePeer? && connection.peer.id == peer.id }
    end

    def wakeDevices(peers)
      notification = {
        restricted_package_name:  "com.macbury.secondhalf",
        registration_ids:         peers.map(&:gcm_registration_id),
        data:                     { 'action' => 'connect' },
      }

      ShardBroker.gcm.deliver(notification) do |response|
        ShardBroker.logger.debug "gcm response: #{response}"
      end
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
      peers = []
      findConnectionByUser(user).each do |connection|
        connection.write(msg)
        peers << connection.peer
      end

      peersToWake = user.peers.where("id NOT IN (:id)", { id: peers.map(&:id) }).all
      wakeDevices(peersToWake) if peersToWake.size > 0
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