class CopForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  METHODS = {
    :gc_website   => "a) Through the UN Global Compact website only",
    :all_access   => "b) COP is easily accessible to all interested parties (e.g. via its website)",
    :stakeholders => "c) COP is actively distributed to all key stakeholders (e.g. investors, employees, consumers, local community)",
    :all          => "d) Both b) and c)"
  }.freeze

  def self.new_form(organization, type, contact_name)
    raise "cop type is nil, must specify a copy type." unless type
    cop = organization.communication_on_progresses.new
    cop_form_class = forms_for_type(type)
    cop_form_class.new(cop, type, contact_name)
  end

  def self.edit_form(cop, contact_name)
    type = determine_cop_type(cop)
    cop_form_class = forms_for_type(type)
    form = cop_form_class.new(cop, type, contact_name)
    form.submitted = true
    form
  end

  def self.determine_cop_type(cop)
    cop.cop_type || :advanced
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
  attr_accessor :submitted

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
            :type,
            :format,
            :cop_files,
            :cop_questions,
            :cop_answers,
            :errors,
            :readable_error_messages,
            to: :cop

  def initialize(cop, type, contact_name)
    @cop = cop
    @cop.title = organization.cop_name
    @cop.type = type
    @contact_name = contact_name
    @submitted = false
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
    cop.attributes = params
    cop.contact_name = contact_name
    remember_link_params(params)
    @submitted = true
    clear_answer_text_from_unselected_answers
    valid? && cop.save
  end
  alias_method :update, :submit

  def valid?
    cop.valid? && cop_file.valid?
  end

  def errors
    cop.cop_files.each do |file|
      next if file.valid?
      file.errors.full_messages.each do |message|
        cop.errors.add_to_base message
      end
    end
    cop.errors
  end

  def organization
    @cop.organization
  end

  def partial
    "#{type}_form"
  end

  def clear_answer_text_from_unselected_answers
    # my guess is that this is here to stop answers with user input
    # from ending up int the database when the user unchecks the checkbox
    cop.cop_answers.each do |answer|
      answer.text = "" if answer.value == false && answer.text.present?
    end
  end

  def new_link
    CopLink.new({
      attachment_type: CopFile::TYPES[:cop],
      language_id: link_language,
      url: link_url,
    })
  end

  def cop_file
    @cop_file ||= cop.cop_files.first || CopFile.cop
  end

  def link_language
    @link_language || default_language_id
  end

  def link_url
    @link_url || ''
  end

  def contact_name
    cop.contact_name || @contact_name
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

  alias_method :submitted?, :submitted

  protected

    def remember_link_params(params)
      # remember the language and url the user selected in case of an new, but invalid submission
      if params.has_key?(:cop_links_attributes)
        new_cop = params[:cop_links_attributes][:new_cop]
        if new_cop
          @link_language = new_cop[:language_id]
          @link_url = new_cop[:url]
        end
      end
    end

    def default_language_id
      Language.for(:english).try(:id)
    end

end