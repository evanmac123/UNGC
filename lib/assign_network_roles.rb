# ./script/runner 'AssignNetworkRoles.new'

class AssignNetworkRoles
  def run
    
    # (1) Assign roles to Network Managers

    puts "Assigning roles\n"

    c = Contact.find([13224,23253,23254,23138,26273])
    c.each {|c| c.roles << Role.network_regional_manager}
    # c.roles.delete(Role.contact_point)

    # c = Contact.find([13224,23253,23254,23138,26273])
    c.each {|c| c.roles.delete(Role.ceo)}

    # (2) Assign Global Compact contact IDs to Regions

    # 13224 Meng, China
    # 23253 Nike, Africa
    # 23254 Javier, Americas
    # 23138 Walid, MENA and Europe
    # 26273 Yukako, Asia and Australasia

    puts "Assigning managers\n"

    Country.where_region('Africa').update_all(:manager_id => 23253)
    Country.where_region('Americas').update_all(:manager_id => 23254)
    Country.where_region('MENA').update_all(:manager_id => 23138)
    Country.where_region('Europe').update_all(:manager_id => 23138)
    Country.where_region('Asia').update_all(:manager_id => 26273)
    Country.where_region('Australasia').update_all(:manager_id => 26273)
    Country.find_by_name('China').update_attribute(:manager_id, 13224)
  end
end