class AboutFoundationPage < ArticlePage

  def initialize(container, data, new_donation_url)
    super(container, data)
    @new_donation_url = new_donation_url
  end

  def sidebar_widgets
    # inject a contribute CTA
    contribute_cta = {
      label: "Contribute by Credit Card",
      external: false,
      url: @new_donation_url
    }

    @data[:widget_calls_to_action] ||= []
    @data[:widget_calls_to_action] << contribute_cta
    super
  end

end
