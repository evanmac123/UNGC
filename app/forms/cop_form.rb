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
    cop = organization.communication_on_progresses.new
    cop_form_class = forms_for_type(type)
    cop_form_class.new(cop, type, contact_info)
  end

  def self.edit_form(cop, contact_info)
    type = determine_cop_type(cop)
    cop_form_class = forms_for_type(type)
    form = cop_form_class.new(cop, type, contact_info)
    form.submitted = true
    form.edit = true
    form
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
            :cop_files,
            :cop_questions,
            :cop_answers,
            :errors,
            :readable_error_messages,
            :new_record?,
            to: :cop

  def initialize(cop, type, contact_info)
    @cop = cop
    @cop.title ||= organization.cop_name
    @cop.cop_type = type
    @contact_info = contact_info
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
    cop.assign_attributes(params)
    cop.contact_info ||= contact_info
    remove_deleted_links(params)
    remember_link_params(params)
    @submitted = true
    clear_answer_text_from_unselected_answers
    valid? && cop.save
  end

  def update(params)
    submit(params) && cop.set_differentiation_level
  end

  def valid?
    cop.valid? && cop_file.valid?
  end

  def errors
    cop.cop_files.each do |file|
      next if file.valid?
      file.errors.full_messages.each do |message|
        cop.errors.add :cop_files, message
      end
    end
    cop.errors
  end

  def organization
    @cop.organization
  end

  def partial
    "#{cop.cop_type}_form"
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

  def has_links?
    cop.cop_links.any?
  end

  def links
    cop.cop_links
  end

  def languages
    Language.scoped
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
    if edit
      admin_organization_communication_on_progress_path(cop.organization.id, cop.id)
    else
      cop_introduction_path
    end
  end

  alias_method :submitted?, :submitted

  protected

    def remove_deleted_links(params)
      if params.has_key? :cop_links_attributes
        link_attrs = params[:cop_links_attributes]

        if link_attrs.is_a?(Array)
          ids = link_attrs.map {|a| a[:id]}

          links_to_destroy = if ids.count == 0
            links # all the links
          else
            links.where('id NOT IN (?)', ids)
          end

          links_to_destroy.destroy_all
        end
      else
        # no cop_links_attributes was sent, destroy them all
        links.destroy_all
      end
    end

    def remember_link_params(params)
      # remember the language and url the user selected in case of an new, but invalid submission
      link_attrs = params[:cop_links_attributes]
      if link_attrs.is_a?(Hash)
        new_cop = link_attrs[:new_cop]
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
