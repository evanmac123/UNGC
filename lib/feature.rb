# Feature flags.
# Add predicates here for enabling/disabling features
class Feature
  class << self

    # The SDG Pioneer forms are only open for a short time every year.
    def sdg_pioneer_form?
      feature_enabled = false
      feature_enabled ||
        Rails.env.test? # enable the forms for tests
    end

  end
end
