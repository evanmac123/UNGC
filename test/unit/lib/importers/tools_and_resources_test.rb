require 'test_helper'
require './lib/importers/tools_and_resources'

class Sheet
  def initialize(sheet=[])
    @sheet = sheet.unshift(header_row)
  end

  def header_row
    %w(resource_id title year description image_url ISBN)
  end

  def each(skip, &block)
    @sheet.drop(skip).each(&block)
  end
end

class ToolsAndResourcesTest < ActiveSupport::TestCase

  setup do
    @importer = Importers::ToolsAndResourcesImporter.new('fake')
  end

  context "When importing resources" do

    should "not import the header row" do
      sheet = Sheet.new [[1, 't', 2012.0, 'd', 'i', 'is']]
      @importer.import_resources(sheet)
      assert_equal 1, Resource.count, "should not have imported the header."
    end

    context "with normal values" do

      setup do
        sheet = Sheet.new [[11, 'title1', 2012.0, 'description1', 'image_url1', 'isbn1']]
        @importer.import_resources(sheet)
        @resource = Resource.find(11)
      end

      should "create resources" do
        assert_not_nil @resource
      end

      should "import id" do
        assert_equal 11, @resource.id
      end

      should "import title" do
        assert_equal 'title1', @resource.title
      end

      should "import year" do
        assert_equal 2012, @resource.year.year
      end

      should "import description" do
        assert_equal 'description1', @resource.description
      end

      should "import image_url" do
        assert_equal 'image_url1', @resource.image_url
      end

      should "import isbn" do
        assert_equal "isbn1", @resource.isbn
      end
    end

    context "with n/a values" do
      setup do
        sheet = Sheet.new [[22, 'title2', 'n/a', 'n/a', 'n/a', '']]
        @importer.import_resources(sheet)
        @na = Resource.find(22)
      end

      should "not import n/a as a year" do
        assert_nil @na.year
      end

      should "not import n/a images" do
        assert_nil @na.image_url
      end
    end

    context "empty values" do
      setup do
        sheet = Sheet.new [[33, 'title3', '', 'description3', '']]
        @importer.import_resources(sheet)
        @empty = Resource.find(33)
      end

      should "not import empty year" do
        assert_nil @empty.year
      end

      should "not import empty images" do
        assert_nil @empty.image_url
      end
    end

    should "import 'ongoing' as the year of import" do
      sheet = Sheet.new [[44, 'title4', 'ongoing', 'n/a', 'n/a', '']]
      @importer.import_resources(sheet)
      assert_equal Time.now.year, Resource.find(44).year.year
    end

    context "nil and missing values" do
      setup do
        sheet = Sheet.new [[55, 'title5', nil, 'description5']]
        @importer.import_resources(sheet)
        @nil = Resource.find(55)
      end

      should "not import nil year" do
        assert_nil @nil.year
      end

      should "not import nil image_url" do
        assert_nil @nil.image_url
      end

      should "not import nil isbn" do
        assert_nil @nil.isbn
      end
    end
  end

  context "When importing links" do
  end

  context "When importing authors" do
  end

  context "When importing authors/resources" do
  end

end
