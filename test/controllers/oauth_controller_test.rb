require 'test_helper'

class OauthControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get oauth_index_url
    assert_response :success
  end

  test "should get callback" do
    get oauth_callback_url
    assert_response :success
  end

  test "should get authrize" do
    get oauth_authrize_url
    assert_response :success
  end

  test "should get send_message" do
    get oauth_send_message_url
    assert_response :success
  end

end
