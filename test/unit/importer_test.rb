require 'test_helper'

class ImporterTest < ActiveSupport::TestCase
  context "given a new importer object" do
    setup do
      @importer = Importer.new
    end
    
    should "run without throwing exceptions" do
      assert_nothing_raised do
        @importer.run(:folder => File.join(RAILS_ROOT, 'test/fixtures/un7_tables'))
      end
    end
  end
end
