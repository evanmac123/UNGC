class AssignFundingModelValuesToLocalNetworks < ActiveRecord::Migration
  def up

    collaborative = [
      'Argentina',
      'Australia',
      'Belgium',
      'Brazil',
      'Canada',
      'Chile',
      'France',
      'Germany',
      'Ghana',
      'Gulf States',
      'India',
      'Indonesia',
      'Italy',
      'Mexico',
      'Netherlands',
      'Nigeria',
      'Nordic Network',
      'Paraguay',
      'Portugal',
      'South Africa',
      'Spain',
      'Switzerland',
      'Turkey',
      'Uganda',
      'UK',
      'USA'
    ]

    LocalNetwork.update_all({funding_model: 'collaborative'}, ["name IN (?)", collaborative])
    LocalNetwork.update_all({funding_model: 'independent'}, ["name NOT IN (?)", collaborative])
  end

  def down
    LocalNetwork.update_all({funding_model: nil})
  end
end
