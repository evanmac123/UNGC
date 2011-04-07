require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  context "given a hash of key/value" do
    setup do
      hash = {:one => "Number One"}
      @select_tag = select 'model', 'attribute', select_options_from_hash(hash)
    end

    should "create select <option> based on reversed key/value" do
      assert @select_tag.include?('<option value="one">Number One</option>')
    end
  end

end

