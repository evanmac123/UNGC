class Redesign::ParticipantSearchController < Redesign::ApplicationController

  def index
    set_current_container :highlight, '/participant-search'
    @page = create_page
    @search = ParticipantSearch::Presenter.new
  end

  def search
    @page = create_page
    form = ParticipantSearch::Form.new(search_params)
    results = ParticipantSearch::Search.new(form).execute
    @search = ParticipantSearch::ResultsPresenter.new(form, results)
  end

  private

  def search_params
    params.require(:search).permit(:organization_type)
  end

  def create_page
    ParticipantSearch::Page.new(current_container, current_payload_data)
  end

  module ParticipantSearch

    class Presenter < SimpleDelegator

      def initialize(search = nil)
        super(search || ParticipantSearch::Form.new)
      end

      def organization_type_options
        OrganizationType.pluck(:name, :id)
      end

      def initiative_options
        Initiative.pluck(:name, :id)
      end

      def geography_options
        Country.pluck(:name, :id)
      end

    end

    class ResultsPresenter < ParticipantSearch::Presenter
      attr_accessor :results

      def initialize(search, results)
        super(search)
        @results = results || Results.new
      end

      def with_results(&block)
        if results.any?
          block.call(results)
        end
      end

      def no_results(&block)
        if results.empty?
          block.call
        end
      end

    end

    class Page < ContainerPage

      def blurb
        "The Compact: 8,0000 Companies + 4,000 Non-Businesses"
      end

      def hero
        {
          title: {}
        }
      end

      # TODO add parent, sibling, children menu

    end

    class Form
      include ActiveModel::Model

      attr_accessor :organization_type

      def page
        @page || 1
      end

      def per_page
        @per_page || 12
      end

      def order
        @order
      end

    end

    class Results
      attr_reader :results

      def initialize(results = nil)
        @results = results || []
      end

      def any?
        results.any?
      end

      def empty?
        results.empty?
      end

      def count
        results.count
      end

      def each(&block)
        results.map do |r|
          Result.new(r)
        end.each(&block)
      end

      class Result < SimpleDelegator

        def type
          organization.organization_type.name
        end

        def sector
          organization.sector.name
        end

        def country
          organization.country.name
        end

        def company_size
          organization.employees
        end

        private

        def organization
          __getobj__
        end

      end

    end

    class Search
      attr_reader :search

      def initialize(search)
        @search = search
      end

      def execute
        search_results = Organization.search(keywords, options)
        Results.new(search_results)
      end

      private

      def keywords
        ''
      end

      def options
        options = {}

        if search.organization_type.present?
          options[:organization_type_id] = search.organization_type
        end

        {
          page: search.page || 1,
          per_page: search.per_page || 12,
          order: search.order,
          star: true,
          with: options
        }
      end

    end

  end

end
