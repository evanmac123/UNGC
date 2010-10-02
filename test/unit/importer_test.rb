require 'test_helper'

class ImporterTest < ActiveSupport::TestCase
  # context "given a new Importer object" do
  #   setup do
  #     @importer = Importer.new
  #   end
  #   
  #   should "run without throwing exceptions" do
  #     assert_nothing_raised do
  #       @importer.run(:folder    => File.join(RAILS_ROOT, 'test/fixtures/un7_tables'),
  #                     :silent    => true,
  #                     :run_habtm => false)
  #       @importer.delete_all
  #       assert_equal 0, Contact.count
  #       assert_equal 0, LogoRequest.count
  #       assert_equal 0, LogoComment.count
  #       assert_equal 0, Organization.count
  #     end
  #   end
  #   
  #   should "properly set the pledge_amount field" do
  #     @importer.run(:folder    => File.join(RAILS_ROOT, 'test/fixtures/un7_tables'),
  #                   :files     => [:sector, :organization_type, :organization],
  #                   :silent    => true)
  #     # ORG with id = 4 has a non-null pledge
  #     organization = Organization.find_by_old_id(4)
  #     assert_not_nil organization
  #     assert_equal 500, organization.pledge_amount
  #   end
  # end
  # 
  # context "given a new HabtmImporter object" do
  #   setup do
  #     @importer = HabtmImporter.new
  #   end
  #   
  #   should "run without throwing exceptions" do
  #     assert_nothing_raised do
  #       @importer.run(:folder => File.join(RAILS_ROOT, 'test/fixtures/un7_tables'),
  #                     :silent => true)
  #     end
  #   end
  # end
end
