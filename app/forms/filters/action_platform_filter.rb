class Filters::ActionPlatformFilter < Filters::FlatSearchFilter

  def initialize(selected_ids)
    items = ActionPlatform::Platform.select(:id, :name)
    super(items, selected_ids)
    self.label = 'Platform'
    self.key = 'action_platforms'
  end

  protected

  def item_option(platform)
    FilterOption.new(platform.id, platform.name, key, selected.include?(platform.id), label)
  end

end
