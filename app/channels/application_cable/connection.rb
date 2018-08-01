module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      #logger.add_tags 'ActionCable', current_user.name
    end

    private

    def find_verified_user
      if verified_user = User.find_by(id: cookies.signed['user.id'])
        verified_user
      else
        #User.new  # Anonymous user
        "guest"  # TODO: fix guest logins, figure out how to assign a new user object to guests in a usable way...
        #reject_unauthorized_connection
      end
    end
  end
end
