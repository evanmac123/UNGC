class MoveContributionDescriptions < ActiveRecord::Migration
  def up
    ContributionLevelsInfo.find_each do |info|
      ContributionDescription.create!(
        pledge: info.pledge_description,
        pledge_continued: info.pledge_description_continued,
        payment: info.payment_description,
        contact: info.contact_description,
        additional: info.additional_description,
        local_network_id: info.local_network_id
      )
    end
  end

  def down
    ContributionDescription.find_each do |desc|
      l = ContributionLevelsInfo.find_by_local_network_id(desc.local_network_id)
      l.update_attributes(
        pledge_description: desc.pledge,
        pledge_description_continued: desc.pledge_continued,
        payment_description: desc.payment,
        contact_description: desc.contact,
        additional_description: desc.additional
      )
    end
  end
end
