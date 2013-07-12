module ShardBroker
  class Server

    def findConnectionByUser(user)
      @connections.select { |connection| connection.havePeer? && connection.peer.user_id == user.id }
    end

    def findConnectionByPeer(peer)
      @connections.select { |connection| connection.havePeer? && connection.peer.id == peer.id }
    end

    def wakeDevices(peers)
      registration_ids = peers.map(&:gcm_registration_id).compact
      return if registration_ids.empty?
      notification     = {
        restricted_package_name:  "com.macbury.secondhalf",
        registration_ids:         registration_ids,
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

    def sendActionToUser(msg, user, options={})
      peers = []
      findConnectionByUser(user).each do |connection|
        connection.write(msg)
        peers << connection.peer
      end

      peersToWake = user.peers.where("id NOT IN (:id)", { id: [peers.map(&:id), -1].flatten }).all
      peersToWake.each { |peer| peer.shards.create(content: msg) } if options[:persist]
      
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