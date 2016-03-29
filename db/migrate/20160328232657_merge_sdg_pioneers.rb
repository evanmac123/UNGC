class MergeSdgPioneers < ActiveRecord::Migration
  def up
    add_column :sdg_pioneer_submissions, :tmp_old_id, :integer
    update migrate_sdg_pioneer_businesses
    update migrate_sdg_pioneer_individuals
    update migrate_sdg_pioneer_business_attachments
    update migrate_sdg_pioneer_individual_attachments
    remove_column :sdg_pioneer_submissions, :tmp_old_id, :integer
  end

  def down
    # no-op
  end

  private

  def migrate_sdg_pioneer_businesses
    <<-SQL
      insert into sdg_pioneer_submissions (
        tmp_old_id,
        pioneer_type,
        global_goals_activity,
        matching_sdgs,
        name,
        title,
        email,
        phone,
        organization_name,
        organization_name_matched,
        country_name,
        reason_for_being,
        accepts_tou,
        website_url,
        is_participant,
        created_at,
        updated_at
      )
      select
        id,
        0,
        positive_outcomes,
        matching_sdgs,
        contact_person_name,
        contact_person_title,
        contact_person_email,
        contact_person_phone,
        organization_name,
        organization_name_matched,
        country_name,
        other_relevant_info,
        accepts_tou,
        website_url,
        is_participant,
        created_at,
        updated_at
      from
        sdg_pioneer_businesses
      ;
    SQL
  end

  def migrate_sdg_pioneer_individuals
    <<-SQL
      insert into sdg_pioneer_submissions (
        tmp_old_id,
        pioneer_type,
        global_goals_activity,
        matching_sdgs,
        name,
        title,
        email,
        phone,
        organization_name,
        organization_name_matched,
        country_name,
        reason_for_being,
        accepts_tou,
        website_url,
        is_participant,
        created_at,
        updated_at
      )
      select
        id,
        1,
        description_of_individual,
        matching_sdgs,
        name,
        title,
        email,
        phone,
        organization_name,
        organization_name_matched,
        country_name,
        description_of_individual,
        accepts_tou,
        website_url,
        is_participant,
        now(),
        now()
      from
        sdg_pioneer_individuals
      ;
    SQL
  end

  def migrate_sdg_pioneer_business_attachments
    <<-SQL
      update
        uploaded_files as file
      inner join
        sdg_pioneer_submissions as subs
      on
        file.attachable_id = subs.tmp_old_id
        and
        file.attachable_type = 'SdgPioneer::Business'
      set
        attachable_id = subs.id,
        attachable_type = 'SdgPioneer::Submission'
    SQL
  end

  def migrate_sdg_pioneer_individual_attachments
    <<-SQL
      update
        uploaded_files as file
      inner join
        sdg_pioneer_submissions as subs
      on
        file.attachable_id = subs.tmp_old_id
        and
        file.attachable_type = 'SdgPioneer::Individual'
      set
        attachable_id = subs.id,
        attachable_type = 'SdgPioneer::Submission'
    SQL
  end

end
