class RedesignPreview

  def self.permitted?(contact_or_id)
    return true if Rails.env.test?

    contact = if contact_or_id.respond_to?(:id)
      contact_or_id.id
    else
     contact_or_id
    end

     [134841, 28987, 8622, 32100, 134571, 41905, 42409, 42175, 17778, 120871, 132021, 137311, 139061].include?(contact)
  end

end
