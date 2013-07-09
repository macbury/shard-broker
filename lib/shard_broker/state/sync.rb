module ShardBroker
  module State
    class Sync < Base
      def onEnter
        sendDevices
      end

      def onResponse(node)
        
      end

      def onAction(node)
      end

      def onPing!
        ShardBroker.logger.info "Ping!"
      end

      def onExit

      end

      def sendDevices
        action = Action.new
        action.setType("network-map")
        action.addArray("device", { test: "2" })
        connection.write(action)
      end
    end
  end
end