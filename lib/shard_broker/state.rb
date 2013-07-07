require_relative "state/base"
require_relative "state/init"
require_relative "state/relationship"
require_relative "state/sync"

module ShardBroker
  module State
    def go(state_klass)
      if @current_state
        @current_state.onExit
        @current_state.afterExit
        ShardBroker.logger.info "Moving from state: #{@current_state.class} to #{state_klass}"
      else
        ShardBroker.logger.info "Moving to state: #{state_klass}"
      end  

      @current_state = state_klass.new(self)
      @current_state.onEnter
    end

    def getCurrentState
      @current_state
    end

    def runStateWith(node)
      if getCurrentState
        EM.synchrony do 
          if node.is?(ShardBroker::ProtocolTags::PING_TAG)
            getCurrentState.onPing!
          elsif node.is?(ShardBroker::Action::TAG)
            getCurrentState.onAction(node)
          elsif node.is?(ShardBroker::Response::TAG)
            getCurrentState.onResponse(node)
          end
        end
      end
    end

  end
end