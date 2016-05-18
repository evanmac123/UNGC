class CopForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include Rails.application.routes.url_helpers

  METHODS = {
    :gc_website   => "a) Through the UN Global Compact website only",
    :all_access   => "b) COP is easily accessible to all interested parties (e.g. via its website)",
    :stakeholders => "c) COP is actively distributed to all key stakeholders (e.g. investors, employees, consumers, local community)",
    :all          => "d) Both b) and c)"
  }.freeze

  def self.new_form(organization, type, contact_info)
    raise "cop type is nil, must specify a copy type." unless type
    cop = organization.communication_on_progresses.draft.new
    cop_form_class = forms_for_type(type)
    if cop_form_class.present?
      cop_form_class.new(cop, type, contact_info)
    end
  end

  def self.edit_form(cop, contact_info)
    type = determine_cop_type(cop)
    cop_form_class = forms_for_type(type)
    if cop_form_class.present?
      form = cop_form_class.new(cop, type, contact_info)
      form.submitted = true
      form.edit = true
      form
    end
  end

  # Maybe we should add this logic into a migration
  # and write the cop_type information for existing cops
  def self.determine_cop_type(cop)
    if cop.cop_type
      cop.cop_type
    elsif cop.additional_questions
      :advanced
    elsif cop.cop_files.any?
      :intermediate
    else
      :basic
    end
  end

  def self.forms_for_type(type)
    @forms ||= {
      basic: BasicCopForm,
      intermediate: CopForm,
      advanced: CopForm,
      lead: CopForm,
      non_business: NonBusinessCopForm,
    }.freeze

    @forms[type.to_sym]
  end

  attr_reader :cop
  attr_accessor :submitted, :edit

  delegate  :id,
            :title,
            :starts_on,
            :ends_on,
            :cop_questions_for_grouping,
            :include_continued_support_statement,
            :references_human_rights,
            :references_labour,
            :references_environment,
            :references_anti_corruption,
            :references_business_peace,
            :references_business_peace?,
            :references_water_mandate,
            :references_water_mandate?,
            :references_human_rights?, # required by _form
            :additional_questions, # required by _form
            :additional_questions?, # required by _form
            :notable_program?, # required by _form
            :references_labour?, # required by _form
            :references_environment?, # required by _form
            :references_anti_corruption?, # required by _form
            :is_grace_letter?, # required by _form
            :include_measurement,
            :method_shared,
            :cop_type,
            :format,
            :cop_links,
            :cop_links_attributes,
            :cop_links_attributes=,
            :cop_files,
            :cop_questions,
            :cop_answers,
            :readable_error_messages,
            :new_record?,
            to: :cop

  def initialize(cop, type, contact_info)
    @cop = cop
    @cop.title ||= organization.cop_name
    @cop.cop_type = type
    @contact_info = contact_info
    @submitted = false
    @errors = ActiveModel::Errors.new(self)
  end

  def build_cop_answers
    # build answers for questions related to this cop
    # these will be used by the form templates to collect the answers.

    cop.cop_questions.map do |question|
      question.cop_attributes.map do |cop_attribute|
        cop.cop_answers.build \
          :cop_attribute_id => cop_attribute.id,
          :value            => false,
          :text             => nil
      end
    end
  end

  def submit(params)
    cop.submission_status = :submitted
    do_save(params).tap do |saved|
      cop.publish if saved
    end
  end

  def update(params)
    do_save(params)
  end

  def save_draft(params)
    do_save(params, validate: false)
  end

  def valid?
    cop.valid? && cop_file.valid?
  end

  def organization
    @cop.organization
  end

  def partial
    "#{cop.cop_type}_form"
  end

  def clear_answer_text_from_unselected_answers
    # Prevent answers with no user input from ending up in
    # the database when the checkbox is unselected
    cop.cop_answers.each do |answer|
      answer.text = "" if (answer.value == false && answer.text.present?) || answer.text.blank?
    end
  end

  def new_link
    CopLink.new({
      attachment_type: CopFile::TYPES[:cop],
      language_id: link_language,
      url: link_url,
    })
  end

  def new_file
    file = CopFile.cop
    file.cop_id = cop.id
    file
  end

  def cop_file
    @cop_file ||= first_or_new_file
  end

  def errors
    @errors.clear
    cop.errors.each do |attribute, error|
      @errors.add(attribute, error)
    end
    cop_files.each do |file|
      file.errors.each do |attribute, error|
        @errors.add(attribute, error)
      end
    end
    cop.cop_links.each do |link|
      link.errors.each do |attribute, error|
        @errors.add(attribute, error)
      end
    end
    @errors
  end

  def self.human_attribute_name(attribute, options)
    options[:default]
  end

  def link_language
    @link_language || default_language_id
  end

  def link_url
    @link_url || ''
  end

  def has_links?
    cop.cop_links.any?
  end

  def links
    cop.cop_links
  end

  def languages
    Language.all
  end

  def contact_info
    cop.contact_info || @contact_info
  end

  def formats
    CommunicationOnProgress::FORMAT
  end

  def methods
    METHODS
  end

  def persisted?
    false
  end

  def return_url
    if edit # ungc staff editing a completed COP
      admin_organization_communication_on_progress_path(cop.organization.id, cop.id)
    else
      cop_introduction_path
    end
  end

  alias_method :submitted?, :submitted

  protected

    def remove_empty_links_from(params)
      attrs = params.fetch('cop_links_attributes', {})
      return if attrs.empty?

      key = if attrs.is_a?(Array)
        attrs.count - 1
      elsif attrs.is_a?(Hash)
        attrs.keys.last
      else
        raise "Expected Hash or Array, got: #{attrs.class}"
      end

      link = attrs[key]

      if link.present?
        id = link['id']
        url = link['url']
        language = link['language_id']

        if id.blank? && url.blank? && language.to_s == default_language_id.to_s
          if attrs.is_a?(Array)
            attrs.delete_at(key)
          elsif attrs.is_a?(Hash)
            attrs.delete(key)
          end
        end
      end
    end

    def handle_incoming_cop_answers(params)
      clear_answer_text_from_unselected_answers

      answers = params.delete(:cop_answers_attributes)
      if answers.nil?
        return
      end

      answers.each do |index, answer_or_nil|
        # if answers is an array, the answer is the 1st argument
        # if it's a hash, the answer is the 2nd argument
        answer = answer_or_nil || index

        # I'm not 100% clear on why these params aren't already permitted.
        answer_attrs = answer.reverse_merge(text: '', value: nil)
        if answer_attrs.respond_to?(:permit)
          answer_attrs = answer_attrs.permit(:id, :cop_id, :text, :value, :cop_attribute_id)
        end

        # determine whether to create or update the answer
        if answer_attrs.has_key?(:id)
          id = answer_attrs.fetch(:id).to_i
          record = cop.cop_answers.detect do |a|
            a.id == id
          end
          record.update(answer_attrs) if record.present?
        else
          cop.cop_answers.build(answer_attrs)
        end
      end
    end

    def default_language_id
      Language.for(:english).try(:id)
    end

    def first_or_new_file
      if cop.cop_files.length < 1
        cop.cop_files.new(new_file.attributes)
      end

      cop.cop_files.first
    end

    def do_save(params, validate: true)
      remove_empty_links_from(params)
      handle_incoming_cop_answers(params)
      cop.assign_attributes(params)
      cop.contact_info ||= contact_info

      CommunicationOnProgress.transaction do
        @submitted = true

        is_valid = if validate then valid? else true end
        is_valid && cop.save(validate: validate) && cop.set_differentiation_level
      end
    end

end
