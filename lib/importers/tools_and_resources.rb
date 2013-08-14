require_relative "./excel_importer"

module Importers

  class InvalidLanguage < StandardError
    def initialize(language)
      super
      @language = language
    end
    def to_s
      "Invalid language: #{@language}"
    end
  end

  class ToolsAndResourcesImporter
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def self.import(path)
      self.new(path).run
    end

    def workbook
      @workbook ||= Spreadsheet.open(path)
    end

    def worksheet(name)
      workbook.worksheet(name)
    end

    def run
      import_resources(worksheet('resources'))
      import_resources_links(worksheet('resources_links'))
      import_authors(worksheet('authors'))
      import_resources_authors(worksheet('resources_authors'))
    end

    def import_resources(sheet)
      each_row(sheet) do |row|
        attrs = ResourceAttrs.new(*row)
        resource = Resource.find_or_create_by_id(attrs.id)
        resource.update_attributes(attrs.to_h)
      end
    end

    def import_resources_links(sheet)
      each_row(sheet) do |row|
        begin
          attrs = ResourceLinkAttrs.new(*row)
          resource = Resource.find(attrs.resource_id)
          resource.links.create!(attrs.to_h)
        rescue => e
          puts "Error: #{e}"
        end
      end
    end

    def import_authors(sheet)
      each_row(sheet) do |row|
        attrs = AuthorAttrs.new(*row)
        author = Author.find_or_create_by_id(attrs.id)
        author.update_attributes(attrs.to_h)
      end
    end

    def import_resources_authors(sheet)
      each_row(sheet) do |row|
        attrs = AuthorResourceAttrs.new(*row)
        author = Author.find(attrs.author_id)
        resource = Resource.find(attrs.resource_id)
        unless author.resources.include?(resource)
          author.resources << resource
        end
      end
    end

    private

    def each_row(sheet, &block)
      sheet.each(1, &block) # skip the header row
    end

    ResourceAttrs = Struct.new(:id, :title, :year_f, :description, :image_url_s, :isbn) do

      def year
        begin
          if year_f == 'ongoing'
            Time.new
          elsif year_f > 0
            Time.new(year_f)
          end
        rescue
          nil
        end
      end

      def image_url
        if image_url_s.present? && image_url_s != 'n/a'
          image_url_s
        end
      end

      def to_h
        {
          id: id,
          title: title,
          year: year,
          description: description,
          image_url: image_url,
          isbn: isbn,
        }
      end
    end

    ResourceLinkAttrs = Struct.new(:resource_id, :resource_title, :url, :title, :language_s, :type) do

      def language_id
        language = Language.where(name: language_s).first
        if language.nil?
          raise InvalidLanguage.new(language_s)
        else
          language.id
        end
      end

      def to_h
        {
          url: url,
          title: title,
          link_type: type,
          resource_id: resource_id,
          language_id: language_id,
        }
      end
    end

    AuthorAttrs = Struct.new(:id, :full_name, :acronym) do
      def to_h
        {
          id: id,
          full_name: full_name,
          acronym: acronym,
        }
      end
    end

    AuthorResourceAttrs = Struct.new(:resource_id_or_formula, :resource_title, :author_id, :author_name) do

      def resource_id
        if resource_id_or_formula.respond_to?(:value)
          resource_id_or_formula.value
        else
          resource_id_or_formula
        end
      end

      def to_h
        {
          resource_id: resource_id,
          author_id: author_id,
        }
      end
    end
  end
end
