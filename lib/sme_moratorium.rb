# rails runner 'SmeMoratorium.new.run'
# bundle exec rails runner -e production 'SmeMoratorium.new.run' 
#  Organization.about_to_end_sme_extension.each {|o| o.delist}

class SmeMoratorium
  def run
    
    # Organization.update_all(inactive_on: nil)

    smes = Organization.participants.active.smes.noncommunicating.where(cop_due_on: '2012-12-21'..'2013-12-21')
    inactives = []
    have_submitted = []
    smes.each do |sme|
      if sme.communication_on_progresses.approved.count == 0
        date_diff = (sme.cop_due_on - sme.joined_on).to_i
        date_diff = (date_diff / 365).to_i
        if date_diff >= 2
          inactives << sme.id
        end
      elsif sme.communication_on_progresses.approved.any?
        latest_cop = sme.communication_on_progresses.approved.all(order: 'created_at DESC').first
        cop_date_diff = (sme.cop_due_on - latest_cop.created_at.to_date).to_i
        cop_date_diff = (cop_date_diff / 365).to_i
        if cop_date_diff >= 2
          # puts "Org ID: #{sme.id} - #{latest_cop.created_at.to_date}: #{sme.cop_due_on} - #{latest_cop.title}"
          inactives << sme.id
        elsif cop_date_diff <= 2
          # puts "Org ID: #{sme.id} - #{latest_cop.created_at.to_date}: #{sme.cop_due_on} - #{latest_cop.title}"
        end
      end
    end

    inactives.each do |id|
      org = Organization.find(id)
      org.update_attribute :inactive_on, org.cop_due_on
      puts "Setting inactive_on for Organization #{id} to #{org.cop_due_on}"
    end

    puts "There are #{smes.count} SMEs and #{inactives.count} to be delisted."


  end # run
end # class SmeMoratorium
