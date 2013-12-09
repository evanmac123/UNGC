module Cop
  class PresenterNotFoundError < StandardError; end

  class Presenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TagHelper

    attr_reader :cop, :current_contact

    delegate :id,
             :number_missing_items,
             :latest?,
             :include_continued_support_statement?,
             :references_human_rights?,
             :references_labour?,
             :references_environment?,
             :references_anti_corruption?,
             :include_measurement?,
             :evaluated_for_differentiation?,
             :additional_questions?,
             :created_at,
             :starts_on,
             :ends_on,
             :cop_files,
             :cop_links,
             :is_grace_letter?,
             :format,
             :organization_business_entity?,
             :differentiation_description,
             :differentiation,
             :is_advanced_programme?,
             :differentiation_level_public,
             :can_approve?,
             :can_reject?,
             to: :cop

    def initialize(cop, current_contact)
      @cop = cop
      @current_contact = current_contact
    end

    def return_path
      if current_contact.from_organization?
        dashboard_path(tab: :cops)
      else
        admin_organization_path(cop.organization, tab: :cops)
      end
    end

    def delete_path
      admin_organization_communication_on_progress_path(cop.organization, cop.id)
    end

    def triple_learner_for_one_year?
      cop.organization.triple_learner_for_one_year?
    end

    def double_learner?
      cop.organization.double_learner?
    end

    def title
      cop.organization.cop_name
    end

    def acronym
      cop.organization.cop_acronym
    end

    def differentiation_placement
      levels = { 'learner' => "Learner Platform &#x25BA;", 'active' => "GC Active &#x25BA;", 'advanced' => "GC Advanced" }
      html = levels.map do |key, value|
        content_tag :span, value.html_safe, :style => cop.differentiation_level_public == key ? '' : 'color: #aaa'
      end
      html.join(' ').html_safe
    end

    def admin_partial
      if cop.evaluated_for_differentiation?
        "/shared/cops/show_#{cop.differentiation}_style"
      else
        partial
      end
    end

    def show_partial
      if cop.evaluated_for_differentiation?
        "/shared/cops/show_differentiation_style_public"
      else
        partial
      end
    end

    def results_partial
      return unless cop.evaluated_for_differentiation?

      # Basic COP template has its own partial to display text responses
      if cop.is_basic?
        '/shared/cops/show_basic_style'
      else
        '/shared/cops/show_differentiation_style'
      end
    end

    private
      def partial
        if cop.is_grace_letter?
          '/shared/cops/show_grace_style'
        elsif cop.is_basic?
          '/shared/cops/show_basic_style'
        elsif cop.is_non_business_format?
          '/shared/cops/show_non_business_style'
        elsif cop.is_new_format?
          '/shared/cops/show_new_style'
        elsif cop.is_legacy_format?
          '/shared/cops/show_legacy_style'
        end
      end

  end
end
