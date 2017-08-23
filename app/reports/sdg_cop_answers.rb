# -*- coding: utf-8 -*-
class SdgCopAnswers < SimpleReport

  COLUMN_INDEXES = {
    6511 =>  9, #opportunity,
    6521 => 10, #priorities,
    6531 => 11, #indicators,
    6541 => 12, #business_model,
    6551 => 13, #activity,
    6561 => 14, #collaboration,
    6571 => 15, #other,
    6341 => 16, #sdg1,
    6351 => 17, #sdg2,
    6361 => 18, #sdg3,
    6371 => 19, #sdg4,
    6381 => 20, #sdg5,
    6391 => 21, #sdg6,
    6401 => 22, #sdg7,
    6411 => 23, #sdg8,
    6421 => 24, #sdg9,
    6431 => 25, #sdg10,
    6441 => 26, #sdg11,
    6451 => 27, #sdg12,
    6461 => 28, #sdg13,
    6471 => 29, #sdg14,
    6481 => 30, #sdg15,
    6491 => 31, #sdg16,
    6501 => 32, #sdg17,
  }

  def records
    CopAnswer.joins(communication_on_progress: [:organization], cop_attribute: [:cop_question]).
      includes(communication_on_progress: [{ organization: [:sector, :country, :organization_type] }],
        cop_attribute: [:cop_question ]).
      where("grouping = 'sdgs'").
      order(:cop_id).
      group_by do |answer|
        answer.communication_on_progress
      end
  end

  def render_output
    self.render_xls
  end

  def headers
    [
      "Organization ID",
      "Organization Name",
      "COP ID",
      "COP Type",
      "COP Published On",
      "Organization Type",
      "Country",
      "Sector",
      "Employees",
      "Opportunities and responsibilities that one or more SDGs represent to our business",
      "Where the company’s priorities lie with respect to one or more SDGs",
      "Goals and indicators set by our company with respect to one or more",
      "How one or more SDGs are integrated into the company’s business model",
      "The (expected) outcomes and impact of your company’s activities related to the SDGs",
      "If the companies activities related to the SDGs are undertaken in collaboration with other stakeholder",
      "Other established or emerging best practices",
      "SDG 1",
      "SDG 2",
      "SDG 3",
      "SDG 4",
      "SDG 5",
      "SDG 6",
      "SDG 7",
      "SDG 8",
      "SDG 9",
      "SDG 10",
      "SDG 11",
      "SDG 12",
      "SDG 13",
      "SDG 14",
      "SDG 15",
      "SDG 16",
      "SDG 17",
    ]
  end

  def row(cop_with_answers)
    cop, answers = cop_with_answers

    # create a row with the COP info
    excel_row = [
      cop.organization.id,
      cop.organization.name,
      cop.id,
      rename_cop_type(cop),
      cop.published_on,
      cop.organization.organization_type_name,
      cop.organization.country_name,
      cop.organization.sector_name,
      cop.organization.employees,
    ]

    # loop through the answers one at a time
    # adding the value of the answer to the corresponding position (index)
    # in the excel row
    answers.each do |answer|
      # find the column index based on the cop_attribute_id
      column_index = COLUMN_INDEXES.fetch(answer.cop_attribute_id)

      # put the value of the answer in that column for this row
      excel_row[column_index] = answer.value ? 1 : 0
    end

    # return the row
    excel_row
  end

  private

  def rename_cop_type(cop)
    if cop.cop_type == "intermediate"
      "active"
    else
      cop.cop_type
    end
  end

end
