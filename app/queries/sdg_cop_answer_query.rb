class SdgCopAnswerQuery
  def run
    CopAnswer.joins(communication_on_progress: [organization: [:country]],
                    cop_attribute: [:cop_question]).
    includes(communication_on_progress: [{ organization: [:sector, :country, :organization_type] }],
             cop_attribute: [:cop_question ]).
    where("value = 1 or cop_answers.text <> ''").
    where("grouping = 'sdgs'").
    order(:cop_id, "cop_questions.id")
  end

  def by_country(country_id)
    run.where(country_id: country_id)
  end
end
