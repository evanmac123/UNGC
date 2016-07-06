module TestPage
  class CopDetail < Base

    def initialize(cop)
      @cop = cop
    end

    def path
      admin_organization_communication_on_progress_path(@cop.organization.id, @cop)
    end

    def has_published_notice?
      has_content?('The communication has been published on the Global Compact website')
    end

  end
end
