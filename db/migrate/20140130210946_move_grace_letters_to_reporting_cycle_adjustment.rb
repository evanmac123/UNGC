class MoveGraceLettersToReportingCycleAdjustment < ActiveRecord::Migration
  def up
    CommunicationOnProgress.transaction do
      connection.update(<<-SQL)
        UPDATE communication_on_progresses
        SET cop_type = 'reporting_cycle_adjustment', communication_on_progresses.format = 'reporting_cycle_adjustment'
        WHERE title = 'Reporting Cycle Adjustment' and communication_on_progresses.format = 'grace_letter'
      SQL
      connection.update(<<-SQL)
        UPDATE cop_files AS f
        INNER JOIN communication_on_progresses AS c
        ON f.cop_id = c.id
        SET f.attachment_type = 'reporting_cycle_adjustment'
        WHERE c.format = 'reporting_cycle_adjustment'
        AND f.attachment_type <> 'reporting_cycle_adjustment'
      SQL
    end
  end

  def down
    CommunicationOnProgress.transaction do
      connection.update(<<-SQL)
        UPDATE cop_files AS f
        INNER JOIN communication_on_progresses AS c
        ON f.cop_id = c.id
        SET f.attachment_type = 'grace_letter'
        WHERE c.format = 'reporting_cycle_adjustment'
        AND f.attachment_type = 'reporting_cycle_adjustment'
      SQL
      connection.update(<<-SQL)
        UPDATE communication_on_progresses
        SET cop_type = 'grace_letter', communication_on_progresses.format = 'grace_letter'
        WHERE communication_on_progresses.title = "Reporting Cycle Adjustment" and communication_on_progresses.format = 'reporting_cycle_adjustment'
      SQL
    end
  end
end
