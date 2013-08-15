require 'test_helper'
require './lib/importers/tools_and_resources_importer'

class ToolsAndResourcesTest < ActiveSupport::TestCase

  setup do
    @importer = Importers::ToolsAndResourcesImporter.new('test/fixtures/files/tools_and_resources.xls')
  end

  context "When importing resources" do

    setup do
      @importer.import_resources @importer.worksheet('resources')
    end

    should "not import the header row" do
      assert_equal 4, Resource.count, "should not have imported the header."
    end

    context "with normal values" do

      setup do
        @resource = Resource.find(1)
      end

      should "create resources" do
        assert_not_nil @resource
      end

      should "import id" do
        assert_equal 1, @resource.id
      end

      should "import title" do
        assert_equal 'Publications from the Office', @resource.title
      end

      should "import year" do
        assert_equal 2012, @resource.year.year
      end

      should "import description" do
        assert_equal 'As the first publication', @resource.description
      end

      should "import image_url" do
        assert_equal 'http://www.unglobalcompact.org/pics/example.png', @resource.image_url
      end

      should "import isbn" do
        assert_equal "ISBN1234", @resource.isbn
      end
    end

    context "with n/a values" do
      setup do
        @na = Resource.find(55)
      end

      should "not import n/a as a year" do
        assert_nil @na.year
      end

      should "not import n/a images" do
        assert_nil @na.image_url
      end
    end

    should "import 'ongoing' as the year of import" do
      assert_equal Time.now.year, Resource.find(5).year.year
    end

  end

  context "When importing links" do

    setup do
      # setup some languages
      @arabic = create_language(name:"Arabic")
      @english = create_language(name:"English")

      # import some resources
      @importer.import_resources @importer.worksheet('resources')

      @resource = Resource.find(2)

      link_sheet = @importer.worksheet('resources_links')
      @importer.import_resources_links(link_sheet)
      @link = @resource.links.find_by_resource_id(2)
    end

    should "not import the header row" do
      # there should only be 3 valid rows, excluding the header
      assert_equal 3, ResourceLink.count, "should not have imported the header."
    end

    should "import resource_id" do
      assert_equal 2, @link.resource_id
    end

    should "import url" do
      assert_equal "http://www.ohchr.org/Documents/Publications/GuidingPrinciplesBusinessHR_EN.pdf", @link.url
    end

    should "import title" do
      assert_equal "Guiding Principles on Business and Human Rights", @link.title
    end

    should "import link_type" do
      assert_equal "pdf", @link.link_type
    end

    should "import language_id" do
      assert_equal @english.id, @link.language_id
    end

    should "be associated with a resource" do
      assert @resource.links.include?(@link)
      assert_equal @link.resource, @resource
    end
  end

  context "When importing authors" do

    setup do
      author_sheet = @importer.worksheet('authors')
      @importer.import_authors(author_sheet)
      @deloitte = Author.find(3)
      @oxfam = Author.find(8)
    end

    should "not import the header row" do
      assert_equal 2, Author.count, "should not have imported the header."
    end

    should "import id" do
      assert_equal 3, @deloitte.id
    end

    should "import full name" do
      assert_equal "Deloitte", @deloitte.full_name
    end

    should "import acronym" do
      assert_equal "OHCHR", @deloitte.acronym
    end

    should "allow empty acronym" do
      assert_nil @oxfam.acronym
    end

  end

  context "When importing authors/resources" do

    setup do
      @importer.import_resources @importer.worksheet('resources')
      @importer.import_authors @importer.worksheet('authors')

      sheet = @importer.worksheet('resources_authors')
      @importer.import_resources_authors(sheet)

      @deloitte = Author.find(3)
      @publications = Resource.find(1)
      @guiding_principles = Resource.find(2)
    end

    should "associate a resource with an author" do
      assert @guiding_principles.authors.include?(@deloitte)
    end

    should "associate resources by vlookup" do
      assert @deloitte.resources.include?(@publications)
    end

    should "associate resources by numeric id" do
      assert @deloitte.resources.include?(@guiding_principles)
    end
  end

  context "Destroying" do
    should "destroy depedent links" do
      link = create_resource_link
      link.resource.destroy
      assert_equal 0, ResourceLink.count
    end
  end

end
