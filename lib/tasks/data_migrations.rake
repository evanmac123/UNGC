namespace :data do

  desc "rename LocalNetwork states"
  task rename_local_network_states: :environment do
    LocalNetwork.transaction do
      puts LocalNetwork.where(state: 'Established').update_all(state: 'Active')
      puts LocalNetwork.where(state: 'Formal').update_all(state: 'Advanced')
    end
  end

end
