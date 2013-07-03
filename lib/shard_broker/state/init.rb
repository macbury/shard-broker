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
            connection.writeActionError(node, ShardBroker::Status::UNSUPPORTED_TYPE_ERROR, "")
          end
        else
          connection.write_error(ShardBroker::Status::UNDEFINED_COMMAND_ERROR)
        end
      end

      def onExit
        
      end

      private

      def handleRegistrationNode(node)
        params = {
          "email"           => nil,
          "password"        => nil,
          "device"          => nil,
          "signing-key"     => nil,
          "encryption-key"  => nil,
        }.merge(node.params)

        user = User.authOrCreateByEmailAndPassword(params["email"], params["password"])

        if user
          if user.valid?
            peer     = user.addPeer(params["device"], params["encryption-key"], params["signing-key"]) 
            if peer.valid?
              response = node.getResponse
              response.setStatus(ShardBroker::Status::SUCCESS)
              response.addParam("token", peer.token)
              connection.write(response)
              connection.close
            else
              connection.writeActionError(node, ShardBroker::Status::REGISTRATION_ERROR, peer.errors.full_messages.join(", "))
            end
          else
            connection.writeActionError(node, ShardBroker::Status::REGISTRATION_ERROR, user.errors.full_messages.join(", "))
          end
        else
          connection.writeActionError(node, ShardBroker::Status::INVALID_PASSWORD_ERROR, "Invalid password")
        end
      end

      def handleAuthNode(node)
        if node.have?(ShardBroker::Action::ELEMENT_TOKEN)
          
        else
          connection.writeActionError(node, ShardBroker::Status::INVALID_ACTION_PACKAGE, "No #{ShardBroker::Action::ELEMENT_TOKEN.inspect} element!")
        end
      end
    end
  end
end
