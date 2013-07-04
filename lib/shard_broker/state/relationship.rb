module ShardBroker
  module State
    class Relationship < Base
      def onEnter 
        connection.peer.user.invitations.isNotAccepted.all.each do |invitation|
          connection.write(buildInvitationAction(invitation.user))
        end
      end

      def onResponse(node)
        
      end

      def onAction(node)
        if node.is?(ShardBroker::Action::TAG)
          if node.type?(ShardBroker::Action::ACTION_INVITE)
            inviteUser(node)
          elsif node.type?(ShardBroker::Action::ACTION_INVITE_ACCEPT)
            acceptUser(node)
          else
            connection.writeActionError(node, ShardBroker::Status::UNSUPPORTED_TYPE_ERROR, "")
          end
        else
          connection.write_error(ShardBroker::Status::UNDEFINED_COMMAND_ERROR)
        end
      end

      def buildInvitationAction(fromUser)
        action = Action.new
        action.setType(ShardBroker::Action::ACTION_INVITE_PENDING)
        action.setId(ShardBroker.guid)
        action.addParam("email", fromUser.email)
        action
      end

      def acceptUser(node)
        params = {
          "email"           => nil
        }.merge(node.params)

        userToInvite = User.where(email: params["email"]).first
        currentUser  = connection.peer.user

        if currentUser.inRelationship?
          connection.writeActionError(node, ShardBroker::Status::RELATIONSHIP_ERROR, "User already in relationship!")
          connection.go ShardBroker::State::Sync
        else
          if userToInvite
            if userToInvite.inRelationship?
              connection.writeActionError(node, ShardBroker::Status::RELATIONSHIP_ERROR, "User #{userToInvite.email} already in relationship!")
            else
              if userToInvite.accept!(currentUser)
                response = node.getResponse
                response.setStatus(ShardBroker::Status::SUCCESS)
                connection.write(response)
                ShardBroker.server.sendActionToUser(buildInvitationAction(currentUser), userToInvite)
                ShardBroker.server.closeConnectionForUser(userToInvite)
                ShardBroker.server.closeConnectionForUser(currentUser)
              else
                connection.writeActionError(node, ShardBroker::Status::RELATIONSHIP_ERROR, "Cannot invite user #{userToInvite.email}")
              end
            end
          else
            connection.writeActionError(node, ShardBroker::Status::PARAMS_ERROR, "User with email: "+params["email"] + " not found")
          end
        end
      end

      def inviteUser(node)
        params = {
          "email"           => nil
        }.merge(node.params)

        userToInvite = User.where(email: params["email"]).first
        currentUser  = connection.peer.user

        if currentUser.inRelationship?
          connection.writeActionError(node, ShardBroker::Status::RELATIONSHIP_ERROR, "User already in relationship!")
          connection.go ShardBroker::State::Sync
        else
          if userToInvite
            if userToInvite.inRelationship?
              connection.writeActionError(node, ShardBroker::Status::RELATIONSHIP_ERROR, "User #{userToInvite.email} already in relationship!")
            else
              if currentUser.invite!(userToInvite)
                response = node.getResponse
                response.setStatus(ShardBroker::Status::SUCCESS)
                connection.write(response)
                ShardBroker.server.sendActionToUser(buildInvitationAction(currentUser), userToInvite)
              else
                connection.writeActionError(node, ShardBroker::Status::RELATIONSHIP_ERROR, "Cannot invite user #{userToInvite.email}")
              end
            end
          else
            connection.writeActionError(node, ShardBroker::Status::PARAMS_ERROR, "User with email: "+params["email"] + " not found")
          end
        end
      end

      def onExit

      end
    end
  end
end