module ShardBroker
  module State
    class Base
      attr_accessor :connection

      def initialize(connection)
        self.connection = connection
      end

      def onPing!
        
      end

      def onResponse(action)
        raise "Implement onAction"
      end

      def onAction(action)
        raise "Implement onAction"
      end

      def onEnter
        raise "Implement onEnter"
      end

      def onExit
        raise "Implement onExit"
      end

      def afterExit
        clearTimeoutAfter!
      end

      def timeoutAfter!(seconds)
        @timeout_timer = EventMachine.add_timer seconds, proc { connection.timeout! }
      end

      def clearTimeoutAfter!
        return if @timeout_timer.nil?
        EventMachine.cancel_timer @timeout_timer
        @timeout_timer = nil
      end
    end
  end
end