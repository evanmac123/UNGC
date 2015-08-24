module SearchableModelTests
  extend ActiveSupport::Concern

  included do

    should "index a record" do
      subject
      assert_difference -> { Searchable.count }, +1 do
        Searchable.index_all
      end
    end

  end

end
