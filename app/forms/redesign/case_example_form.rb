class Redesign::CaseExampleForm
  include ActiveModel::Model

  attr_accessor :company, :country_id, :sector_ids, :is_participant, :file

  validates :sector_ids, presence: true
  validate :sector_ids_cant_be_blank_and_must_exist
  validate :case_example_is_valid

  HUMANIZED_ATTRIBUTES = {
    :sector_ids => "Sectors",
    :is_participant => "Global Compact Participant"
  }

  def submit
    if valid?
      result = case_example.save && TaggingUpdater.new({sectors: sector_ids}, case_example).update
      send_email(case_example) if result
      result
    else
      false
    end
  end

  def sector_options
    Sector.where.not(parent_id: nil).map do |sector|
      OpenStruct.new({
        # ActionView::Helpers::FormOptionsHelper#collection_check_boxes evaluates
        # value_method (this method) against the values of @case_example.sector_ids
        # looking for equality. However through POST params transmission the
        # the values of @case_example.sector_ids have become strings so the sector
        # ID here must also be string for the user-selected checkboxes to be rechecked.
        id: sector.id.to_s,
        name: sector.name
      })
    end
  end

  def is_participant_options
    [
      OpenStruct.new({id: 'true', name: 'Yes'}),
      OpenStruct.new({id: 'false', name: 'No'})
    ]
  end

  def countries
    Country.all
  end

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  private
    def case_example
      @case_example ||= CaseExample.new({
        company: company,
        country_id: country_id,
        is_participant: is_participant,
        file: file
      })
    end

    def send_email(case_example)
      CaseExampleMailer.delay.case_example_received({
        company: case_example.company,
        country: case_example.country,
        sectors: case_example.sectors,
        is_participant: (case_example.is_participant ? 'Yes' : 'No'),
        link: case_example.file.url
      })
    end

    def sector_ids_cant_be_blank_and_must_exist
      if sector_ids
        sector_ids.reject! { |i| i.empty? }

        errors.add(:sector_ids, "can't be blank") if sector_ids.empty?

        sector_ids.each do |sector_id|
          errors.add(:sector_ids, "must exist") unless Sector.exists? sector_id
        end
      end
    end

    def case_example_is_valid
      if case_example.valid?
        true
      else
        case_example.errors.each do |attribute, message|
          self.errors.add attribute, message
        end
        false
      end
    end
end
