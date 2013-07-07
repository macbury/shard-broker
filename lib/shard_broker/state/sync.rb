module ShardBroker
  module State
    class Sync < Base
      def onEnter
        
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
    end
  end
end