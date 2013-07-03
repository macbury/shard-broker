module ShardBroker
  module State
    class PrepareToAuth < Base
      TIMEOUT = 15

      def onEnter
        timeoutAfter!(TIMEOUT)
      end

      def onExit

      end
    end
  end
end