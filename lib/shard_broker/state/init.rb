module ShardBroker
  module State
    class Init < Base
      TIMEOUT = 15

      def onEnter
        timeoutAfter!(TIMEOUT)
        connection.send_start_stream_tag
      end

      def onAction(node)
        if node.is?(ShardBroker::Action::TAG)
          if node.type?(ShardBroker::Action::ACTION_REGISTRATION)
            handleRegistrationNode(node) 
          elsif node.type?(ShardBroker::Action::ACTION_AUTH)
            handleAuthNode(node) 
          else
            connection.write_error(ShardBroker::Status::UNSUPPORTED_TYPE_ERROR, "", node.getId)
          end
        else
          connection.write_error(ShardBroker::Status::UNDEFINED_COMMAND_ERROR)
        end
      end

      def onExit
        
      end

      private

      def handleRegistrationNode(node)
        if validRegistrationNode?(node)
          
        else
          connection.write_error(ShardBroker::Status::INVALID_ACTION_PACKAGE, "Invalid package", node.getId)
        end
      end

      def handleAuthNode(node)
        if node.have?(ShardBroker::Action::ELEMENT_TOKEN)
          
        else
          connection.write_error(ShardBroker::Status::INVALID_ACTION_PACKAGE, "No #{ShardBroker::Action::ELEMENT_TOKEN.inspect} element!", node.getId)
        end
      end

      def validRegistrationNode?(node)
        node.have?(ShardBroker::Action::LOGIN_TAG) && node.have?(ShardBroker::Action::PASSWORD_TAG) && node.have?(ShardBroker::Action::DEVICE_TAG) && node.have?(ShardBroker::Action::ENCRYPTION_KEY_TAG) && node.have?(ShardBroker::Action::SIGN_KEY_TAG)
      end
    end
  end
end