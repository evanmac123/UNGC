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
        title1: '9,000 companies',
        title2: '+ 4,000 non-businesses'
      },
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/b1/b1757c442f979297b1e13aa44dcaf58da156106a---forest.jpg',
      size: 'small',
      theme: 'light',
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
  rescue
    website_url
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
    if participant.joined_on.present?
      I18n.l(participant.joined_on)
    end
  end

  def cop_due_on
    if participant.cop_due_on.present?
      I18n.l(participant.cop_due_on)
    end
  end

  def expelled_on
    if participant.delisted_on.present?
      I18n.l(participant.delisted_on)
    end
  end

  def communication_type
    non_business? ? 'COE' : 'COP'
  end

  def next_communication_due_on
    "Next #{communication_type} due on:"
  end

  def cop_label
    non_business? ? 'Communication On Engagement' : 'Communication On Progress'
  end

  def cops
    communication_on_progresses.map {|cop| CommunicationOnProgressPresenter.new(cop)}
  end

  def global_compact_status
    I18n.t(participant.cop_state, scope: :reporting_status)
  end

  def reason_for_delisting
    participant.removal_reason.try(:description) || ''
  end

  def recommitment_letter
    participant.recommitment_letter.try(:attachment)
  end

  def contributions
    @campaigns_by_year.map do |year, campaigns|
      [year, campaigns.map { |c| CampaignPresenter.new(c) }]
    end
  end

  def action_platform_subscriptions
   participant.action_platform_subscriptions.active_at
  end

  class CommunicationOnProgressPresenter < SimpleDelegator

    def level
      if cop.differentiation.blank? && !cop.is_differentiation_program?
        'N/A'
      else
        cop.differentiation_level_name
      end
    end

    private

    def cop
      __getobj__
    end

  end

  # this is needed to have nicer names for campaigns
  # XXX remove it once the salesforce database is updated
  class CampaignPresenter < SimpleDelegator
    def name
      cname = campaign.name
      cname.sub(/C4C/,'Caring for Climate').
        sub(/CWM/, 'CEO Water Mandate').
        sub('WEP', "Women's Empowerment Principles")
    end

    def campaign
      __getobj__
    end
  end

  def has_extra_information?
    has_financial_information? || has_non_financial_information?
  end

  def financial_information
    if has_financial_information?
      [{
        links: [{
          label: 'Google Finance',
          url: "http://finance.google.com/finance?q=%s:%s" % [exchange.code, stock_symbol],
          external: true
        },{
          label: 'Yahoo! Finance',
          url: "http://finance.yahoo.com/q?s=%s%s" % [stock_symbol, ('.' + exchange.secondary_code unless exchange.secondary_code.blank?)],
          external: true
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
        url: 'http://www.business-humanrights.org/Categories/Individualcompanies/' + bhr_url,
          external: true
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
