module TestPage
  class CopDetail < Base

    def has_published_notice?
      has_content?('The communication has been published on the Global Compact website')
    end

  end
end
