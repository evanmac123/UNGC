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
      group(:cop_id, :cop_attribute_id).
      having('count(cop_attribute_id) > 1').
      pluck(:cop_id).
      uniq
  end

  desc "find COPs with answers for b4p who are not signatories"
  task :non_b4p_signatories_with_answers => :environment do
    b4p = Initiative.id_by_filter(:business4peace)
    puts CopAnswer.
      joins(communication_on_progress: [organization: :signings]).
      joins(cop_attribute: [:cop_question]).
      where(cop_questions: {grouping: 'business_peace'}).
      where.not(signings: {initiative_id: b4p}).
      where(value: false, text: '').
      where(communication_on_progresses: {differentiation: 'advanced'}).
      delete_all
  end

end
