module ShardBroker
  module State
    class Init < Base
      TIMEOUT = ShardBroker.env == :development ? 120 : 15

      def onEnter
        timeoutAfter!(TIMEOUT)
        connection.send_start_stream_tag

        action = Action.new
        action.setId(ShardBroker.guid)
        action.setType("status")
        action.addParam("secret", connection.getConnectionSecret)
        action.addParam("version", VERSION)
        action.addParam("uptime", ShardBroker.uptime)
        connection.write(action)
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

      def onResponse(node)
        
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
              response.addParam("in-relationship", user.inRelationship?)

              connection.write(response)
              proceedAuthWithPeer(peer)
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
          params = {
            "token" => nil
          }.merge(node.params)

          peer = Peer.where(token: params["token"]).first
          if peer
            response = node.getResponse
            response.setStatus(ShardBroker::Status::SUCCESS)
            response.addParam("in-relationship", peer.user.inRelationship?)
            connection.write(response)

            proceedAuthWithPeer(peer)
          else
            connection.writeActionError(node, ShardBroker::Status::INVALID_PASSWORD_ERROR, "Invalid token")
          end
        else
          connection.writeActionError(node, ShardBroker::Status::INVALID_ACTION_PACKAGE, "No #{ShardBroker::Action::ELEMENT_TOKEN.inspect} element!")
        end
      end

      def proceedAuthWithPeer(peer)
        ShardBroker.server.closeConnectionForPeer(peer)
        connection.peer = peer
        peer.last_login = Time.now
        peer.save

        if peer.user.inRelationship?
          connection.go ShardBroker::State::Sync
        else
          connection.go ShardBroker::State::Relationship
        end
      end
    end
  end
end
