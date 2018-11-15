require 'test_helper'

class WordsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    get answer_url
    
    assert_response :success
  end

end
