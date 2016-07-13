# Feature flags.
# Add predicates here for enabling/disabling features
class Feature

  # The SDG Pioneer forms are only open for a short time every year.
  def self.sdg_pioneer_form?
    feature_enabled = false
    feature_enabled ||
      Rails.env.test? # enable the forms for tests
  end

  def self.send_featured_events_to_landing?
    # temporarily send featured events to the events landing page
    # until we formalize the feature.
    false
  end

end
