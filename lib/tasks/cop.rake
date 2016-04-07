namespace :cop do

  desc "delete duplicate cop answers for a COP"
  task :dedupe_answers, [:cop_id] => :environment do |t, args|
    cop_id = args[:cop_id]
    all_answers = CopAnswer.where(cop_id: cop_id).order('created_at desc')
    count_before = all_answers.count

    grouped = all_answers.group_by do |answer|
      answer.cop_attribute_id
    end

    to_delete = []
    grouped.each do |cop_attribute_id, answers|
      to_delete += answers.drop(1)
    end

    to_delete.map(&:destroy)

    count_after = CopAnswer.where(cop_id: cop_id).count

    puts "Deleted duplicate answers: #{count_before} =>  #{count_after}"
  end

  desc "find COPs with duplicate answers"
  task :with_duplicated_answers => :environment do
    puts CopAnswer.
      select('distinct cop_id').
      group(:cop_attribute_id).
      having('count(cop_attribute_id) > 1').
      pluck(:cop_id).
      uniq
  end

end
