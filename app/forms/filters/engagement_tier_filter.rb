class Filters::EngagementTierFilter < Filters::FlatSearchFilter

  def initialize(selected)
    items = Organization.level_of_participations

    super(items, selected)
    self.label = 'Tier'
    self.key = 'engagement_tiers'
  end

  protected

  def item_option(name_and_id)
    name, id = name_and_id
    humanized_name = I18n.t(name, scope: "engagement_tiers.filter_labels")
    FilterOption.new(id, humanized_name, key, selected.include?(id), label)
  end
end
