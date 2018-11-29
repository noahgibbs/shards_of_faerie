module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    def setup
      @user = User.create(name: "John", email: "bobo@dyne.com", password: "s00pers33krit")
      @user.save!
    end

    def test_connects_with_cookies
      connect cookies: { "user.id" => @user.id }
      assert_equal "John", connection.current_user.name
    end

    def test_rejects_with_no_user
      assert_reject_connection do
        connect
      end
    end
  end
end
