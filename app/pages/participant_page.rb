class ParticipantPage < SimpleDelegator

  attr_reader :container

  def initialize(container, participant, campaigns_by_year)
    super(participant)
    @campaigns_by_year = campaigns_by_year
    @container = container
  end

  def hero
    {
      title: {
        title1: 'The Compact:',
        title2: '8,000 Companies + 4,000 Non-Businesses'
      },
      size: 'small',
      show_section_nav: true
    }
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def meta_title
    participant.name
  end

  def meta_description
  end

  def website
    URI::parse(website_url).hostname
  end

  def website_url
    participant.url
  end

  def has_website?
    website_url.present?
  end

  def country
    participant.country.try(:name)
  end

  def type
    participant.organization_type.name
  end

  def sector
    participant.sector.name
  end

  def ownership
    participant.listing_status.try(:name)
  end

  def joined_on
    participant.joined_on.try(:strftime, '%B, %Y')
  end

  def cops
    communication_on_progresses
  end

  def contributions
    @campaigns_by_year
  end

  def has_extra_information?
    has_financial_information? || has_non_financial_information?
  end

  def financial_information
    if has_financial_information?
      [{
        links: [{
          label: 'Google Finance',
          url: "http://finance.google.com/finance?q=%s:%s" % [exchange.code, stock_symbol]
        },{
          label: 'Yahoo! Finance',
          url: "http://finance.yahoo.com/q?s=%s%s" % [stock_symbol, ('.' + exchange.secondary_code unless exchange.secondary_code.blank?)]
        }]
      }]
    end
  end

  def has_financial_information?
    stock_symbol.present? && exchange.present?
  end

  def non_financial_information
    [{
      links: [{
        label: 'Business and Human Rights Resource Centre',
        url: 'http://www.business-humanrights.org/Categories/Individualcompanies/' + bhr_url
      }]
    }]
  end

  def has_non_financial_information?
    bhr_url.present?
  end

  private

  def participant
    __getobj__
  end

end
