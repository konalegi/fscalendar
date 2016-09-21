require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'should update users profile info' do
    user = users(:one)
    sign_in user
    new_name = 'New Name'
    put :update, { user: { full_name: new_name, password: '1231231', password_confirmation: '1231231' } }

    user.reload
    assert_equal new_name, user.full_name
  end

end