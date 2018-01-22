class AddContainerPathToInitiatives < ActiveRecord::Migration
  def up
    add_column :initiatives, :sitemap_path, :string, limit: 255

    initiatives = Hash["Anti-Corruption Working Group", '/take-action/action/anti-corruption-working-group',
        "Business for Peace Signatories", '/take-action/action/peace',
        "Call to Action: Anti-Corruption and the Post-2015 Development Agenda", '/take-action/action/anti-corruption-call-to-action',
        "Carbon Pricing Champions", '/take-action/action/carbon',
        "Caring For Climate", '/take-action/action/climate',
        "Caring for Climate (non-business)", '/take-action/action/climate',
        "CEO Water Mandate", '/take-action/action/water-mandate',
        "Child Labour Platform", '/take-action/action/child-labour',
        "Founding Companies", '/what-is-gc/participants?search[keywords]=&search[initiatives][]=13',
        "GC 100", '/take-action/action/global-compact-100',
        "Global Compact Board Programme", '/take-action/action/gc-board-programme',
        "Global Compact LEAD", '/take-action/leadership/gc-lead',
        "Human Rights and Labour Working Group", '/take-action/action/human-rights-labour-working-group',
        "Supply Chain Advisory Group", '/take-action/action/human-rights-labour-working-group',
        "Women's Empowerment Principles", '/take-action/action/womens-principles',]

    initiatives.each do |k, v|
      Initiative.find_by!(name: k).update_columns(sitemap_path: v) unless v.blank?
    end

  end

  def down
    remove_column :initiatives, :sitemap_path
  end
end
