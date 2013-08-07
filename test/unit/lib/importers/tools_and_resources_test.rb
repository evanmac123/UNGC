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

# TODO move to fixture
# def create_resource(attrs={})
  # defaults = {title:'resource', description:'description'}
  # Resource.create! attrs.merge(defaults.merge(attrs))
# end

# def create_author(attrs={})
#   defaults = {}#title:'resource', description:'description'}
#   Author.create! attrs.merge(defaults.merge(attrs))
# end

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

    setup do
      @language = create_language(name:"English")
      @resource = create_resource
      sheet = Sheet.new [[
        @resource.id,
        'res_title',
        'url1',
        'title1',
        @language.name,
        'web'
      ]]
      @importer.import_resources_links(sheet)
      @link = @resource.resource_links.find_by_url('url1')
    end

    should "not import the header row" do
      assert_equal 1, ResourceLink.count, "should not have imported the header."
    end

    should "create a link" do
      assert_not_nil @link
    end

    should "import resource_id" do
      assert_equal @resource.id, @link.resource_id
    end

    should "import url" do
      assert_equal "url1", @link.url
    end

    should "import title" do
      assert_equal "title1", @link.title
    end

    should "import link_type" do
      assert_equal "web", @link.link_type
    end

    should "import language_id" do
      assert_equal @language.id, @link.language_id
    end

    should "be associated with a resource" do
      assert @resource.resource_links.include?(@link)
      assert_equal @link.resource, @resource
    end
  end

  context "When importing authors" do

    setup do
      sheet = Sheet.new [[123, "bob barker", "PIR"]]
      @importer.import_authors(sheet)
      @author = Author.find(123)
    end

    should "not import the header row" do
      assert_equal 1, Author.count, "should not have imported the header."
    end

    should "import id" do
      assert_equal 123, @author.id
    end

    should "import full name" do
      assert_equal "bob barker", @author.full_name
    end

    should "import acronym" do
      assert_equal "PIR", @author.acronym
    end

  end

  context "When importing authors/resources" do

    setup do
      @author = create_author(id: 123)
      @resource = create_resource(id: 456)
      sheet = Sheet.new([[@resource.id, "title", @author.id]])
      @importer.import_resources_authors(sheet)
    end

    should "associate an author with a resource" do
      assert @author.resources.include?(@resource)
    end

    should "assicate a resource with an author" do
      assert @resource.authors.include?(@author)
    end
  end

end
