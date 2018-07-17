# frozen_string_literal: true

class AcademyPage < ContainerPage
  def initialize(container, payload_data)
    super(container, payload_data)
  end

  def title
    @data.dig(:hero, :title, :title1)
  end

  def hero
    hero = @data.fetch(:hero) { Hash.new }
    hero.reverse_merge(size: "small")
  end

  def blurb
    @data.dig(:hero, :blurb) || ""
  end

  def accordion
    @_accordion ||= Accordion.new(@data.fetch(:accordion, {}))
  end

  def article_blocks
    Array(@data[:article_blocks])
  end

  def logos_and_partners
    OpenStruct.new(@data.fetch(:logos_and_partners))
  end

  private

  class Accordion
    attr_reader :title, :blurb

    def initialize(attributes)
      @title = attributes.fetch(:title) { "" }
      @blurb = attributes.fetch(:blurb) { "" }
      @items = attributes.fetch(:items) { [] }
    end

    def items
      @_wrapped_items ||= @items.map do |item|
        OpenStruct.new(item)
      end
    end

  end

end
