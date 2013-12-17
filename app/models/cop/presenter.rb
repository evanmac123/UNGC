module Cop
  class PresenterNotFoundError < StandardError; end

  class Presenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TagHelper

    attr_reader :cop, :current_contact

    delegate :id,
             :differentiation_level_public,
             :created_at,
             :starts_on,
             :ends_on,
             :cop_files,
             :cop_links,
             :is_grace_letter?,
             :format,
             :evaluated_for_differentiation?,
             :organization_business_entity?,
             :include_continued_support_statement?,
             :references_human_rights?,
             :differentiation_description,
             :references_labour?,
             :differentiation,
             :references_environment?,
             :references_anti_corruption?,
             :include_measurement?,
             :is_advanced_programme?,
             :additional_questions?,
             to: :cop

    def self.create(cop, current_contact = nil)
        c = if cop.is_grace_letter?
          # '/shared/cops/show_grace_style'
          presenter_class("GraceStyle")
        elsif cop.is_basic?
          # '/shared/cops/show_basic_style'
          presenter_class("BasicStyle")
        elsif cop.is_non_business_format?
          # '/shared/cops/show_non_business_style'
          presenter_class("NonBusinessStyle")
        elsif cop.is_new_format?
          # '/shared/cops/show_new_style'
          presenter_class("NewStyle")
        elsif cop.is_legacy_format?
          # '/shared/cops/show_legacy_style'
          presenter_class("LegacyFormat")
        else
          raise PresenterNotFoundError.new(cop)
          # or self.new(cop, contact) ???
        end
        c.new(cop, current_contact)
    end

    def initialize(cop, current_contact)
      @cop = cop
      @current_contact = current_contact
    end

    def title
      cop.organization.cop_name
    end

    def acronym
      cop.organization.cop_acronym
    end

    def return_path
      if current_contact.from_organization?
        dashboard_path(tab: :cops)
      else
        admin_organization_path(cop.organization, tab: :cops)
      end
    end

    # seems like differentiation can be one of
    # ["learner", "active", "", "advanced", nil, "blueprint"]
    def admin_partial
      if cop.evaluated_for_differentiation?
        "/shared/cops/show_#{cop.differentiation}_style"
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

    def show_partial
      if cop.evaluated_for_differentiation?
        "/shared/cops/show_differentiation_style_public"
      else
        partial
      end
    end

    private
      def self.presenter_class(name)
        "Cop::#{name.camelize}Presenter".constantize
      end

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
        else
          raise PresenterNotFoundError
        end
      end

  end

  class AdminPresenter < Presenter
    def self.create(cop, contact)
      if cop.evaluated_for_differentiation?
        presenter_class("#{cop.differentiation}Style").new(cop, contact)
      else
        super(cop, contact)
      end
    end
  end

  class GraceStylePresenter < Presenter
  end

  class LegacyFormatPresenter < Presenter
  end

  class NewStylePresenter < Presenter
    delegate :is_test_phase_advanced_programme?,
             to: :cop
  end

  class DifferentiationStylePresenter < Presenter
  end

  class SelfAssessmentPresenter < Presenter
  end

  class QuestionnaireResultsPresenter < Presenter
    delegate :is_advanced_lead?,
             :cop_answers,
             :notable_program?,
             to: :cop
  end

  class QuestionnaireResultsAdvancedLeadPresenter < Presenter
    delegate :cop_attributes, to: :cop
  end

  class ActiveStylePresenter < AdminPresenter
    delegate :additional_questions,
             to: :cop
  end

  class AdvancedStylePresenter < AdminPresenter
    delegate :questions_missing_answers,
             :meets_advanced_criteria,
             :issue_areas_covered,
             :is_advanced_lead?,
             :cop_answers,
             :notable_program?,
             :cop_attributes,
             to: :cop
  end

  class LearnerStylePresenter < AdminPresenter
    delegate :id,
             :number_missing_items,
             :can_approve?,
             :can_reject?,
             :latest?,
             to: :cop

    def triple_learner_for_one_year?
      cop.organization.triple_learner_for_one_year?
    end

    def delete_path
      admin_organization_communication_on_progress_path(cop.organization, cop.id)
    end

    def double_learner?
      cop.organization.double_learner?
    end

    def differentiation_placement
      levels = { 'learner' => "Learner Platform &#x25BA;", 'active' => "GC Active &#x25BA;", 'advanced' => "GC Advanced" }
      html = levels.map do |key, value|
        content_tag :span, value.html_safe, :style => cop.differentiation_level_public == key ? '' : 'color: #aaa'
      end
      html.join(' ').html_safe
    end

  end
end
