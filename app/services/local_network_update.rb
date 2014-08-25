class LocalNetworkUpdate

  def self.update(*args)
    new(*args).update
  end

  def initialize(local_network, params)
    @local_network = local_network
    @params = params
  end

  def update
    LocalNetwork.transaction do
      @local_network.update_attributes!(@local_network_params)
      update_contribution_levels if has_contribution_level_params?
    end
    @local_network
  end

  private

  def update_contribution_levels
    contribution_levels.update_attributes(description_params)
    delete_old_levels
    save_new_and_updated_levels
  end

  def delete_old_levels
    ids = updated_levels.map(&:id).compact
    if ids.empty?
      levels.delete_all
    else
      levels.where('id not in (?)', ids).delete_all
    end
  end

  def save_new_and_updated_levels
    updated_levels.map(&:save!)
  end

  def updated_levels
    @updated_levels ||= levels_params.map do |params|
      id = params[:id]
      description = params[:description]
      amount = params[:amount]

      next if description.blank? || amount.blank?

      contribution_level = levels.find_or_initialize_by_id(params[:id])
      contribution_level.id = id
      contribution_level.description = description
      contribution_level.amount = amount
      contribution_level
    end.compact
  end

  def has_contribution_level_params?
    @params.has_key? :contribution_levels
  end

  def description_params
    @description_params ||= @params.fetch(:contribution_levels).slice(:level_description, :amount_description, :pledge_description, :payment_description, :contact_description, :additional_description)
  end

  def levels_params
    @levels_params ||= @params.fetch(:contribution_levels).fetch(:levels, [])
  end

  def contribution_levels
    @local_network.contribution_levels
  end

  def levels
    contribution_levels.levels
  end

end
