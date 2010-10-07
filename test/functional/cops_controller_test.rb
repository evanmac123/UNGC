require 'test_helper'

class CopsControllerTest < ActionController::TestCase

  context "given a request for feeds/cops" do
    setup do
      get :feed, :format => 'atom'
    end    
    
    should "display the atom feed" do  
      assert_template 'cops/feed.atom.builder'
    end
  end

end
