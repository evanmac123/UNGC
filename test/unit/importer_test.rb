require 'test_helper'

class ImporterTest < ActiveSupport::TestCase
  context "given a new Importer object" do
    setup do
      @importer = Importer.new
    end
    
    should "run without throwing exceptions" do
      assert_nothing_raised do
        @importer.run(:folder => File.join(RAILS_ROOT, 'test/fixtures/un7_tables'),
                      :silent => true)
        @importer.delete_all
        assert_equal 0, Contact.count
        assert_equal 0, LogoRequest.count
        assert_equal 0, LogoComment.count
        assert_equal 0, Organization.count
      end
    end
  end
  
  context "given a new HabtmImporter object" do
    setup do
      @importer = HabtmImporter.new
    end
    
    should "run without throwing exceptions" do
      assert_nothing_raised do
        @importer.run(:folder => File.join(RAILS_ROOT, 'test/fixtures/un7_tables'),
                      :silent => true)
      end
    end
  end
end
