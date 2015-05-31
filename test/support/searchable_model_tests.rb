module SearchableModelTests
  extend ActiveSupport::Concern

  included do

    should "index a record" do
      subject
      assert_difference -> { Redesign::Searchable.count }, +1 do
        Redesign::Searchable.index_all
      end
    end

  end

end
